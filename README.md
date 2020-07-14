alexkarle.com
=============

My small corner of the internet.

www.
----
A static site with a small templating system, build with `make`.

Currently hosted with OpenBSD's `httpd`, but any web server should be able to
serve it up.

git.
----
I use a simple setup of git-daemon for anonymous (read-only) downloads,
ssh+git for read+write access (limited to myself) and [stagit][1] to host static
views into the diffs and files of each repo.

I like the stagit approach in that it is simple, modular, and emphasizes the use
of regular git for larger operations (i.e. diff between refs, etc).

In the stagit/ directory, find:

  * style.css    -- CSS for all pages
  * post-receive -- the git-hook to update the pages
  * logo.png     -- AK logo
  * setup.sh     -- small script to setup all exported repos with proper hooks, etc
                    also used to bulk update style.css/post-receive/logo.png

The content, being static, is served up with `httpd` as well.

[1]: https://git.codemadness.org/stagit
