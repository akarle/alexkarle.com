DEST = /var/www/htdocs/karleco

.PHONY: install
install:
	mkdir -p $(DEST)
	cp -f *.html style.css $(DEST)
