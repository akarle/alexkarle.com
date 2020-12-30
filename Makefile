# sub-Makefile so that mandoc -Oman can find the Xr references
HIDE = @
HTML := \
    intro.7.html \
    blog.7.html \
    a-new-hope.7.html \
    domain-names.7.html \
    BLM.7.html \
    self-hosted.7.html \
    on-writing.7.html

.PHONY: build
build: $(HTML)

.PHONY: clean
clean:
	rm -f $(HTML)

.SUFFIXES: .7 .7.html
.7.7.html:
	@echo "mandoc $<"
	$(HIDE)mandoc -Thtml -O 'man=%N.%S.html;https://man.openbsd.org/%N.%S,style=style.css' $< \
	    | sed 's#</head>#<meta name="viewport" content="width=device-width,initial-scale=1">&# ' \
	    > $@
