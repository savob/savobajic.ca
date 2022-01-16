---
title: "ESC V2"
date: 2021-05-05T12:33:12-05:00
draft: false
started: "May 2020"
finished: "August 2020"
status: "Complete"
client:
tags: [ESC, embedded, BLDC, KiCAD]
skills: [embedded, KiCAD, BLDC]
summary: "My first actual attempt at building an ESC. A shrunk down revision of the first."
githubLink:
thumbnail:
---

# Overview

This was my successful attempt at miniturizing my previous ESC, from 65mm x 35mm to 40mm x 25mm. It is completely 
electronically identical to V1.

Unlike V1 I actually went ahead and not only built one proper, but developed and ran code on it. Eventually actually 
managing to properly spin a BLDC motor, albeit only at 100% due to hardware contraints of the microcontroller used.

## Takeaways

- **I needed a revised board that enables proper PWM control of the inverter**
  - New microcontroller
  - New traces to suit the new microcontroller
- There are lots of ways to accidentally fry your own board when working with mixed voltages. To name a few:
  - Reversing polarity
  - Driving pins on unpowered chips
  - Shorting power rails
  - Inductive flyback
- I need to fix the programming interface for ISP over SPI

# Detailed Report

The goal of this revision was to miniaturize the previous version to something that would fit more easily into the drone's 
frame. So although the circuit remains the same, the layout was completely redone from scratch, using more compact versions 
of components.

The boards were purchased and assembled so development could be done with them. The code is where I started to really 
deviate from the work of [ELECTRONOOBS](http://electronoobs.com/eng_arduino_tut91_code1.php) that I was following. I ended up 
rewriting much of his code to suit my system (I changed the purpose of some pins on the ATmega) and my desires (e.g. I2C). 
**I then made significant alterations to his code to correct his handling of zero-crossings and commutations!**

In the end I was able to achieve most of what I had set out to. However 

## Circuit Design

Since this is the same as V1, please refer to [its section](/projects/personal/esc-v1/#circuit-design) on the circuit's design

<figure>
<img src="/images/esc-v2-schematic.svg">
<figcaption>Fig. 1 - The completed schematic for the ESC V1 (PDF version: <a href="/pdf/ESC_V2.pdf">Colour</a> / <a href="/pdf/ESC_V2_BW.pdf">BW</a>)</figcaption>
</figure>

***Note: there is a connection from the RST on the ISP header (pin 5 - J1) directly to RESET on the ATmega (pin 29 - U1) 
that was not present in V1 or V2.*** This was put in to reflect the bodge wire I needed to use so they would bypass C8 on the 
board, hence why this schematic is revision **2.1**, not 2. (The appending letters change on U1 are just to designate package, 
it remains the same internally (ATmega328P).

## Layout


<figure>
<img src="/images/esc-v2-combined-layout.png">
<figcaption>Fig. 2 - The overall layout of the board</figcaption>
</figure>

The output stage was put all on one side for simplicity and because given the powerful nature of the components, they were 
generally bulkier, as well as the traces. I designed all the power traces to be 5mm wide to carry upwards of 10A without 
exceeding a 20°C rise in temperature with 1oz. copper (~35um) (on the drone they will be positioned under the propellors 
which should aid with cooling. In addition to their width, I exposed the power traces to allow easier soldering of wires 
to them as well flooding them with solder to increase their current capacities.

<figure>
<img src="/images/esc-v2-bottom-layout.png">
<figcaption>Fig. 3 - The layout of the output stage side</figcaption>
</figure>

The remainder of the system (control and voltage regulator) were housed on one shared side. The 5V buck regulator was nested 
between the ground and +5V pads on the left part of the board, with distinct thicker traces for the power into and out of it 
to carry the up to 1A at 5V without issue. The remainder of the side was used for the control part of the system.

<figure>
<img src="/images/esc-v2-top-layout.png">
<figcaption>Fig. 4 - The layout of the control and voltage regulator side</figcaption>
</figure>

## Coding



## Testing

<iframe width="560" height="315" src="https://www.youtube.com/embed/1bNdviOC-_0" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

