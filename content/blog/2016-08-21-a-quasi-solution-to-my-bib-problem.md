---
title: 'A quasi-solution to my bib problem'
date: '2016-08-21'
tags:
  - 'bibtex'
  - 'latex'
  - 'work'
  - 'bibliography'
---

For some time, one of my concerns is bibliography management.
See my [projects page](http://abelsiqueira.github.io/en/projects/) if you have
interest on working with something like that.

In the past, what we had was simply writing all your bibliographies directly on
a .tex file. Then, if you needed to write again, you would copy-paste it
somewhere. If you made a mistake, you would have to fix it by hand. If the
journal changed styles, you would have to change everything by hand.
**If you're still doing this. STOP.**

Then, we got BibTeX and all it's reimplementations. BibTeX allows you to define
key-value pairs and process to the specific style desired.
So, this

```
\bibitem{key} Author, S.: Some Title. Journal of Something, 10, 200-230, (2016)
```

which was written directly in the .tex, changed to this

```
@journal{key,
author = "Some Author",
title = "Some title",
journal = "Journal of something",
volume = "10",
pages = "200-230",
year = "2016"
}
```

in a different .bib file, and the .tex had 4-5 lines adding a package, options,
style, the .bib file, and where to put the bib.

This is useful. Really, it is. Perhaps you don't think so, because you have to
learn something new, and it looks strange (?), and nobody uses it (??), but
really, it is useful. Keep reading.

Now, we need something new. BibTeX was created 31 years ago, and it really
needed something new. Well, it has. You wanna you **BibLaTeX** now, instead of
BibTeX, but it works in the same way. But what we really need is something new,
and smarter.

Computers are very fast and smart now, we can have something more useful.
Something in the cloud (#thereisnocloud), some server-like thing using HTML5.
Use JSON.

Anyway, the BibTeX problem is a part of the LaTeX problem, which is also too
old, but there is nothing fully working as good right now.

For now, I found some middle ground, specially if you're trying to leave writing
directly on the .tex, and wants to create a .bib file.

Use JabRef + JabFox. Search each entry of your bibliography and use JabFox to
save it. There is an option to update the entries that have DOI, so do that too.
Then you can generate your .bib as needed.
