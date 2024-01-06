---
title: "FPGA Video Processing System"
date: 2023-02-08T00:16:59-05:00
draft: true
started: "January 2023"
finished: "March 2023"
status: "Complete"
client: "ECE532, Digital Systems Design"
tags: [FPGA, video, "machine learning"]
skills: [FPGA]
summary: "Developed a hardware-only video processing system to do kernel operations on a live video feed, including a primitive number detection system."
githubLink: https://github.com/richard259/G6_imageprocessing
thumbnail: /images/video-pip.png
---

# Overview

For my digital systems class in my masters we had to complete a group project. I teamed up with three others and we choose to do ours on making a video processing pipeline on an Field Programmable Gate Array (FPGA). The FPGA would control a camera, get a video feed from it, apply some process on it, and then display it on a monitor over a VGA interface. The point of using an FPGA in this rather than a computer was that it would be able to do this much more efficiently and with lower latency.

We not only successly accomplished our original intentions, and exceeded our objectives, but actually ended up adding a nifty feature: **digit recognition!** All accomplished in hardware, without any soft-core or co-processor needed.

My main contribution to the project was the video output stage. Originally I anticipated this to be simple, just read in the pixel values and synchronize it with the screen timings - then I'd be free to contribute to other parts. *However,* this was far from the case since we needed the output to be broadcast at 60 frames per second (fps) regardless of what rate we were processing video. So implementing the frame buffering system was what really took up my time.

{{< fig src="/images/video-pip.png" caption="Live video feed of a digit, with a preview of the processed image used for recognition in the top left" >}}

## Requirements

- Provide video output at 10&nbsp;fps
- Use only hardware for video processing
- Apply meaningful video processing (e.g. edge-detection)

## Objectives

- Achieve the full 30&nbsp;fps support by our camera
- Not require any external memory or significant buffers
- Latency below 200&nbsp;ms
- No pixel glitches visible

## Takeaways

- Digital systems are cooooool
- Hardware optimization, while somewhat difficult, can really pay off!
- Using commercial intellectual properties (IP, essentially "libraries" but for hardware) has benefits and drawbacks

# Detailed Report

In my masters I took ECE532, Digital Systems Design, which taught students the design of large scale digital systems focusing primarily on FPGAs. As part of the course we had to for teams of about four and create some digital system of our choosing using the Xilinx Artix 7 FPGAs offered to us through the course (we selected to use the [Nexys 4 DDR](https://digilent.com/reference/programmable-logic/nexys-4-ddr/start)) within the span of about two months. My team of four decided to peruse a video processing project since we felt that it was an area that was ripe for accelerated processing using the techniques taught to use in the course.

# Background

In image (and by extent video) processing a common tool used is a "kernel". Kernel operations in essence use not only the pixel's original value, but also its neighbouring pixels to generate some resulting value for the pixel. This operation is generally applied to each pixel in an image to achieve a desired effect, a basic example would be blurring. The underlying math is a **Multiplication and ACcumulation (MAC)** operation, where the values used in the kernel act as the factor or weight for each pixel in the neighbourhood.

{{< fig src="/images/video-kernel.png" caption="A visual example of a 3-by-3 kernel operation." attr="Apple" attrlink="https://developer.apple.com/documentation/accelerate/blurring_an_image" >}}

MACs require quite a few steps, for an *n*-by-*n* kernel one needs to perform *n*^2 multiplications and then *n*^2-1 additions to accumulate the values, so 2*n*^2-1 operations. On a conventional processor that can perform one operation at a time per clock cycle *(yes, I know this isn't how they really work)*, this means 17 cycles per pixel for a 3-by-3 kernel. This has to be repeated for *every* pixel in the image too! So that's a lot of cycles, in reality there would be many more to move the data around the processor in addition to performing this math.

The reason it takes so many steps on a conventional processor is that they *(generally)* don't have the hardware to perform a MAC in a single step, so it has to be achieved through these individual operations it can perform. Using the configurable logic of an FPGA one can design the hardware that would be needed to perform a MAC in a single cycle! This was the crux of our project, getting the FPGA to do these operations in hardware. From there it would just be a matter of adjusting our kernel values to achieve different effects.

# System Design

The first stage in any successful design is planning. For this project as is typically of digital systems projects this took the form of a block diagram where we outlined all the modules we would need and drew the flow of data through our system. From here we then divvied up tasks among ourselves. There were a few main sections that we identified:

- **Camera interface** - Responsible for getting the video data for us. Handled by one of us on their own.
- **Image processing** - Would apply a kernel to the video feed. Worked on by two members.
- **VGA Interface** - Would output the processed image for the user. I focused on this.
- **Neural Network** - Used to perform the digit recognition. Was combined effort from my three teammates.

{{< fig src="/images/video-overall-blockdiagram.png" caption="Final system block diagram" class="whiteBackground" >}}

I focused on the VGA output stage to display the video. Another took the camera front end, and the other two focused on the processing. When we decided to add the digit recognition feature the three of them worked on the processing for that while I prepared the preview utility.

# Camera Interface

This was relatively simple module that had two main parts: a configuration module to control the camera, and a module to read in the video from the camera. We actually sourced (and cited!) much of the camera code from an open source project[^^1] we found online.

[^^1]: OV7670-Verilog by Weston Braun. Available: https://github.com/westonb/OV7670-Verilog

## Camera Configuration

Configuration only had to be performed once to initialize the camera, from then on it would stream out the data as configured to. Communication to the camera took place over an manufacturer design SCCB protocol, which was a lightly modified I2C protocol. The configuration for the camera was hardcoded into a Read Only Memory (ROM) block on the FPGA as a series of target registers and values to write. This meant that to change the camera's configuration we would need to compile a new bitstream for the FPGA, however we only had to change the configuration twice or thrice throughout the project so this was fine.

We assigned a button to trigger a camera reconfiguration in the event it was disconnected or some other issue required remedying. 

## Reading Video Data

Receiving the video data wasn't too difficult. The data was already digitally transmitted to the FPGA so all we needed to really do was watch for the start of frame signal and then accept the pixels starting from top-left, going across to the right and then down, row-by-row, for the entire image.

# Video Processing

This was the selling point of our project, processing a live video feed, ideally at full speed, with minimal latency. The processing we would be working towards was a kernel operation. Initially we planned to allow kernel values to be changed on the fly from a host computer, however we decided to simply load a couple of distinguishable presets on the FPGA and switch between them using the switches.

Our main example would be edge detection which we accomplished using a Sobel filter[^^2]. This approximates the gradient of an image's intensity, which highlights sudden changes - edges. Then we would compare the magnitude of the gradient at each pixel to a threshold (user adjustable) to mark it as an edge or not.

[^^2]: Sobel Operator on WikiPedia - https://en.wikipedia.org/wiki/Sobel_operator

{{< fig src="/images/video-edge-detection-diagram.png" caption="Flow diagram for edge detection using a Sobel filter" >}}

## Conversion to Greyscale

Although not shown in the block diagrams, one key component of the video processing pipeline was a conversion from a full colour (RGB) image to a greyscale one. The motivation for this was to simplify the processing that would follow since having multiple colour channels would make effects hard to administer in a visually coherent way and it didn't even really matter for our intended result (edge detection and number recognition).

This was done by a simple pixel-wise operation on the pixel stream by combining their RGB values in certain portions. 

## Kernel Implementation

Writing the code to perform the MAC operation was trivial. The real meat of this portion was ensuring that the right data was being used. What I mean by this is that the camera sends the pixels sequentially from top left to bottom right, and each pixel only once. The MAC however needs to operate on a grid of pixels across sequential columns and rows, and pixels need to be used multiple times, so streaming pixels straight from the camera into the MAC operator wouldn't work.

For this to work properly each kernel operator needed to buffer at least three adjacent rows which it would then scan through to perform the kernel operation on all the pixels. For our literal *corner* and *edge* cases where the kernel would extend beyond available pixel data, we would use zeros for the lacking pixels ("zero-padding"). In the end each kernel operator module had a buffer for four rows, so that one row would have data written to it while the other three were being computed on.

{{< fig src="/images/video-edge-detection-buffer.png" caption="Diagram of buffering in the kernel modules on a six row image" class="whiteBackground">}}

## Testing the Kernel

The kernel worked as expected after a few iterations. However, due to the limited colour depth of the camera we had issues with getting noisy outputs for edge detection, especially in shaded scenes.

{{< fig src="/images/video-demo-noisy.gif" caption="Demonstration of the initial edge detection system" >}}

To clean this up, we made use of our kernel module once again, this time the kernel was set to count how many edge pixels neighboured other edge pixels. If a pixel didn't have enough neighbouring edge pixels it was likely just noise/dithering along the transition of shades and ignored. We called this our **DeNoise** kernel/effect.

## Adjusting Thresholds

Since the comparison thresholds needed to be adjusted to suit the ambient lighting conditions so the system could operate optimally for edge detection and such, we made use of the buttons on the board to allow on the fly changes to be made and reviewed in real time. My contribution to this part of the project was writing the 80 lines of Verilog to output to the seven segment displays.

{{< fig src="/images/video-controls.png" caption="Board controls and output layout" >}}

{{< fig src="/images/video-seven-segment.jpg" caption="The seven segment displays working, their values set by the switches" >}}

# VGA Driver

Originally I (and the rest of my team) anticipated that the VGA portion would be a simple task since we would ideally just stream the video out at the rate it arrived from our VGA camera, and thus there would be no real need for a buffer. Once that was sorted I would join the guys working on the processing portion to help them complete that. Unfortunately, after some initial tests we quickly learned that was not going to be the case. 

We anticipated that since our camera was marked as a "VGA" camera, with a resolution of 640 by 480 pixels, that it would output a video stream that could be readily displayed on a monitor that accepted VGA. The betrayal was that the camera had a VGA resolution - *but not framerate*. VGA monitors require a 60&nbsp;fps input at that resolution, but the camera only output at 30&nbsp;fps. So when we first tried to feed the camera data directly to a monitor it failed to be displayed. 

**We would need a frame buffer to show each frame twice to bring the framerate up to 60.** Not only that, but also we needed to do it right otherwise there would be visible artifacts if we were reading from the buffer as it was being partially written to ("screen tares"). This would need there to be two full frame buffers that we would alternate between reading and writing to, a **"ping-pong"** buffer arrangement. We did the math to see how much memory was needed to accomodate this: 12-bit colour depth, 640 by 480 (307&nbsp;200) pixels, so 3&nbsp;686&nbsp;400 bits per frame. The FPGA had only a smidgen over 6&nbsp;Mb so it would be unable to hold the frames, so it needed to go off-chip into the Dynamic RAM (DRAM).

To compound the complexity introduced in moving data off-cip, DRAM is mapped memory (each read/write needs an address), however the pixel data was provided as a stream and the VGA module expected a stream input so I would need to convert between these two methods of data transfer. Luckily there was an IP available to me from Xilinx which helped simplify the job for me, amply named `DataMover`. So I built out the expanded VGA system around it as the core.

{{< fig src="/images/video-vga-block-diagram.png" caption="Block diagram of the final VGA system" class="whiteBackground" >}}

So, time for a tour of the trials and tribulations this system's parts imparted on me.

## Pixel to Stream

This part actually went quite easily, it was responsible for taking in the data for several pixels and combining them into one packet which was then sent forward over a AXI Stream interface towards the DataMover. The reason packets were collected like this was twofold: firstly packing them made more efficient use of space and bandwidth since each pixel needed 12-bits, not a nice multiple of 8 - secondly the image processing didn't actually use AXI Stream interfaces, so there needed to be something that would signal the way DataMover expected inputs would be provided.

The only issue I had with this code was that I initially didn't stage my inputs right. So if I received pixels too quickly and couldn't offload them then some would be lost. This caused issues later because then the first few pixels from the next frame would fill in for these lost pixels, causing the last few rows in the image to look odd. Luckily when I went back to fix this once I determined the root cause I was greeted with this lovely past assumption.

```verilog
// Look into adding a second internal buffer so the flow in isn't interrupted.
// Realistically the pixels are coming in at a rate about 12.5 Mpixels/second
// so this should be more than capable of handling it now

localparam PIXELS_TO_BUFFER = STREAM_WIDTH / 16;
```

## Stream to VGA

This was the first part I started in the system since it was derived from my initial VGA driver code. Its function was pretty simple: take in a stream of pixels and put them up on the screen. Other than needing to unpack the pixels to undo what `pixelToStream` did, this was a pretty standard VGA output affair, I simply had it keep counters to know when pixels were meant to be broadcast, and others to know when to properly signal the end of a row or frame. Outputting colour data was done directly from the FPGA's pins into a resistor network which feed the VGA interface.

It made use of a small AXI Stream buffer feeding it to smooth out the flow of pixels, accumulating them then VGA driver was in a [blanking](https://en.wikipedia.org/wiki/Blanking_(video)) period and then doling them out quickly when pixels were being drawn.

I later expanded on this a bit to accommodate the [preview](#digit-preview) of the input to the digit recognition system.

## Memory Interface Generator (MIG)

This was a Xilinx IP and it connected directly to the DRAM interface/pins on the FPGA and the DataMover IP. We didn't do anything else with it other than verify the range of memory addresses available since it was automatically configured to match our development boards.

## DataMover and Controller

This is where I spent several weeks tearing out my hair.

The purpose of these two modules was to move data from an AXI stream into a part of AXI mapped memory while reading part of mapped memory back into a stream. This was actually the express purpose of the DataMover IP, however the DataMover needed something to issue it command so that's where my module came in.









# Digit Recognition

We had all the parts complete for our original design to a reasonable level with a couple weeks to spare in the project so we decided to attempt introducing a character recognition system. This wasn't *as* outlandish of a feature for us to implement as would first sound. Firstly, it was obviously still tied to our image processing goal, but a second more subtle reason is that some neural network schemes themselves, especially for image processing, operate using kernels/MACs!

I personally wasn't super involved in the development of this portion as I was still wrangling the last few bugs in the VGA system at the time. My contributions to this outside helping brainstorm solutions for some of the issues was in adding the previewer for digit images over the live video feed.

## Image Compression



## Neural Network


## Digit Preview




# Outcome

We not only

## Tips for Others




