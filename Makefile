# alexkarle.com makefile
# targets:
# 	build [default] -- generates HTML in current dir
# 	clean -- deletes said HTML
HTML != echo index.html *.[1-9] | sed 's/\.[1-9]/.html/g'
SETS != find jam-tuesday -name '[01][0-9]-*'

# Running with HIDE="" shows the full build command instead
# of the abbreviated version (@ suppresses the command in make)
HIDE = @

CC = cc
CFLAGS = -g -O2 -Wall -Wpedantic -Wextra

.PHONY: build
build: $(HTML) atom.xml jam-tuesday/greatest-hits bin/kiosk

.PHONY: clean
clean:
	rm -f $(HTML) atom.xml jam-tuesday/greatest-hits

index.html:
	ln -sf intro.html $@

atom.xml: blog.7 genatom.sh
	./genatom.sh > $@

jam-tuesday/greatest-hits: $(SETS) jam-tuesday/stats.sh
	(date; echo; ./jam-tuesday/stats.sh) > $@

bin/kiosk: src/kiosk.c
	mkdir -p bin
	$(CC) $(CFLAGS) -DMANDIR="\"`pwd`\"" $< -o $@

$(HTML): Makefile

.SUFFIXES: .7 .html
.7.html:
	@echo "mandoc $<"
	$(HIDE)mandoc -Tlint -Werror $<
	$(HIDE)mandoc -Thtml -O 'man=%N.html;https://man.openbsd.org/%N.%S,style=style.css' $< \
	    | sed -e 's#</head>#<meta name="viewport" content="width=device-width,initial-scale=1">&# ' \
	          -e 's#^<html#& lang="en"#' \
	          -e '/<td class="head-vol">Miscellaneous Information Manual<\/td>/d' \
	          -e 's#</body># \
<p class="foot-license"> \
  © 2019-2021 Alex Karle | <a href="/license.html">License</a> \
</p> \
&#' \
	    > $@
