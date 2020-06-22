DEST = /var/www/htdocs/karleco

.PHONY: build
build:
	./bin/build.sh

.PHONY: install
install: build
	mkdir -p $(DEST)
	cp build/* $(DEST)

.PHONY: release
release:
	rsync --delete --exclude=.git -av ./ alexkarle.com:karleco/ && \
	    ssh -t alexkarle.com doas make -C karleco install
