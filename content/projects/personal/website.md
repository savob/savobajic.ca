---
title: "Website"
date: 2021-12-30T23:52:32-05:00
draft: false
started: "December 2021"
finished:
status: "Ongoing"
client: "Viewers like you"
tags: [html, HUGO, css]
skills: [html, css, markdown]
summary: "I made this website from scratch, would you like to peer behind the curtain?"
githubLink: "https://github.com/savob/savobajic.ca"
thumbnail:
---

# Overview

I made this website to have a little showcase of myself on the web, both for professional 
advancement as well as just a way to show off what I'm up to to friends and family. It's 
something I've talked about doing on and off for years but finally got around to commiting 
to it.

Although I originally intended to write it entirely word by word in HTML, I switched to 
using the [HUGO](https://gohugo.io/) website builder to help me accelerate my progress 
and simplify updating it in the future. I am hosting my website on [Netlify](https://www.netlify.com/), 
with the source files hosted on [my GitHub account](https://github.com/savob/savobajic.ca).

## Takeaways

* Switching to HUGO was immensely helpful for ensuring that my content is consistant as well 
as enjoying the pages it automatically generates like tag pages in addition to the content 
itself.
* Making a functional site is easy, but making it engaging is not as straight forward

## Progress and Plans

Progress comes and goes, I am satisfied with the layout of the site for now and am focusing 
on populating it with actual content at a rate of a few projects daily. I hope to have all 
the content I want up by the 17th of January, at which point I will look to improve the 
layout of the website.

# Detail

After years of throwing aroung the idea of having a personal website I committed and purchased 
this domain December 30th, 2021. Just in time to ring in the new year. Originally I wanted the 
`savo.ca` domain but it has already been purchased and now redirects to a site about the 
benefits of owning a `.ca` domain. The irony is a *bit* frustrating.

## Finding a Host

The next step in the process was finding a host for my website. I considered rolling my own 
server with some spare Raspberry Pi's or my NAS but to keep things simple for myself I 
decided to go with a commercial host instead.

After doing some research the main concern for me was the cost, so I was trying to find 
the cheapest service since I [currently] do not most of the features offered to me. After 
asking my sister where she hosted her site and how much she pays for it, I decided to 
go to Netlify since the their basic plan is free.99.

## Website Architecture

I initially intended to make the website largely, if not entirely from scratch in HTML 
and some potential scripting. After I started, I quickly came to realize some of the 
limitations of using pure HTML - namely that it was difficult to modularize one's website. 
This meant that in order to have a consistent header and footer I would need to either 
copy them into each `.html` by hand, or resort to some trickery.

I have these original scraps of a website I prepared in HTML by hand available for 
download [here](/website-by-hand.zip) for those curious.

After looking up solutions I came across the concept of Static Site Generators (SSGs), 
which as the name implies, build static HTML pages for you programmatically that you then 
host. Of the ones available the one that stood out and I decided to use was HUGO. I 
picked it for a few reasons:
1. It was on the shortlist of recommended builders for Netlify.
2. It advertised itself as the fastest which is nice
3. It is open source and based in Golang which is new to me, so I wanted to warm up to that language
4. I knew a guy named Hugo once, while all other builders had names no child should bear.

In addition to the benefits of having the SSG follow templates for my content, so I 
could easily update shared elements, it came with several advantages I quickly began to 
use. Most notable for you, the user, are the "list" pages used to outline the contents 
in each directory. Since these are all generated and updated automatically as I modify 
the content on my site I don't have to think about them past setting their templates!

## Website Design

I would like to minimize the amount of scripting needed for my website, ideally keep 
it at zero to ensure that the content is viewable by anyone with just an HTML parser. 
To that end I am try to stict to only formatting the website with CSS, and so far I 
have been successful at sticking to it.

The layout of my website is kept basic for now, largely given my CSS abilities. The 
design used is inspired (stolen) from a print portfolio of my projects that I 
prepared at the end of my third year studies, roughly April 2019. *(I still need to 
grab that font!)*

<figure>
<img src="/images/website-portfolio-clip.png">
<figcaption>Fig. 1 - An section from the print portfolio</figcaption>
</figure>

The website design is not set right now, and will definitely change. I would like to 
have the website, especially the list pages, fell more alive and reactive to viewers. 
However the format I have now is sufficient for me to display the content I want in 
an acceptable, if uninspired design.

## Adding Content

All the content for the site is prepared in markdown (`.md`) files within folders that 
match the structure of the website, as per HUGO guidelines. Media and such are 
uploaded to the "static" directory, also as per HUGO guidelines. For more detail about 
how these are then synthesised into HTML, please refer to the HUGO documentation 
[here](https://gohugo.io/documentation/).

To prepare one article takes me usually a couple of hours, especially if it is an old 
project that needs me to sift through my old photos on my phone for something to use. 

Once prepared, I push a commit related to that content up to the GitHub. Once uploaded, 
Netlify detects the push and rebuilds the site with the new data and begins to host it 
immediately if there is no issue during build. HUGO is actually able to use the dates 
of my Git commits to determine the date a file was most recently modified automatically!


