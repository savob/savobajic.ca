% Team 15 obstacle avoidance w/ compass

% Copyright (c) 2020, Ian G. Bennett
% All rights reserved.
% Development funded by the University of Toronto, Department of Mechanical
% and Industrial Engineering.
% Distributed under GNU AGPLv3 license.

clear
close all
clc


sim = 1; %Feeding into simulator or straight into robot? 1 for simulator, 0 otherwise

if sim
    % Initialize tcp server to read and respond to algorithm commands
    [s_cmd, s_rply] = tcp_setup();
    fopen(s_cmd);
    %fopen(s_rply);
else
    %connect to rover Bluetooth
end

%% Way points and navigation config
% Grid is defined with the top left being [1 1], with the first value being
% the row, the second being the column. E.g. the no wall square is [2 6].

% ===================================

endPoint = [3 3]; % Drop point

% ===================================

fprintf("\n\nEnd point set to [%.0f %.0f] by line 31.\n\n", endPoint(1), endPoint(2));
pause(1);

pathMask =  [1 1 1 1 0 1 0 1; 1 1 0 1 1 1 1 1; 1 0 1 0 0 1 0 1; 1 1 1 1 1 1 0 1];

% Set up map LUTs
mazeClearanceMap = setUpClearanceMap(pathMask);
mazeWallMap = setUpWallMap(pathMask);

clearConfid = ones(4, 8);
wallConfid = ones(4, 8);
headingEstimate = zeros(4, 8);
resultingPMap = ones(4, 8);

% Probabilities assigned to either a hit or miss
pMatch = 0.8;
pMiss = 0.2;

% Weighting for the three methods
wallWeight = 1;
clearWeight = 0.5;
prevWeight = 1;

% ===========================================
% IMPORTANT THRESHOLD TO CALL LOCALIZED!!
localizedThreshold = 2;
% Factor of how much the main result should exceed the second place one to be called localized
% ===========================================

currentRotation = 0; % Stores the last rotation applied to the heading going CCW
localizedState = 0; % 0 if not localized/lookin

%% Initial alignment loop
% The rover starts in the middle of a block, this means it can safely
% rotate on the spot for a bit without bumping into things. The worst case
% for starting is at 45 deg. So no more than 45 deg of rotation should be
% needed before locking into alignment with the maze grid.

if ~(sim == 1)
    % Inform user
    fprintf("\n\n\nSIMULATOR MODE. GRIPPER WILL NOT BE ACTIVE!\nSet sim = 0 at line 14 to enable them.\n\n\n");
    pause(1); % So it can be seen
end

alignSteps = 5; %Increments taken to align bot to wall
angleTol = 15; % Degrees misalignment with wall that is tolerated, +/-

% Loop until a suitable angle is found (0 (error) < |angle| < tolerance)
% Should not take more than 45ish degrees of rotation (depends on level of
% error). Goes in steps predefined
for i = 0:alignSteps:90
    % Try to align to the wall
    [angle, ~] = alignToWall(s_cmd, s_rply);

    if angle == 0
        sendCommand(strcat('r1-', num2str(alignSteps)), s_cmd, s_rply); % Rotate and re-test until aligned
    elseif abs(angle) < angleTol
        break; % Exit early if we're within tolerances
    end
end

alignToWall(s_cmd, s_rply);

%% Navigation loop - hug the right wall
% The plan for this is to simply go forward maintaing a set distance from
% the right wall (also used to maintain alignment with the maze) until a
% wall is encountered, then the robot will simply rotate until it can move
% forward. If the right side detects an opening, it will turn into it.

% Note: since we can't really monitor anything other than 90 degree
% orientations, all turns will be done at 90 degrees and we will hope for
% the best. Hopefully no colissions ocurr before the rover can readjust
% itself in this new direction.

bumpTol = 1;                    % How close we will tolerate going to an obstacle
robotRadius = 4;                % Radius of robot footprint

maximumStepSize = 7;            % Max step size allowed
defaultStepSize = 4;            % Default step size
stepSize = defaultStepSize;     % Inches moved per step forward

laneWidth = 1; % Width of the virtual lane in the center of nodes we want to ride

step = 1; % Used to keep track of loop iteration

while 1 % 20 feet let's go
    
    clearances = findClearances(s_cmd, s_rply);
    headingEstimate = checkComp(s_cmd, s_rply, 1);
    
    % Move previous estimate
    movedConfid = applyMotion(resultingPMap, headingEstimate);
    
    [clearConfid, clearHeadEst] = guessLocationClearances(mazeClearanceMap , clearances);
    [wallConfid, wallHeadEst] = guessLocationWalls(mazeWallMap, clearances);
    
    % Combine headings into one ezstimate, prioritize the ones found using
    % the clearance location guesser over wall ones as they are generally
    % more accurate
%     headingEstimate = wallHeadEst .* (clearHeadEst == 0);
%     headingEstimate = headingEstimate + clearHeadEst;
%     headingEstimate = headingEstimate .* pathMask;
    
    clearConfid = applyP(clearConfid, pMiss, pMatch, pathMask) .^ clearWeight;
    wallConfid = applyP(wallConfid, pMiss, pMatch, pathMask) .^ wallWeight;
    movedConfid = applyP(movedConfid, pMiss, pMatch, pathMask) .^ prevWeight;
    
    % Combine and weigh confidences
    resultingPMap = movedConfid .* clearConfid .* wallConfid;
    resultingPMap = resultingPMap .* pathMask; % Remove obstacle blocks
    resultingPMap = resultingPMap / sum(resultingPMap, 'all'); % Normalize probabilities
    
    if localizedState == 0, statusString = "Localizing prior to LZ";
    elseif localizedState == 1, statusString = "On way to LZ";
    elseif localizedState == 2, statusString = "Relocalizing before going to drop";
    elseif localizedState == 3, statusString = "On way to drop";
    elseif localizedState == 4, statusString = "Looking for block";
    end

    sgtitle(strcat("Robot Status: ", statusString),'FontSize', 16);
    
    subplot(2,3,1);
    imagesc(movedConfid);
    title("Prev. Confidence");
    subplot(2,3,2);
    imagesc(wallConfid);
    title("Wall Confidence");
    subplot(2,3,3);
    imagesc(clearConfid);
    title("Clear. Confidence");
    
    subplot(2,3,[4 5 6]);
    imagesc(resultingPMap);
    title(strcat("Starting Location Step: ", num2str(step)));
    pause(0.25);
    
    %Print location
    [maxConfidence, maxIndex] = max(resultingPMap,[], 'all', 'linear');
    [maxRow, maxCol] = ind2sub(size(resultingPMap), maxIndex);
    
    orderOfConfidence = sort(resultingPMap(:), 'descend');
    fprintf("\nMax confidence of %.2f (Ratio of %.2f) that rover started at:\n\tRow: %.0f\tCol: %0.f\n\n", ...
        maxConfidence, maxConfidence / orderOfConfidence(2), maxRow, maxCol);
    
    % Check if we are looking to localize
    if maxConfidence > (localizedThreshold * orderOfConfidence(2))
        
        % Check what stage robot is in
        if or(localizedState == 0, localizedState == 2)
            fprintf("LOCALIZED! Confidence ratio of %.2f between top two.\n", ...
                (maxConfidence / orderOfConfidence(2)));
            
            
            % Get best path to current destination
            if localizedState == 0
                if and(maxCol < 3, maxRow <3)
                    fprintf("IN LZ! Congrats rover, look for block\n");
                    [~, pathListCurrent] = findPath([maxRow, maxCol], endPoint, pathMask);
                    localizedState = 4; % Advance to scouting for return
                else
                    % LZ is current target
                    fprintf("\tLooking for shortest route to LZ.\n");
                    [pathCostA, pathListA] = findPath([maxRow, maxCol], [2 1], pathMask);
                    
                    [pathCostB, pathListB] = findPath([maxRow, maxCol], [1 2], pathMask);
                    
                    if pathCostA < pathCostB
                        pathListCurrent = pathListA;
                    else
                        pathListCurrent = pathListB;
                    end
                    listOfTurns = turnList(pathListCurrent, headingEstimate);
                    localizedState = localizedState + 1;
                end
            elseif localizedState == 2
                if isequal(endPoint, [maxRow, maxCol])
                    pathListCurrent = endPoint;
                else
                    % End point, no need to record score
                    fprintf("\tLooking for shortest route to end point.\n");
                    [~, pathListCurrent] = findPath([maxRow, maxCol], endPoint, pathMask);
                end
                listOfTurns = turnList(pathListCurrent, headingEstimate);
                localizedState = localizedState + 1;
            end
            
        else
            % General notice
            fprintf("LOCALIZED! Confidence ratio of %.2f between top two.\n\n", (maxConfidence / orderOfConfidence(2)));
        end
    end
    
    % Check if it is time to rotate
    currentRotation = 0;
    if or(localizedState == 0, localizedState == 2)
        % Bumble about until localized, going forward
        
        if (clearances(1) + robotRadius) < 7
            % Close enough to a wall in front to start turning
            % Find direction that is open, avoiding going backwards
            openThreshold = 8;
            if clearances(2) > openThreshold
                fprintf("Wall detected in front, turning left.\n");
                sendCommand('r1-90', s_cmd, s_rply);
                currentRotation = 1;
            else
                if clearances(4) > openThreshold
                    fprintf("Wall detected in front and left, turning right.\n");
                    sendCommand('r1--90', s_cmd, s_rply);
                    currentRotation = 3;
                else
                    % Turn around backwards, in two steps
                    fprintf("WE'RE SURROUNDED! RETREAT!\n\t(Walls in front and on the sides, turning around).\n");
                    sendCommand('r1-180', s_cmd, s_rply);
                    currentRotation = 2;
                end
            end
        end
        
    elseif localizedState == 1
        % Expecting to be be on path to LZ, double check
        
        
        if or(isequal(pathListCurrent, [1 2]), isequal(pathListCurrent, [2 1]))
            if and(maxCol < 3, maxRow <3)
                fprintf("\n\n\n\n\n\n\nIN LZ! Congrats rover, look for block.\n\n\n\n\n\n");
                pause(2);
                localizedState = 4; % Advance to scouting for return
            else
                fprintf("Should be in LZ, but not confident. Relocalizing.\n");
                localizedState = localizedState - 1; % Relocalize
            end
            
            
        else
            if ~isequal([maxRow, maxCol], pathListCurrent(1, :))
                localizedState = localizedState - 1; % Push it back to searching
                
                % If we don't match it's possible we may have skipped some
                % going forwards. So we need to see if the current location is
                % on the list before a turn is needed. Start at 2 since we know
                % 1 wasn't a match
                
                for i = 2 : size(pathListCurrent, 1)
                    if ~(listOfTurns(i - 1) == 0)
                        % We're expecting a turn, break and relocalize since the
                        % rover will not turn without instruction
                        break;
                    end
                    
                    if isequal([maxRow, maxCol], pathListCurrent(i, :))
                        
                        fprintf("Skipped %.0f forward steps. Readjusting path to starting at:\n\tRow %.0f\tCol: %.0f\n",...
                            (i - 1), pathListCurrent(i, 1), pathListCurrent(i, 2));
                        
                        % Remove points in list
                        pathListCurrent(1:(i-1), :) = [];
                        listOfTurns(1:(i-1)) = [];
                        localizedState = localizedState + 1; % Relocatized
                        break;
                    end
                end
                
                
            end
            
            % Check we're still localized
            if localizedState == 1
                % At expected location, turn according to plan
                fprintf("At expected location - Row: %.0f Col: %.0f. Turning %.0f.\n",...
                    maxRow, maxCol, listOfTurns(1));
                if listOfTurns(1) == 2
                    sendCommand('r1-180', s_cmd, s_rply);
                elseif listOfTurns(1) == 1
                    sendCommand('r1-90', s_cmd, s_rply);
                elseif listOfTurns(1) == -1
                    sendCommand('r1--90', s_cmd, s_rply);
                end
                currentRotation = mod(listOfTurns(1), 4);
                % Advance lists
                pathListCurrent(1, :) = [];
                listOfTurns(1) = [];
            else
                fprintf("OFF PATH! Relocalizing and navigating.\n");
            end
        end
    elseif localizedState == 3
        % Expecting to be be on path to end point, double check
        if isequal(pathListCurrent, endPoint)
                        
            if isequal([maxRow, maxCol], endPoint)
                fprintf("\n\n\nIN END ZONE! Congrats rover, drop the block.\n");
                localizedState = localizedState + 1; % Advance to scouting for return
                
                break; % Exit this wile loop
            else
                fprintf("Should be in endpoint, but not confident. Relocalizing.\n");
                localizedState = localizedState - 1; % Relocalize
            end
            
            
        else
            if ~isequal([maxRow, maxCol], pathListCurrent(1, :))
                localizedState = localizedState - 1; % Push it back to searching
                
                % If we don't match it's possible we may have skipped some
                % going forwards. So we need to see if the current location is
                % on the list before a turn is needed. Start at 2 since we know
                % 1 wasn't a match
                
                for i = 2 : size(pathListCurrent, 1)
                    if ~(listOfTurns(i - 1) == 0)
                        % We're expecting a turn, break and relocalize since the
                        % rover will not turn without instruction
                        break;
                    end
                    
                    if isequal([maxRow, maxCol], pathListCurrent(i, :))
                        
                        fprintf("Skipped %.0f forward steps. Readjusting path to starting at:\n\tRow %.0f\tCol: %.0f\n",...
                            (i - 1), pathListCurrent(i, 1), pathListCurrent(i, 2));
                        
                        % Remove points in list
                        pathListCurrent(1:(i-1), :) = [];
                        listOfTurns(1:(i-1)) = [];
                        localizedState = localizedState + 1; % Relocalized
                        break;
                    end
                end
                
                
            end
            
            % Check we're still localized
            if localizedState == 3
                % At expected location, turn according to plan
                fprintf("At expected location - Row: %.0f Col: %.0f. Turning %.0f.\n",...
                    maxRow, maxCol, listOfTurns(1));
                if listOfTurns(1) == 2
                    sendCommand('r1-180', s_cmd, s_rply);
                elseif listOfTurns(1) == 1
                    sendCommand('r1-90', s_cmd, s_rply);
                elseif listOfTurns(1) == -1
                    sendCommand('r1--90', s_cmd, s_rply);
                end
                currentRotation = mod(listOfTurns(1), 4);
                % Advance lists
                pathListCurrent(1, :) = [];
                listOfTurns(1) = [];
            else
                fprintf("OFF PATH! Relocalizing and navigating.\n");
            end
        end
        
        
    end
    
    if localizedState == 4
        fprintf("\n\nLOOKING FOR BLOCK NOW\n\n");
        
        % Looking for block
        blockUSInset = 4;               % How inset US6 is compared to US1
        blockAppraochDist = 7;          % How close to be before grabbing block (clearance for grabber)
        rotUndertaken = 0;              % Track rotations done to try and undo them once done
        startPoint = [maxRow, maxCol];  % Record estimated starting point
        rotateIncrement = 10;           % Used to determine rotation steps to find the block
        rampFromUS = 3;                 % Distance from US6 to ramp lip
        
        sgtitle("Robot Status: Looking for block",'FontSize', 16);
                
        % Set up rover to look into the corner [1 1] of the LZ
        if isequal(startPoint, [1, 2])
            % If starting in top right of LZ
            snapToHeading(2, s_cmd, s_rply);
            rotUndertaken = trackRotation(-20, rotUndertaken, s_cmd, s_rply);
            rotateIncrement = 10;
        elseif isequal(startPoint, [2 1])
            snapToHeading(1, s_cmd, s_rply);
            rotUndertaken = trackRotation(20, rotUndertaken, s_cmd, s_rply);
            rotateIncrement = -10;
        elseif isequal(startPoint, [1 1])
            snapToHeading(3, s_cmd, s_rply);
            rotUndertaken = trackRotation(-20, rotUndertaken, s_cmd, s_rply);
            rotateIncrement = 10;
        end
        
        % Scan across field for block
        fprintf("Scanning for block\n\n");
        for i = 1:16
            if blockPresent(s_cmd, s_rply) > 0
                break;
            else
                rotUndertaken = trackRotation(rotateIncrement, rotUndertaken, s_cmd, s_rply);
            end
        end
        
        fprintf("\nTrying to center on block\n\n");
        % Hit the block, scan for other side to center
        rotUndertaken = recenterOnBlock(rotateIncrement/2, rotUndertaken, s_cmd, s_rply);
        
        % Approach block if needed
        distToBlock = blockPresent(s_cmd, s_rply);
        
        if distToBlock < blockAppraochDist
            fprintf("Distance to block: %.1f\n", distToBlock);
        else
            fprintf("Distance to block: %.1f, advancing %.1f\n", distToBlock, distToBlock - blockAppraochDist);
            sendCommand(strcat('d1-', num2str(distToBlock - blockAppraochDist)), s_cmd, s_rply);
        end
        
        
        % Recenter on block, first by going to one side
        fprintf("\n\nFinal aligning to block\n\n");
        
        for i = 1:5
            if blockPresent(s_cmd, s_rply) == 0
                rotUndertaken = trackRotation(rotateIncrement, rotUndertaken, s_cmd, s_rply); % Pull back into contact
                break;
            else
                rotUndertaken = trackRotation(-rotateIncrement, rotUndertaken, s_cmd, s_rply);
            end
        end
        
        % Hit the block on one extreme, scan for other side
        rotUndertaken = recenterOnBlock(rotateIncrement, rotUndertaken, s_cmd, s_rply);
        
        % Approach block
        distToBlock = blockPresent(s_cmd, s_rply);
        distToBlock = distToBlock - rampFromUS;                             % Remove ramp offset
        
        if ~(sim == 1)
            sendCommand('g1-180', s_cmd, s_rply); % Bring gripper out
        end
        
        fprintf("Grabber up, final approach: %.1f\n", distToBlock);
        sendCommand(strcat('d1-',num2str(distToBlock,2)), s_cmd, s_rply);
        
        if ~(sim == 1)
            sendCommand('g1-40', s_cmd, s_rply); % Bring gripper down on block
        end
        fprintf("Block should be grabbed\n");
        % Rotate roughly back to aligning with the grid
        rotUndertaken = trackRotation(-rotUndertaken, rotUndertaken, s_cmd, s_rply);
        fprintf("Realigning to grid and relocalizing\n\n");
        
        localizedState = 2; % Switch to relocalize and look for drop zone
        
        % Set localization to expect rover in LZ
        resultingPMap = zeros(4,8);
        resultingPMap(1, 1) = 1;
        resultingPMap(2, 1) = 1;
        resultingPMap(1, 2) = 1;
        resultingPMap(2, 2) = 1;
        resultingPMap = applyP(resultingPMap, pMiss, pMatch, pathMask);
    end
    
    
    % Rotate clearances as needed
    if ~(currentRotation == 0)
        clearances = circshift(clearances, -currentRotation); % Rotate clearances with the rotation prior to moving
        
        fprintf("Rotated clearances are:\n\tF: %5.1f\tB: %5.1f\n\tL: %5.1f\tR: %5.1f\n", ...
            clearances(1), clearances(3), clearances(2), clearances(4));
    end
    
    % Go forwards
    advanceForward(s_cmd, s_rply, clearances, bumpTol, ...
        defaultStepSize, maximumStepSize, laneWidth, robotRadius);
    
    fprintf("\n================ END OF STEP %.0f ================\n\n", step);
    step = step + 1;
end

%% Run end code

sgtitle("Robot Status: Run Complete",'FontSize', 16); 

% Check for clearance to open grabber, pull back as needed
gripperClearance = 4; % Space needed to safely open gripper

clearances = findClearances(s_cmd, s_rply);
if clearances(1) < gripperClearance
    sendCommand(strcat('a1-',num2str(gripperClearance - clearances(1), 1)), s_cmd, s_rply);
end

if ~(sim == 1)
    sendCommand('g1-180', s_cmd, s_rply); % Bring gripper out
end

alignToWall(s_cmd, s_rply);
sendCommand('a1-2', s_cmd, s_rply); % Pull back to release the cube

fprintf("\n\n\n\nBlock should be released in drop zone now.\n\nAdios!\n");

%% Block grabbing code

function track = trackRotation(rotation, currentCount, s_cmd, s_rply)
% Rotates the robot and helps keep track of the overall angle taken
track = currentCount + rotation;
track = rem(track, 360);

sendCommand(strcat('r1-', num2str(rotation)), s_cmd, s_rply);
end

function blockThere = blockPresent(s_cmd, s_rply)
blockThere = 0; % Default
USreadings = checkUS([1 6], s_cmd, s_rply); % Get readings for both front facing US sensors

if USreadings(6) < USreadings(1)
    % Block is presdent
    blockThere = USreadings(6);
elseif and(USreadings(1) == 0, USreadings(6) > 0)
    % Main front US isn't getting a reading, likely due to robot being at 
    % shallow angle to walls. See if US6 is still getting something due to
    % catching the block
    if USreading(6) < 24
        blockThere = USreadings(6);
    end
end

if blockThere == 0
    fprintf("Block not detected. US1: %.1f, US6 %.1f.\n", USreadings(1), USreadings(6));
else
    fprintf("Block detected. US1: %.1f, US6 %.1f.\n", USreadings(1), USreadings(6));
end
end

function rotAccum = recenterOnBlock(rotStep, rotAccumStart, s_cmd, s_rply)
% Center on block assuming we are on one end with a hit
rotAccum = rotAccumStart;

rotAccum = trackRotation(rotStep, rotAccum, s_cmd, s_rply); % Rotate one step to ensure contact

% Rotate until we hit the opposite side
for i = 1:10
    if blockPresent(s_cmd, s_rply) == 0
        rotAccum = trackRotation(-rotStep, rotAccum, s_cmd, s_rply); % Pull back into contact
        break;
    else
        rotAccum = trackRotation(rotStep, rotAccum, s_cmd, s_rply);
    end
end
secondSide = rotAccum;

% Find and aim for midpoint
midPoint = (secondSide - rotAccumStart) / 2;
rotAccum = trackRotation(-midPoint, rotAccum, s_cmd, s_rply);
fprintf("\nAimed for center of block\n");
end

%% Pathfinding code
function turns = turnList(pathList, currentHeading)
lengthPath = size(pathList, 1); % Get number of blocks
turns = [];

% Path length needs to be of at least 2 to have turns
if lengthPath < 2
    return;
end

% Record global heading to take between motions
headingsBetweenSteps = zeros(1, lengthPath - 1);
for i = 1: (lengthPath - 1)
    difference = pathList(i + 1,:) - pathList(i, :);
    
    if isequal(difference, [1 0])
        headingsBetweenSteps(i) = 3;
    elseif isequal(difference, [-1 0])
        headingsBetweenSteps(i) = 1;
    elseif isequal(difference, [0 1])
        headingsBetweenSteps(i) = 4;
    elseif isequal(difference, [0 -1])
        headingsBetweenSteps(i) = 2;
    end
end

% Turn headings into runs based on differences
turns = zeros(1, lengthPath - 2); % One short because start is inserted at the end
for i = 1: (lengthPath - 2)
    turns(i) = headingsBetweenSteps(i + 1) - headingsBetweenSteps(i);
end

% Insert initial heading based on provided initial heading
turns = [headingsBetweenSteps(1) - currentHeading, turns];

turns = mod(turns + 1, 4) - 1; % Turns should be -1, 0, 1, 2
end

function [pathCost, pathList] = findPath(startPoint, endPoint, pathMask)

nodeValues = zeros(4, 8);         % Stores heurisitc value of nodes
nodeJourneyCosts = zeros(4, 8);   % Stores cost of shortest path to nodes
nodeSources = zeros(4, 8, 2);     % Stores where nodes were accessed from
nodeScanned = zeros(4, 8);        % Stores if a node has been scanned yet
pathList = [];
pathCost = -1;

if ~and(pathMask(startPoint(1),startPoint(2)), pathMask(endPoint(1), endPoint(2)))
    % One or both entries are invalid
    fprintf("Start and/or end points for pathfinding are invalid!\n\t Start: [%.0f, %.0f]\n\tEnd: [%.0f, %.0f]\n", ...
        startPoint(1), startPoint(2), endPoint(1), endPoint(2));
    return;
end

% Initialize starting point and add to open list
nodeValues(startPoint(1), startPoint(2)) = ...
    nodeValue(startPoint(1), startPoint(2), startPoint(1), startPoint(2), endPoint, nodeJourneyCosts);
nodeSources(startPoint(1), startPoint(2), :) = startPoint;
nodeJourneyCosts(startPoint(1), startPoint(2)) = 0;
openList = [startPoint, nodeValues(startPoint(1), startPoint(2))];

while true
    % Get the lowest cost node available from the open list
    [~, entryIndex] = min(openList(:, 3)); % Cost is third entry
    
    currentY = openList(entryIndex, 1);
    currentX = openList(entryIndex, 2);
    
    % Remove this node from scan lists
    openList(entryIndex, :) = [];
    nodeScanned(currentY, currentX) = 1;
    
    % Investigate nodes adjacent to this node, add them to the list or
    % update them as needed
    if currentY > 1
        testx = currentX;
        testy = currentY - 1;
        % Check new block is (not obstacle and yet to be scanned)
        if and(pathMask(testy, testx), ~nodeScanned(testy, testx))
            
            temp = nodeValue(testy, testx, currentY, currentX, endPoint, nodeJourneyCosts);
            % Check new value exceeds previous one and isn't on an obstacle
            if or(temp < nodeValues(testy, testx), nodeValues(testy, testx) == 0)
                nodeValues(testy, testx) = temp;
                nodeSources(testy, testx, :) = [currentY, currentX];
                nodeJourneyCosts(testy, testx) = nodeJourneyCosts(currentY, currentX) + distCost([testx, testy], [currentX, currentY]);
                openList = [openList; testy, testx, temp];
            end
        end
    end
    if currentY < 4
        testx = currentX;
        testy = currentY + 1;
        if and(pathMask(testy, testx), ~nodeScanned(testy, testx))
            temp = nodeValue(testy, testx, currentY, currentX,endPoint, nodeJourneyCosts);
            if or(temp < nodeValues(testy, testx), nodeValues(testy, testx) == 0)
                nodeValues(testy, testx) = temp;
                nodeSources(testy, testx, :) = [currentY, currentX];
                nodeJourneyCosts(testy, testx) = nodeJourneyCosts(currentY, currentX) + distCost([testx, testy], [currentX, currentY]);
                openList = [openList; testy, testx, temp];
            end
        end
    end
    if currentX > 1
        testx = currentX - 1;
        testy = currentY;
        if and(pathMask(testy, testx), ~nodeScanned(testy, testx))
            temp = nodeValue(testy, testx, currentY, currentX,endPoint, nodeJourneyCosts);
            if or(temp < nodeValues(testy, testx), nodeValues(testy, testx) == 0)
                nodeValues(testy, testx) = temp;
                nodeSources(testy, testx, :) = [currentY, currentX];
                nodeJourneyCosts(testy, testx) = nodeJourneyCosts(currentY, currentX) + distCost([testx, testy], [currentX, currentY]);
                openList = [openList; testy, testx, temp];
            end
        end
    end
    if currentX < 8
        testx = currentX + 1;
        testy = currentY;
        if and(pathMask(testy, testx), ~nodeScanned(testy, testx))
            temp = nodeValue(testy, testx, currentY, currentX,endPoint, nodeJourneyCosts);
            if or(temp < nodeValues(testy, testx), nodeValues(testy, testx) == 0)
                nodeValues(testy, testx) = temp;
                nodeSources(testy, testx, :) = [currentY, currentX];
                nodeJourneyCosts(testy, testx) = nodeJourneyCosts(currentY, currentX) + distCost([testx, testy], [currentX, currentY]);
                openList = [openList; testy, testx, temp];
            end
        end
    end
    
    % Plot and pause
    %image(nodeValues,'CDataMapping','scaled');
    %pause(1.0) % Pause between steps to see progress
    
    % Check if we've hit the endpoint
    if isequal([currentY, currentX], endPoint)
        temp = endPoint;
        pathList = endPoint;
        %Record list of nodes connecting end to start by tracing sources
        while 1
            tempx = temp(2);
            tempy = temp(1);
            pathList = [nodeSources(tempy, tempx, 1), nodeSources(tempy, tempx, 2); pathList];
            temp = [nodeSources(tempy, tempx, 1), nodeSources(tempy, tempx, 2)];
            
            if isequal(temp, startPoint)
                break; % Break out of path loop
            end
        end
        
        break; % Break out of search loop
    end
end

pathCost = nodeValues(endPoint(1), endPoint(2));
end

% Find value/cost of node
function value = nodeValue(ypos, xpos, ysource, xsource, endGoal, nodeJourneyCosts)

value = distCost([ypos, xpos], endGoal); % Set cost to distance to endpoint
value = value + distCost([ypos, xpos], [ysource, xsource]); % Add distance to source
value = value + nodeJourneyCosts(ysource, xsource); % Add source node's journey

% Add any other heuristic here

end

% Distance function
function dist = distCost(startIndex, endIndex)
% Calculates the minimum distance the rover will have to travel to get to
% the end. Since we only want the robot to travel along one axis at a time
% the distance the robot will travel will be the sum of overall difference
% along each axis.

% Magnitude of each axis change
dx = abs(endIndex(2) - startIndex(2));
dy = abs(endIndex(1) - startIndex(1));

dist = dx + dy;
end

%% Localization Code

function cellCodes = setUpClearanceMap(pathMask)
cellCodes = strings(4,8);

% Find distance from cell to wall along each axis
for row = 1:4
    for col = 1:8
        
        % Check and record obstacles differently
        if pathMask(row, col) == 0
            cellCodes(row, col) = 'x';
            continue % Skip to next cell
        end
        
        up = 0;
        if row > 1
            for i = row-1:-1:1
                if pathMask(i, col) == 1
                    up = up + 1;
                else
                    break;
                end
            end
        end
        
        down = 0;
        if row < 4
            for i = row+1:4
                if pathMask(i, col) == 1
                    down = down + 1;
                else
                    break;
                end
            end
        end
        
        left = 0;
        if col > 1
            for i = col-1:-1:1
                if pathMask(row, i) == 1
                    left = left + 1;
                else
                    break;
                end
            end
        end
        
        right = 0;
        if col < 8
            for i = col+1:8
                if pathMask(row, i) == 1
                    right = right + 1;
                else
                    break;
                end
            end
        end
        
        % Record results in normalized string
        cellCodes(row, col) = vec2str([up, left, down, right]);
    end
end

end

%Converts 4 element vectors to strings with leading zeros\
function stringOut = vec2str(vector)
temp = 0;
power = 1;
numberDigits = size(vector, 2);

% Convert vector to a single number
for i = 1 : numberDigits
    temp = temp + power * vector(numberDigits - i + 1);
    power = power * 10;
end

stringOut = string(num2str(temp,'%04.f'));
end

% Guess location based on clearances
function [locations, headings] = guessLocationClearances(map, clearances)

clearances = round((clearances) / 12); % Calculate nodes adjacent
locations = zeros(4,8);
headings = zeros(4,8);

searchString = vec2str(clearances); % Get string to check for
%fprintf("Scanning for cleanances %s to walls.\n", searchString);


for heading = 1:4
    for row = 1:4
        for col = 1:8
            if strcmp(map(row, col), searchString)
                %fprintf("Clearance match at row %.0f, col %.0f, heading %.0f.\n", row, col, heading);
                locations(row, col) = 1;
                headings(row,col) = heading;
            end
        end
    end
    
    % Rotate heading for next round
    searchString = strcat(extractAfter(searchString, 3), extractBefore(searchString, 4));
end

end

function [locations, headings] = guessLocationWalls(map, clearances)

fprintf("Scanning for adjacent walls.\n");
locations = zeros(4,8);
headings = zeros(4,8);

% Use vector to store which walls are adjacent, need leading zeros
vector = clearances < 6;
wallStr = vec2str(vector);

for heading = 1:4
    for row = 1:4
        for col = 1:8
            
            if strcmp(map(row, col), wallStr)
                % A match has been found!
                %fprintf("Wall match at row %.0f, col %.0f.\n", row, col);
                locations(row, col) = 1; % Mark it down
                
                
                % Check if there is already a heading
                if headings(row, col) == 0
                    headings(row, col) = heading;
                else
                    headings(row, col) = heading + 2; % Record if both directions are possible
                end
                
            end
        end
    end
    
    % Rotate heading for next round
    wallStr = strcat(extractAfter(wallStr, 3), extractBefore(wallStr, 4));
end


end

function map = setUpWallMap(pathMask)

map = strings(4, 8);

for row = 1:4
    for column = 1:8
        temp = [1 1 1 1];
        
        % Markdown if there is a wall or not adjacent
        if row > 1
            temp(1) = 1 - pathMask(row - 1, column);
        end
        if row < 4
            temp(3) = 1 - pathMask(row + 1, column);
        end
        if column > 1
            temp(2) = 1 - pathMask(row, column - 1);
        end
        if column < 8
            temp(4) = 1 - pathMask(row, column + 1);
        end
        
        map(row, column) = vec2str(temp);
    end
end
end

function transformed = applyMotion(pMap, heading)
shiftVals = [0 0];

% Which way are we shifting out probabilities?
if heading == 1
    shiftVals = [-1 0];
elseif heading == 3
    shiftVals = [1 0];
elseif heading == 2
    shiftVals = [0 -1];
elseif heading == 4
    shiftVals = [0 1];
end

transformed = circshift(pMap, shiftVals);

% Need to introduce the basically 0 (0.001) probability squares on the
% blocks the rover should not be in
if or(heading == 1, heading == 3)
    if heading == 1
        row = 4;
    else
        row = 1;
    end
    
    for col = 1:8
        transformed(row,col) = 0.001;
    end
elseif or(heading == 2, heading == 4)
    if heading == 2
        col = 8;
    else
        col = 1;
    end
    
    for row = 1:4
        transformed(row,col) = 0.001;
    end    
end

end

function adjustedPMap = applyP(map, pMin, pMax, pathMap)
adjustedPMap = pMin + (map * ( pMax - pMin)); % Sets 1 to pMax, 0 to pMin
adjustedPMap = adjustedPMap .* pathMap;
end

%% Supporting Robot Functions

% Function to send commands and return the response
function response = sendCommand(commandInput, s_cmd, s_rply)

cmdstring = [commandInput newline];
%fprintf("Command sent: %s", cmdstring); %Print command for debugging
response = tcpclient_write(cmdstring, s_cmd, s_rply);

end

function response = snapToHeading(tarHeading, s_cmd, s_rply)
curHeading = checkComp(s_cmd, s_rply);
response = 0;

% Check if change is even needed
if curHeading == tarHeading
    return;
end

difference = tarHeading - curHeading;

difference = mod(difference + 2, 4) - 2;

if difference == 1
    angle = 90;
elseif difference == -2
    angle = 180;
elseif difference == -1
    angle = -90;
end

sendCommand(strcat('r1-', num2str(angle)), s_cmd, s_rply)
end


% Function to repeatedly sample a selection of US sensors
function readings = checkUS(~, s_cmd, s_rply, superSampling)
% First Parameter used to specify the sensors we were interested in, no
% longer needed but kept there so old commands are still valid

usCommand = 'ua'; % Default call

% If supersampling is defined in call, use that value
if exist('superSampling','var')
    usCommand = strcat('ua-', num2str(superSampling));
end

readings = sendCommand(usCommand, s_cmd, s_rply);
end

% Function to estimate heading based on compass
function quadrant = checkComp(s_cmd, s_rply, superSampling)

% If supersampling is not defined in call, use 1 reading
if ~exist('superSampling','var')
    superSampling = 1;
end

heading = zeros(1, superSampling);
for i = 1: superSampling
    heading(i) = mod(sendCommand('c1', s_cmd, s_rply), 360);
end
averageHeading = sum(heading) / superSampling;
maxDifference = max(heading) - min(heading);

% Break heading down into quadrant (1 pointing up, 45 - 135 degrees)
quadrant = mod(averageHeading - 45, 360);   % Shift readings so 0 is at the old 45
quadrant = 1 + floor(quadrant / 90);        % Divide down into 90 degree buckets
fprintf("Compass read. Heading is %.0f.\n\tAverage of %.0f readings: %.1f. Max. Diff.: %.1f.\n",...
    quadrant, superSampling, averageHeading, maxDifference);
end

% Function to calculate angle relative to the wall
function angle = checkAngleToWall(s_cmd, s_rply)

USvalues = checkUS([4 5], s_cmd, s_rply, 2); % Super sample right sensors

% Return a zero if the two sensors aren't hitting the same wall (difference
% is massive)
angle = 0;
if abs(USvalues(4) - USvalues(5)) > 4
    return;
end

%Finds angle for robot to right wall, +ive is tilted away
dParaUltra = 4.6875; % Difference between parallel US on same side

angle = atan((USvalues(4) - USvalues(5)) / dParaUltra);
angle = 0 - rad2deg(angle); % Invert angle so it is the robot to the wall
fprintf("Angle to wall is %.2f degrees. US4: %.1f US5: %.1f\n", angle, USvalues(4), USvalues(5));
end

function dist = longwiseDist(s_cmd, s_rply)
dist = 0;
USvalues = checkUS([1 3], s_cmd, s_rply);

% Check US measurements were made for both
if or(USvalues(1) == 0, USvalues(3) == 0)
    return;
end

% Get overall length along front-rear axis
dyUltra = 6.15; % Difference between left and right US
dist = USvalues(1) + USvalues(3) + dyUltra;
end

function dist = widthwiseDist(s_cmd, s_rply)
dist = 0;

USvalues = checkUS([2 4 5], s_cmd, s_rply);

% Check US measurements were made for both
if or(or(USvalues(2) == 0, USvalues(4) == 0) , USvalues(5) == 0)
    return;
end

% Get overall length along left-right axis
right = max([USvalues(4), USvalues(5)]); % Use the larger of the two readings as the right, to avoid a zero influence

dxUltra = 5.65; % Difference between front and back US
dist = USvalues(2) + right + dxUltra;
end

function angle = checkAngleToGrid(s_cmd, s_rply)
% The robot when aligned to the maze will always have a multiple of 12
% inches of space along each axis (front/back and left/right). Any
% deviation from alignment will result in an increase in this distance
% and this can be used to estimate angle off axis.

width = widthwiseDist(s_cmd, s_rply);
angle1 = acos((12 * round(width/12)) / width);

length = longwiseDist(s_cmd, s_rply);
angle2 = acos((12 * round(length/12)) / length);

angle = rad2deg(mean([real(angle1), real(angle2)])); % Average angle to grid, as degrees
fprintf("Angle to grid is %.2f degrees.\n", angle);
end

function [angle, response] = alignToWall(s_cmd, s_rply, angleLimit) % Try to align to wall
% Check for angle limit
if ~exist('angleLimit','var')
    angleLimit = 15; % Default
end

% Get the angle to using US
angle = checkAngleToWall(s_cmd, s_rply);

% If invalid result resort to grid estimate
if angle == 0
    fprintf("!! Can't align to walls, invalid angle, Good luck !!!\n");
    %angle = checkAngleToGrid(s_cmd, s_rply);
    return;
end

% Check angle falls within limit
if abs(angle) > angleLimit
    angle = sign(angle) * angleLimit;
end

angle = round(-angle);
fprintf("Angle correction is %.0f degrees.\n", angle);

rotateCommand = strcat('r1-', num2str(angle));
response = sendCommand(rotateCommand, s_cmd, s_rply);
end

function clear = findClearances(s_cmd, s_rply, checkRear)
% Check what sides to scan
scanIndecies = 1:5; % Default without rear
if exist('checkRear','var')
    if checkRear == 0
        scanIndecies = [1 2 4 5];
    end
end

% Get the US readings
clear = checkUS(scanIndecies, s_cmd, s_rply);

% Use minimum the two US on the right into one reading
clear = [clear(1:3), min(clear(4:5))];

% Add the distance between US and robot perimeter for each side
clearanceConst = [-0.5, -0.95,-1.85,-1.1];
clear = clear + clearanceConst;

% List clearances
fprintf("Clearances are:\n\tF: %5.1f\tB: %5.1f\n\tL: %5.1f\tR: %5.1f\n", ...
    clear(1), clear(3),clear(2),clear(4));

end

function dist = advanceForward(s_cmd, s_rply, clearances, bumpTol, ...
    defaultStepSize, maximumStepSize, laneWidth, robotRadius)


% Get distance to the center of the next node based on the closer of the
% front or back clearances, since smaller US readings are generally more
% accurate
if clearances(1) < clearances(3)
    % Use front US to find distance of robot from current spot to front boundary
    distToNext = 6 - (rem(clearances(1), 12));
    distToNext = distToNext + 6 + robotRadius; 
    % Add distance for rover to bring center to the edge and then to the next node center
else
    % Find distance from robot center to front boundary
    distToNext = 12 - (robotRadius + rem(clearances(3), 12));  
    distToNext = distToNext + 6; % Move to center of next block from boundary
end
fprintf("Advancing forward one block, distance to cover %.1f...\n", distToNext);
dist = 0;

% A few steps should suffice, there is an early exit condition too
for i = 1:5
    if i > 1
        clearances = findClearances(s_cmd, s_rply, 0); % Get new front and side clearances after moving
    end
    
    % Get possible step size forward
    forward_distance = clearances(1);
    if forward_distance > 12
        stepSize = 1.5 * sqrt(forward_distance); % variable step size based on forward distance to travel
    else
        stepSize = defaultStepSize; % Default step size
    end
    
    % Limit step to the lowest limitation, be it clearance or maximum step size
    % if it exceeds either.
    stepSize = min([stepSize, maximumStepSize, clearances(1) - bumpTol]);
    
    % Limit stepSize to the amount needed to reach the center of the next
    % cell (only really matters on last iteration)
    stepSize = min([stepSize, distToNext]);
    
    % Check we are not immediately next to a wall
    if (clearances(2) < bumpTol)
        % Move away from the left wall if too close
        
        turnAngle = asind((6-(robotRadius + clearances(2)))/stepSize);
        if ~isreal(turnAngle)
            turnAngle = 40;
        end
        fprintf("Wall detected on left, moving away.\n\tSteering angle: %.0f\tDist: %.1f\n",turnAngle, stepSize);
        sendCommand(strcat('r1-', num2str(0 - turnAngle)), s_cmd, s_rply);
        sendCommand(strcat('d1-', num2str(stepSize)), s_cmd, s_rply);
        sendCommand(strcat('r1-', num2str(0.75*turnAngle)), s_cmd, s_rply);
        
    elseif clearances(4) < bumpTol
        % Move away from the right wall if too close
        
        turnAngle = asind((6-(robotRadius + clearances(4)))/stepSize);
        if ~isreal(turnAngle)
            turnAngle = 40;
        end
        fprintf("Wall detected on right, moving away.\n\tSteering angle: %.0f\tDist: %.1f\n",turnAngle, stepSize);
        sendCommand(strcat('r1-', num2str(turnAngle)), s_cmd, s_rply);
        sendCommand(strcat('d1-', num2str(stepSize)), s_cmd, s_rply);
        sendCommand(strcat('r1-', num2str(0 - 0.75*turnAngle)), s_cmd, s_rply);
        
    else
        % All clear? Go forward a step
        
        % Check if it is within a single lane (walls on left and right,
        % allowing for skewing). Will
        if and((clearances(2) + clearances(4)) < 6, abs(clearances(2) - clearances(4)) > laneWidth)
            % Off lane, correct by aiming for midpoint
            turnAngle = asind((clearances(2) - clearances(4))/(2 * stepSize));
            
            if ~isreal(turnAngle)
                turnAngle = 40;
            end
            
            turnAngle = round(turnAngle);
            
            fprintf("Centering in lane, right-leaning by %.2f.\n\tAngle: %.0f\tStep size: %.2f\n", ...
                (clearances(2) - clearances(4)), turnAngle, stepSize);
            
            sendCommand(strcat('r1-', num2str(turnAngle)), s_cmd, s_rply);
            sendCommand(strcat('d1-', num2str(stepSize)), s_cmd, s_rply);
            sendCommand(strcat('r1-', num2str(0 - turnAngle * 0.75)), s_cmd, s_rply);
            
            alignToWall(s_cmd, s_rply); % Try to align to the wall
            
            
        elseif sum([clearances(2), clearances(4)] < 6) == 1
            % We are not in a lane, hug the closest wall on the left or right
            % Avoids this if there are no walls (row 2 col 5)
            [minClearance, whichWall] = min([clearances(2), clearances(4)]);
            
            % Find angle to correct to centreline
            turnAngle = round(asind((robotRadius + minClearance - 6)/stepSize));
            if ~isreal(turnAngle)
                turnAngle = 40;
            end
            
            % Condition based on side
            if whichWall == 1
                %Hug wall on left
                fprintf("No wall detected on right, hugging left wall.\n\tSteering angle: %.0f\tDist: %.1f\n",turnAngle, stepSize);
            else
                fprintf("No wall detected on left, hugging right wall.\n\tSteering angle: %.0f\tDist: %.1f\n",turnAngle, stepSize);
                turnAngle = 0 - turnAngle; % Need to reverse direction so it's CW
                
            end
            
            sendCommand(strcat('r1-', num2str(turnAngle)), s_cmd, s_rply);
            sendCommand(strcat('d1-', num2str(stepSize)), s_cmd, s_rply);
            sendCommand(strcat('r1-', num2str((0 - turnAngle) *0.75)), s_cmd, s_rply);
            
        else
            % In lane, or no guides - giv'er. Hope for the best
            fprintf("Going forward %.2f.\n", stepSize);
            sendCommand(strcat('d1-', num2str(stepSize)), s_cmd, s_rply);
        end
    end
    
    distToNext = distToNext - stepSize; % Reduce the distance needed to cover
    dist = dist + stepSize; % Update distance covered
    
    % No more movement needed, or the increments are too small (result of
    % overestimsating the initital distance)
    if or(distToNext <= 0, or(stepSize < 1.5, ((clearances(1) - stepSize) + robotRadius) <6))
        break;
    end
end

fprintf("...Reached next cell.\n");
end
