alexkarle.com
=============
My small corner of the internet.

www.
----
A static site comprised of [mdoc(7)][mdoc] flavored man pages, built to
HTML via [mandoc(1)][mandoc] (managed by [make(1)][make]).

Currently hosted with OpenBSD's [httpd(8)][httpd], but any web server
should be able to serve it up.

git.
----
I use a simple setup of git-daemon for anonymous (read-only) downloads,
ssh+git for read+write access (limited to myself) and
[stagit(1)][stagit] to host static views into the diffs and files of
each repo.

I like the stagit approach in that it is simple, modular, and emphasizes
the use of regular git for larger operations (i.e. diff between refs,
etc).

I use the default post-receive and create scripts that ship with the
tool (with small modifications for the installation). The logo is in
this repo as logo.png.

The content, being static, is served up with [httpd(8)][httpd] as well.

I also discuss the setup in my blog posts [self-hosted(7)][self-hosted]
and [my-old-man(7)][my-old-man].

[mdoc]: https://man.openbsd.org/mdoc.7
[mandoc]: https://man.openbsd.org/mandoc.1
[make]: https://man.openbsd.org/make.1
[httpd]: https://man.openbsd.org/httpd.8
[stagit]: https://git.codemadness.org/stagit
[git-daemon]: https://git-scm.com/docs/git-daemon
[self-hosted]: https://alexkarle.com/self-hosted.html
[my-old-man]: https://alexkarle.com/my-old-man.html
