#!/bin/sh
# genpost.sh -- reads mdoc(7) from stdin, generates HTML to stdout


# Command Explained
# -----------------
# man=%N.html;man.openbsd.org -- look for files in CWD for .Xr, then link to openbsd.org
# sed:
#   1. Add a viewport tag for mobile
#   2. Add lang="en" to head for accessibility
#   3. Remove Misc Info column in header (too large on mobile)
#   4. Add a footer with license info
mandoc -Thtml -O 'man=%N.html;https://man.openbsd.org/%N.%S,style=style.css' \
    | sed \
    -e 's#</head>#<meta name="viewport" content="width=device-width,initial-scale=1">&# ' \
    -e 's#^<html#& lang="en"#' \
    -e '/<td class="head-vol">Miscellaneous Information Manual<\/td>/d' \
    -e 's#</body>#<p class="foot-license">\
  © 2019-2021 Alex Karle | <a href="/license.html">License</a>\
</p>\
&#'
