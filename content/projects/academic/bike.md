---
title: "Mountain Bike Suspension"
date: 2018-10-04T17:20:32-05:00
draft: false
started: "October 2018"
finished: "November 2018"
status: "Completed"
client: "MIE301, Kinematics and Dynamic of Machines"
tags: [matlab, kinematics, vehicle, optimization]
skills: [MATLAB, optimization]
summary: "Developed a kinematic model in MATLAB to perform a design optimization of a mountain bike suspension system."
thumbnail: "/images/bike-render.png"
---

# Overview

I worked on a team to contribute a MATLAB model and simulator for a four-bar mechanism to design a new mountain bike suspension system.

{{< fig src="/images/bike-render.png" alt="Render of the final bike design" caption="A render of the final bike design" >}}

## Requirements
- We had to at the minimum double the travel of the rear wheel from 140mm to 280mm
- All simulation and modelling had to be done in MATLAB
- Add provision for the charging of a phone or similar device from energy dissipated by the system

## Objectives
- Implement a "progressive" suspension response. The intitial displacement would be easy, but an equivalent 
increment towards the end of the suspension stroke would be more difficult

## Takeaways

I gained significant MATLAB practice with this. I especially developed the ability to have MATLAB sift through large sets of data and experimented with parallelization of scripts to limited success.

I also practiced with novel data visualization strategies needed to convey the data to the team.

# Detailed Report

This was another class project I undertook; this one was done in groups of four. The outline for the project was to either find an existing linkage system that can be reworked or come up with a new system altogether in our teams. Our instructors would then pose as our clients and specify something they wanted our design to achieve and it was our task to try and succeed in achieving this. Our final design was to be presented in a report accompanied with a simulation to verify it worked.

Our group decided to redesign the rear suspension of a performance downhill racing mountain bike, our instructors decided that we should aim to double the possible displacement of the rear wheel (from 140mm to 280mm) and implement an energy generation system to recharge a mobile phone from the actuation of the suspension.

{{< fig src="/images/bike-old-design.png" caption="A diagram of a conventional mountain bike suspension" >}}

Our proposed general design was the result of research we conducted. it is referred to as a ‘lower-link’ shock and is known for being a very configurable configuration. It is also not incredibly complex to analyze/assemble either by being a four-bar mechanism.

{{< fig src="/images/bike-proposed-design.png" caption="The proposed design" >}}

We divided up major tasks amongst group members, my role was to program the simulation and optimization systems in MATLAB. This system would increment various dimensions and record their effect on the displacement path of the wheel during the shock cycle. It would then sort out any paths that were impossible (e.g. the wheel needing to travel downwards to continue as this would cause the system to seize in the event of a loading from the bottom as would be the usual case). 

{{< fig src="/images/bike-matlab-model.png" caption="An example configuration with its path ploted" >}}

Once it would process all the different cases across our ranges of interest the system was programmed to then output a chart displaying what configurations achieved our desired displacement (280 to 320mm).

{{< fig src="/images/bike-configuration-summary.png" caption="The summarized results from a set of simulations" >}}

We then would select configurations from different regions of the chart and compare their performance using another function I wrote that would animate a given configuration going through one shock cycle and record how the shock behaved during this cycle. These simulation results were then compiled with the work of my teammates to create our final recommendation and documenting it in our report.

{{< fig src="/images/bike-shock-attributes.png" caption="An example chart of how each configuration's reaction was characterized" >}}

