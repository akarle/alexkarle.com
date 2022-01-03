#!/bin/sh
# genatom.sh -- generate atom.xml
set -e

REPO=$(dirname "$(dirname "$0")")

POSTS=$(grep '^- ../..' "$REPO/www/blog/index.txt" | sed 's#.*/blog/\([^)]*\).*#\1#')

ARCH="$(uname)"
parsedate() {
    case "$ARCH" in
        Linux) date +%F --date="$1" ;;
        *) date -juf"%b %d, %Y" +%F "$1" ;;  # assume *BSD
    esac
}

cat <<HEADER
<?xml version="1.0" encoding="utf-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title>Alex Karle's blog</title>
  <link rel="alternate" type="text/html" href="https://alexkarle.com/blog/index.html"/>
  <id>https://alexkarle.com/atom.xml</id>
  <link rel="self" type="application/atom+xml" href="https://alexkarle.com/atom.xml"/>
  <author>
    <name>Alex Karle</name>
  </author>
HEADER

for post in $POSTS; do
    p=$(basename $post .html)
    src="$REPO/www/blog/$p.txt"
    [ "$p" = "index" ] && continue

    d=$(parsedate "$(grep '^_Published' "$src" | sed 's/_Published: \([^_]*\)_/\1/')")
    if [ -z "$printed_update" ]; then
        printed_update=1
        printf "  %s\n" "<updated>${d}T00:00:00Z</updated>"
    fi

    title=$(sed -e 's/^# //' -e '1q' "$src")
    cat <<ENTRY
  <entry>
    <title>$title</title>
    <link rel="alternate" type="text/html" href="https://alexkarle.com/blog/$p.html"/>
    <id>https://alexkarle.com/blog/$p.html</id>
    <updated>${d}T00:00:00Z</updated>
    <published>${d}T00:00:00Z</published>
    <content type="html">
    <![CDATA[
ENTRY
    nihdoc < "$src"
    cat <<EOENTRY
    ]]>
    </content>
  </entry>
EOENTRY
done
printf "</feed>\n"
