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

<figure>
<img src="/images/blueshift-render.jpg">
<figcaption>A render of the Blueshift's internal layout</figcaption>
</figure>

## Requirements



## Objectives



## Takeaways


Made a [hypothetical V4 schematic](#version-4) to address the circuit issues and improvements I identified.

# Detailed Report



## Overall Design



## Electrical Design

I had a teammate interested in helping with the project, so I had them prepare a design block for the new light driver 
circuit I wanted to implement. Other than these blocks, the rest of the circuitry is my own design.

The third iteration of the design is what we committed to using in Blueshift.

<figure>
<img src="/images/blueshift-v3-schematic.svg">
<figcaption>The completed schematic for the Blueshift V3 (PDF version: <a href="/pdf/blueshift-v3.pdf">Colour</a> / <a href="/pdf/blueshift-v3-BW.pdf">BW</a>)</figcaption>
</figure>


## Layout

My teammate had prepared the layout for the light drivers as part of her work to make the design blocks for them. Other than 
those, the rest of the layout I did myself.

<figure>
<img src="/images/blueshift-v3-layout-combined.png">
<figcaption>The combined layout</figcaption>
</figure>

<figure>
<img src="/images/blueshift-v3-layout-front.png">
<figcaption>The front layout</figcaption>
</figure>

<figure>
<img src="/images/blueshift-v3-layout-back.png">
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

In the end the board came out as so.

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

## Testing


## Programming


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
