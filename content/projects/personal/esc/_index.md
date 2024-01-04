---
title: "Drone ESC"
date: 2020-05-01T18:49:04-05:00
draft: false
started: "May 2020"
finished:
status: "In Progress"
client:
tags: [ESC, embedded, BLDC, KiCAD, drone]
skills: [embedded, BLDC, KiCAD]
summary: "Making a custom electronic speed controller for my drone's motors"
githubLink: "https://github.com/savob/esc"
thumbnail: "/images/esc-test-motor.jpg"
---

# Overview of the ESC Project

I decided to try and make my own quad-rotor drone from scratch to give myself a large project. One component of this is to make the *Electronic Speed Controller (ESC)* used for the each rotor's motor.

My designs were originally based on ELECTRONOOB's work with his [open-source ESC](http://electronoobs.com/eng_arduino_tut91.php). This first three versions of my ESC was basically a replica of his hardware. With the fourth onward, the hardware is completely my own.

Most of my software development for features was done with my second version. Initially I intended to use [ELECTRONOOB's code](http://electronoobs.com/eng_arduino_tut91_code1.php) however I needed to change it to match my hardware design and I noticed it wasn't commuting the motor correctly, so I ultimately decided to re-write most of it from scratch.

When I moved to my fourth revision I needed to re-write much of my code again because I made extensive use of hardware and registers that were different between the two microcontrollers.

***Current Status:* I am able to [control small motors]({{< ref "projects/personal/esc/esc-v5#motor-success" >}}) with the fifth version! However larger motors damage and eventually destroy my boards so I am redesigning my circuit to be able to handle the stresses imposed by larger motors.**

## Requirements

- Operate with supply voltages between 9V and 20V
- Be able to supply 30A continuously
- Allow control over I2C

## Objectives

- PWM control
- RPM control feature (over I2C)
- Allow data to be extracted over I2C (e.g. current duty cycle)

## Takeaways

- Mixed voltages and power levels need special considerations
- Having the right hardware capabilities goes a long way

# Motor Theory

Although I wouldn't describe myself a great teacher, I will try my best to provide a basic overview of brush-less DC motor control theory.

An electric motor generally uses a set of permanent magnets and electrified coils to generate rotary motion. As current flows through a coil, a magnetic field is generated, this magnetic field will induce a force (torque) on the coil as it tries to align itself with the ambient magnetic field produced by the permanent magnets. Just before the fields reach alignment (and thus no more force will be imparted on the motor), the current is commutated so the fields generated are no longer about to align and the force continues to be imparted on the motor shaft. This cycle repeats as long as the motor is operating. The rotating assemble in the motor is called the *rotor*, the stationary assembly the *stator*.

{{< fig src="/images/esc-dc-motor-gif.gif" caption="An animation of a brushed DC motor. Courtesy of [CVEL](https://cecas.clemson.edu/cvel/auto/actuators/motors-dc-brushed.html)" >}}

Basic DC motors use mechanical commutation methods like the brushes in the animation above. The motors used in most quad-copters, especially for high performance drones, are brush-less DC motors which are constructed differently and need a special controller to operate properly, generally called Electronic Speed Controllers (ESC). Their more complicated operation is a trade off for significantly increased power density, vital for flight.

Instead of having the coils attached to the rotating shaft to induce force on it due to the fixed ambient field from the permanent magnets, they reverse this setup and have the motors on the shaft and windings stationary. Thus no brushes are present and the motors are instead controlled using a three phase scheme. To do this the voltage on one of the wires must pulled low, and high on another, while the third one is disconnected from either extreme. The supply of power must be quickly and reliably changed to generate the needed rotation. This supply of power and commutation timing is what is handled by the ESC.

{{< fig src="/images/esc-bldc-motor.gif" caption="An animation of a brush-less DC motor. Courtesy of [embitel](https://www.embitel.com/blog/embedded-blog/brushless-dc-motor-vs-pmsm-how-these-motors-and-motor-control-solutions-work)" class="whiteBackground">}}

Since most motors used on drones are meant to be compact and cheap, they usually lack any sensors on them to aid the controller in properly knowing the position of the rotor, thus when it is optimal to commutate. However, there is a trick that can be employed to derive the position of the rotor! Due to the generally rapid rotation of the rotor, there is a **back electro-motive force (BEMF)** exerted on the coils in the stator, which can be monitored using the disconnected phase of the motor.

When disconnected from power the voltage on a phase will start at the voltage it was last supplied, as the rotor rotates the voltage will gradually change to approach the other extreme at which point it will need to switch to that supply. 

{{< fig src="/images/esc-bldc-timing-chart.png" caption="Timing chart showing a basic BLDC rotation with the voltage on (dotted line) and current through (solid) each phase marked. Figure 9 of [TI Application Report SPRABQ7A](https://www.ti.com/lit/an/sprabq7a/sprabq7a.pdf?ts=1642166596205)" >}}

One generally finds it easiest to use the moment the voltage on this disconnected phase crosses the average voltage of all phases (also called the "zero" voltage) using a comparator to know when the rotor is halfway through the step and time the next commutation based on the time elapsed since the most recent phase change to reach that midpoint-crossing.


# List of Versions

This project has been very iterative, and I have made a page for each revision to explain the intent of it and details related to it the main ones of interest being V2 and V4.

