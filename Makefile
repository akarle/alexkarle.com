# sub-Makefile so that mandoc -Oman can find the Xr references
HIDE = @
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
