#!/bin/sh
mkdir -p build
cp content/*.css build
for f in content/*.html; do
    ./bin/tm.pl $f > build/`basename $f`
done
