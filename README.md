alexkarle.com
=============
My small corner of the internet.

www.
----
A static site comprised of mdoc(7) flavored man pages, built to HTML via
mandoc(1) (managed by make(1)).

Currently hosted with OpenBSD's httpd(8), but any web server should be able to
serve it up.

git.
----
I use a simple setup of git-daemon for anonymous (read-only) downloads,
ssh+git for read+write access (limited to myself) and stagit(1) to host static
views into the diffs and files of each repo.

I like the stagit approach in that it is simple, modular, and emphasizes the use
of regular git for larger operations (i.e. diff between refs, etc).

I use the default post-receive and create scripts that ship with the tool (with
small modifications for the installation). The logo is in this repo as
logo.png.

The content, being static, is served up with httpd(8) as well.

See Also:
---------
* [mandoc(1)](https://man.openbsd.org/mandoc.1)
* [mdoc(7)](https://man.openbsd.org/mdoc.7)
* [stagit(1)](https://git.codemadness.org/stagit)
* [httpd(8)](https://man.openbsd.org/httpd.8)
* [git-daemon(1)](https://git-scm.com/docs/git-daemon)

I also discuss the setup in my blog post,
[self-hosted(7)](https://alexkarle.com/self-hosted.html).