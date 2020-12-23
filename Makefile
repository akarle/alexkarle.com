HOST = alexkarle.com
DEST = /var/www/htdocs

.PHONY: build
build:
	./bin/build.sh

.PHONY: install
install: build
	mkdir -p $(DEST)
	cp build/* $(DEST)

.PHONY: release
release:
	rsync --delete --exclude=.git -av ./ $(HOST):karleco/ && \
	    ssh -t $(HOST) doas make -C karleco install
