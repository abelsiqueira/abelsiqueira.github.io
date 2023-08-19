---
title: 'Professional site and blog for researchers, professors and students'
date: '2016-02-13'
tags:
  - 'jekyll'
  - 'site'
  - 'blog'
---

TL; DR: Make a professional web page, like [mine]({{local_prefix}}/../),
and/or a blog, like [mine]({{local_prefix}}). Use
[Jekyll](https://jekyllrb.com/) and my links:
[work page](http://github.com/abelsiqueira/abelsiqueira.github.io),
[blog page](http://github.com/abelsiqueira/blog).

---

## Summary:

- [Summary:](#summary)
  - [Introduction](#introduction)
  - [General Information](#general-information)
  - [Using my site as a starting point](#using-my-site-as-a-starting-point)
    - [Work page - Easy way](#work-page---easy-way)
    - [Work page - Hard way](#work-page---hard-way)
    - [Blog page - Easy way](#blog-page---easy-way)
    - [Blog page - Hard way](#blog-page---hard-way)
    - [Both - Hard way](#both---hard-way)

---

### Introduction

We live in the age of information.
It is easier than ever to find someone from another site of the planet, and
contact them.
That said, that is only possible if you are online.

Most of us are online, some way or another. If you google your full name,
chances are you're gonna find some information about you. Possibly a Facebook or
other social media page.
Maybe an old blog, that you forgot to delete.
Possibly things you didn't even know were online, like public documents with
your name, or aggregator sites with your information.
Most of all, you'll probably find things that aren't you.

Suppose someone is trying to find you, but they know only your name, and
possibly occupation. Could they?
Furthermore, could they contact you?
Do you have enough information for they to discern if it is really you?
Do they have to contact you to see your area of expertise? Your projects?
For that end, it is usually a good idea to store some information about youself
in a webpage mantained by yourself.

I'll will show an example of web page management that takes little effort, and
you can use for a personal page and/or a blog.

### General Information

The name of the game is
[Jekyll](https://jekyllrb.com/). This software mantains web pages using
templates, page snippets, and a little programming to make your job easier.
If you enter [this blog](http://github.com/abelsiqueira/blog), you'll see what
it looks like.

The most important folder is `_posts`. This is where you write your posts. The
naming follows the format `YYYY-MM-DD-name-of-the-post.ext`, and you begin the
file with a little header like

```
---
layout: post
title:  Professional site and blog for researchers, professors and students
date:   2016-02-13
name:   2016-02-13-professional-site-and-blog-for-researchers-professores-and-students
---
```

and then you can write the content.
On a clean project, just creating a new file like this is enough for you to have
a new blog post, but now you want to make it look good.
To create a page that is not a post, like my `about` page, you can simply create
a file inside the folder, create a similar header, and write the page. See my
own
[about.md](https://raw.githubusercontent.com/abelsiqueira{{local_prefix}}gh-pages/about.md).

The first thing you'll notice is the `layout` part. In the folder `_layouts`
there are some templates for a site. For instance, the "default" layout is an
html documeent that includes a head.html, then a header.html, then the content,
then a footer.html. These included files reside in the folder `_includes`.

Notice that the content is written between
`{{` and `}}`. This is the language
that Jekyll interprets to generate the site. This between
`{%` and `%}` are for
commands, and between
`{{` and `}}` are for variable input.
For instance, to print the current page's title somewhere in your text, you may
use `{{ page.title }}`. Not very useful so far, but if want
to put a list of posts in a page you may use

```
{% for pt in site.posts %}
  - {{ pt.date }}: {{ pt.title }}
{% endfor %}
```

This is only a simple example, and you'll probably want to improve your list to
your liking.
In addition, you can play around with conditionals and filters. For instance,
the navigation bar on my work site is a list of all pages with a title, of the
same language of the one you're in, ordered by an internal value.

To create a clean site and test these fun things, first install Jekyll (follow
the instructions on the site for your system), and then issue the commands in
the terminal

```
jekyll new mysite
cd mysite
jekyll serve -w
```

Your site will be built and available at
`localhost:4000`.
To get the site to look good, however, you'll need to edit a few things, like
the layouts for your liking, the css, and so on.
To avoid doing that, you can use my own site as a starting point. I show you how
in the next section.

### Using my site as a starting point

First, let's create a work page. If you don't want one, then jump to the blog
part.
Also, if you know git, and are familiar with GitHub, you can jump a few steps.

#### Work page - Easy way

- Create a [GitHub](http://github.com) account.
- Go to [my github page](http://github.com/abelsiqueira/abelsiqueira.github.io).
- Fork the page, finding the button that says fork and clicking on it.
- In your page, with name http://github.com/youruser/abelsiqueira.github.io, go to

```
settings, and rename the repository to `youruser.github.io`.
```

- Edit the file `_config.yml` and change all pertinent information. Don't leave
  anything with my user.
  **You can edit and create files directly on GitHub, but you can't preview
  your site before publishing. To edit, click on edit, make your modifications
  and then on the bottom of the page click on commit. To create, click on the +
  button, and do similar steps.**

This is sufficient for a site to appear on `http://youruser.github.io` in at
most a few minutes. Now you only need to edit to your liking.
For a multilingual support (default), I suggest you create files with the format
`name.lg.md` where `name` is whatever name you want to give, like `research` and
`lg` is a language prefix. There is no real need to follow this, but it's
cleaner.
Then inside this file, you need to fill

```
---
layout: page
title:  Page Title
key:    name
lang:   lg
order:  Where you want the page in the navigation bar. Lower if leftmost.
permalink: /lg/name/
---
```

See the files `research.br.md` and `research.en.md` for the differences.

It's very important that pages that are translations for each other to have the
same key. Also, for the flag image to appear, you need a file `lg.png` in the
folder `assets`.

I keep a folder `disciplinas` for my teaching files. You may erase it.

If you don't want a blog, you probably want to delete the navigation bar's
`blog`, which is hardcoded. Go to file `_includes/header.html` and find the
lines with `<a class=...Blog</a>` and delete it.

Change the picture.

#### Work page - Hard way

Read the easy way first, but don't do anything yet.
Download my page's source code, either using git or zip.
Modify as you see fit, following the guidelines above.
Test the page with `jekyll serve -w` as I said before, and build it for
publishing with `jekyll build`.
Your page's files will be inside the folder `_site`.
You can publish them however you want. If you have a site at your university,
you can send these files there (probably). For that, you'll have to check with
your IT department.

The advantage of this is that you don't have to use GitHub (or even git) for
anything. The disavantage is that you need to install Jekyll, and you won't have
a default site location.

#### Blog page - Easy way

- Create a [GitHub](http://github.com) account.
- Go to [my github blog page](http://github.com/abelsiqueira/blog).
- Fork the page, finding the button that says fork and clicking on it.
- Edit the file `_config.yml` and change all pertinent information. Don't leave
  anything with my user.
  **You can edit and create files directly on GitHub, but you can't preview
  your site before publishing. To edit, click on edit, make your modifications
  and then on the bottom of the page click on commit. To create, click on the +
  button, and do similar steps.**
- Edit the `about.md` file to be about you.
- Delete all posts in `_posts`, except maybe one to use as a beginning point.
- Write your post.

If you access `http://youruser.github.io{{local_prefix}}`, you'll see your blog. Notice
that, if you haven't created the work page, `http://youruser.github.io` won't
exist, although your blog will.
Also, you won't want the `Work` entry on the navigation bar.
Go to the file `_includes/header.html` and modify the line
`<a class="page-link" href="/">Work</a>`.
If you don't have a work page, then delete it.
If you do, you can change the "/" to your work page url.

#### Blog page - Hard way

Read everything. Do as in the hard part of the work page.

#### Both - Hard way

If you want both, when publishing the content of the blog, remember to publish
the blog pages to a folder `blog`.
