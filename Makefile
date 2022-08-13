# alexkarle.com makefile
DESTDIR = /var/www/htdocs
CFLAGS = -g -O2 -Wall -Wpedantic -Wextra

# Variables used to determine what to build (and clean)
HTML != echo www/*.txt www/blog/*.txt | sed 's@\([^\.]*\)\.txt@\1.html@g'
SETS != find www/jam-tuesday -name '[0-9][0-9][0-9][0-9]-*'
NOTES != find gopher/notes/all
PHLOG != find gopher/phlog | grep -v atom.xml

BUILT = $(HTML) \
	gopher/notes/index.gph \
	gopher/phlog/atom.xml \
	www/atom.xml

# Top level targets
.PHONY: build
build: $(BUILT)

.PHONY: jams
jams: gopher/jam-tuesday/stats www/jam-tuesday/index.html

.PHONY: install
install: build
	pax -rw www $(DESTDIR)
	pax -rw gopher $(DESTDIR)
	install -m 444 $(SETS) $(DESTDIR)/gopher/jam-tuesday
	install -m 444 LICENSE $(DESTDIR)/gopher
	install -m 444 www/blog/*.txt www/atom.xml $(DESTDIR)/gopher/blog
	install -m 444 gopher/bin/* $(DESTDIR)/gopher/code
	for d in jam-tuesday code; do \
		(cat gopher/$$d/index.gph; \
		 gopher/bin/dirlist $(DESTDIR)/gopher/$$d)\
		 > $(DESTDIR)/gopher/$$d/index.gph; \
	done
	(cat gopher/blog/index.gph; gopher/bin/blogidx.sh) > $(DESTDIR)/gopher/blog/index.gph
	gzip -k -f $(DESTDIR)/www/*.html $(DESTDIR)/www/*/*.html

.PHONY: clean
clean:
	rm -f $(BUILT)

# Individual files to build
gopher/jam-tuesday/stats: $(SETS) bin/jam-stats.sh
	(date; echo; ./bin/jam-stats.sh -f) > $@

www/jam-tuesday/index.html: $(SETS) bin/jam-index.sh bin/jam-stats.sh
	./bin/jam-index.sh > $@

www/atom.xml: $(HTML) bin/genatom.sh
	./bin/genatom.sh > $@

gopher/notes/index.gph: $(NOTES)
	(cd gopher/notes && ../bin/notetag) > $@

gopher/phlog/atom.xml: $(PHLOG) gopher/bin/gophatom.sh
	./gopher/bin/gophatom.sh > $@

# Inference rules (*.txt -> *.html)
$(HTML): Makefile bin/genpage

.SUFFIXES: .txt .html
.txt.html:
	./bin/genpage $< > $@
