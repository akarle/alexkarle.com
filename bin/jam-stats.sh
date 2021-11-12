#!/bin/sh
# stats.sh -- get frequencies of jam-tuesday songs/artists
# run with -f to show a plaintext table of the "full archive"
set -e

N=10
REPO=$(dirname "$(dirname "$0")")
DIR="$REPO/jam-tuesday"
TMP=$(mktemp)
num_sessions=0
for set in "$DIR"/[0-9][0-9][0-9][0-9]-*; do
    # Remove leading notes, blank lines, and instrument/reprise
    # comments (and blank lines before or after the comments)
    sed '1,/---/d' "$set" | grep -v '^ *$' | sed 's/ *([^)]*) *//g'
    num_sessions=$((num_sessions + 1))
done > "$TMP"

artists() {
    sed 's/.*, *//' "$TMP" | sort -f | uniq -i -c
}

songs() {
    sed 's/ *//' "$TMP" | sort -f | uniq -i -c
}

topN() {
    sort -n -r | head -n "$N"
}

echo "Play Stats:"
echo "-----------"
printf "%4d Jam Sessions\\n" "$num_sessions"
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

# TODO: Don't hardcode the width to be perfect (if we ever have more setlists...)
if [ "$1" = "-f" ]; then
    printf "\n\n\nFull Archive:\n"
    SEP="----------------------------+---------------------------------------+--\n"
    sed 's/.*, *//' "$TMP" | sort -u -f | while read artist; do
            first=""
            grep ", *$artist\$" "$TMP" | sort -f | sed "s#, *$artist *##" | uniq -c -i | \
                    while read plays song; do
                            if [ -z "$first" ]; then
                                    first=1
                                    printf "$SEP"
                                    printf "%-27s | %-37s |%2d\n" "$artist" "$song" "$plays"
                            else
                                    printf "%-27s | %-37s |%2d\n" "" "$song" "$plays"
                            fi
                    done
    done
    printf "$SEP"
fi

rm "$TMP"
