# alexkarle.com makefile
# targets:
# 	build [default] -- generates HTML in current dir
# 	clean -- deletes said HTML
HTML != echo index.html *.[1-9] | sed 's/\.[1-9]/.html/g'

# Running with HIDE="" shows the full build command instead
# of the abbreviated version (@ suppresses the command in make)
HIDE = @

.PHONY: build
build: $(HTML)

.PHONY: clean
clean:
	rm -f $(HTML)

index.html:
	ln -sf intro.html $@

.SUFFIXES: .7 .html
.7.html:
	@echo "mandoc $<"
	$(HIDE)mandoc -Thtml -O 'man=%N.html;https://man.openbsd.org/%N.%S,style=style.css' $< \
	    | sed 's#</head>#<meta name="viewport" content="width=device-width,initial-scale=1">&# ' \
	    > $@
