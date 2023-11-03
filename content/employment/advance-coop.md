---
title: "Advanced Co-op"
date: 2018-05-03T01:11:10-05:00
draft: false
period: "May 2018 - August 2018"
company: "IGB Automotive"
summary: "Focused on developing novel quality assurance testing schemes for an automotive component supplier."
points: ["Integrated a force regulation system into legacy robotic arm systems for use in seat durability testing. This system was an expanded version of my previous work going from regulating a single axis of force to six, so a controlled path can be followed adapting to regulate force and torque at each point.", "A PLC to computer interface was created using a National Instruments data acquisition unit that was operated using a LabVIEW program on the computer using an emulated a serial communication protocol.", "Trained technicians to operate and configure the durability testing system, allowing tests to be tailored to the needs of specific clients.", "Prepared technical documents detailing system operation catered to different levels of users for the system.", "Contributed code to improve the flexibility of our end of line product testers so they could be easily reconfigured for new clients and products."]
---

*Small note: the actual title of this position was "Advance Co-op" since I worked for the "Advance" department which was responsible to "advance" our technologies. However, I have listed it as "Advance**d**" since everyone seems to think of it as a spelling mistake at first glance.*

# Overview

This was my second tour of work at IGB Automotive, and my work continued in the same vein as it did previously: developing internal end-of-line (EOL) testing equipment and procedures. In summary:

- Integrated a force regulation system into legacy robotic arm systems for use in seat durability testing. 
This system was an expanded version of my previous work going from regulating a single axis of force to six, so a controlled path can be followed adapting to regulate force and torque at each point.
- A PLC to computer interface was created using a National Instruments data acquisition unit that was operated using a LabVIEW program on the computer using an emulated a serial communication protocol.
- Trained technicians to operate and configure the durability testing system, allowing tests to be tailored to the needs of specific clients.
- Prepared technical documents detailing system operation catered to different levels of users for the system.
- Contributed code to improve the flexibility of our end of line product testers so they could be easily reconfigured for new clients and products.

# Main Work

Unlike my previous term where I jumped between several smaller projects, basically picking up projects that didn't require much commitment; this time I focused on two main projects in parallel:

1. Develop a multi axis [force feedback robot]({{< ref "projects/work/force-feedback" >}}) by expanding on the [kneeload robot]({{< ref "projects/work/kneeload" >}}) I developed the summer prior.
2. Aid in the integration and assembly of custom EOL tester for use with all products.

My effort was split roughly 70/30 between them - favouring the robot, since I was the only one working on that project while there was a whole team for the EOL system. Both these projects taught me the importance and methods needed to ensure that a system is scalable and also easy to use for a non-technical end user.

### EOL Testers

For the EOL testers I helped mostly in organizing the codebase which was entirely in LabVIEW. I did help somewhat with some of the assembly of units but not their electrical design.

The novel code I contributed focused on enabling the system to respond correctly to changes in hardware configuration, other than that I helped resolve issues scattered across the entire programm and reorganize the pictographs and make use of more optimal LabVIEW structures. For example, instead of nesting `if...else...` blocks I would migrate to a `case` block, which was lent itself to easier extension.

### Force Feedback

The main project for this term, I would develop my single axis feedback system for the [kneeload robot]({{< ref "projects/work/kneeload" >}}) into a multi-axis [force feedback robot]({{< ref "projects/work/force-feedback" >}}) to perform ingress-egress durability testing.

{{< fig src="/images/ff-body.png" caption="The ingress-egress robot" >}}

The difference between these tests sounds simple, in the kneeload test one only had to consider the linear force applied by the end-effector at a series of points. For the ingress-egress test, the robot had to follow a controlled path to emulate a person entering and exiting the seat, with certain forces required at certain key points in the motion.

The fundamental change was easy to implement, monitoring additional force values. However there were several changes that stemmed from this and other project requirements that required more effort to address:

- Needed more data bandwidth between robot and host PC - *achieved through a software serial protocol*
- Developing a system to easily change between different testing profiles and making it easy to add new ones
- More thorough training for new operators given the more complicated test

This project is covered in more detail in my [write up]({{< ref "projects/work/force-feedback" >}}).
