#!/bin/sh
# stats.sh -- get frequencies of jam-tuesday songs/artists
set -e
DIR=$(dirname "$0")
TMP=$(mktemp)
for set in "$DIR"/[01][0-9]-*; do
    # Remove leading notes, blank lines, and instrument/reprise
    # comments (and blank lines before or after the comments)
    sed '1,/---/d' "$set" | grep -v '^ *$' | sed 's/ *([^)]*) *//'
done > "$TMP"

echo "Top 10 Artists (Frequency, Name):"
echo "---------------------------------"
sed 's/.*, *//' "$TMP" | sort -f | uniq -i -c | sort -n -r | head -n 10

echo ""
echo "Top 10 Songs (Frequency, Name):"
echo "-------------------------------"
sort -f "$TMP" | uniq -i -c | sort -n -r | head -n 10

rm "$TMP"
