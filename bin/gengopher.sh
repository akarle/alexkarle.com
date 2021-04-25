#!/bin/sh
# generates my gopherhole based on the checkout of the files
# in the html area
set -e

WWW=/var/www/htdocs/akcom
DEPLOY=/var/gopher
PHLOG=$DEPLOY/phlog

# First generate the content
for f in $WWW/*.7; do
	# col -b to strip backspace underlines, see mandoc(1)
	mandoc -Tascii -Owidth=72 $f | col -b > $PHLOG/`basename $f .7`.txt
done

# Remove/move some non-phlog cruft
mv $PHLOG/intro.txt $DEPLOY/intro.txt
rm $PHLOG/template.txt

# Set the mtimes so they show nicely in the directory listing
# by parsing the .Dd lines using grep(1) and date(1)
# TODO: create a real gophermap for this directory based on blog(7)
for f in $PHLOG/*.txt; do
	grep '\.Dd' $WWW/`basename $f .txt`.7 \
		| grep -v Mdocdate \
		| sed "s#\.Dd #$f	#"
done > /tmp/mtimes

IFS="	" # tab to split file/date for read (see ksh(1))
while read f d; do
	touch -m -d `date -j -f "%b %d, %Y" "+%Y-%m-%dT%H:%M:%S" "$d"` "$f"
done < /tmp/mtimes
