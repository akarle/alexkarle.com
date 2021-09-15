# alexkarle.com makefile
#
# a tale of two builds
#
# This Makefile builds both text.alexkarle.com (text-only) and
# alexkarle.com (html) from the same mdoc(7) by leveraging "timestamp"
# (*.ts) files which indicate when the two for each *.7 file were made.
# On OpenBSD, all artifacts are built into the obj/ dir (after make obj)
# for an out-of-tree build, but care was taken to maintain gmake
# compatibility.
#
# targets:
# 	build [default] -- generates html and text in obj (OpenBSD) or $PWD
#	obj   -- makes the obj/ directory for out-of-tree build on OpenBSD
# 	clean -- deletes html and text artifacts

# gmake defines CURDIR, OpenBSD defines .CURDIR -- one should work
DIR = $(.CURDIR)$(CURDIR)

#----------------------------------------------------------
# Variables to store timestamp and setlist dependencies
TS != echo $(DIR)/*.[1-9] | sed 's@$(DIR)/\([^\.]*\)\.[1-9]@\1.ts@g'
SETS != find $(DIR)/jam-tuesday -name '[0-9][0-9][0-9][0-9]-*'


#----------------------------------------------------------
# Top Level Targets
.PHONY: build
build: $(TS) html/atom.xml jam-text.ts jam-html.ts \
	html/index.html html/style.css html/logo.png \
	text/000-welcome.txt text/LICENSE

obj:
	mkdir -p obj

.PHONY: clean
clean:
	rm -f *.ts bin/fixlinks
	rm -rf text html obj

#----------------------------------------------------------
# jam-tuesday targets
jam-text.ts: $(SETS) bin/jam-stats.sh
	@mkdir -p text/jam-tuesday
	(date; echo; $(DIR)/bin/jam-stats.sh) > text/jam-tuesday/stats
	@cp $(SETS) text/jam-tuesday
	@echo 'cp $$SETS html/jam-tuesday'
	@touch $@
	
jam-html.ts: $(SETS) bin/jam-index.sh bin/jam-stats.sh
	@mkdir -p html/jam-tuesday
	$(DIR)/bin/jam-index.sh > html/jam-tuesday/index.html
	@cp $(SETS) html/jam-tuesday
	@echo 'cp $$SETS html/jam-tuesday'
	@touch $@


#----------------------------------------------------------
# Various files that just need to be copied into html/text
html/index.html:
	cd html && ln -sf intro.html index.html

html/style.css: style.css
	cp $(DIR)/style.css $@

html/logo.png: logo.png
	cp $(DIR)/logo.png $@

html/atom.xml: blog.7 bin/genatom.sh
	$(DIR)/bin/genatom.sh > $@

text/000-welcome.txt: welcome.txt
	cp $(DIR)/welcome.txt $@

text/LICENSE: LICENSE
	cp $(DIR)/LICENSE $@


#----------------------------------------------------------------------
# Finally, the actual meat -- generating *.html/*.txt from the mdoc(7)
# The most egregious hack here is the live renaming of the files via
# grepping through the ORDER file so that text.alexkarle.com presents
# the files in a reasonable order for viewing
$(TS): bin/genpost.sh bin/fixlinks

bin/fixlinks: LINKS
	mkdir -p bin
	printf "#!/bin/sh\n# GENERATED DO NOT EDIT\nsed" > $@
	awk '{ printf " \\\n  -e s#https://man.openbsd.org/%s#%s#g", $$1, $$2 } END { printf "\n" }' $(DIR)/LINKS >> $@
	chmod +x $@


.SUFFIXES: .7 .ts
.7.ts:
	@echo "mandoc $<"
	@mkdir -p text html
	@mandoc -Tlint -Werror $<
	@$(DIR)/bin/genpost.sh < $< > html/$$(basename $< .7).html
	@mandoc -Tascii -Owidth=72 < $< | col -b > text/$$(grep $$(basename $< .7) $(DIR)/ORDER)
	@touch $@
