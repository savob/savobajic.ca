---
title: "Entry Fob Replication"
date: 2017-09-08T17:05:25-05:00
draft: false
started: "September 2017"
finished: "September 2017"
status: "Complete"
client:
tags: ["reverse engineering", embedded, "signal processing", "EAGLE"]
skills: ["reverse engineering", embedded, EAGLE]
summary: "Reverse engineered and replicated an access fob for my residence at the time"
githubLink:
thumbnail: "/images/fob-assembled.jpg"
---

# Overview

I was curious to see how the entry system worked in the condo I was living in during my second year of studies, 
so I decided to see how the entry fob I was given worked (ideally in a non-destructive way). After taking it 
apart it became apparent it was a glorified TV remote so I set about replicating it with hobbist equipment.

## Requirements

- Understand how the entry fob communicates with the security system
  - *NON-DESTRUCTIVELY!* I needed to return my original fob in working condition.
- Replicate the fob if reasonably possible

## Objectives

- Spoof access to other floors (fobs only allowed access to certain floors)
- Allow for "field" reprogramming without any additional equipment

## Takeaways

Some systems are simplier than you would have expected. Case and point, the fob's method of communicating to the building.

Having the right tools makes the difference. When trying to catch the fob's output signal I originally was trying 
to use an Arduino as a rudimentary oscilloscope as I did not have access to one of my own at the time. I later used 
one on campus. This caused issues for few reasons:
1. **It wasn't fast enough**. It could only sample and broadcast a value a few times a millisecond, which made it hard to catch the narrow spikes
2. **It wasn't regular**. The timebase was unclear, I just had a string of values with no times associated with them.
3. **It was difficult to change the window of measurement**. I assumed that the signal would be very short, so I set 
the system up to blast data as fast as it could. It was only when I used the oscilloscope I was able to easily 
widen the window and see the period between pulses was wider than I anticipated.

## Points of Improvement

My final blaster has a few possible improvements:
- **Use a smaller battery, mounted to the board.** 9V batteries are annoying to lug around and having it visibly dangling off the board as you use it is suspicious at best.
- **Reduce power usage.** Currently the system polls the button to blast, I can change this to have it instead sleep and wake up on button presses, or use the button to connect power to the entire system.
- **Increase the range.** Although the replica has a reasonable useful range for interior spaces where it is rarely further than a metre from a scanner, 
the same could not be said if I were using it in the parking garage, even on my bike. This could be easily improved by reducing the resistor value for the LEDs.
- **Finally develop the "field" reprogramming feature.** *Sigh...*

# Detailed Report

I moved into a new condo for my second year of university with two friends, and to enter the building it required the use 
of a fob. I was curious to see how it worked and if I could replicate it. The fob was a small black box with two bulbs 
sticking out the front that we had to aim at little panels and a single button to blast our entry code.

I started by cracking it open carefully to avoid potentially damaging any delicate components that lay hidden within.
With the top off, I could examine the compact and rather simple circuit contained. My main interest was in the bulbs 
as I wanted to see what they were. Prior to opening it up I assumed acted as a sender and the other recieved to 
allow some cross-talk with the building. However I found that they were connected in series! This meant that they could 
only be acting as a transmitters, thus my job of reverse engineering the protocol with the building was going to be an 
order of magnitude easier.

<figure>
<img src="/images/fob-probing.jpg">
<figcaption>Fig. 1 - Exposed board being probed for the output signal</figcaption>
</figure>

I took the board to an oscilloscope and began to probe the output to the LEDs try and find the secrets of the sent signal. 
I learned that the sent signal followed a consistent basic structure once the button was pressed: 
1. A single pulse would be sent. (Likely to awake the building's system)
2. An 80ms pause
3. A 400ms string of pulses in rapid succession
4. A 1000ms pause
5. (Steps 3 and 4 would repeat until the button was released)

I focused on trying to find a pattern in the third part of the structure, first to convert it to some value in binary, 
then to see if there is any pattern between messages each time the button is pressed. The first step was easy when I 
noticed that in the message there were pulses every 4ms, with some having a second pulse 0.8ms after the first.

<figure>
<img src="/images/fob-pulses.jpg">
<figcaption>Fig. 2 - A section of message pulses, with a double pulse circled in red</figcaption>
</figure>

I decided to assign the single pulses a value of 0, and the doubles a value of 1. I downloaded the data from the 
oscilloscope and prepared an spreadsheet to spot spikes in the voltage readings and translate them accordingly into a 
string of binary.

<figure>
<img src="/images/fob-signal-data.png">
<figcaption>Fig. 3 - An exerpt from the spreadsheet. Leftmost column is time (ms), then voltage reading (V), then if this reading is a spike compared to the previous one, and the rightmost column records a 1  if there is another spike in close succession (a 0 otherwise)</figcaption>
</figure>

I compared the data across five samples from my fob and found that it sent the same signal each time! I confirmed 
this by measuring my roommates' fobs to see theirs acted the same, albeit with unique messages for each fob. This 
meant all I needed to do was was replicated this signal with a system of my own and I would have a fob clone!

All I needed were some basic parts (microcontroller, IR LED, button, resistors, battery) and I was set. I made 
my first prototype that was about as crude as I could get away with and went to test in the parking garage, 
away from most traffic so I could test in peace without having to explain myself to, or alarming, anyone.

<figure>
<img src="/images/fob-prototype.jpg">
<img src="/images/fob-prototype-back.jpg">
<figcaption>Fig. 4 and 5 - My kitchmade prototype from the front and the back</figcaption>
</figure>

It was successful on the first try! Which was very convientent since to recode the Arduino would need me to 
return to my apartment. Obviously running around with an Arduino, battery, and breadboard taped together is 
nowhere near as subtle or durable a final product as I wanted for the long term, so I made more compact system, 
substituting the Arduino development board for an embedded ATtiny85 microcontroller with everything (except the 
battery) on a single, custom circuit board I prepared in EAGLE.

<figure>
<img src="/images/fob-assembled.jpg">
<figcaption>Fig. 6 - Completed assembly (the "940" is for the wavelength of LED used)</figcaption>
</figure>

