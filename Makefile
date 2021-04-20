# alexkarle.com makefile
# targets:
# 	build [default] -- generates HTML in current dir
# 	clean -- deletes said HTML
HTML != echo index.html *.[1-9] | sed 's/\.[1-9]/.html/g'
SETS != find jam-tuesday -name '[01][0-9]-*'

# Running with HIDE="" shows the full build command instead
# of the abbreviated version (@ suppresses the command in make)
HIDE = @

.PHONY: build
build: $(HTML) atom.xml jam-tuesday/greatest-hits

.PHONY: clean
clean:
	rm -f $(HTML) atom.xml jam-tuesday/greatest-hits

index.html:
	ln -sf intro.html $@

atom.xml: blog.7 genatom.sh
	./genatom.sh > $@

jam-tuesday/greatest-hits: $(SETS) jam-tuesday/stats.sh
	(date; echo; ./jam-tuesday/stats.sh) > $@

.SUFFIXES: .7 .html
.7.html:
	@echo "mandoc $<"
	$(HIDE)mandoc -Tlint -Werror $<
	$(HIDE)mandoc -Thtml -O 'man=%N.html;https://man.openbsd.org/%N.%S,style=style.css' $< \
	    | sed 's#</head>#<meta name="viewport" content="width=device-width,initial-scale=1">&# ' \
	    | sed 's#^<html#& lang="en"#' \
	    | sed '/<td class="head-vol">Miscellaneous Information Manual<\/td>/d' \
	    > $@
