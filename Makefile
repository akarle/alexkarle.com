# alexkarle.com makefile
DESTDIR = /var/www/htdocs
CFLAGS = -g -O2 -Wall -Wpedantic -Wextra

# Variables used to determine what to build (and clean)
HTML != echo www/*.txt www/blog/*.txt | sed 's@\([^\.]*\)\.txt@\1.html@g'
SETS != find www/jam-tuesday -name '[0-9][0-9][0-9][0-9]-*'

BUILT = $(HTML) \
	www/atom.xml

# Top level targets
.PHONY: build
build: $(BUILT)

.PHONY: jams
jams: www/jam-tuesday/index.html

.PHONY: install
install: build
	pax -rw www $(DESTDIR)
	gzip -k -f $(DESTDIR)/www/*.html $(DESTDIR)/www/*/*.html

.PHONY: clean
clean:
	rm -f $(BUILT)

# Individual files to build

www/jam-tuesday/index.html: $(SETS) bin/jam-index.sh bin/jam-stats.sh
	./bin/jam-index.sh > $@

www/atom.xml: $(HTML) bin/genatom.sh
	./bin/genatom.sh > $@

# Inference rules (*.txt -> *.html)
$(HTML): Makefile bin/genpage www/style.css

.SUFFIXES: .txt .html
.txt.html:
	./bin/genpage $< > $@
