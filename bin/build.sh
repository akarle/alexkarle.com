#!/bin/sh
mkdir -p build
cp content/*.css build
for f in content/*.md; do
    Markdown.pl $f | ./bin/tm.pl > build/`basename $f md`html
done
