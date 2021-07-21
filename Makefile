# alexkarle.com makefile
# targets:
# 	build [default] -- generates HTML in current dir
# 	clean -- deletes said HTML
HTML != echo index.html *.[1-9] | sed 's/\.[1-9]/.html/g'
SETS != find jam-tuesday -name '[0-9][0-9][0-9][0-9]-*'
JAMGEN = jam-tuesday/index.html jam-tuesday/greatest-hits

# Running with HIDE="" shows the full build command instead
# of the abbreviated version (@ suppresses the command in make)
HIDE = @

CC = cc
CFLAGS = -g -O2 -Wall -Wpedantic -Wextra

.PHONY: build
build: $(HTML) atom.xml $(JAMGEN) bin/kiosk

.PHONY: clean
clean:
	rm -f $(HTML) atom.xml $(JAMGEN)

index.html:
	ln -sf intro.html $@

atom.xml: blog.7 bin/genatom.sh
	./bin/genatom.sh > $@

jam-tuesday/index.html: $(SETS) bin/jam-index.sh bin/jam-stats.sh
	./bin/jam-index.sh > $@

jam-tuesday/greatest-hits: $(SETS) bin/jam-stats.sh
	(date; echo; ./bin/jam-stats.sh) > $@

bin/kiosk: src/kiosk.c
	$(CC) $(CFLAGS) -DMANDIR="\"`pwd`/kiosk\"" src/kiosk.c -o $@

$(HTML): bin/genpost.sh

.SUFFIXES: .7 .html
.7.html:
	@echo "mandoc $<"
	$(HIDE)mandoc -Tlint -Werror $<
	$(HIDE)./bin/genpost.sh	< $< > $@
	$(HIDE)mkdir -p kiosk
	$(HIDE)mandoc $< > kiosk/`basename $@ .html`
