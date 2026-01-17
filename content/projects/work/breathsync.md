---
title: "Breath Sync / Nuit Blanche"
date: 2026-01-17T15:52:37Z
draft: false
started: "August 2024"
finished: "October 2024"
status: "Complete"
client: "Kara Springer Design via EDL"
tags: [art, networking, EDL]
skills: [networking, lighting, "Design for ease of use", documentation]
summary: "Designed the electronics that powered an art installation for Toronto's Nuit Blanche 2024 and beyond, synchronizing lights with the artist's breathing rhythms"
githubLink:
thumbnail: "/images/breathsync_installation_night_3.jpeg"
---

# Overview

[Kara Springer](https://www.karaspringer.ca/) had designed and exhibited art pieces that were designs printed onto light panels that would synchronize their brightness to her breathing with the help of EDL for the engineering. The [first exhibition using this](https://www.engdesignlab.com/works/mobile-led-communication-system) was in 2022 and the system had been re-exhibited since by Kara. When she was going to exhibit it for [Nuit Blanche 2024](https://www.toronto.ca/explore-enjoy/festivals-events/nuitblanche/nuit-history/?project_id=6fd7f71e-1ca8-46f6-b0e1-8fb64d9b91d2) in Toronto she reached out for assistance to scale it up and prepare it for the outdoors.

Kara also had some other potential exhibits in the near future and was interested in using this opportunity to also have us renovate her system to be more reliable and easier to setup for those upcoming exhibits.

{{< fig src="/images/breathsync_prior_installation.jpeg" caption="The first installation of this system in 2022" attr="EDL" attrlink="https://www.engdesignlab.com/works/mobile-led-communication-system" >}}

My job was pretty straightforward: familiarize myself with the project, build out a stronger system, add make it easier for Kara or her collaborators to deploy in the future.

## Requirements

The project was pretty well defined since Kara had already finished her design for the artwork when she approached us, and we had experience before with the work. There were three main changes: the panels were going to be larger than ever before, it was going to be outdoors, and that there would be essentially two installations running concurrently next to one another. 

> *Originally Kara had also wanted us to make the hardware and software changes so that we could have five people separately control each of the five panels in response to their breathing, but this was scrapped for due to budgetary and logistical reasons early on.*

To better explain the last point, until this point Kara's installations had all been indoors in the center of rooms as shown in the photo before. Thus it was feasible to connect them all into a single control system to keep them synchronized. However for Nuit Blanche Kara envisioned that people would be able to walk between two "islands" of her panels. For safety reasons any wire run between them would need to be covered appropriately, however this would ruin the appearance and also the effortless walk due to their presence - so we would need to run the two islands independently yet assure that they remained synchronized.

{{< fig src="/images/breathsync_wire_ramp.webp" caption="The offending and unsightly prospective wire covers">}}

## Takeaways

I learned a bit about how to do networking as I reverse engineered the prior system as well as JavaScript. The main takeaway for me was the experience of working with artists making an installation and the considerations they make. One thing I found that was helpful in this project was expressing confidence in my work as the others felt helpless should it fail without my aid.

# Design

With everything laid out I got cracking on addressing each point we needed to complete the exhibition.

## Restarting the System

Firstly I had to familiarize myself with the system and how it worked so I knew how I could most effectively make the changes needed. Without revealing all the secret sauce, at a high level the system operated in three parts:

- **Sensor system** or **Transmitter** - This was a set of electronics focused on reading the state of the wearer's breathing and forwarding it to our server. This was achieved using a device worn over the ribs that tracks their expansion and contraction as one breathes which was then paired with supporting electronics to upload the values in real time.
- **Server** - This would receive the sensor values and forward it to any active installations that were tuned in. It also provided logging features for the data received as well as notifications when connections were made or broken to transmitters or receivers.
- **Control system** or **Reciever** - The electronics present at an installation responsible for controlling a set of light panels. They would listen for a data stream from the server and modulate the light panels accordingly. In the event there was no data stream they would transition to a fallback loop of pre-recorded breathing so that people wouldn't notice.

I realized that the only part of this that we needed to really develop was the control system, so the sensor system and server could remain as they were. This was convenient for us since Kara was not in Toronto at all until the setup for the exhibition, and she possessed the only sensor systems, so had we needed to work on them we would have needed to get them from her somehow. Eventually I was confident enough in my understanding of the system, I reached out to Kara to have her run the sensor system to ensure that I had the system working well enough to have data go from her to the mock receiver I prepared through the server. 

**It worked on my first try!** This shouldn't have really surprized anyone since I was just copying what had already been done until then. However I noticed as I was looking at the readout that Kara's breathing had eased after I told her so, and we continued chatting her breathing got shorter as she spoke of things that clearly stressed her that were going on, and then eased up when we moved on. It felt a little... *perverse?*... to see this as I spoke to a client so I shut it down and mentioned it to her. She got a laugh out of it and told me that keeping an eye on her breathing to help regulate it was actually part of why she made these pieces!

## Redesigning the Circuitry

At the heart the hardware for the receiver was dimming LEDs from a DC power source so they weren't too complicated and I won't spoil much more otherwise I might as well share the schematics. Redoing them to handle more power would be necessary since the most power they previously handled was about 300&nbsp;W, and the panels we were going to use for Nuit Blanche were expected to double that given their size.

Other than building up the output stage of the board to handle this increase in power the only modification I did to the circuit from before was adding additional output channels so up to ten panels could be handled instead of just six since one of her future installations was likely to need nine panels. For improved usability I changed  from using screw terminals to XT-60 connectors on the inputs and outputs to prevent reverse polarity incidents and hastening assembly generally.

We didn't have long to work on this so I designed the circuit board to use primarily through hole parts so we could easily assemble them by hand in a day and get to testing sooner rather than waiting for an assembly service that would add another week or so. *That's what interns are for anyways.*  I did include the footprint for the microcontroller on the topside, however as a backup in the event we failed to properly solder it I had the footprint for its development board on the bottom side.

{{< fig src="/images/breathsync_pcb.jpeg" caption="Completed soldered PCB">}}

The circuit worked as expected when we flashed it with firmware and we were ready for installation with a few weeks to spare!

## Weatherproofing

This was addressed pretty easily. We spoke to the company handling the construction of the light panels and their supporting frames to inquire if they could also make two wooden boxes that would fit the look of the piece overall so we could protect the electronics. They obliged and we used them after adding some better water sealing around the joints just to be sure.

{{< fig src="/images/breathsync_in_box.jpeg" caption="One set of electronics, tucked away in their box">}}

## Dual Islands

One concern was how to handle multiple islands. However after examining the way everything worked, we could freely have as many receivers tune in at once and they would all be synchronized so long as they were connected. Should any one lose connection it would quickly re-synchronize once it regained connection. So with that determined, we built a second unit and tested this. This went without a hitch, they were perfectly synced when connected!

*Dun dun dun, but what if they **both** lose connection?*

# Installation

With everything prepared in our office we waited out the last couple of weeks to the installation excited to put this out there. I went with our intern at the time to meet with Kara and the crew in the early afternoon to start our part of the installation. We had planned it out to follow these steps:

1. Prepare light panels to have the required connectors to mate with our board
2. Mount the electrical boxes in their respective frames
3. Plug everything in and check the lights operate using the test loop
4. Connect to the internet and validate we can still get data from the transmitter through the server
5. Celebrate, then head back to the office *(Boo)*
6. Return after sunset to tune the brightness levels to be appropriate in the dark of night
7. Do a final check of the system before leaving for the night

{{< fig src="/images/breathsync_installation_daylight.jpeg" caption="Installation site during the daylight">}}

{{< fig src="/images/breathsync_box_in_frame.jpeg" caption="One electrical box tucked inside the frame of an island">}}
## Minor Power Panic

The first two steps were completed just fine. However when we plugged in the lights and ran the test cycle they didn't light up - *shit!* My intern and I scrambled, we checked everything with a multimeter on the board and it seemed fine, we checked the wiring - fine, connectors - fine. Shoot, shoot, shoot, as a final resort we plugged the lights into directly into the power supplies and... *nothing.* We measured the current going into the panel and it was only about 10% what we anticipated so we had no idea what was happening.

We called over the lead guy from the light panel crew and told him we we worried that the lights weren't turning on. He asked us to show him, so my intern and I turned back into the electrical box to connect the light to full power.

"It's working." *What?*

Turns out it was working, just that it was so faint under the midday sun the change was imperceptible unless you were watching it the moment power was supplied. They had greatly reduced the number of LEDs since they had designed it to be seen at night - without blinding people - unlike her earlier panels which needed to be bright in daylight, so that's why it was far less powerful than anticipated.

With that sorted out my intern and I were put at ease and did short work of the remaining tasks, all done within a few hours of our arrival. One additional thing we did for Kara before leaving until dusk was that we updated the fallback loop with a recording from that day.

## Tuning Dual Islands

As the sun was setting I met up with Kara so we could dial in the brightness levels she wanted for the maximum and minimum brightness which didn't take long to apply to the two islands. This led to me conducting the final checks and tests before declaring the exhibit ready for the night. As part of the final check I wanted to make sure that the islands properly transitioned to their backup loops and recovered when the transmitter was online again since this was difficult to easily assess in the daylight.

{{< fig src="/images/breathsync_installation_night.jpeg" caption="The installation after nightfall">}}

Below is a short video recording of the system working live after I had set the light levels. Please note that the lighting wasn't as aggressive, its just my phone's camera being dramatic.

{{< youtube id="NXQIIIoausA" title="Breath Sync Live Demo" >}}

What happened caught us off gaurd. They did both go to their fallback loops as intended, however these loops were not synced between the islands and it was immediately apparent in the lighting appearing chaotic. This was because the fallback loop ran continuously in the background locally on each receiver - started at boot. Since they were booted at different times when the two islands simultaneously switched to their backup loops they weren't at the same point.

Kara was unsure if she liked this or not, since she intended for the piece to be calming, and having the two islands clash like this would achieve the opposite effect. So I quickly worked to have the loops initiate when needed, this way if they lost the transmitter, both would start the backup loop at a similar time and be basically synced up and prevent this issue. During this time Kara consulted with some other organizers for the event about their thoughts.

As I finished testing the successful fix, Kara asked me kindly if I could revert it.

They discussed it and felt that having the piece effectively plunge into chaos and disharmony without Kara's breathing would be rather fitting. Essentially like something calling out for its creator. I agreed and did as they asked, as I also found the effect pretty nice to look at too.

# Outcome

The exhibit was a success! Fortunately for us, the weather was kind that evening so there were plenty of people visiting and we never had to worry about our electronics getting wet. I got a real sense of pride when I visited it at night and saw it working as we intended it to in front of the public, unfortunately at that point Kara had left with the sensor so I was unable to play around with the lights myself for a bit.

> There was a minor issue briefly and rather adorably early in the night though! Kara called me and I heard the panic in her voice as she explained that the breathing sensor was not responsive. When I asked what happened leading up to this outage she admitted that she might've gotten excited to see her daughter for the first time in a couple of days and hugged her a little too enthusiastically.
>
> After a little chuckle I instructed her to reboot the system and this did the trick. I added an instruction to avoid any further intense hugs for the remainder of the night.

{{< fig src="/images/breathsync_pointing_at_box.jpeg" caption="Me pointing at my little box of secrets">}}

All in all, even if this was probably among the simplest projects I did at EDL, I still rank it among my favourites just because it was one that clearly got to be enjoyed by countless people that night all while working without a hitch. I hope Kara's future installations continue to go as smoothly!

{{< fig src="/images/breathsync_installation_night_2.jpeg" caption="Another exhibition picture">}}

{{< fig src="/images/breathsync_installation_night_3.jpeg" caption="One last exhibition picture, bye bye!">}}

