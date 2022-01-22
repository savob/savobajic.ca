---
title: "ESC V5"
date: 2021-08-20T01:46:25-05:00
draft: flase
started: "August 2021"
finished:
status: "Designed, waiting for boards to arrive"
client:
tags: [ESC, embedded, BLDC, drone]
skills: [embedded, KiCAD, BLDC]
summary: "Newest revision to the ESC. Largely design to use the available MOSFET drivers"
githubLink:
thumbnail: "/images/esc-v5-combined-layout.png"
---

# Overview

I need a new revision of my ESC to accommodate the replacement MOSFET drivers I was able to source. I will also use this as 
an opportunity to fix some of the minor inconveniences I face with V4.

Currently still finalizing the board and hope to order it in the coming weeks.

## Takeaways

None so far, project is still to be designed, let alone tested.

# Detailed Report

This revision was started because I had run out of functioning parts during the testing of V4 and the IC shortage has forced 
me to select an alternative MOSFET driver, the [IRS2334S](https://www.mouser.ca/datasheet/2/196/Infineon-IRS2334-DataSheet-v01_00-EN-1228568.pdf) 
from International Rectifier as the replacement for the FAN7388s and FAN7888s I was using until then.

My goal is to keep the board as similar to V4 so that my code doesn't have to be significantly altered and I can focus on 
getting the motors to work.

## Circuit Design

Circuit design is basically the same as [V4](../esc-v4/#circuit-design) with only a few minor changes.

- Replaced the FAN7388/FAN7888 MOSFET driver with the IRS2334S
- Removed the unnecessary resistor on the UDPI line (R2 in V4's schematic)
- Rearranged the MOSFET driver signals such that all the low side signals are on one port. (Done to simplify/optimize coding for commutations)
- Added a status LED on the last unused pin

<figure>
<img src="/images/esc-v5-schematic.svg">
<figcaption>The completed schematic for the ESC V5 (PDF version: <a href="/pdf/ESC_V5.pdf">Colour</a> / <a href="/pdf/ESC_V5_BW.pdf">BW</a>)</figcaption>
</figure>

## Layout

Laying out the board I wanted to try and keep the part placements identical to V4's so I could reuse the same solder paste 
stencil, this is a major reason why I choose the IRS2334S since it came in the same package as the FAN7x88s. Other than the 
addition of the status LED, I was able to leave all components in their place and seat the new ones in place of removed ones 
(R2 where old R2 was, and the MOSFET drivers).

Routing traces was a bit harder than expected since I didn't want to redo the entire thing from scratch. As a result, I 
spent a good portion of my routing seeing how close I could squeeze some traces and vias.

<figure>
<img src="/images/esc-v5-combined-layout.png">
<figcaption>The overall layout of the board</figcaption>
</figure>

The top side of the board houses the MOSFET driver circuitry on the left half and the feedback network on the right.

<figure>
<img src="/images/esc-v5-top-layout.png">
<figcaption>The layout of the top side</figcaption>
</figure>

The bottom of the board is where the control section and MOSFETs are located. I added the status diode between the address 
pads and R2 on the left.

<figure>
<img src="/images/esc-v5-bottom-layout.png">
<figcaption>The layout of the bottom side</figcaption>
</figure>

## Assembly

I have already ordered and recieved the components I need for this project. All that I need to do is order the boards and 
to get to it.

## Outcomes

Nothing really yet.
