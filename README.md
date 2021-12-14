alexkarle.com
=============
My small corner of the internet.

www.
----
A small static blog powered by my own personal markup parser, [nihdoc].

Currently hosted with OpenBSD's [httpd(8)], but any web server should be
able to serve it up.

gopher://
---------
A pure ascii dump of the content of the www site, served over Gopher by
[geomyidae(1)] respectively!

Builds via [make(1)] at the same time as the HTML.

Also has gopher-exclusive content!

git.
----
I use a simple setup of [git-daemon(8)] for anonymous (read-only) downloads,
ssh+git for read+write access (limited to myself) and [stagit(1)] to
host static views into the diffs and files of
each repo.

I like the stagit approach in that it is simple, modular, and emphasizes
the use of regular git for larger operations (i.e. diff between refs,
etc).

I use the default post-receive and create scripts that ship with the
tool (with small modifications for the installation). The logo is in
this repo as git/logo.png.

The content, being static, is served up with [httpd(8)] as well.

[make(1)]: https://man.openbsd.org/make.1
[httpd(8)]: https://man.openbsd.org/httpd.8
[stagit(1)]: https://git.codemadness.org/stagit
[git-daemon(8)]: https://git-scm.com/docs/git-daemon
[geomyidae(1)]: http://r-36.net/scm/geomyidae
[nihdoc]: https://git.sr.ht/~akarle/nihdoc
