---
title: "Hardware Clock"
date: 2021-11-20T14:56:48-05:00
draft: false
started: "November 2021"
finished:
status: "Waiting for boards"
client:
tags: [hardware, clock, KiCAD]
skills: [logic, KiCAD]
summary: "A modular clock composed entirely out of discrete logic chips I got secondhand."
githubLink: "https://github.com/savob/digital_clock"
thumbnail: "/images/clock-display.png"
---

# Overview

I have for a while wanted to take a break from microcontroller-based projects and try 
my hand at doing a projet without one. Without completely surrendering myself to the 
world of analog, I took a stop towards this by try to do the classic hobbyist project 
of a clock, but only with discrete logic chips.

The idea came to me when browsing through a cache of old electronics a friend of mine had 
come into and a friend mentioned they wanted to learn to make a clock with a microcontroller
so I decided to make one of my own too.

Currently I have tested all the modules on breadboards and transferred them to KiCAD 
so I could layout PCBs. **Currently waiting to have them made.**

## Requirements

- Show the time in some format
- Be modular by function
- No microcontrollers allowed!

## Objectives

- Be accurate to within two seconds a day

## Takeaways

I'm a bit rusty at breadboard prototyping, need to double check my connections are actually 
working as they appear they should with continuity tests.

Discrete logic isn't as troublesome as I expected, but this also is a basic project really. 
I would look to maybe use some in future projects, especially for safety systems and such.

*Does h4x0r aesthetic == poor user experience?*

# Detail

I've wanted to do something without a microcontroller for a while now since that's been the 
common denominator in basically any project of moderate scale I've undertaken thus far. During 
a visit back home I was invited by friend to check out a cache of second-hand electronic 
components he had purchased to see if there was anything that tickled my fancy.

These were a collection of organizers chock-full of goodies, from bulky switches and 
potentiometers down to individual passives clearly pried from some long forgotten control 
cabinet. Among these dozen or so cabinets were a few stuffed with logic ICs from all the 
standard families: 7400-, 4000-, or 4500-series classic.

Initially I was just grabbing ones that looked cool to *potentially* use in some future project. 
However my other friend mentioned they wanted to make a clock so I took their idea and ran 
with it, grabbing ICs I felt would be useful for the job and a fistful of LED displays.

I quickly realized that this circuit was going to have to be large to fit all the ICs, 
especially since they all came in DIP14/16 packaging. So I felt that a modular design would 
be wise to keep things (and issues) seperate. It would also help create a sort of cliché 
"80's hacker" aesthetic when paired with all through hole components and floating jumpers.

## Module Design and Prototyping

I broke the system into modules based on function:
- Displays and counters. Two digits per panel
- Reset (rollover, carry) logic for each digit
- Base clock signal and power delivery

### Chip Choice

Limiting myself to the chips available in the cache, I selected the following chips for 
the different modules:

- Display drivers (they share functionality pin-for-pin for easy switching as needed)
  - 74LS47 for common anode displays
  - CD4511 for common cathode displays
- Counters
  - 74LS193 programmable 4-bit counters
- Reset logic
  - 74LS32 quad OR gate
  - 74LS08 quad AND gate
- Clock divider (for 32.768 kHz crystal to 1Hz base)
  - CD4060
  
### Displays

The first part I worked on prototyping and getting working was the displays since they 
would be used to debug the rest of the circuit. Once I had sorted the displays based on 
whether they were common anode or cathode, I begain to connect them to the drivers 
and would cycle through values to display using a set of switches to ensure I had 
everything connected properly. This worked without a hitch.

<figure>
<img src="/images/clock-decoder-test.gif">
<figcaption>Fig. 1 - Cycling through values using a DIP switch set</figcaption>
</figure>

### Counters

A clock is basically one large counter composed of individual counters for each digit. 
The ones on the seconds count to 10, then reset and increment the next digit, up to 6. 
At that point the minutes increment up, so on and so forth. Thus each digit needs its 
own counter in addition to a driver. These counters would count the leading edges of 
an input wave and output their value on four pins. 

### Reset Logic

The counters I used (74LS193) are true 4-bit counters so they rollover and reset at 16, 
so all digits need external logic to properly reset the counters and increment the next 
digit. To achieve this I am using some AND and OR gates to check the output of the counters 
and then use the result of this logic to reset and increment counters.

For example, if we want to rollover a digit at 10, we can use a single AND gate to 
see if the 8 and 2 bits are both set and then use it to reset the counter. This works 
because under normal operation the numbers increment upwards from 0 so there is no 
chance for the clock to overshoot and miss the reset. However if the user inputs a 
value over the set point, i.e. 11, then depending on the logic used, the system 
might not recent properly. I believe this is an acceptable error case because it 
will correct itself once the digit is reset, although it will through off the time 
in the process.

Below is a demonstartion of a counter set up as described to count to 10 using the 
external AND gate.

<figure>
<img src="/images/clock-digit-test.gif">
<figcaption>Fig. 2 - Cycling through a counter</figcaption>
</figure>

To ensure the pulse generated to reset a counter is long enough to also increment the 
adjacent counter I performed tests on cascaded timers that were successful.

<figure>
<img src="/images/clock-cascade-test.jpg">
<figcaption>Fig. 3 - Cascading counters test. Note the additional counter at the bottom of the breadboard connected to the other (second chip from the top) and the AND gate between them</figcaption>
</figure>

### Signal Generator

The heartbeat of the clock is a steady, accurate 1Hz square wave. This square wave is 
generated using the same system used in most digital watches and real-time clocks (RTCs), 
dividing a 32 768 Hz signal down to 1 Hz. This is done by using a chain of T flip-flops 
that each half the frequency fed into them. 15 of these are needed to divide the 32 768 
Hz (2^15) down to 1 Hz.

<figure>
<img src="/images/clock-division.jpg">
<figcaption>Fig. 4 - Division of the reference 32 768 Hz wave (blue) by a factor of 16 to generate the output (yellow)</figcaption>
</figure>

The CD4060 was designed for this job, having a string of T flip flops needed to divide the 
signal, as well as the circuitry needed to drive the reference crystal used to provide 
the 32 768 Hz. The only isue is that it has only 14 flip flops internally, so two CD4060s 
are needed to divide the signal all the way down to 1 Hz.

#### Protopying Issues

Making the protoype module for the clock on a breadboard was where I lost most of my time. 
I was using a reference design I found and the system would work fine, however if I left it 
running for a few minutes it would start to shift its frequency higher until it would 
eventually just stop working entirely. This is not something I wanted. I wanted to make a 
*"clock"* clock, not an egg timer.

So I spent a few days trying to tune and dial in the values of the passives around the 
crystal, changing the crystal, even the CD4060 with brand new ones to see what I could 
do to improve the stability. The best I got was just about 3 minutes before failure.

<figure>
<img src="/images/clock-crystal-trials.jpg">
<figcaption>Fig. 5 - Results of my trials of different passives around my crystal</figcaption>
</figure>

In the end what turned out to be the cause of my issues is that the CD4060 did not have 
its reset pin properly grounded so it collected a charge during operation and resulted 
in these intermittent resets of the chip. This was caused by a break internal to the 
jumper I was using to ground it, inside the plastic head at one end.


## Circuit Boards

Once I had established the circuit for each module tested and documented, I transferred 
the schematics to KiCAD and layed out a circuit board for each module.

I used edge connectors to pass the signals between them since it will also provide more 
structural stiffness compared to jumpers when hung up on a wall.

For the display I added the ability for the user to set the digits using jumpers to set 
a value, and then pressing a button to load it into the desired counter. Originally 
I intended to use a more conventional and user-friendly button to increment counters but 
the issue of debouncing and combining clock signals would have needed me to add much 
more to the boards. On the plus side, I think the exposed headers will add to the "hacker" 
aesthetic.

<figure>
<img src="/images/clock-display.png">
<figcaption>Fig. 6 - Layout of the display module</figcaption>
</figure>

The reset module is little more than a breakout for the two available logic ICs. Since each 
digit set may need different conditions to reset, it will be up to me to wire the logic on 
each board myself as need when I assemble them. 

<figure>
<img src="/images/clock-reset.png">
<figcaption>Fig. 7 - Layout of the reset board</figcaption>
</figure>

The only addition to the signal generator board was the power input to supply the power rails.

<figure>
<img src="/images/clock-signal.png">
<figcaption>Fig. 8 - Layout of the signal board</figcaption>
</figure>

## Assembly

I have all of the components ready to go.

I am currently waiting for a few other projects to be designed before commiting to one 
massive PCB order which this will be part of.


