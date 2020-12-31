# alexkarle.com makefile
# targets:
# 	build [default] -- generates HTML in current dir
# 	clean -- deletes said HTML
HTML := \
    index.html \
    intro.html \
    blog.html \
    a-new-hope.html \
    domain-names.html \
    BLM.html \
    self-hosted.html \
    on-writing.html \
    my-old-man.html

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
