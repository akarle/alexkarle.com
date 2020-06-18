DEST = /var/www/htdocs/karleco

.PHONY: build
build:
	./bin/build.sh

.PHONY: install
install: build
	mkdir -p $(DEST)
	cp build/* $(DEST)
