# alexkarle.com makefile
#
# a tale of two builds
#
# This Makefile builds both gopher://alexkarle.com (text-only) and
# alexkarle.com (html) from the same mdoc(7) by leveraging inference
# rules. Since this generates a LOT of derived files, it's recommended
# to run BSD make and run `make obj` first to get an out-of-tree build.
# GNU make should work in a pinch though!
#
# targets:
# 	build [default] -- generates html and text in obj (OpenBSD) or $PWD
#	obj   -- makes the obj/ directory for out-of-tree build on OpenBSD
# 	clean -- deletes html and text artifacts
# 	install -- install to $DESTDIR/{www,gopher} (default: /var/www/htdocs)
# 	jams  -- regenerate jam-tuesday index and stats files

# gmake defines CURDIR, OpenBSD defines .CURDIR -- one should work
DIR = $(.CURDIR)$(CURDIR)
DESTDIR = /var/www/htdocs

# Variables used to determine what to build (and clean)
HTML != echo $(DIR)/*.[1-9] | sed 's@$(DIR)/\([^\.]*\)\.[1-9]@\1.html@g'
TEXT != echo $(DIR)/*.[1-9] | sed 's@$(DIR)/\([^\.]*\)\.[1-9]@\1.txt@g'
SETS != find $(DIR)/jam-tuesday -name '[0-9][0-9][0-9][0-9]-*'
NOTES != find $(DIR)/gopher/notes/all

BUILT = $(HTML) \
	$(TEXT) \
	atom.xml \
	index.html \
	gopher/notes/index.gph


# Top level targets
.PHONY: build
build: $(BUILT)

.PHONY: jams
jams: jam-tuesday/stats jam-tuesday/index.html

obj:
	mkdir -p obj/jam-tuesday obj/bin obj/gopher/notes

.PHONY: install
install: build
	# HTML to DESTDIR/www
	install -m 755 -Dd $(DESTDIR)/www/jam-tuesday
	install -m 444 $(SETS) $(DIR)/jam-tuesday/index.html $(DESTDIR)/www/jam-tuesday
	install -m 444 *.html atom.xml $(DIR)/LICENSE $(DIR)/style.css $(DESTDIR)/www
	# Text + gopher exclusives to DESTDIR/gopher
	cd $(DIR) && pax -rw gopher $(DESTDIR)
	pax -rw gopher $(DESTDIR)  # for out-of-tree builds
	install -m 444 $(SETS) $(DESTDIR)/gopher/jam-tuesday
	install -m 444 $(DIR)/LICENSE $(DESTDIR)/gopher
	for f in *.txt; do \
		install -m 444 $$f $(DESTDIR)/gopher/blog/$$(grep $$f $(DIR)/ORDER); \
	done
	install -m 444 atom.xml $(DESTDIR)/gopher/blog
	cp $(DIR)/gopher/bin/* $(DESTDIR)/gopher/code
	for d in jam-tuesday blog code; do \
		(cat $(DIR)/gopher/$$d/index.gph; \
		 $(DIR)/gopher/bin/dirlist $(DESTDIR)/gopher/$$d)\
		 > $(DESTDIR)/gopher/$$d/index.gph; \
	done

.PHONY: clean
clean:
	rm -f $(BUILT) bin/fixlinks


# Individual files to build
jam-tuesday/stats: $(SETS) bin/jam-stats.sh
	(date; echo; $(DIR)/bin/jam-stats.sh -f) > $@

jam-tuesday/index.html: $(SETS) bin/jam-index.sh bin/jam-stats.sh
	$(DIR)/bin/jam-index.sh > $@

index.html:
	ln -sf intro.html index.html

atom.xml: blog.7 bin/genatom.sh
	$(DIR)/bin/genatom.sh > $@

bin/fixlinks: LINKS
	mkdir -p bin
	printf "#!/bin/sh\n# GENERATED DO NOT EDIT\nsed" > $@
	awk '{ printf " \\\n  -e s#https://man.openbsd.org/%s#%s#g", $$1, $$2 } END { printf "\n" }' $(DIR)/LINKS >> $@
	chmod +x $@

gopher/notes/index.gph: $(NOTES)
	(cd $(DIR)/gopher/notes && $(DIR)/gopher/bin/notetag) > $@

# Inference rules (*.txt and *.html)
$(HTML): bin/genpost.sh bin/fixlinks

.SUFFIXES: .7 .txt .html
.7.html:
	@echo "mandoc -Thtml $<"
	@mandoc -Tlint -Werror $<
	@$(DIR)/bin/genpost.sh < $< > $@

.7.txt:
	@echo "mandoc -Tascii $<"
	@mandoc -Tlint -Werror $<
	@mandoc -Tascii -Owidth=72 < $< | col -b > $@
