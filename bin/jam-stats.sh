#!/bin/sh
# stats.sh -- get frequencies of jam-tuesday songs/artists
set -e

N=${1:-10}
REPO=$(dirname "$(dirname "$0")")
DIR="$REPO/jam-tuesday"
TMP=$(mktemp)
for set in "$DIR"/[01][0-9]-*; do
    # Remove leading notes, blank lines, and instrument/reprise
    # comments (and blank lines before or after the comments)
    sed '1,/---/d' "$set" | grep -v '^ *$' | sed 's/ *([^)]*) *//g'
done > "$TMP"

artists() {
    sed 's/.*, *//' "$TMP" | sort -f | uniq -i -c
}

songs() {
    sort -f "$TMP" | uniq -i -c
}

topN() {
    sort -n -r | head -n "$N"
}

echo "Play Stats:"
echo "-----------"
printf "%4d Songs Total\\n" "$(wc -l < "$TMP")"
printf "%4d Unique Songs\\n" "$(songs | wc -l)"
printf "%4d Unique Artists\\n\\n" "$(artists | wc -l)"

echo "Top $N Artists (Frequency, Name):"
echo "---------------------------------"
artists | topN

echo ""
echo "Top $N Songs (Frequency, Name):"
echo "-------------------------------"
songs | topN


rm "$TMP"
