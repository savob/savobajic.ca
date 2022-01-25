---
title: "Drone Flight Controller"
date: 2020-04-01T20:17:17-05:00
draft: false
started: "May 2020"
finished:
status: "Programming, focusing on ESC"
client:
tags: [drone, imu, controls]
skills: [KiCad, c++, embedded, control]
summary: "Making a a custom flight controller for my drone to work with my custom ESCs and potentially other electronics."
githubLink:
thumbnail: "/images/flight-controller-thumbnail.jpg"
---

# Overview

As part of my project to make a quadcopter from scratch I need a flight controller to control it in flight and receive 
instructions from me. Overall this board would have four over responsibilities:

1. Communicate with the ESCs for the motors
2. Read sensor data to determine that state of the drone
3. Receive commands from the controller
4. Apply control algorithms to adjust the drone's behaviour accordingly

To achieve these, a microcontroller was put on a board as well as the basic sensors needed for a drone (accelerometer 
and gyroscope) with breakouts to connect to the ESCs and the radio module.

There are two main revisions, the original ATmega328P based one, and a second STM32F103 based one.

I intend to write as much of the code related to the drone controls as I can, although I am prepared to revert to an 
established open-source standard such as [BetaFlight](https://betaflight.com/) and the like.

Although I have prepared the boards and done some basic tests, I plan to leave off most of the coding until I have 
functioning ESCs to allow the drone to fly and better test control systems.

## Requirements

- Communicate with the ESCs over I2C
- Have a sensor to monitor linear and rotational accelerations
- Have a way of receiving instruction wirelessly
- Maintain the stability of the drone

## Objectives

- Monitor the altitude of the drone
- Be able to send data back to the controller
- Allow for additional features to be added later

## Takeaways

Not too many so far really, other than the benefits of using a proper IDE for larger projects. 

Will probably have more once I get coding them properly.

# Detailed Report

The brain of a drone is generally called a flight controller and a drone is little more than four stupidly powerful motors 
attached to a minuscule frame without one. This flight controller is responsible for not only receiving commands from the 
pilot but also stabilizing the drone given feedback from sensors, namely Inertial Measurement Units (**IMU**) that keep 
track of the accelerations the drone experiences and thus can be used to construct an idea of the drone's orientation and 
speed.

Although there are commercial flight controllers available on the market I wanted to try my hand at making one from scratch 
to see the effort that goes into it, as well as allowing myself to tailor it to my desires, most notably digital control 
of the ESCs. I would also like to retain flexibility for future uses such as a fixed wing aircraft.

So far I have made two similar versions, save the microcontroller at the heart of them. I am primarily focusing my efforts 
on developing the second one as it has the more capable microcontroller so I should be able to get more out of it in the 
long run. 

I intend to try and code them entirely, although I may likely make concessions to using publicly available libraries to 
interface with the modules in the system so I may focus on the more application specific aspects of coding. I am also 
aware of projects such as [ArduPilot](https://ardupilot.org/) and [BetaFlight](https://betaflight.com/) that I could try 
to get working on my flight controller to simplify the development process if I find it too difficult.

## Shared Electric Design

Although each revision is based around a different microcontroller, the majority of the systems around them are the same 
across versions.

### Power Supply

Both boards have built in linear regulators to generate the voltages needed to run the microcontroller and the sensors on 
board. They also both carry banks of decoupling capacitors for the regulator and most integrated circuits present.

### Communication

THe method of communication I intend to use on these boards is digital communication at 2.4GHz provided by standalone 
nRF24L01 modules from Nordic Semiconductors. These house all the radio black magic on a separate board that is interacted 
with over SPI from the main microcontroller. I gained familiarity with these from my telemetry work for HPVDT. In addition 
to the SPI pins shared between the microcontroller and the module, there is a line used to flag the flight controller of a 
received transmission which I have prepared to be used as an interrupt on the flight controller.

These modules I have purchased are rated for low bandwidth (~1 kb/s) at ranges of around 1km with direct line of sight. 
This is good for me as I intend to operate this drone (for now) exclusively with direct line of sight and up to a few 
hundred meters at most.

### Sensors

There are two primary sensors ICs on each board use I2C to communicate with the microcontroller. They are the IMU and 
barometer. This I2C bus needs to be operated at 3.3V since both chips operate at this level. Thi requires a level shifter 
from the 5V I2C bus for the ESC to these.

#### IMU

The boards use the same inertial measurement unit, an [ICM-20600](https://invensense.tdk.com/products/motion-tracking/6-axis/icm-20600/) 
which monitors six axes of motion: linear and rotational acceleration around the three Cartesian axes (X, Y, Z) relative 
to the IC. They are capable of monitoring ±16g of acceleration and ±2000°/sec of rotation at their full scale, but this 
can be decreased in exchange for improved accuracy in the measurements.

These will be used to help the drone deduce its current orientation based on the integrals of these readings. 

#### Barometer 

Each board has a barometer designed into it, the [BMP280](https://www.bosch-sensortec.com/products/environmental-sensors/pressure-sensors/bmp280/) 
which is used to monitor the ambient pressure and thus help estimate the altitude of the drone so it can maintain it.
It is accurate to under a meter and lower with the right algorithms so it will hopefully be helpful when navigated 
closed spaces.

### Extra Inputs/Outputs

In the interest of keeping my design flexible for future use I have broken out many of the otherwise unused pins on my 
microcontrollers to headers that I can easily connect to later. For example I could use these to control lights on my 
drone(s) or actuators.

### Programming and Debugging 

I left headers for the microcontrollers to be easily programmed using their designated protocols as well as the using 
the standard Arduino-esque bootloader and USB to Serial adapter which is handy for sending detailed debugging data to 
the controller even when not used for programming.

# Versions

Below is a list of my different versions of my flight boards. Their logs will contain the information specific to them 
such as my motivation for making them as I did and the differing hardware.
