---
title: "Composite Oven Control System"
date: 2021-06-01T23:29:55-04:00
draft: true
started: "June 2021"
finished:
status: "Needs board revision."
client: "HPVDT"
tags: [embedded, "user experience", hpvdt]
skills: [embedded, "user experience", KiCad]
summary: "Made a complete general oven controller for properly curing composites in our team's hand-made oven."
githubLink: "https://github.com/hpvdt/oven"
thumbnail:
---

# Overview

To properly cure most composites our team uses properly, a two step heating process is needed with a controlled temperature 
ramp between each stage. Most commercial oven controllers are designed to maintain a single constant temperature, so I made 
one specifically for the team.

This has been in worked on for a couple of years and this system is the third and hopefully last incarnation the team needs.
It was designed to fit inside a repurposed case and use screw terminals to connect to power, the heater, and a thermocouple 
for feedback. Inside the case is the screen for the user to interact with using the number pad on the outside.

The system *essentially* works, however due to some odd connectivity issues the temperature cannot be read using the current 
board design and a new board is needed to change the connections between the MAX6675 IC and the ATmega328P. Other than that 
the software is working properly.

Once I get the new board and assemble it *(and the team gets a working heater to control)* I will be able to do proper tests 
to verify the system's functionality.

## Requirements

- Monitor and maintain temperature to a target
- Allow users to input custom parameters for the temperature profile
- Contain everything needed inside one enclosure

## Objectives

- Convey to the user the present status of the curing

## Takeaways

Some errors just seem to defy explanation. This MAX6675 seems to poison SPI buses, and only works with GPIO bit-banging, not 
proper SPI busses. No clue why, but I guess I just have to deal with it.

# Detailed Report

HPVDT uses *a lot* of composites in all its projects. These composites have their shape held by epoxy, which we generally 
leave to cure at room temperature under vacuum conditions. For peak structural performance, and pre-pregnated composites a 
properly controlled heated curing or "bake" is required. This bake generally has two stages, defined by the following 
properties:

- Target temperature - How hot to keep it. Generally between 70 and 130 degrees Celsius.
- Hold time - how long to maintain this temperature.
- Rise rate - how fast to heat up the composite to reach the temperature. Typically a couple degrees a minute.

The problem for the team is that most (cheap) oven controller available commercially are designed to maintain a single 
temperature for a given amount of time. They do not care about the rise rate, nor can they do two stages. So I have been 
working on making a custom one for the last couple of years.

The software has largely remained the same since the first version, only adapting to the hardware changes between versions. 
Even the circuitry hasn't changed much, most of my work has gone into simply making the circuitry better suited to the 
production environment by fiting inside enclosures.

## Circuit Design

The heart of the system is essentially an Arduino Nano, since this is what I developed the previous systems for and it also 
has just the right amount of I/O and features needed for this project. It has headers to allow it to be programmed using 
either SPI or serial with a bootloader.

### User Interface

This was one of my first projects that was intended to be used by someone other than myself, and likely those that would not 
be thoroughly trained on how to use it, so making a simple user experience was necessary.

User input is handled by a simple 4 x 4 button pad, allowing them to use 10 buttons for entering digits, a decimal point, a 
backspace key, and then the last four to navigate up, down, left, and right through the menus. The main output to the user 
is a 20 by 4 character LCD display which uses a series of descriptive menus/forms to allow the user to set the oven's 
behaviour and then progress.

### Temperature Monitoring and Control

In my earliest iterations I had intended to use NTC thermistors to monitor temperature. However these proved to be very 
unreliable and inaccurate at the higher end of our temperature range as they approached their rated limits. For this reason 
I wanted us to move to using a a thermocouple system with an IC specifically to handle the analog to digital conversion for 
me. In the end I settled on using the familiar MAX6675 IC to monitor temperature with a K-type thermocouple, allowing us to 
monitor temperatures between 0 and 1024 degrees Celsius to within 0.25 degrees!

To control the heater I used a commercial solid state relay to cut or provide power to the heater. This wouldn't really 
allow me to implement some high-end PWM modulation of the heater but it was certainly enough for what we were trying to do. 
All it needed from the microcontroller is a simple on/off digital signal.

### The Resulting Schematic

Combining all these parts into one schematic produces this. Note that I have added connections for a USB charger to provide 
the system 5 VDC from 120 VAC, as well as a grounding connection for the metal enclosure used.

<figure>
<img src="/images/oven_schematic.svg">
<figcaption>The original schematic for the oven (PDF version: <a href="/pdf/oven.pdf">Colour</a> / <a href="/pdf/oven_bw.pdf">BW</a>)</figcaption>
</figure>

## Layout

This board was pretty simple to layout thanks to the rather simple circuit. However this board had to fit inside the 
enclosure so I made sure to place the mounting holes and edges first before I began laying out my components, lest I be 
forced to relocate them later.

**This was my first time designing a board to have 120V running on it**, which was honestly a little frightening at first 
since I was worried about trace spacing, and other potential issues like accidental shorts in assembly. I kept these high 
voltage traces in their own region of the board, clearly indicated and segregated from the low-voltage control system.

<figure>
<img src="/images/blueshift-render.jpg">
<figcaption>A render of the Blueshift's internal layout</figcaption>
</figure>


## Assembly

Unlike most of my other projects where assembly starts and ends with the circuit board, this one had me integrate not only 
external (off-board) components, but also fit them all sensibly within an enclosure.

## Testing

### Power Test

### Programming

### Display and Interface

### Temperature Reading

### Curing Performance

Unfortunately due to the issues with reading temperature on the current board, I cannot use the system to cure some 
composites. It doesn't help that the team broke our heater anyways so we need a new one.

# Revision

<figure>
<img src="/images/oven_v2_schematic.svg">
<figcaption>The revised schematic for the oven (PDF version: <a href="/pdf/oven_v2.pdf">Colour</a> / <a href="/pdf/oven_v2_bw.pdf">BW</a>)</figcaption>
</figure>

Perhaps add a buzzer?

