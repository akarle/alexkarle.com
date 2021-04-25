#!/bin/sh
# genatom.sh -- generate atom.xml
set -e

# All posts are a item (.It) in the list, and linked via .Xr
POSTS=$(sed '/SEE ALSO/q' blog.7 | grep -A1 '\.It' | grep '\.Xr' | sed 's/^\.Xr \([^ ]*\) 7/\1/')
# Assume dates are 1-1
DATES=$(grep -o '[0-9]\{1,2\}/[0-9]\{1,2\}/[0-9]\{4\}' blog.7 \
    | sed -e 's#\([0-9]\{2\}\)/\([0-9]\{2\}\)/\([0-9]\{4\}\)#\3-\1-\2#')

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

set $DATES
printf "  %s\n" "<updated>${1}T00:00:00Z</updated>"
for p in $POSTS; do
    d="$1"
    shift
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
    mandoc -Thtml -O'fragment,man=%N.html;https://man.openbsd.org/%N.%S' $p.7 \
        | sed '/<td class="head-vol">Miscellaneous Information Manual<\/td>/d'
    cat <<EOENTRY
    ]]>
    </content>
  </entry>
EOENTRY
done
printf "</feed>\n"
