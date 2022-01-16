---
title: "ESC V1"
date: 2020-05-04T12:33:08-05:00
draft: false
started: "May 2020"
finished: "May 2020"
status: "Assembled, Never Used"
client:
tags: [ESC, embedded, BLDC, KiCAD]
skills: [embedded, KiCAD, BLDC]
summary: "My first attempt to make a sensor-less ESC for my drone"
githubLink:
thumbnail: 
---

# Overview

I decided to try and make my own quad-rotor drone from scratch to give myself a large project. One component of this 
is to make the *Electronic Speed Controller (ESC)* used for the rotors.

This design is based on ELECTRONOOB's work with his [open-source ESC](http://electronoobs.com/eng_arduino_tut91.php). 
This first version of my ESC was basically a replica of his work.

Although I designed the system and *[almost]* assembled a board, I never actually did anything with them beyond that because 
it was just a warm up for my second version and beyond.

## Requirements

- Operate with supply voltages between 9V and 20V
- Be able to supply 30A continuously
- Allow control over PWM and I2C

## Objectives

- Allow for RPM control
- Allow data to be extracted over PWM (e.g. current duty cycle)

## Takeaways

- This board was quite large and would barely fit on the frame I ordered. So I needed to shrink it down.

# Detailed Report

I was looking for an interesting project to bite into that would be both fun for me and cool to show off, even to 
non-technically inclined people (such as my mother), so I decided to try and make my own quad-rotor drone from scratch. 
As many would have you believe, the motors need to be accurately controlled for it to stay in the air. 

## Motor Theory

Although I wouldn't describe myself a great teacher, I will try my best to provide a basic overview of brush-less DC 
motor control theory.

An electric motor generally uses a set of permanent magnets and electrified coils to generate rotary motion. As current 
flows through a coil, a magnetic field is generated, this magnetic field will induce a force (torque) on the coil as it 
tries to align itself with the ambient magnetic field produced by the permanent magnets. Just before the fields reach 
alignment (and thus no more force will be imparted on the motor), the current is commutated so the fields generated are 
no longer about to align and the force continues to be imparted on the motor shaft. This cycle repeats as long as the 
motor is operating. The rotating assemble in the motor is called the *rotor*, the stationary assembly the *stator*.

<figure>
<img src="/images/esc-dc-motor-gif.gif">
<figcaption>Fig. 1 - An animation of a brushed DC motor. Courtesy of <a href="https://cecas.clemson.edu/cvel/auto/actuators/motors-dc-brushed.html">CVEL</a></figcaption>
</figure>

Basic DC motors use mechanical commutation methods like the brushes in the animation above. The motors used in most 
quad-copters, especially for high performance drones, are brush-less DC motors which are constructed differently and need 
a special controller to operate properly, generally called Electronic Speed Controllers (ESC). Their more complicated 
operation is a trade off for significantly increased power density, vital for flight.

Instead of having the coils attached to the rotating shaft to induce force on it due to the fixed ambient field from the 
permanent magnets, they reverse this setup and have the motors on the shaft and windings stationary. Thus no brushes are 
present and the motors are instead controlled using a three phase scheme. To do this the voltage on one of the wires must 
pulled low, and high on another, while the third one is disconnected from either extreme. The supply of power must be 
quickly and reliably changed to generate the needed rotation. This supply of power and commutation timing is what is 
handled by the ESC.

<figure>
<img src="/images/esc-bldc-motor.gif">
<figcaption>Fig. 2 - An animation of a brush-less DC motor. Courtesy of <a href="https://www.embitel.com/blog/embedded-blog/brushless-dc-motor-vs-pmsm-how-these-motors-and-motor-control-solutions-work">embitel</a></figcaption>
</figure>

Since most motors used on drones are meant to be compact and cheap, they usually lack any sensors on them to aid the 
controller in properly knowing the position of the rotor, thus when it is optimal to commutate. However, there is a trick 
that can be employed to derive the position of the rotor! Due to the generally rapid rotation of the rotor, there is a 
**back electro-motive force (BEMF)** exerted on the coils in the stator, which can be monitored using the disconnected 
phase of the motor.

When disconnected from power the voltage on a phase will start at the voltage it was last supplied, as the rotor rotates 
the voltage will gradually change to approach the other extreme at which point it will need to switch to that supply. 

<figure>
<img src="/images/esc-bldc-timing-chart.png">
<figcaption>Fig. 3 - Timing chart showing a basic BLDC rotation with the voltage on (dotted line) and current through (solid) each phase marked. Figure 9 of <a href="https://www.ti.com/lit/an/sprabq7a/sprabq7a.pdf?ts=1642166596205">TI Application Report SPRABQ7A</a></figcaption>
</figure>

One generally finds it easiest to use the moment the voltage on this disconnected phase crosses the average voltage of all 
phases (also called the "zero" voltage) using a comparator to know when the rotor is halfway through the step and time the 
next commutation based on the time elapsed since the most recent phase change to reach that midpoint-crossing.

## Circuit Design

I started this design based on ELECTRONOOB's work with his [first ESC](http://electronoobs.com/eng_arduino_tut91.php) 
but primarily his [third version](https://youtu.be/-ymTE-Nivzw). This first version of my ESC was largely a replica 
of his work, with only a few tweaks related to the MOSFETs and the driver I selected.

The circuit design was basically taken from his first version, with the modifications made to basically feature match his 
third version. This meant removing the parts related to the USB and the buzzer. In addition some parts relating to the 
MOSFETs were changed to ones I could readily find.

<figure>
<img src="/images/esc-v1-schematic.svg">
<figcaption>Fig. 4 - The completed schematic for the ESC V1 (PDF version: <a href="/pdf/ESC_V1.pdf">Colour</a> / <a href="/pdf/ESC_V1_BW.pdf">BW</a>)</figcaption>
</figure>

### Brains

The heart of the system is the ATmega328P, in the TQFP-32 form of Arduino Nano fame. This chip is responsible for all the 
control of the system, it will receive commands over PWM or I2C and direct the MOSFET driver accordingly. It is also used 
for detecting the zero-crossings using the internal comparator and some external resistor arrays to divide the voltages 
from the motors down to a safe level for the Atmega328P as well as averaging them for a "zero". It is configured to be 
programmable using a generic serial programmer from the like of FTDI like a normal Arduino Nano.

There are a set of solder jumpers to be used to configure the ESC without needing to reprogram it: the default rotation 
can be reversed with a jumper, and the I2C address the ATmega will take.

### Inverter (Motor Control)

Motor control is handed by a three phase inverter made of [TPN2R903PL](https://toshiba.semicon-storage.com/us/semiconductor/product/mosfets/12v-300v-mosfets/detail.TPN2R903PL.html) 
N-channel MOSFETs, driven by a single [FAN7888](https://www.onsemi.com/products/power-management/gate-drivers/fan7888) 
MOSFET driver IC that receives control signals from the ATmega. 

N-channel MOSFETs are used on both sides of the bridge due to their lower "on" resistance. To drive the high-side FETs 
requires "bootstrapping" to get a gate voltage higher than the drain (VBAT) for optimal performance. This process is 
handled by the FAN7888 and a capacitor and diode for each phase (D1-D3, C2-C4), resistors are recommended but not required 
(RN3).

*Bootstrapping* in this application is the process of changing a capacitor between ground and the supply voltage, then 
disconnecting it on both ends. Then connecting the capacitor terminal that was previously connected to ground, to the supply 
rail. Since the potential across the capacitor has not been changed, the potential at the positive side is now twice that of 
the supply rail relative to ground. This is then routed to drive the gate of the high side MOSFETs. *The FAN7888 does not 
actually switch the connections on the low side of the bootstrapping capacitor*, it has that constantly connected to the 
source of the MOSFETs (phase output), but it achieves the same effect and is useful for a few other reasons such as avoiding 
potentially exceeding the gate-source voltage.

### 5V Regulator (Battery Elimination Circuit)

A 5V buck regulator is used to supply the microcontroller with power from the battery input. Although the individual draw of 
the microcontroller on the ESC is well within what could be reasonably provided by a linear regulator, thus saving space on 
the board and reducing system cost, I decided to use the buck regulator to allow the 5V from an ESC to be used as a common 
rail to *efficiently* power other drone systems instead having to design a 5V regulator into each.

## Board Layout

I laid out the circuit on a board that I arbitrarily set to be 65mm x 35mm. In order to decrease the size I had the output 
stage of the circuit on one side and the remainder of the electronics on the other. All power lines are t be soldered on 
their designated pads/exposed traces. Along the right edge of the figures there is a large exposed pad for the two power 
rails, this was done to easily allow the soldering of buffer capacitors along this edge as needed.

<figure>
<img src="/images/esc-v1-combined-layout.png">
<figcaption>Fig. 5 - The overall layout of the board</figcaption>
</figure>

The output stage was put all on one side for simplicity and because given the powerful nature of the components, they were 
generally bulkier, as well as the traces. I designed all the power traces to be 5mm wide to carry upwards of 10A without 
exceeding a 20°C rise in temperature with 1oz. copper (~35um) (on the drone they will be positioned under the propellors 
which should aid with cooling. In addition to their width, I exposed the power traces to allow easier soldering of wires 
to them as well flooding them with solder to increase their current capacities.

<figure>
<img src="/images/esc-v1-top-layout.png">
<figcaption>Fig. 6 - The layout of the output stage side</figcaption>
</figure>

The remainder of the system (control and voltage regulator) were housed on one shared side. The 5V buck regulator was nested 
between the ground and +5V pads on the left part of the board, with distinct thicker traces for the power into and out of it 
to carry the up to 1A at 5V without issue. The remainder of the side was used for the control part of the system.

<figure>
<img src="/images/esc-v1-bottom-layout.png">
<figcaption>Fig. 7 - The layout of the control and voltage regulator side</figcaption>
</figure>


## Assembly

Assembly wasn't too notable, other than being my first set of SMT board to have components on both sides. This required me 
to prop up the edges of the board so it would not be resting on the components and be level for when I was applying the 
solder paste using the stencil. Since I was ordering and assembling V1 and V2 of the ESCs and Flight Computers together, I 
ordered a stencil that had a portion for each of them.

One thing I did mess up during assembly is when ordering the resistor arrays I accidentally ordered the wrong size - 
*twice*. This is partially why I never tested these boards, although I could have easily fit through-hole resistors in their 
place like I did with my [gameBOI](/projects/personal/gameboi).
