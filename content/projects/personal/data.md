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
thumbnail: /images/data_presentation_setup.jpg
---

# Overview

I wanted to make a little tribute to an album I really like, "DATA" by Tainy, to also serve as a pitch for a collaboration. Given the sci-fi theme of the album a custom circuit board was a perfect fit for it, and I realized that I could further elevate it by making it react to music through lights going around the edge. When the idea came to me I couldn't help but go through with it!

{{< fig src="/images/data_hoodie_logo.png" caption="The DATA's logo variant used for reference, there were other variants with different colouring" >}}

The final result was my physically largest board I've made to date which also has the most LEDs I've used yet (72)! The LEDs were both back and side facing so the illumination would be visible if the board was pressed against a wall or free-standing further away. The music was fed in via standard 3.5&nbsp;mm aux plugs, where the board would pass the signal on to a normal amplifier/headphones/speakers. I also made the board interactive by using the tabs on the left side as sensing pads to allow for the effects to be changed or brightness adjusted.

{{< fig src="/images/data-pcbs-side-by-side.jpg" caption="Completed board, assembled and lit up next to another face down" >}}

I couldn't have completed this as easily without the help of [Elliott Muscat](http://elliottmuscat.com/) _(really cool guy, check out his site!)_, the creative director for Tainy, who provided me the design of the logo in a format for me to use for the PCB when I asked.

{{< youtube id="rodq5CGr5OI" title="DATA Video Demo" >}}

## Requirements

- Shine a bunch of LEDs in response to music passing through via aux
- Not distort the logo visually on the board
- Use the tabs to tune LED behaviour
- Impart minimal distortion on audio passing through
- Use only a single colour of LED (white)

## Objectives

- Have over 10 different LED effects
- Have stereo audio effects
- Update the lights at a rate of 20 times a second or more
- Complete the project in under a month

## Takeaways

The project was a success, one of my fastest turnarounds for an idea into reality taking only a couple of weeks to have it working at a basic level! I tuned the effects for a few weeks afterwards. It's impressed most people I've had the chance to show it off to, and I enjoy seeing it run. I learned a fair bit about lighting planning and some basic audio interactions and **I can confidently say that this was a completed project that achieved everything I wanted of it.**

_...That being said, there are always improvements to be made!_ I think this was a beautiful functional prototype but if I were to really release it to the wild I would need to work a fair bit on improving its usability. Some basic ideas would be to use a microphone instead of depending on an aux pass through since few people regularly use those, and even moving to a battery instead so it can be placed freely. Changing the PCB to white on black would definitely improve the look and be more faithful too.

# Detailed Report

As I was finishing my masters I got into Latin music, as I was searching for music with lyrics I couldn't understand and thus distract me as I wrote my final report. This coincided with the release of Tainy's album so it was being promoted and I was quickly hooked. Eventually through a chain of events ended up working next to the office of his creative director, Elliott, who I got to meet! We got along well talking about the album and our inspirations, thus I proposed that we could do a collaboration of sorts. As a preliminary pitch I showed him different boards including the ever famous [raccoon](/projects/personal/raccoon/) as examples.

After chatting some more I decided to just go ahead and make a entire proposal to show him, and once the idea of combining the circuit board with lights and sound came to me, I decided to jump right in.

## Schematic Design

In the interest of keeping this project moving fast, I didn't want to take many risks with the circuit design lest they fail and I lose a lot of time either bodging it to work or ordering a new revision. As a result the design of the board is pretty simple electrically, a few chips and parts that are connected directly to a soldered on microcontroller development board.

For the DATA board I selected the Raspberry Pi Pico for the RP2040 as the microcontroller board because it was designed to be soldered as a surface mount module which would spare the art on the top side of the PCB. It also is a capable and fast microcontroller which would be needed for the audio processing I foresaw, with its dual core it even opened the opportunity to split tasks to be completed in parallel such as collecting audio data and then processing it.

### User Interaction

Indispensable on any prototype circuit board is at least one light and button for the microcontroller to interact with directly, so I had three of each on the board. This way I would have a reliable way to get some feedback in or out of the system if the other supporting chips were not working as intended.

As I mentioned earlier I wanted the users to be able to operate the system using the tabs on the left of the logo as buttons. This would be done using capacitive sensing, _which warrants another shameless throwback to the [raccoon](/projects/personal/raccoon/) where I used it before_. Unlike the hack I used in the first version of the raccoon, I would use a dedicated capacitive sensing chip for this: a [CAP1206](https://www.microchip.com/en-us/product/cap1206). This would make the operation more reliable, especially with multiple channels. It has six channels so in addition to the four tabs I also intended to connect the "DA" and "TA" as additional possible buttons.

### Bright, Bright LEDs

**White LEDs ONLY!** For the sake of circuit simplicity and style I elected to only use white LEDs to match the eventual black PCB. Going with a single colour of light meant that I didn't have to concern myself with a minimum distance to ensure proper diffusion (mixing of separate lights) when they would be close to a surface. I personally find poorly diffused lights annoying and cheap looking so I generally try to avoid RGB LEDs for this reason. Also I find that by committing to a single colour you give yourself some constraints to work with creatively rather than having the whole gamut of colour at your command.

I wanted there to be several dozen LEDs around the edge so that the lighting effects could be granular, with each LED having its brightness individually controlled. To attempt this using the conventional resistor and LED connected to a microcontroller pin is futile for several reasons:

- The RP2040 only has around 35 pins total, and several are already being used for other things
- It is unlikely we would be able to use PWM to dim each LED individually
- The RP2040 wouldn't be able to supply all the current needed if all LEDs needed to be on at once
- I would need a resistor for each individual LED and their variation in resistance would cause nonidentical current and thus brightness at the same duty

For these reasons I used two discrete LED driver chips, the [IS31FL3236A](https://www.lumissil.com/assets/pdf/core/IS31FL3236A_DS.pdf). These are puppetted digitally from the RP2040 to allow each of their 36 LEDs to be controlled independently and also only need a single reference resistor to set the current across all LEDs for a given chip reducing brightness variation.

### Audio Input

I had to look around online on how to best handle audio inputs for microcontrollers. The obvious "best" performance came from using a dedicated audio-grade analog to digital converter, however I did not have the fiscal nor temporal budget to allow myself such luxury so I opted for a cheaper and dirtier approach: using the microcontroller's own onboard convertor connected to the audio lines using a capacitor and biasing resistors. The audio would pass directly from one aux jack to the next, with each stereo channel being "T"'d off for sampling via the circuit described.

{{< fig src="/images/data_audio_input_circuit.png" caption="Audio input circuitry" >}}

## Printed Circuit Board Design

The layout of this circuit board carried some characteristic constraints for artistic boards, namely not messing with the art where possible. To that end, I put all parts on the back of the PCB, and made an effort to route the majority of connections on the back too. 

To start the design of the PCB I needed the logo, so I reached out to Elliot and asked him for a version in gray scale so it would be easier for me to process into the different layers I needed for the board (copper, outline, silkscreen, etc.), which he generously provided - the one I showed at the start but I'll repeat here. The file name implied it was meant for hoodies.

{{< fig src="/images/data_hoodie_logo.png" caption="The gray scale DATA logo provided to me" >}}

I wanted this to be a visible board, an art piece of sorts, so I needed to make sure it was appropriately sized. I wanted the height to be 70&nbsp;mm (about 2.75") since I felt any shorter would've made the tabs along the side small to operate since they would only be about 13&nbsp;mm (about 0.5"), and the entire board likely feel tiny. The wide aspect ratio of the logo meant that to have that height, the board was going to be almost 300&nbsp;mm (12") wide!

In my view it made the most sense to have all the cables come in on one of the sides, so I decided the left side where the tabs are, as this would be where the user's focus would naturally be directed to interact with the board. This strongly influenced me to put all the computation and control circuitry in the same area to simplify routing the signals.

The LEDs followed the perimeter of the board, alternating between up- or side-facing LEDs to ensure an approximately even illumination around the board regardless the distance to a wall from behind. There were some tough to place lights around the computation area due to the components and connectors present - although their disruption was minimized as best I could.

{{< fig src="/images/data_leds_around_connectors.png" caption="LEDs placed around the connectors, note their highlighted footprints" >}}

### Circuit Art Technique Demonstration

As part of my proposal I intended to show the different ways one could do art with a PCB so I did a couple little patches to demonstrate different techniques so we could refer to them in future discussions:

- The front was done in a very simple style with no exposed copper, thus it depended heavily on the white silkscreen for details and contrast.
- On the rear I cut out "TAINY" from the solder mask (green coating) which revealed the traces beneath which became shiny, almost reflective. This could be made golden like I did for features on the raccoons.
- I did organic "spaghetti" routing near the computation region of the board where all the chips are
- For the LED signals I routed the traces in a more conventional parallel bus that fanned out to LEDs
- I did want to have the traces to the LEDs go from a rigid typical straight lines at the chips to eventually more organic and curvy forms near the LEDs mirroring the gradual humanization of the album. _Unfortunately I was unfamiliar with how to achieve it at the time and I wanted something done quick so I skipped that._

{{< fig src="/images/data_bare_pcb.jpg" caption="Bare DATA circuit boards, front and back so all demonstrated techniques are visible" >}}

Honestly laying out the board wasn't too tough, even trying to keep things to a single layer was easy as there weren't that many connections that needed to cross one another. Whenever I could I would reassign pins to prevent the need to cross signal paths. The only real challenging part that I would like to change in the future is moving away from a RPi Pico board to a proper embedded microcontroller since its large footprint was annoying.

## Assembly

Not much to report here. I opted for a manual assembly to reduce personal cost but also expedite their completion by a few days. It was a pretty simple assembly process, only catch was the hulking size of the boards which meant I really had to be careful not to rest my hands on the board by accident before fixing the parts into place via reflow soldering.

The process was the standard for surface mount parts: stencil alignment, paste application, part placement, reflow.

{{< fig src="/images/data_stencil_alignment.jpg" caption="Stencil alignment" >}}

{{< fig src="/images/data_dispensed_paste.jpg" caption="Applied solder paste" >}}

{{< fig src="/images/data_placed_parts.jpg" caption="Parts placed prior to reflow" >}}

I started the project on the 14th of February or so, and these photos imply that I finished the assembly on 26th, so sub-two week turnaround!

## Initial Testing

Initial hardware testing wasn't too difficult a time. The only hard part was getting the right aux cables to test with as I had accidentally tucked the connectors slightly too far from the edge so I needed to whittle some of the encasing of the aux cables off. Luckily I had properly placed the RPi Pico well so that USB cables had no issue plugging into it.

Once I had the system connected and powered for the first time I observed no smoke or otherwise spectacularly failing components, and the power supply was verified to be at the expected level - so I had nothing left to do but move to programming and testing each bit of code.

## Programming

For programming I took a back-to-front approach; I would program the output stage (LEDs) first, so that then I would be able to reliably observe my work on the stages feeding into it, and thus the stages feeding into those. Once I had built up a verified pipeline from audio to LED, I would expand on the lighting effects offered.

### LED Code









{{< fig src="/images/data_first_illumination.jpg" caption="First proper illumination of a board's LEDs!" >}}

### Audio Code

Once I had the system powered and connected, I began testing the audio input. Fortunately it worked without major issue. However it did have some difficulty at first and imparted some buzzing to the audio when I was using my desktop as the audio source although it didn't seem to affect the RPi's audio readings. When I switched to my phone it went away. I attribute this to likely be the cause of the longer run of cables from my computer's audio output compared to the phone's.



{{< fig src="/images/data_testing_with_scope.jpg" caption="Testing setup with oscilloscope probing the audio passed through, headphones split off at the source aux port" >}}






### User Interaction Code










### Effects Code

With the foundation of the system complete, I had the freedom to build whatever effects I wanted, so I drafted a few in my notebook and then got to working on them.


I did even consider a basic "rendering" engine, but I need to check my notes.







## Reflections







{{< fig src="/images/data_presentation_complete.jpg" caption="A small parting arrangement of the DATA system on my work tables" >}}

### Future Improvements

As it stands I'm not sure about a return to this project soon, life's gotten quite busy for me and I don't have much time to spare. Should I or anyone else decide to pick up the project again I would advise them to consider the following changes, namely for portability:

 - Switch from aux to a microphone. Using an aux pass through isn't super convenient for many people and force the board to live in proximity to audio device rather than on display. Using a microphone to listen for audio would allow for freer placement of the board, aux can still remain as a possible input.
 - Make it battery powered. For much the same reason as the microphone, it would be handy to move it around freely. The cell if placed cleverly on the back could act as a supporting leg for the board to stand upright on a table without a separate stand part.
 - Shrink the board so it is easier to place.
 - Ditch stereo effects. They require double the processing of mono effects and visually haven't paid off much. Perhaps tuning the visuals' code might help.
 - Add a system to detect proximity to a wall and adjust the lighting of LEDs to suit based on their orientation.
