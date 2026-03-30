---
title: "DATA Music Visualizer"
date: 2026-03-29T19:03:56-04:00
draft: true
started: "February 2024"
finished: "March 2024"
status: "Shelved"
client: "Myself"
tags: [art, audio, lighting]
skills: [art, pcb, sound]
summary: "Made a circuit board for doing light effects as a tribute to the DATA album"
githubLink: "https://github.com/savob/data_loading"
thumbnail:
---

# Overview

I wanted to make a little tribute to an album I really like, "DATA" by Tainy. Given the sci-fi theme of the album a custom circuit board was a perfect fit for it, and I realized that I could further elevate it by making it react to music through lights going around the edge. When the idea came to me I couldn't help but go through with it!

{{< fig src="/images/data_hoodie_logo.png" caption="The DATA's logo variant used for reference, there were other variants with different colouring" >}}

The final result was my physically largest board I've made to date which also has the most LEDs I've used yet (72)! The LEDs were both back and side facing so the illumination would be visible if the board was pressed against a wall or free-standing further away. The music was fed in via standard 3.5&nbsp;mm aux plugs, where the board would pass the signal on to a normal amplifier/headphones/speakers. I also made the board interactive by using the tabs on the left side as sensing pads to allow for the effects to be changed or brightness adjusted.

{{< fig src="/images/data-pcbs-side-by-side.jpg" caption="Completed board, assembled and lit up next to another face down" >}}

I couldn't have completed this as easily without the help of [Elliott Muscat](http://elliottmuscat.com/) _(really cool guy, check out his site!)_, the creative director for Tainy, who provided me the design of the logo in a format for me to use for the PCB when I asked.

{{< youtube id="rodq5CGr5OI" title="DATA Video Demo" >}}

## Requirements

- Shine a bunch of LEDs in response to music passing through via aux
- Not distort the logo visually
- Use the tabs to tune LED behaviour

## Objectives

- Have over 10 different LED effects
- Have stereo audio effects
- Update the lights at a rate of 20 times a second or more
- Impart no distortion on audio passing through

## Takeaways

The project was a success, one of my fastest turnarounds for an idea into reality taking only a couple of weeks to have it working at a basic level! I tuned the effects for a few weeks afterwards. It's impressed most people I've had the chance to show it off to, and I enjoy seeing it run. I learned a fair bit about lighting planning and some basic audio interactions and **I can confidently say that this was a completed project that achieved everything I wanted of it.**

_...That being said, there are always improvements to be made!_ I think this was a beautiful functional prototype but if I were to really release it to the wild I would need to work a fair bit on improving its usability. Some basic ideas would be to use a microphone instead of depending on an aux pass through since few people regularly use those, and even moving to a battery instead so it can be placed freely. Changing the PCB to white on black would definitely improve the look and be more faithful too.

# Detailed Report

As I was finishing my masters

