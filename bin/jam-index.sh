#!/bin/sh
set -e
REPO=$(dirname "$(dirname "$0")")
DIR="$REPO/www/jam-tuesday"

# Prep for the by artist listing
ALL=$(mktemp)
for f in "$DIR"/[0-9][0-9][0-9][0-9]-*; do
	sed '1,/---/d' $f | grep -v '^ *$' | sed 's/ *([^)]*) *//g'
done | sort -f > "$ALL"

cat <<EOM
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1">
<!-- Inspired by https://www.swyx.io/css-100-bytes/ -->
<style>
html {
  max-width: 80ch;
  padding: 3em 1em;
  margin: auto;
  font-size: 1em;
  font-family: sans-serif;
}
footer {
  margin-top: 50px;
  font-size: .8em;
}
code { font-family: consolas, courier, monospace; }
h1 { font-size: 1.5em; }
h2 { font-size: 1.2em; }
h3 { font-size: 1.1em; }
blockquote, code pre {
  background: #ffffea;
  overflow: auto;
  padding: 10px;
  border: 2px solid black;
}
.jam-artists tr:nth-child(even) {
    background-color: #e3e3e3;
}
td.jam-artists, th.jam-artists, table.jam-artists {
    border: 1px solid black;
}
</style>
<title>Jam Tuesday Archive</title>
</head>
<body>
<small><code><a href="/">/home/alex</a> / <a href="/jam-tuesday">jam-tuesday</a></code></small>
<h1>Jam Tuesday Archive</h1>
<h2>About</h2>
<p>
From about October 2020 up until August 2021, my brother Matt and I
got together every Tuesday evening to play music. It started as a
way to stay sane during the COVID quarantine, but it quickly became
a tradition and a highlight of the week.  No matter how stressful
work was, or what was going on in the outside world, we could leave
it all behind as we played some of our favorite tunes.
</p>
<p>
At some point (woefully late), I realized it would be fun to start
cataloging what we played.
</p>
<p>
This archive includes the setlists and some play stats.
</p>
<p>
There are no audio recordings (at least publicly), but there's a
stray note here and there to "set the scene".
</p>
<p>
The setlist notation is hopefully pretty straightforward. Unless
otherwise noted, I'm on guitar and Matt's on keys (and if only one
instrument is specified, it's me switching to it).  We both
(attempt to) sing.  Sometimes we even harmonize :)
</p>
<h2>Stats</h2>
EOM

"$REPO"/bin/jam-stats.sh | sed \
    -e 's#^$#</ul>#' \
    -e 's#.*:$#<h3>&</h3>#' \
    -e 's#^-*$#<ul>#' \
    -e 's#^ *[0-9].*#<li>&</li>#'

cat <<EOM
</ul>
<h2>Setlists</h2>
Updated weekly:
<ul>
EOM

for f in "$DIR"/[0-9][0-9][0-9][0-9]-*; do
    name=$(basename "$f")
    echo "<li><a href=\"/jam-tuesday/$name\">$name</a></li>"
done

cat <<EOM
</ul>
<h2>All Songs, by Artist</h2>
<table class="jam-artists">
<tr><th>Artist</th><th>Song</th><th>Plays</th></tr>
EOM
sed 's/.*, *//' "$ALL" | sort -u -f | while read artist; do
	first=""
	grep ", *$artist\$" "$ALL" | sort -f | sed "s#, *$artist *##" | uniq -c -i | \
		while read plays song; do
			if [ -z "$first" ]; then
				first=1
				echo "<tr><td>$artist</td><td>$song</td><td>$plays</td></tr>"
			else
				echo "<tr><td></td><td>$song</td><td>$plays</td></tr>"
			fi
		done
done
cat <<EOM
</table>
<br><br>
<p style="font-size: 0.7em">Last Updated: $(date)</p>
<p class="foot-license">
© 2019-2022 Alex Karle | <a href="/">Home</a> | <a href="/license.html">License</a>
</p>
</body>
</html>
EOM
