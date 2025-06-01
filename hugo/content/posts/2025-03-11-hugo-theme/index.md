---
title: "My new Hugo theme"
date: 2025-03-11T12:00:00-05:00
draft: false
summary: As a Hugo user, I want to write my own theme, so that I can learn how Hugo works.
tags: [programming, frontend]
---

I've rewritten my Hugo theme using Tailwind and Go templates. The motivation
came partly from seeing other personalized sites with custom theming, and
partly from wanting to get a better handle on frontend development in general.
I have a lot of ideas in my head about developing fullstack applications, but
they rarerly come to fruition due to the sea of papercuts associated with
vanilla JavaScript, CSS, and managing dynamic state in the browser. This
re-theming was fun because I allowed myself to deploy something incrementally
rather than attempting to perfect every aspect of the "product". It's my
website, I'll do what I like with it!

# General Structure

A basic Hugo theme generated with `hugo new theme <NAME> [OPTIONS]` is layed
out with this structure:

```txt
.
├── assets
│   ├── css
│   └── js
├── content
│   ├── _index.md
│   └── posts
├── hugo.toml
├── layouts
│   ├── _default
│   └── partials
├── static
│   └── main.css
└── theme.toml
```

For simplicity, I imported the contents of my theme directly into my existing
site. There are some redundant files in here, but I chose to focus on the
layouts and assets directories since they contain almost everything I needed to
style the site. The `hugo.toml` file also needed some tweaks, but more on that
later.

## Defaults and Partials

Hugo sites can be broken into two categories of parts: default layouts and
partials. The default layouts, like "baseof", describe the underlying structure
of a page which content and "partial" components will be injected into. I left
most of these the same, but hid the "tags" and "posts" pages since I found them
unnecessary.

The "partial" templates are intended for creating reusable components that can
be reused in different contexts. My first partial template was the "title"
which lists a post's title, tags, and publish date in the home page and within
each post. Other Hugo themes tend to contain a lot of these, for things as
large as a page layout and as small as an external link. I found other themes'
partials to be a good inspiration, but chose to keep mine simple for now. In
the future I will explore using partials to load KaTeX, Mermaid, or other
external Javascript bundles which require a CDN to install.

After all was said and done, my first draft of the theme had this structure:

```txt
layouts/
├── 404.html
├── _default
│   ├── baseof.html
│   ├── home.html
│   ├── list.html
│   └── single.html
└── partials
    ├── footer.html
    ├── head.html
    ├── header.html
    └── menu.html
```

Note the default head.html loads a "css.html" and "js.html" partial at the
start of the page content. I chose to keep my styling in `assets/css/` and
remove all Javascript.

### SVG assets

All the assets on the page are SVGs, with the exception of my profile picture
in the top right. I had fun creating these by hand, though I had to keep the
drawing to a simple subset of what SVG is capable of rendering and animating.
The animations are stored in assets/css/main.css, separate from the "base"
styling for normal pages. Tailwind is sadly lacking in animations, but I found
that refering to my custom cloud and smoke keyframe animations with
`animate-[slide_60s_linear_infinite]` was a tidy trick to get around this.

# Tailwind

The second reason for rebuilding Camp Hopkins was to get more familiar with
Tailwind. I find that a styling system that forces you to build from the ground
up rather than pasting in pre-built components allowed me to understand what
was going on much better. My personal theme going into this project was to put
something online without overthinking it, and I can see how the many methods of
organizing CSS can get overwhelming. Slapping a handful of utility classes on a
single "component" partial allowed me to get something working quickly and
focus on cleaning it up later, without a mess of naming conventions and
organizational hierarchy getting in the way.

The only pure CSS I had to write was the SVG animation keyframes, and even that
had a handy trick available in Tailwind. I was able to shove Tailwind classes
into my CSS classes via the `@apply` directive, which worked surprisingly well.
This may require revisiting in the future if I ever need to define my own
utility classes and decide to overhaul the admittedly basic post styling. Maybe
if I start adding more dynamic partial templates I can clean this up.

Bam it's done! An entire post written in two hours! Ship it!

