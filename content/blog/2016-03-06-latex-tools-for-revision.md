---
title: 'LaTeX tools for revision'
date: '2016-03-06'
tags:
  - 'latex'
  - 'diff'
  - 'revision'
  - 'xournal'
---

This post is just to introduce two new tools I found.

[LatexDiff](https://github.com/ftilmann/latexdiff) is a tool that compares two
tex files and generates a third marking the differences between them.
It is great, for instance, when you update a thesis or article, and want to show
the differences to your advisor or colleague.

Beware that this tool is not without mistakes. Sometimes it fails to mark a
difference, specially in equations.

The other tools is [Latexpand](https://gitlab.com/latexpand/latexpand), which
reads a .tex file and replace `input` and `include` commands with the content of
the tex.
This tools isn't really necessary in a normal context because latexdiff can do
this expansion (or flattening) if you use the argument `--flatten`. I haven't
tried it, though.

What I did was use them with git. If you want to compare two files under git,
one simple option is

```
git checkout old-commit
latexpand main.tex > oldmain.tex
git checkout new-commit
latexpend main.tex > newmain.tex
latexdiff oldmain.tex newmain.tex > diffmain.tex
```

I'm still going to try it under git difftool.
