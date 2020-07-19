<!-- {% include=head %} -->

### July 17, 2020: Migrating to a Self-Hosted Site

If you look at the [first post][1] on this site, you'll see that this site
started as a series of static HTML files that I was, by hand, uploading to
Fastmail via their "files" GUI.

Being a total nerd for automation, I was always on the lookout for an excuse to
migrate to my own server, where I could (over)engineer a pipeline to build my
static content and deploy it without ever leaving the terminal.

That excuse presented itself in the form of needing to get a VPS to stand up my
hobby-project, [`euchre.live`][el]. If I was going to pay for a tiny VM, it was
a no-brainer to move my personal site to it too.

This turned out to be a great learning experience -- getting hands on experience
with reverse proxies, DNS, and a variety of operating systems and webservers
(first hosted on Alpine Linux and migrated to OpenBSD). Additionally, I could
self-host git repos, which has long been a nerd-goal of mine :)

I plan to write a lengthier post about the joys of self-hosting in the future,
but for now, I really just wanted to give a brief update on where I landed and
what the current stack is.

I'm currently running (in no particular order):

* **OS:** OpenBSD
* **Web server:** OpenBSD's `httpd(8)`
  - Serves the `www.` static content
  - Also serves [git.alexkarle.com][git]
* **Reverse proxy:** OpenBSD's `relayd(8)`
  - Used to send traffic between [`euchre.live`][el] (which uses a [Mojolicious][mojo]
    web server as the backend) and `alexkarle.com` based on URL
* **`www` content:**
  - 100% static content
  - No metrics, ads, or tracking
  - Posts and pages written in markdown
  - HTML generated with a pipeline of the original `Markdown.pl` into a small
    templating Perl script that I home-rolled
* **Git:**
  - Public repos served with `git-daemon(1)` over the `git://` protocol
  - Push access via the `ssh://` protocol
  - static HTML of content generated via post-receive hook with [stagit][stagit]

That's all for now!

[1]: 12-19-19-a-new-hope.html
[el]: http://euchre.live
[git]: https://git.alexkarle.com
[stagit]: https://git.codemadness.org/stagit/
[mojo]: https://mojolicious.org

<!-- {% include=post-tail %} -->
