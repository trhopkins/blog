---
title: "My new Hugo theme"
date: 2025-03-11T12:00:00-05:00
draft: false
summary: As a Hugo user, I want to write my own theme, so that I can learn how Hugo works.
tags: [programming]
---

I've rewritten my Hugo theme using Tailwind and Go templates. The motivation came partly from seeing other personalized sites with custom theming, and partly from wanting to get a better handle on frontend development in general. I have a lot of ideas in my head about developing fullstack applications, but they rarerly come to fruition due to the sea of papercuts associated with JavaScript, CSS, and managing dynamic state in the browser. This re-theming was fun because it was 

# General Structure

A basic Hugo theme generated with `hugo new theme <NAME> [OPTIONS]` is layed out with this structure:

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

For simplicity, I imported the contents of my theme directly into my site.
There are some redundant files in here, but I chose to focus on the layouts and
assets directories since they contain almost everything I needed to style the
site. The `hugo.toml` file also needed some tweaks, but more on that later.

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
    ├── head
    │   ├── css.html
    │   └── js.html
    ├── head.html
    ├── header.html
    └── menu.html
```

Note the "css.html" and "js.html" partials which are loaded in the head of the page. I left these untouched.

### SVG assets

### TODO

