#!/bin/sh
# setup.sh -- setup repos in $HOME and index for stagit
# meant to be run as the git user, requires stagit installed

SCRIPTDIR="$(dirname "$(readlink -f "$0")")"

# First setup the dest
DEST=/var/www/htdocs/git
cp "$SCRIPTDIR/style.css" "$DEST"
cp "$SCRIPTDIR/logo.png" "$DEST"
cp "$SCRIPTDIR/logo.png" "$DEST/favicon.png"

cd $HOME
for d in *.git; do
    if [ -e "$d/git-daemon-export-ok" ]; then
        echo "Processing $d"

        # Setup src
        cp "$SCRIPTDIR/post-receive" "$d/hooks"
        echo "Alex Karle" > "$d/owner"
        echo "git://git.alexkarle.com/$d" > "$d/url"

        # Setup dst
        base=`basename $d .git`
        mkdir -p "$DEST/$base"
        cp "$SCRIPTDIR/style.css" "$DEST/$base"
        cp "$SCRIPTDIR/logo.png" "$DEST/$base"
        cp "$SCRIPTDIR/logo.png" "$DEST/$base/favicon.png"
        (cd $DEST/$base && stagit $HOME/$d)

        # Add to the list of things to index...
        exported="$exported $d"
    fi
done

stagit-index $exported > $DEST/index.html
