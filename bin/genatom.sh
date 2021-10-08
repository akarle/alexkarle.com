#!/bin/sh
# genatom.sh -- generate atom.xml
set -e

REPO=$(dirname "$(dirname "$0")")

# Find fixlinks in either bin or the out-of-tree obj build
PATH="$REPO/bin:$REPO/obj/bin:$PATH"

# All posts are a item (.It) in the list, and linked via .Xr
POSTS=$(sed '/SEE ALSO/q' "$REPO/blog.7" | grep -A1 '\.It' | grep '\.Xr' | sed 's/^\.Xr \([^ ]*\) 7/\1/')

cat <<HEADER
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Alex Karle's blog(7)</title>
  <link rel="alternate" type="text/html" href="https://alexkarle.com/blog.html"/>
  <id>https://alexkarle.com/atom.xml</id>
  <link rel="self" type="application/atom+xml" href="https://alexkarle.com/atom.xml"/>
  <author>
    <name>Alex Karle</name>
  </author>
HEADER

for p in $POSTS; do
    d=$(date -juf"%b %d, %Y" +%F "$(grep '^\.Dd' "$REPO/$p.7"  | cut -d' ' -f2-)")
    if [ -z "$printed_update" ]; then
        printed_update=1
        printf "  %s\n" "<updated>${d}T00:00:00Z</updated>"
    fi
    cat <<ENTRY
  <entry>
    <title>$p</title>
    <link rel="alternate" type="text/html" href="https://alexkarle.com/$p.html"/>
    <id>https://alexkarle.com/$p.html</id>
    <updated>${d}T00:00:00Z</updated>
    <published>${d}T00:00:00Z</published>
    <content type="html">
    <![CDATA[
ENTRY
    # Print fragment (no need for escapes -- in CDATA
    mandoc -Thtml -O'fragment,man=%N.html;https://man.openbsd.org/%N.%S' "$REPO/$p.7" \
        | sed '/<td class="head-vol">Miscellaneous Information Manual<\/td>/d' \
        | fixlinks
    cat <<EOENTRY
    ]]>
    </content>
  </entry>
EOENTRY
done
printf "</feed>\n"
