---
title: "ESC V5"
date: 2021-08-20T01:46:25-05:00
draft: false
started: "August 2021"
finished: "April 2022"
status: "Complete. Revision needed."
client:
tags: [ESC, embedded, BLDC, drone]
skills: [embedded, KiCAD, BLDC]
summary: "Newest revision to the ESC. Largely designed to use the available MOSFET drivers."
githubLink: "https://github.com/savob/esc_v5_firmware"
thumbnail: "/images/esc-v5-combined-layout.png"
---

# Overview

I need a new revision of my ESC to accommodate the replacement MOSFET drivers I was able to source. I will also use this as 
an opportunity to fix some of the minor inconveniences I face with V4.

Currently still finalizing the board and hope to order it in the coming weeks.

## Takeaways

Overall I would say that this was a success. I had a complete working BEMF ESC working for smaller motors, which implies 
that most of the foundation (at least in software) is present for the larger motors. I will need to revise my hardware to 
accommodate the proper motors I intend to use as well as tweaking the weaker parts of software.

- Transients can really be a pain in the stinker
  - More power, harsher transients
  - Non-idealities in capacitor leads
  - Switching noise / inductive kick back
- **Using the decode function on my oscilloscope for UART debug messages was helpful since I check the reaction of the MCU using a single pin**

# Detailed Report

This revision was started because I had run out of functioning parts during the testing of V4 and the IC shortage has forced 
me to select an alternative MOSFET driver, the [IRS2334S](https://www.mouser.ca/datasheet/2/196/Infineon-IRS2334-DataSheet-v01_00-EN-1228568.pdf) 
from International Rectifier as the replacement for the FAN7388s and FAN7888s I was using until then.

My goal is to keep the board as similar to V4 so that my code doesn't have to be significantly altered and I can focus on 
getting the motors to work.

## Circuit Design

Circuit design is basically the same as [V4](../esc-v4/#circuit-design) with only a few minor changes.

- Replaced the FAN7388/FAN7888 MOSFET driver with the IRS2334S
- Removed the unnecessary resistor on the UDPI line (R2 in V4's schematic)
- Rearranged the MOSFET driver signals such that all the low side signals are on one port. (Done to simplify/optimize coding for commutations)
- Added a status LED on the last unused pin

<figure>
<img src="/images/esc-v5-schematic.svg">
<figcaption>The completed schematic for the ESC V5 (PDF version: <a href="/pdf/ESC_V5.pdf">Colour</a> / <a href="/pdf/ESC_V5_BW.pdf">BW</a>)</figcaption>
</figure>

## Layout

Laying out the board I wanted to try and keep the part placements identical to V4's so I could reuse the same solder paste 
stencil, this is a major reason why I choose the IRS2334S since it came in the same package as the FAN7x88s. Other than the 
addition of the status LED, I was able to leave all components in their place and seat the new ones in place of removed ones 
(R2 where old R2 was, and the MOSFET drivers).

Routing traces was a bit harder than expected since I didn't want to redo the entire thing from scratch. As a result, I 
spent a good portion of my routing seeing how close I could squeeze some traces and vias.

<figure>
<img src="/images/esc-v5-combined-layout.png">
<figcaption>The overall layout of the board</figcaption>
</figure>

The top side of the board houses the MOSFET driver circuitry on the left half and the feedback network on the right.

<figure>
<img src="/images/esc-v5-top-layout.png">
<figcaption>The layout of the top side</figcaption>
</figure>

The bottom of the board is where the control section and MOSFETs are located. I added the status diode between the address 
pads and R2 on the left.

<figure>
<img src="/images/esc-v5-bottom-layout.png">
<figcaption>The layout of the bottom side</figcaption>
</figure>

## Assembly

I received the components and boards I needed, and started the assembly at the start of April. The final results came out 
pretty nicely. Unfortunately I didn't think to take any nice photographs of it before I started to solder on the regulator 
I made for the drone, and then the bank of capacitors to try and handle the transients.

*So really, pictures are to come sometime in the future once I desolder these additions!*

Honestly speaking though, it intentionally has the same appearance and layout of V4 as explained in layout. The only real 
difference in the appearance of V5 from V4 is that I ordered it in a white solder mask with black silkscreen scheme, whereas 
V4 was red and white respectively.

## Porting Code from V4

Since I kept the same microcontroller and largely the same pin allocations, I was able to quickly reuse most of the code I 
developed for V4. The only changes I had to accommodate was a minor shuffling of the motor control pins, and the new status 
LED.

The changes for the motor pins was just changing some of the masks used for changing the registers.

### LED Library

For the LED I made a basic library of some boilerplate code; `LEDSetup()`, `LEDOn()`, `LEDBlink()`, etc. The most 
challenging aspect of this library was making a set of functions to allow for non-blocking blinking functionality. This was 
accomplished using one function (`setNonBlockingBlink`) that sets some global variables to the number of blinks desired and 
the period, then another (`nonBlockingLEDBlink`) that is called with each iteration of the main loop that checks these 
global variables and operates the LED.

```
void nonBlockingLEDBlink() {

  // Check if we are even blinking
  if (nonBlockTogglesLeft > 0) {

    // See if we have passed a point to blink
    if (nonBlockToggleTime < millis()) {

      LEDToggle();
      nonBlockToggleTime = millis() + nonBlockTogglePeriod;
      nonBlockTogglesLeft--;

      if (nonBlockTogglesLeft == 0) LEDOn(); // Turn on LED at finish
    }
  }
}

void setNonBlockingBlink (unsigned int period, unsigned int count) {
  LEDOff(); // Start with LED off

  nonBlockTogglesLeft = (count * 2) - 1;  // Two toggles per count, exclude starting one
  nonBlockTogglePeriod = period;

  nonBlockToggleTime = millis() + period; // Record next toggle time
}
```

With functionality matched with V4, I got cracking on implementing new features that I didn't get to with V4.

## Development

The rough outline of how features were developed for this version. I started with buzzing to try and remedy the issue V4 had 
with it before taking a swing at driving the motor since I *[correctly]* anticipated it would take longer and pose more of a 
challenge to me. 

1. Motor buzzing
2. Get the motor to spin up
3. Maintaining rotation *(at full power)*
   - Without PWM I can focus on the zero-crossing detection system
4. Modulating speed with PWM
   - See how the PWM affects zero-crossing detection
   
***Reminder: I had already managed to spin up and maintain a motor at full speed even with V2! V4 and V5 were supposed to 
allow me to modulate the speed of the motor with proper PWM.** Since I was adding PWM I needed to retrace these steps to 
the PWM didn't break my old approach/code for motor control.* 

### Buzzing

This was what seemed to kill my MOSFET drivers on the V4s. After combing through the code for it I found that the 
`allLow()` function I was using failed to set all the phases low correctly. Once that was remedied, the motors buzzed as I 
commanded them to with my `buzz()` function that had remained largely unchanged since V2, other than pin allocations being 
updated to match each board.

The flow of this function was to take in two arguments for the the period of the buzz, and the duration to buzz; in micro- 
and milliseconds respectively. It would check that the motor wasn't already spinning, constrain the arguments between 
some limits I set, and then actually buzz. Buzzing is achieved by energizing coils for a very brief period of time and 
alternating between two steps at the period requested to produce noise.

Below is how the function roughly looks in code.

```
// Buzzer function.
void buzz(int periodMicros, int durationMillis) { 

  if (motorStatus) return; // Will not run if motor is enabled and spinning.
  // It would [greatly] suck if the drone "buzzed" mid-flight

  // Ensure period is in allowed tolerances
  periodMicros = constrain(periodMicros, minBuzzPeriod, maxBuzzPeriod);

  const unsigned int holdOn = 10;                         // Time the motor is pulled high (microseconds)
  int holdOff = (periodMicros / 2) - holdOn;              // Gets this holdoff period
  unsigned long endOfBuzzing = millis() + durationMillis; // Marks endpoint

  // Buzz until the endpoint
  while (millis() < endOfBuzzing) {
    // Clear the state of all pins so only the phases of interest are driven
    PORTA.OUTCLR = PIN5_bm; 
    PORTC.OUTCLR = PIN3_bm | PIN4_bm;
    PORTB.OUTCLR = PIN0_bm | PIN1_bm | PIN5_bm;
    
    // Set the phases of interest
    PORTA.OUTSET = PIN5_bm; // A high
    PORTB.OUTSET = PIN1_bm; // B low
    delayMicroseconds(holdOn);
    allLow();
    delayMicroseconds(holdOff);

    ...
    (Repeat above but setting A high and C low)
    ...
  }
}
```

### Spin Up

With buzzing sorted, I could get into the meat of the ESC, actually spinning a motor. 

Since BEMF is proportional to the rotational speed of the motor, there is none available for feedback when the motor is 
started. For this reason the motor needs to be spun up using a different control scheme than what is used to maintain 
rotation. The method I have used since V2 is an open-loop approach where I manually commute the motor using a gradually 
decreasing period between steps until I hand it off to the zero-crossing system for usual operation.




### Maintaining Rotation








### PWM Modulation







# Proper Motor Tests

Throughout the development process for all my ESCs thus far I had used a small motor salvaged from an old CD drive that I 
soldered leads to. This was useful for testing for a few reasons: cheap, easy to source a replacement, compact, slower, and 
*[relatively]* high winding resistance of about 2.5Ω (so the stall current would be manageable if my code failed). 

<figure>
<img src="/images/esc-test-motor.jpg">
<figcaption>The test motor with low value resistors used to break out the connections.</figcaption>
</figure>

My drone however was going to use proper motors. These were going to draw significantly more power and lead to more extreme 
operating conditions as a result, notably with more intense transient effects. So I needed to test the ESCs with these to 
verify they were flight ready.

The motors I have are **EMAX's ECO2207-1900KV model**. These are rated for 1900KV which roughly means they will rotate about 
1900 RPM for each volt they are driven. This means that at the roughly 12V I am working with they are expected to rotate at 
about 22800 RPM (380 Hz) at full power! In addition to this massive speed, the winding resistance was only about 70 mΩ so 
the stall currents would exceed 100A at 12V.

## Motor Issues

This jump in power draw quickly led to issues, for both hardware and software to contend with.













## Potential Solutions

From my testing I have noted a few things I could try to address the issues.

- Adding surface mount ceramic capacitors for bypass/decoupling/filtering motor transients
- Try using PWM on the low sides (instead of just holding them low)
- Try using the CCL ("Configurable Custom Logic") on the ATtiny chip to combine the comparator and PWM state for zero-crossing logic
- Look into implementing a closed-loop wind up system for motors. Likely will need current shunts to be added.
   - Application Note 1914 ([AN1914](https://www.nxp.com/docs/en/application-note/AN1914.pdf)) from Freescale Semiconductor has some suggestions

Overall this potential solutions largely steer me to making a new board revision. I will look to also improve the layout of 
the board for usability reasons.

## Outcomes

I have what I believe to be the foundation of a proper, working ESC's firmware and hardware design. I feel that I will soon 
reach the end of this project with one more revision to address my main issues:

1. Hardware revision to reduce the prevalence of transients, and to better handle them when they arise.
2. Improve the spin-up routine to better handle high power motors. Likely with some basic current monitoring.

It's a shame I lost my initial test motor, but I will not let its loss be in vain!
