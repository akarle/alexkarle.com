#!/bin/sh
set -e
REPO=$(dirname "$(dirname "$0")")
DIR="$REPO/jam-tuesday"

# Prep for the by artist listing
ALL=$(mktemp)
for f in "$DIR"/[0-9][0-9][0-9][0-9]-*; do
	sed '1,/---/d' $f | grep -v '^ *$' | sed 's/ *([^)]*) *//g'
done | sort -f > "$ALL"

cat <<EOM
<html lang="en">
<head>
<meta charset="utf-8"/>
<link rel="stylesheet" href="/style.css" type="text/css" media="all"/>
<style>
h1 {
  font-size: 1.6em;
  margin-top: 40px;
}
h2 {
  font-size: 1.3em;
  margin-top: 32px;
  margin-bottom: 0;
}
h3 {
  font-size: 1em;
}
</style>
<title>Jam Tuesday Archive</title>
<meta name="viewport" content="width=device-width,initial-scale=1">
</head>
<body>
<h1>Jam Tuesday Archive</h1>
<p>Welcome to the archive! For more information on the project,
refer to <a href="/jam-tuesday.html">jam-tuesday(7)</a>.</p>
<h2>Stats</h2>
<hr>
EOM

"$REPO"/bin/jam-stats.sh | sed \
    -e 's#^$#</ul>#' \
    -e 's#.*:$#<h3>&</h3>#' \
    -e 's#^-*$#<ul>#' \
    -e 's#^ *[0-9].*#<li>&</li>#'

cat <<EOM
</ul>
<h2>Setlists</h2>
<hr>
Updated weekly:
<ul>
EOM

for f in "$DIR"/[0-9][0-9][0-9][0-9]-*; do
    name=$(basename "$f")
    echo "<li><a href=\"$name\">$name</a></li>"
done

cat <<EOM
</ul>
<h2>All Songs, by Artist</h2>
<hr>
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
© 2019-2021 Alex Karle | <a href="/">Home</a> | <a href="/license.html">License</a>
</p>
</body>
</html>
EOM
