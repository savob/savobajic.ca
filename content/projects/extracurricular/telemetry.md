---
title: "Telemetry"
date: 2020-02-04T12:04:34-05:00
draft: true
started: "Febuary 2020"
finished: "April 2020"
status: "Complete"
client: "HPVDT"
tags: [embedded, wireless]
skills: [c++]
summary: "Developed a general purpose wireless communication system to be used in future projects for HPVDT"
githubLink:
thumbnail:
---

# Overview

HPVDT's vehicles collect data about their state and relay it to their riders in real time. I  developed a general system that could used to broadcast data out of the vehicle to a base station so our crew could also view data in real time instead of going through logs afterwards to analyze performance.

The system is based on nRF24L01 modules that support a range of about 1km with direct line of sight at a bandwidth of couple dozen kilobytes per second, which is a far more than adequate bandwidth for our purposes.

## Requirements

- Communication with vehicles with 400m direct line of sight
   - Based on the distance our trail van is behind our speed bikes
- Have communication bandwidth of 2kbit/s

## Objectives

- Range of 750m with direct line of sight
- Bandwidth of 20kbit/s

## Takeaways

- Double check voltage tolerances of your parts!

# Detailed Report

For all of the team's vehicles more and more data was being gathered, however it is in most cases only visible to the riders when it is measured. For anyone else to make use of it it needs to be logged and read later.
