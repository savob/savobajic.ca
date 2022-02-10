---
title: "Blueshift"
date: 2019-10-08T17:07:58-05:00
draft: true
started: "October 2019"
finished: "March 2019"
status: "Completed, never used."
client: "HPVDT"
tags: [embedded, rpi, c++, HPVDT]
skills: [EAGLE, c++, Arduino]
summary: "Created the electronics system for what would have been our ASME 2020 race bike entry. *A combination of TITAN and Zephyr.*"
githubLink:
thumbnail: "/images/blueshift-v3-assembled-modules.jpg"
---

# Overview

For our team's entry to the ASME 2020 human powered race event we wanted to try an experimental tricycle layout we had not 
yet used with the rider fully recumbent between the rear wheels. Since the rider's vision would be obstructed by both the 
structure (and their own body even if there was no fairing), this vehicle needed a vision system akin to our speed bikes, 
the most recent before this project being [TITAN](../titan-v1), with road worthy features expected of ASME bikes like 
[Zephyr](../zephyr).

<figure>
<img src="/images/blueshift-render.jpg">
<figcaption>A render of the Blueshift's internal layout</figcaption>
</figure>

As a result this project was largely focused on melding these two projects together and addressing the issues they had, 
rather than developing new or novel systems. One major difference is the addition of additional viewing angle for the rider 
although they were meant to be simple.

I lead a team with a few other teammates to develop this system. I focused on the holistic design of the system with the 
teammates contributed certain components they were interested in working on.

**In the end the system was prepared, however due to the COVID-19 pandemic and team decisions that followed; Blueshift was 
not completed so this system's true performance will not be known.** It did however prove to be a useful exercise for all 
team members involved with lessons applicable to many future projects for HPVDT.

## Requirements

- Provide one front facing video feed, overlaid with vehicle data
- Provide additional views without an overlay:
   - Left and right sides (can be "wall-eye" perspective)
   - Rear view (can be "wall-eye" perspective)
- Collect the following data to display
   - Wheel speed
   - Cadence
   - Battery level
- Control four sets of lights
   - Front
   - Rear
   - Left/right turning indicators (blink at about 1Hz)

## Objectives

- Gather and relay the following data to the rider
   - Rider heart rate
   - Ambient temperature and humidity
- Stream data to pit over telemetry
- Record video feed
- Log all collected data

## Takeaways

Unit tests are the right way to test systems, especially novel ones. Had I not incrementally tested the power protection 
systems on their own, I would have likely damaged - if not flat out destroyed the connected modules as I learned they failed 
to perform as I hoped.

Designing the system as a RPi HAT brought many advantages and should be used for future RPi-based projects (*cough cough 
TITAN*)

Made a [hypothetical V4 schematic](#version-4) to address the circuit issues and improvements I identified.

# Detailed Report

For our team's entry to the ASME 2020 human powered race event we wanted to try an new tricycle layout for the team that we 
had not yet used with the rider fully recumbent between the rear wheels. The rider's vision would be obstructed by both the 
structure and their own body even if there was no fairing, so this vehicle needed a vision system akin to our speed bikes, 
the most recent one being [TITAN](../titan-v1) at the time - with road worthy features expected of ASME bikes like 
[Zephyr](../zephyr) added, namely the lighting.

There was going to be only one rider in this vehicles, but we wanted to have four views so they would have a better idea of 
their surrounds than in our speed bikes like TITAN. This is because our speed bikes race in time trials on their own, so we 
do not need to be worried about any other vehicles around us potentially colliding, so we only concern ourselves with seeing 
the road before us. For Blueshift, it would be racing concurrently with other vehicles so it would require a much wider 
field of vision around it for safe and effective operation in races. To this end we wanted one normal front facing camera 
(like a speed bike), a "wall-eye" camera on each side to check for obstacles, and then one rear-facing camera as well that 
could also be "wall-eye".

## Overall Design

The basic design of this started by using TITAN as a template; each view would be handled a separate Raspberry Pi (RPi) with 
their own display and RPi camera. However since all the views would be seen by the same rider, only one needed to be 
overlaid with data, the front-facing one since it would be their primary display.

Since the other three only needed a video display, and not necessarily a great one either since they were going to be used 
to check for obstructions, I decided to instead use **traditional analog cameras feeding directly into the displays**, no 
middle man. This brought several benefits: lower cost, simpler system both in hardware and software, smaller system volume, 
and lower power draw. The hardware I bought for this was a set of automotive backup camera displays and wide view drone 
cameras, both of which worked at 12V and had analog video interfaces.

This left the main display to be similar to TITAN, or really Eta Prime where there was only one display. This single RPi 
system would have a board of our that would help it monitor all the relevant information from the vehicle as well as control 
the lights we needed.

## Electrical Design

I had a teammate interested in helping with the project, so I had them prepare a design block for the new light driver 
circuit I wanted to implement. Other than these blocks, the rest of the circuitry is my own design. The third iteration of 
the design is what we committed to using in Blueshift. 

<figure>
<img src="/images/blueshift-v3-schematic.svg">
<figcaption>The completed schematic for the Blueshift V3 (PDF version: <a href="/pdf/blueshift-v3.pdf">Colour</a> / <a href="/pdf/blueshift-v3-BW.pdf">BW</a>)</figcaption>
</figure>

### Analog System Power

Other than the main Blueshift board there was a 12V regulator we designed to supply steady power to all three peripheral 
video systems. It was a simple board, using the reference design for a boost regulator to generate 12V from our battery's 
nominal 10V. Other than this regulator, there were only the connectors for each of the three cameras and displays to connect 
to and the battery to feed it. 

<figure>
<img src="/images/blueshift-analog-pdb-schematic.svg">
<figcaption>The completed schematic for the Blueshift V3 (PDF version: <a href="/pdf/blueshift-analog-pdb.pdf">Colour</a> / <a href="/pdf/blueshift-analog-pdb-BW.pdf">BW</a>)</figcaption>
</figure>

## Layout

*Note: the boards were originally laid out in EAGLE, they were imported into KiCAD to generate these figures. So there may 
be some small oddities present.*

My teammate had prepared the layout for the light drivers as part of her work to make the design blocks for them. Other than 
those, the rest of the layout I did myself.

The main thing to note with the layout of this system is that **it was designed to be a RPi HAT (Hardware Added on Top), 
that would be seated directly on top of the RPi** instead of connected by a ribbon cable to the RPi like TITAN V1 was. This 
was better because it decreased the footprint the system would occupy, as well as preventing potentially incorrect 
connections related to the use of a ribbon cable.

There is no general "flow" to the board, instead it is segmented by purpose. In the top right quadrant is where all the data 
processing occurs between the RPi and STM32 Bluepill. Beneath it, in the bottom right quadrant lie the nRF24 module and the 
power protection circuitry. To the left of the centre is where the main 5V regulator was, with the GPS module hanging over 
it. On the extreme left is where the LED drivers were.

<figure>
<img src="/images/blueshift-v3-layout-combined.png">
<figcaption>The combined layout</figcaption>
</figure>

All the parts were mounted to the top of the board.

<figure>
<img src="/images/blueshift-v3-layout-front.png">
<figcaption>The front layout</figcaption>
</figure>

The bottom is devoid of any parts, although I did make use of it to put notes related to the project on the silkscreen that 
was printed.

<figure>
<img src="/images/blueshift-v3-layout-back.png">
<figcaption>The rear layout</figcaption>
</figure>

I feel that this board is approaching the limit of complexity I can afford with only two layers. I need to get better or I 
will need to start making my boards larger to fit the traces I need should I want to avoid going to four-layer boards.

### Analog System Board

Given the simple circuit this was a small and simple board to layout and I did it myself.

<figure>
<img src="/images/blueshift-analog-pdb-layout-combined.png">
<figcaption>The combined layout</figcaption>
</figure>


<figure>
<img src="/images/blueshift-analog-pdb-layout-front.png">
<figcaption>The front layout</figcaption>
</figure>

<figure>
<img src="/images/blueshift-analog-pdb-layout-back.png">
<figcaption>The rear layout</figcaption>
</figure>

## Assembly

I did the assembly myself, a pretty standard mixed technology assembly. I would like to take a moment to admire what were up 
to this point my most complicated and interesting board I laid out.

<figure>
<img src="/images/blueshift-v3-board-top.jpg">
<figcaption>The printed circuit board from the top</figcaption>
</figure>

<figure>
<img src="/images/blueshift-v3-board-bottom.jpg">
<figcaption>The printed circuit board from the bottom</figcaption>
</figure>

*For once I actually stopped to take a picture partway through to show what the board looks like when parts are placed but 
are not soldered yet.*

<figure>
<img src="/images/blueshift-v3-pasted-parts.jpg">
<figcaption>The surface mount parts placed prior to reflow</figcaption>
</figure>

In the end the board came out nicely as shown in the figures that follow.

<figure>
<img src="/images/blueshift-v3-assembled-top.jpg">
<figcaption>The assembled board from the top</figcaption>
</figure>

<figure>
<img src="/images/blueshift-v3-assembled-bottom.jpg">
<figcaption>The assembled board from the bottom</figcaption>
</figure>

With all the modules mounted to it, and the board seated on the RPi with the camera cable coming through it looks like quite 
the little system. Would probably introduce me to some new friends if I tried to take it on an airplane.

<figure>
<img src="/images/blueshift-v3-assembled-modules.jpg">
<figcaption>Blueshift system with all modules and mounted to the RPi</figcaption>
</figure>

### Assembling the Analog Power

I ordered the parts for the analog video power board, however I never assembled one since it wasn't going to be used and had 
essentially no utility for the team outside of its purpose to power the analog cameras and displays.

## Testing

### Power Monitoring Tests

### Lighting Tests

### Data System Tests

### Telemetry Tests


## Programming

### Data Collection

### Data Exchange

### Telemetry

### ANT+ Collection

### Light Control

### Video Display and Overlay

## Outcome

Unfortunately near the end of the project just weeks before the competition, the COVID-19 pandemic began so the team had to 
halt the construction of the bike as we lost access to our campus facilities. (I was able to continue work on this since I 
was using my own tools and ordering everything to my address anyways). This was soon followed by the cancellation of the 
event.

After a change of leadership in the team, it was decided that we would not invest the time and resources into competing in 
ASME's competitions for the near future to instead focus on our projects aimed at breaking records instead. **This meant 
that Blueshift was not going to be completed,** and thus my system would never get to be tested or used properly.

Even so, it served as an excellent design exercise and let me figure out some things to bring to TITAN, notably with layout.

### Version 4?

I went back and prepared a new schematic to remedy most of my issues with the design of V3. The issues addressed were:

- Power protection circuitry issues I identified
- Moved the voltage divider for the auxiliary battery on board
- Added protection diodes for axillary battery level line

<figure>
<img src="/images/blueshift-v4-schematic.svg">
<figcaption>The schematic for a hypothetical V4 (PDF version: <a href="/pdf/blueshift-v4.pdf">Colour</a> / <a href="/pdf/blueshift-v4-BW.pdf">BW</a>)</figcaption>
</figure>

**Although this wouldn't be made, I still made this since when someone would look back on this project, be it myself or 
someone else - I would like this to be the schematic they draw from rather than the real but incorrect Blueshift schematic 
used.**
