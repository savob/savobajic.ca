---
title: "TITAN 2022"
date: 2022-09-18T15:44:40-05:00
draft: true
started: "September 2020"
finished: "September 2022"
status: "Completed"
client: "HPVDT"
tags: [embedded, rpi, KiCad, python, HPVDT]
skills: [embedded, rpi, KiCad, python, c]
summary: "My successfully deployed, much revised video bike system for HPVDT's speedbike TITAN"
githubLink: "https://github.com/hpvdt/titan_2022"
thumbnail: "/images/titan-crew-2022.jpg"
---

# Overview

For TITAN, our return entry to the World Human Powered Speed Competition (WHPSC) from 2019 our team needed a video system for the vehicle. This system is vital because it is the **only** way our riders can know what is outside and steer because we do not have windows - primarily to improve our aerodynamic performance. Not only was the system meant to provide a live video feed of the surroundings, but also overlay the video feed with data about the bike's state, namely speed and rider power output.

{{< fig src="/images/titan-crew-2022.jpg" caption="TITAN and our crew at WHPSC 2022 (I'm third from the right!)" >}}

I had already [attempted a system previously]({{<ref "projects/extracurricular/titan-v1" >}}), but I greatly revised it based on feedback from our riders and my improved understanding of embedded systems.

Unlike 2019, I went with the team to help compete at the competition! Although the system had some minor issues in our first few runs which I hadn't experienced in development, I was able to iron out most issues between each set of runs. Unfortunately we suffered a crash on our third run which ended our participation for the remainder of the competition.

So although we didn't get to run it much yet, I feel the system was successful!

### Reviewing TITAN 2019 Feedback

The first step for this revision was to review the feedback for the 2019 version, main points of which are summarized below:

- One RPi/board pair resulted in a boot loop, likely caused by a poor voltage regulator
- The camera feed would flash black periodically, caused by the overlay updating process.
- The rear facing camera was useless
- Use a direct camera-screen setup for the back-up video feed

## Requirements

The requirements for this system are essentially the same as they were for TITAN previously.

- Have three displays, each running a separate video feed running off seperate power sources.
   - One front facing "main" display for front rider
   - One front facing "spare" display as a redundant video feed for the front rider *(does not display bike data)*
   - One "secondary" display for rear rider *(can be either front- or rear-facing)*
- Gather and relay the following *critical* data to the riders
   - Bike speed
   - Distance travelled
   - Cadence (rate of pedalling) per rider
   - Power output per rider
- **Video feed must be stable and run at a minimum of 30 frames per second**

## Objectives

The objectives did not budge much from the original TITAN objectives either.

- Gather and relay additional non-critical data to riders
- Stream data to chase vehicle
- Record video feed
- Log all collected data
- Inform users on the estimated "performance" of the run relative to expectations
- Reduce system footprint from previous iteration

## Takeaways

There are a few takeaways I have from this project.

- Locking connectors are very useful, crimping wires is a quick way to assemble a harness too
- Communications can be greatly improved by using "binary" (non-human readable) data, both for speed and reliability.

# Detailed Report

For our high performance speed bikes we pioneered the use of a video feed in place of a conventional window to see out of our vehicles. This approach provides us with a couple of advantages, namely improving our aerodynamics by allowing more recumbent riding positions for our riders (closer to laying down than sitting) which decreases our frontal cross section, and the removal of a window removes numerous seams between the window and fairing that could contribute to disturbing laminar flow over the remainder of the fairing increasing drag.

In the place of a window, a camera (in a mast is placed outside the vehicle) and a display inside the vehicle provide the view of the surroundings for the rider(s). On TITAN the mast is the black protrusion right behind the hatch.

{{< fig src="/images/titan-mast.jpg" caption="TITAN being tested (with protective jacket) at Downsview Airport" >}}

The vision system is also used to relay information about the vehicle to the riders, like speed, using overlays on top of the video feeds. This makes it trivial for the rider(s) to check how the ride is going since they do not have to greatly shift their focus from the screen to do so.

## Overall System Design

My system scope design didn't change massively from my previous design. 

There would be three cameras used in TITAN, two for the front rider, one for the rear. All of these would be front facing; two of them would be digital cameras (one for each rider), and the third an analog camera (spare for front rider). This is slightly different to the previous system where all the cameras were digital and the rear rider had a rear-facing camera. The switch to analog was done to simplify and thus improve the reliability of the redundant screen for the front rider by minimizing possible points of failure. The switch to have the rear rider's camera face forward was done since our rear rider found a rear facing system useless and found that using a front facing display was more comforting.

For the digital camera systems I reused the Raspberry Pi 3B+'s and Raspberry Pi Camera modules from the previous system. For the analog system I used a commercial analog camera fed directly into a screen. For data collection and communication between the RPis I used an STM32 microcontroller like I had previously.

In the end the basic block diagram was drawn up to be the following. My choices will be explained in greater detail in the sections that follow.

[DIAGRAM LAYOUT]

### Raspberry Pis and Pi Cams

We used Raspberry Pi 3B+'s and Raspberry Pi camera modules for the digital camera systems. As mentioned before, in addition to outputting high resolution and frame rate video (720p at 60 frames per second) the RPis serve to overlay data on top of the video stream as well as recording the video stream for later review.

I kept using these since they were easy to use, I already had some code prepared for them, and most importantly - between 2020 and 2022 we had them on hand during supply shortages of just about any electronics.

### Displays

I reused the displays used previously on TITAN since they all still met the required resolution and frame rate requirements we needed. In addition to them all accepting HDMI, they also accept analog video input so changing the redundant front screen to run off analog video did not require a new hardware (other than the camera). 

These displays are some standard 5" (for the backup) and 7" brandless LCD panels with loose driver boards available from vendors on sites like AliExpress (the vendor which we purchased ours from appears to have closed up shop). We use these since they provide us the flexibility to design our own housings for them which is vital in the constrained space of TITAN.

### Microcontroller

The microcontroller's purpose is to collect data (especially real time) and distribute data about TITAN as needed. I elected to continue to use the STM32F103C8B in TITAN from the previous version. My reasons for this are:

1. It fulfilled its role perfectly previously in TITAN
   - Enough I/O for all the sensors
   - Enough communication peripherals for all the RPis and complex sensors/modules
   - Enough clock speed to avoid unresponsive behaviour
   - Plenty of program space for all the libraries and routines needed for TITAN
2. Familiarity of using it
3. Plenty of reference projects online
4. Has a designated debugging/programming interface

### Sensors

There was a lot of types of data collected on TITAN, I'll be listing the hardware I used and what data it gathered. They all connect to the STM32 with the exception of the ANT+ module which is connected to an RPi since it needs a USB connection.

A review of the sensors reused from the previous system:

- Resistor voltage dividers
   - Battery levels - Used to divide the different battery voltages down to safe levels for the STM32 to measure
- DHT22 (Digital Humidity and Temperature)
   - Used to monitor ambient air conditions
- Optical Encoder
   - Wheel-based speed - The period between pulses provides the rotational rate of the wheel
   - Wheel-based distance - The number of rotations is counted and used to estimate the distance travelled 
- GPS
   - Location - Not super useful during rides but useful in run analysis
   - GPS-based speed - A redundant speed value in the event the encoder is not acting correctly
   - GPS-based distance - Using the current location an estimate can be found for how far TITAN has gone, and how much remains to go
- ANT+ Dongle (USB connection to rear RPi)
   - Power - Both riders have power pedals 
   - Cadence - Both riders have ANT+ power pedals also broadcast this
   - Heart Rates - Both riders wear heart rate monitors
   
From the previous version of TITAN, these sensors were added:

- IR Contactless Thermometers
   - Brake disk temperatures for front and rear
- CO2 Sensor

### Telemetry

To broadcast data out of the bike to our chase vehicle, we used nRF24L01 modules. I had intended to use these back in 2019 but never got around to working them into the system before the competition. Since then I had done some work specifically on [this]({{<ref "projects/extracurricular/telemetry" >}}) so I now was ready to properly incorporate them into TITAN, the difference from before hardware-wise being that the module would be interfaced with the microcontroller instead of an RPi. This was done to simplify coding for the RPis as well as ideally making the system more responsive.

Given that the fairing is largely composed of carbon fibre (which blocks radio waves), telemetry and the GPS both had antennae that were run to the rear of the bike so that the radio waves could escape the fairing through a designated fibreglass portion which permits radio waves. This fibreglass portion is a visually distinct brown next to the black carbon fibre used for the remainder of the fairing.

{{< fig src="/images/titan-at-competition.jpg" caption="TITAN and crew at 2019, prior to its paint job with the fibreglass tail section visible" >}}

## Circuit Design

Once I settled on the hardware I wanted in the system, or rather what changes I wanted from TITAN, I got going on designing the circuit.

I made two revisions for hardware corresponding with my two main periods of work on this, one in fall 2020 and another in the summer of 2022 leading up to competition to iron out some minor issues with the first. Below is the schematic for the first revision.

{{< fig src="/images/titan-2020-schematic.svg" caption="The completed schematic for TITAN 2022 (PDF version: [Colour](/pdf/titan-2020.pdf) / [BW](/pdf/titan-2020-BW.pdf))" >}}

The circuit can be broken into a few main sections:

- The 5V regulator. Includes certain power protections like reverse polarity.
- The microcontroller and communication section (RPis, GPS, telemetry, USB)
- Sensor interfaces

Most of these are based off reference designs for the respective section (e.g. the regulator chip), so there wasn't too much for me to do other than designating the connections between these. The areas where I did design some circuitry of my own were the power protection stages before the 5V regulator and the comparator for the analog input.

### Revised Circuits

For the second version I changed a few things from the first, major changes listed below. It however largely remains the same.

- Off-boarded the encoder comparator to a separate board
- Added the new IR thermometer and CO2 sensor headers
- Added status LEDs (controlled by microcontroller)
- Added SWD debugging header for STM32
- Changed the 5V regulator (due to supply issues)

{{< fig src="/images/titan-2022-schematic.svg" caption="The completed main schematic for TITAN 2022 (PDF version: [Colour](/pdf/titan-2022.pdf) / [BW](/pdf/titan-2022-BW.pdf))" >}}

Overall I am satisfied with the final circuit for TITAN in 2022. **The only hardware issue encountered was that I failed to add enough capacitance to the analog circuitry for the microcontroller so ADC readings used for battery monitoring were too noisy to be used.** This was tolerable though since the batteries were only used for about 20 minutes at a time before recharging but had enough energy when fully charged to run for over 200 minutes.

Below is the schematic used for the daughter board used for the rear wheel to house the IR sensor for brake disk temperature and the IR reflectometer used to track brake spokes as an encoder. It has a simple op-amp circuit used to amplify and convert the reflectometer signal into a digital one for the microcontroller, and headers to connect to the rest of the system.

{{< fig src="/images/titan-wheel-schematic.svg" caption="The completed schematic for TITAN 2022's daughter board (PDF version: [Colour](/pdf/titan-wheel.pdf) / [BW](/pdf/titan-wheel-BW.pdf))" >}}

The circuit for the daughter board worked as intended once tuned. **The only minor quirk it had was that once the brakes were engaged the IR encoder would fail to accurately monitor rotational speed.** This was due to the brake disks heating up enough that the IR emitted by them overwhelmed the sensor. This could be remedied by using a visible light sensor or a different encoder arrangement altogether. However this wasn't an issue since once the brakes are engaged on TITAN the exact speed is no longer of concern since it has finished its run and the GPS provides a rough speed until the disks cool down.

## Board Layout

There were two boards made, the main boards that were put on the RPis as HATs (more on that later) and the daughter boards for the wheel sensors.

### Main Board Layout

The board layout underwent a much more intense change from the previous version than the circuitry. Whereas the previous board was meant to sit completely separate of the RPis connected to them by a 40 wire ribbon cable, the new boards were meant to be mounted using the RPi Hardware on Top (HAT) standard. This eliminated the need for the ribbon cable by putting the TITAN board directly on top of the RPi with a 40-pin header which also reduced the overall footprint of the system by having the board overlap the RPi. This was first attempted with [Blueshift]({{<ref "projects/extracurricular/blueshift#layout" >}}) to reduce system size as well as reducing the chance of incorrect connection.

The HAT standard also has a recommended outline to not extend outside the footprint of the RPi (65 by 56 mm), mounting holes to seat nicely on the RPi, and spaces for the different interfaces that might need to pass through; RPi display and RPi camera cables. The default HAT board is shown below, I made two changes to the outline visible when looking at my layouts later: 
1. I removed the clearance for the display cable on the left edge since we weren't going to use it. HDMI comes out the side of the RPi.
2. I extended the slot for the camera cable to the lower edge. This would allow the HAT to be seated to or removed from the RPi without needing to fiddle with the camera cabling.

{{< fig src="/images/titan-rpi-basic-hat-board.png" caption="The basic HAT template board" >}}

Here is the overall layout of TITAN for 2022. Although all the board itself does not extend outside the boundaries of the HAT standard, there are a few components that protrude beyond the edges. Namely the GPS and nRF24 modules on the right which were placed there intentionally so that they could rest atop the ports there to support their cantilevered boards. They don't protrude significantly beyond the edges of the RPi itself.

I tried to place the majority of ports around the edges of the boards, and the buttons along the bottom edge to moderate success. There really isn't an obvious flow to any of their placings though which could possibly be improved on.

{{< fig src="/images/titan-2022-layout-overall.png" caption="The overall layout of the board" >}}

All the hardware other than the header for the RPi resides on the top side of the board. The microcontroller is seated in the middle with the different parts it connects to placed radially around it. The power regulation and protection circuitry is in the top left quadrant since the 5V pins for the RPi are there so clustering all this there reduces the parasitics present in the power system. Introduced from the previous version, the status LEDs are placed in the centre since I wasn't too sure which side would be easiest to view when mounted in the bike, so here they would be equally visible regardless of board orientation.

{{< fig src="/images/titan-2022-layout-top.png" caption="The layout of the top side" >}}

The majority of traces are on the top, the bottom was reserved mostly for a 3.3V plane and the odd traces that needed to use the bottom. Since it was devoid of parts I used it to record some of the boards features as well as some basic assembly instructions.

{{< fig src="/images/titan-2022-layout-bottom.png" caption="The layout of the bottom side" >}}

Here are renders of this HAT as it should be assembled. *Note: the nRF24 and GPS modules are not modelled in KiCad nor do nice models exist online, so I just have them modelled by the headers they will be seated into.*

{{< fig src="/images/titan-2022-render-top.png" caption="The render of the top side of the HATs" >}}

{{< fig src="/images/titan-2022-render-bottom.png" caption="The render of the bottom side of the HATs" >}}


### Wheel Board Layout

The layout of the wheel board faced some geometric constraints as it needed to fit inside a pocket in the wheel bracket responsible for holding the rear wheel in place. It needed to be low profile so it would avoid collisions because the rider's feet would pass right by it as they pedalled, and reasonably hardy should it be struck.

I used some of the commentary layers for annotating the dimensions that the board needed to abide by for the sensor locations. This was needed so we would then know where to drill holes in the wheel brackets to mount these boards properly and have the sensor seat nicely into them. 

{{< fig src="/images/titan-wheel-layout-holes.png" caption="The overall layout of the board" >}}

I then built up the circuit around these and the other dimensions I recorded.

{{< fig src="/images/titan-wheel-layout-overall.png" caption="The overall layout of the board with all annotations" >}}

With just the actual manufactured layers (copper, edges, silk screen, etc.) the layout is compact but not complicated. 

{{< fig src="/images/titan-wheel-layout-overall-circuits.png" caption="The overall (manufactured) layout of the board " >}}

Focusing on the top layers I set the test point for a ground connection to be perpendicular to the other three so it would be easier to identify. I included labelling for their purposes on the board to ease the tuning that would be needed later.

{{< fig src="/images/titan-wheel-layout-top.png" caption="The layout of the top side" >}}

The bottom served as a 5V plane and had traces for some connections.

{{< fig src="/images/titan-wheel-layout-bottom.png" caption="The layout of the bottom side" >}}

Some 3D renders of this board as it should be assembled. *Note: I couldn't find a 3D model for the IR temperature sensor with four leads included in KiCad so I used one with three.*

{{< fig src="/images/titan-wheel-render-bottom.png" caption="The render of the bottom side facing the wheel" >}}

{{< fig src="/images/titan-wheel-render-top.png" caption="The render of the top side facing out of the wheel well" >}}

## Assembly

Assembly of the boards proceeded without a hitch. Some small changes were made to boards regarding the headers since the team got a 0.100" pitch JST header kit which was used for most interconnects instead of the originally intended 0.100" pitch pin headers since they had builtin locking and orientation ensuring features.

### Main Boards

I assembled three of the main boards: two complete boards to have a spare handy, and one without a microcontroller for the rear rider system. I had a stencil for paste that helped with the surface mount portion.

{{< fig src="/images/titan-main-boards.jpg" caption="Two fully assembled main boards" >}}

Looking closer at the main board, not all the JST headers could physically fit in the corner for the different sensors because I designed it for pin headers, the CO2 sensor header was mounted offboard on a short cable harness. This had the minor advantage that it allowed me to use the opposite header type to the DHT sensor so that it would be impossible to plug their 3-wire cables into the wrong header, although I did have to pay attention to joint fatigue.

{{< fig src="/images/titan-main-board-close-up.jpg" caption="Close up of an assembled main board" >}}

Since USB wasn't likely going to be used for debugging since I now had the SWD header, I omitted their connectors at initial assembly. (These were never added later.)

### Wheel Board

Given the few parts on the daughter board I didn't purchase a stencil for it and just hand soldered all the parts in place. Although these original photos show the cable harness soldered directly to the board, I eventually replaced that with a JST header to minimize the strain on the wires and allow the board to be easily replaced as needed.

{{< fig src="/images/titan-wheel-board-front.jpg" caption="Front face of the wheel board" >}}

{{< fig src="/images/titan-wheel-board-back.jpg" caption="Back (sensor) side of the wheel board" >}}

Although I originally designed the wheel board to have a pass through connection for the front thermal sensor, I decided to minimize the length of wire run through TITAN that I would instead use the cable harness to fork the required connections. I prepared a basic USB header to use as a quick connect for the front thermometer since it needed four wires, which I puttied with hot glue to prevent wire fatigue at the joints.

{{< fig src="/images/titan-wheel-board-harness.jpg" caption="Completed wheel board with cable harness" >}}

### Assembly into TITAN

Putting the electronics in TITAN took place at the end of August 2022 in the days prior to our initial test runs at Downsview Airport, which themselves were only a couple of weeks prior to WHPSC 2022. 

#### Rewiring

Although the structure was the exact same as it was in 2019, I redid all the wiring with the help of some teammates. This was done so that all the wires would be routed inside the frame (they were taped to the inner surfaces in 2019) as well as to add wiring for the new sensors and improve the existing connection (namely for power). Running wires inside the frame protected them from wear from riders in addition to making the system sleeker.

{{< fig src="/images/titan-mid-assembly.jpg" caption="TITAN mid assembly of the electronics systems" >}}

To run wires through the frame a steel washer was tied to a piece of string and a magnet was used to pull the washer along the desired path. Then wires would be tied to the string and pulled back through. In the picture above there is excess wire visible at many of the ports in the frame (front, top, rear) that were later shortened or tucked back into the frame. 

While rewiring the entire bike I decided to reposition the front display system electronics to be in the rear. In 2019 the TITAN board, RPi, and display driver board were all nested behind the front screen. This was far from ideal since it needed many wires to be run to front including the ribbon cable for the front camera which was susceptible to noise along the ribbon cable and poor intermediate connections. Moving the RPi and TITAN board to the rear meant that only a power connection and HDMI cable needed to be run from the rear to the front, so the data connection between the two RPis and most sensor was shortened including the camera. Furthermore, by placing the majority of electronics at the rear meant they were accessible from the hatch which made them easier to reach for maintenance without needing to remove the whole fairing.

#### Mounting Sensors

Once the majority of wiring was in place we mounted the sensors where needed.

- CO2 sensor was placed near the top, between the riders' heads
- Digital humidity and temperature sensor was placed near the air intake at the bottom
- Front wheel brake thermometer had a hole drilled in the front wheel fairing
- Rear wheel board was mounted inside the wheel bracket

For the front brake temperature sensor cable harness a similar USB connector was prepared to what I did for the wheel harness board. I made sure to repeat the connections that were made then so any off-the-shelf Male-Male USB A cable could connect them.

{{< fig src="/images/titan-temperature-sensor.jpg" caption="Front wheel temperature sensor soldered directly to wire harness" >}}

Mounting the wheel board for the rear wheel was not as easy as expected. Since the board used through hole components and was mounting to metal we needed to add insulation to prevent the terminals shorting through the aluminium. Further spacing material was needed under the board to lift it since it was discovered that the IR reflectometer used as an optical encoder was making contact with the brake disk and actually getting damaged. In the end a popsicle stick under the board was used as our "precision" isolating spacer.

{{< fig src="/images/titan-wheel-board-placed.jpg" caption="Wheel board nested in rear wheel bracket" >}}

#### Screen Tests

After installing all the sensors and wiring everything up, a basic functionality test was done on the microcontroller to ensure that it was able to communicate with all the sensors in TITAN and the RPi's to validate their connectivity and video output. All connections worked as expected!

The front video system is two separate camera feeds on entirely separate display systems, with absolutely no connection between them. The upper screen is the digital camera system as hinted at by the overlay, the lower is the analog camera system. *Note: for this the analog camera is inside but not properly seated in the mast so it is partially obscured. This was remedied later prior to WHPSC.*

{{< fig src="/images/titan-front-system.jpg" caption="Front TITAN video system operating" >}}

The rear system is only one screen with a front-facing digital camera system. For testing I used lose hanging cameras as shown in front of the screen in the picture below instead of the ones in the mast. Slightly visible behind the screen is the electronics as I was doing initial placementrs.

{{< fig src="/images/titan-rear-system.jpg" caption="Rear TITAN video system operating" >}}

## Coding

Coding TITAN was a bit different to my other projects for HPVDT.


















### Microcontroller Firmware

The microcontroller firmware was written in C++ using the Arduino IDE. The firmware on it has two main purposes: relay data between the RPis and monitor its sensors. The main loop of code alternates between these duties forever.

#### Collecting Sensor Data

The microcontroller collects the data it is responsible for in different ways. It collects the level of batteries, and the humidity and temperature in the vehicle periodically every few seconds since these are not rapidly changing quantities. The GPS data is updated as it becomes available from the GPS module. The optical encoder handler is connected to an interrupt so as to not miss any encoder pulses.

For the GPS and DHT module, I made use of freely available libraries for that hardware. This greatly accelerated the development of my code for these sensors since they had already handled the majority of the work. Since it was code used by countless others it was also more reliable than what I probably would have written from scratch.

All the sensors and their implementations were tested unit-wise on their own before I combined them into this firmware.

#### Battery Monitoring

Of the four data streams I had to prepare, the **most challenging was the battery monitoring one**. For the GPS and DHT I used their libraries, so it was a trivial matter of calling the right functions. For the encoder I just incremented a counter and converted a period into rotation rate, grade school concepts really. 

Monitoring the batteries was more difficult though since this needed some more complex processing and there wasn't a library I could just drop in. First there was the obvious issue of converting an analog-to-digital (ADC) reading to an actual voltage, since the ADC return an integer between 0 and 4095, with 4095 corresponding to a reading matching the reference voltage supplied (roughly 3.3V). This conversion would then be compounded by the voltage division for each battery, that would vary slightly across the three dividers due to manufacturing tolerances. This needed me to calibrate the readings to a known voltage and store them on the chip. My final code for this looked something like:

```cpp
reading = float(analogRead(FBPin));   // Read ADC
reading = reading * divFactor;        // Multiply by resistor division factor to get the actual input
reading = reading / readingToV;       // Divide by constant to convert the ADC steps to actual volts
```

Knowing the battery's true voltage wasn't enought to determin the battery level since the voltage of the battery *does not* vary linearly with charge level. Each different battery chemistry has its own characteristic discharge curve. The discharge curve of an LiFePO4 battery I used is described [here](https://www.solacity.com/how-to-keep-lifepo4-lithium-ion-batteries-happy/). Note: the batteries referred to in the article use four (4) cells in series, the ones I was using only had three (3) so my voltages were all going to be 3/4 that of what was described there at the same charge level.

{{< fig src="/images/titan-v1-LiFePO4-discharging.png" caption="Discharge curve for a 4S LiFePO4 battery" >}}

To convert a voltage to a charge level, I would fit the voltage reading to the curve using linear interpolation between a set of key points.

```cpp
const byte level[] = {100, 99, 90, 70, 40, 30, 20, 17, 14, 9, 0}; // Percentages linked to voltages
const float voltage[] = {10.2, 10.05, 9.975, 9.9, 9.825, 9.75, 9.675, 9.6, 9.375, 9, 7.5}; // Voltages

// Run though set point from top to bottom
for (byte i = 1; i <= 11; i++) {
  if (reading > voltage[i]) {
    // If the reading is in the region
    float temp = 0; // Used in calculations

    // Linear interpolation formula
    temp = (reading - voltage[i]) * float(level[i - 1] - level[i]);
    temp /= float(voltage[i - 1] - voltage[i]);
    temp += level[i];

    reading = temp; // Stores the result in the reading variable
    break;
  }
}
reading = constrain(reading, 0, 100); // Constrain it to reasonable values

/* Other code */ 

return (reading);
```

#### Communication with RPis

Communication with the RPis was handled over a dedicated serial line for each. The general flow to communication is the RPi sending a message to the STM32, and then the STM32 responds accordingly. **The STM32 *never* initiates an exchange!** The structure of the message received by the STM32 followed this format:

> **1 character** - Message type (capital letters are for sending data, lowercase for requesting data)  
> **1 character** - Data length, ***n*** *(only if the RPi is sending data)*  
> ***n* bytes** - Data to STM32 *(if the RPi is sending data)*

If the RPi is requesting data for itself, it will simply send a lowercase letter for that field, e.g. "s" for speed. If it has data it wants to impart on the STM32 (to pass on to the other RPi), like the ANT+ data, it will start with a capital and be followed by the data length and data itself. E.g. "D!55" would be used to set the right cadence (D) as "55" which is 2 characters long ("!" has the ASCII code of 33, but I add/subtract 31 to the lengths to keep length characters printable since the first printable character is space, " ", at 32).

When the STM32 is responding with data to a request, it replies with just the data length and data itself (*no leading message type character*).

The reason I used a data length character as part of messages, rather than a fixed length or delimiting character to communicate message length is because it allows for greater flexibility than a fixed length, and it doesn't risk a delimiting character randomly occurring in exchanged data, misleading the RPi or STM32.

### Raspberry Pi Code

Unlike the STM32, the code for the RPis was written entirely in Python. I had a basis to work off of given the work done for Eta Prime, however I reworked much if it for various reasons. The main reasons for this refactoring were:

- Different hardware configuration (Eta Prime did not have a microcontroller to help with data collection)
- Different system needs, namely to share data across multiple RPis
- Migrating code between Python 2 and 3

#### Camera Feed

To put the camera feed onscreen and have it recorded was actually pretty simple and accomplished in less than a dozen lines of code thanks to the work of the Raspberry Pi Foundation.

```python
camera = picamera.PiCamera()
camera.resolution = (self.VIDEO_WIDTH, self.VIDEO_HEIGHT)
camera.framerate = self.FRAMERATE
camera.brightness = self.BRIGHTNESS
self.camera = camera
self.camera.start_preview()

# Setup recording file
self.RECORDING = recording # Record if recording or not
if recording:
    video_title = "{}.h264".format(time.strftime('%y%m%d-%H:%M:%S', time.localtime()))
    self.video_title = '/home/pi/Videos/recording-' + video_title
    self.camera.start_recording(self.video_title)
```

This code would put the video feed over the entire screen as a "preview", and start recording it to a fill if desired. The settings we could manage were a stable 720p HD video, at 60 frames per second.

#### Overlay

The overlay code needed a decent amount of rework, since a core library it depended on was written in Python 2. The library was specifically used to create the overlay image with all the data for the riders. Initially I wanted to replace it with something similar but capable of running in Python 3, however I was unable to find a suitable alternative at the time. **So instead I opted to run the entire system in Python 2 instead.**

Once I had the system working, I could produce a text overlay pretty simply. I would just place text boxes around the screen as I wanted and fill them with the text I desired with some basic properties defined. These text boxes were actually drawn on a temporary canvas/image, "img", initially.

```python
font = ImageFont.truetype("../res/consola.ttf", size)
draw = ImageDraw.Draw(self.img)
draw.text(position, text, color, font)
```

Once I was done drawing all the text I wanted on the canvas I would update the overlay with this canvas simply with:

```python
self.overlay.update(self.img.tobytes())
```

#### Communication with STM32

Communication protocol with the STM32 was outlined briefly in the STM32's [section on this](./#communication-with-rpis). The only thing worth mentioning on the RPi side of things is that the RPi's block (wait) the program until a response is received following a request. This is why the STM32 doesn't need to specify what its response is for, the RPi already knows.

#### ANT+

ANT+ was where a sizable chunk of my efforts went into. I found the amptly named "python-ant" library online and it supported operation on the RPi. Not only that but it had examples for a heart rate monitor and power pedal, the exact two devices I needed to operate!

I started by starting the network and then connecting to the devices using the USB dongle. Most of this was copied directly from the examples provided with the code.

```python
from ant.core import driver
from ant.core.node import Node, Network, ChannelID
from ant.core.constants import NETWORK_KEY_ANT_PLUS, NETWORK_NUMBER_PUBLIC
from ant.plus.power import *
from ant.plus.heartrate import *

device = driver.USB2Driver(log=None, debug=False, idProduct=0x1008)
antnode = Node(device)
antnode.start()
network = Network(key=NETWORK_KEY_ANT_PLUS, name='N:ANT+')
antnode.setNetworkKey(NETWORK_NUMBER_PUBLIC, network)

...

frontPWR.open(frontPedals, ANT_TIMEOUT)
print("Connecting front pedals")

frontHRM.open(frontHRM, ANT_TIMEOUT)
print("Connecting front HRM")
```

Working with these examples I looked at how they worked and gained a bit of understanding about Python callbacks since they are an integral part of how this library worked. Eventually I prepared my own, so that when a heart rate or power value was registered, the system would share it immediately with the rest of TITAN.

```python
# Functions for broadcasting data
def front_power_data(eventCount, pedalDiff, pedalPowerRatio, cadence, accumPower, instantPower):
    microController.sendData('E', str(instantPower))
    microController.sendData('C', str(cadence))
def front_heartrate_data(computed_heartrate, event_time_ms, rr_interval_ms):
    microController.sendData('A', str(computed_heartrate))

...

frontHRM = HeartRate(antnode, network, callbacks = {'onDevicePaired': hr_device_found, 'onHeartRateData': front_heartrate_data})
frontPWR = BicyclePower(antnode, network, callbacks = {'onDevicePaired': power_device_found, 'onPowerData': front_power_data})
```

All this was not peachy though. I had to make some adjustments to the library. These were probably due to me running it in Python 2 rather than 3, although it has been a few years so I forget the *exact* issues. Once I had the code to just gather a few devices of interest I developed code to run this as part of the TITAN system. For example I prepared a function to ensure that all devices were connected and alerting the riders if any failed to connect if they didn't.

Testing the code for these was some fun. To test the heart rate monitor I wore it and would either hold my breath or begin hyperventilating to observe a change. As for the power pedals I actually had an exercise bike I would pedal on for testing. We now have additional ANT USB dongles I could use to simulate the output of a device but I feel that it'll ruin much of the fun involved in the process.

#### Radio Communication

I initially wanted to get some telemetry working with the nRF24 modules I found, I even had some radio libraries ready, however I didn't have the time to properly develop or test any code related to this so it was never implemented.



## Outcome








