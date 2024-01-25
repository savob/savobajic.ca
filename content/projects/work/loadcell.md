---
title: "Contact Sensor"
date: 2024-01-24T23:09:18-05:00
draft: true
started: "August 2023"
finished: "September 2023"
status: "Complete"
client: "EDL (Engineering Design Lab)"
tags: [embedded, "3d printing"]
skills: [embedded, miniaturization, KiCad]
summary: "Designed and programmed a custom contact sensor for use in a prototype 3D printer. **My first freelance contract!**"
githubLink:
thumbnail: "/images/loadcell-on-textbook.jpg"
---

# Overview

My first gig for freelance embedded design came through a friend whose employer, [EDL](https://www.engdesignlab.com/), needed someone to design a circuit to detect if there was contact on the print head for a new five-axis 3D printer they were designing - the [PLU5](https://www.plus5axis.com/). The project was framed pretty simply, almost like a classroom exercise: read in some strain gauges placed around the print head and output high signal if contact force is detected. In addition, it should allow for calibration after assembly and be small enough to fit inside a cavity in the print head.

{{< fig src="/images/loadcell-plu5.png" caption="The PLU5 printer." attr="EDL" attrlink="https://www.plus5axis.com/" >}}

I managed to accomplish all they asked for with a couple bonuses thrown in. The resulting board was 18&nbsp;by&nbsp;20&nbsp;mm with a depth less than 4&nbsp;mm owing to the low profile parts I selected *(other than the headers which intentionally extended out for ease of access)*  so it fit snugly in the allocated space. The contact sensor was able to update more frequently than they expected and I was able to automatically detect which communications protocol the board needed to use to communicate upstream so the basic digital, UART, and I2C protocols shared the same two pins!

{{< fig src="/images/loadcell-on-textbook.jpg" caption="A handful of contact detection boards" >}}

*Unfortunately the project is currently closed source, so I'll be rather light on the details of this project for the time being.*

## Requirements

- Read strain gauges placed around print head
- Convert strain gauge readings to 3D force vector
- Alert system over a digital pin if contact force was detected
- Accept a digital signal to tare/zero the sensor

## Objectives

- Allow for calibration after assembly
- Fit within a 22&nbsp;by&nbsp;20&nbsp;by&nbsp;4&nbsp;mm volume
- Have an RGB LED for status indication
- Allow for I2C and UART communications

## Takeaways

- Minaturation is fun but hard
- Nothing beats testing in real hardware
- Avoid having wires share holes on your board for easier assembly. *I did this for the strain gauge half-bridges and it was a bit of a headache to wrangle at times to hold both wires in at once for soldering.*
- **Always check your microcontroller fuses!**
- Strain gauges are *very* well matched

# Detailed Report

A friend of mine was working at a company ([EDL](https://www.engdesignlab.com/) *(Engineering Design Lab)*) designing a new 3D printer, that would become the [PLU5](https://www.plus5axis.com/). Unlike many other 3D printers, it would be five-axis rather than three: the print bed can rotate and tilt while the print head moves relative to the print bed in X, Y, and Z. The reasoning for this was to allow for more advanced and efficient slicing methods to print things faster and cheaper by using less support material but also potentially more performant by using a more flexible infill strategy (rather than just stacking layer by layer which is vulnerable to delamination and other undesirable effects). *They explain it better on [their site](https://www.plus5axis.com/), please check it out!*

Since there 


# Circuit Design





In the end the boards I designed were within the bounds to be nested inside the print head without protruding at 18&nbsp;by&nbsp;20&nbsp;mm. I managed to put all the headers that needed to be accessed after installation (for communication and reprogramming) along one side and the headers for the strain gauges along the other

# Assembly and Testing

Assembling the boards was nothing too new to me, standard SMD assembly by hand. This was the first time I had assembled so many of the same board at once, since most of my projects have been one-offs or limited to only a couple as spares/replacements if needed. The client needed five functional boards since they were making five prototypes, so I ordered components for 10 boards to have some wiggle room. *Boy did I need it later on.*

{{< fig src="/images/loadcell-assembled.jpg" caption="Array of assembled boards ready for final assembly." >}}

Assembling 

{{< fig src="/images/loadcell-in-printhead.jpg" caption="Contact sensor board installed in a printer head prior to silicone pour." >}}

# Programming






# Debugging





# Outcomes

The project was completed in the nick of time and the client was incredibly satisfied! They were impressed with its performance on all fronts and had a fun time testing its responsiveness with their fingertip when it was all assembled.

{{< fig src="/images/loadcell-on-textbook.jpg" caption="A handful of contact detection boards **(again)**" >}}

I've made some revisions on the design based on issues I troubleshot and improvements for assembly I identified. *I hope the project goes well for them and I can work with them to get these revised designs manufactured en mass!*
