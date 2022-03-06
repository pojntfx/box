# Variables
DESTDIR ?=
WWWROOT ?= /var/www/html
WWWPREFIX ?= /uni-sdi-notes
OUTPUT_DIR ?= out

all: build

# Build
build:
	mdbook build
	touch $(OUTPUT_DIR)/release.tar.gz
	tar cvzf "$(OUTPUT_DIR)/release.tar.gz" -C "$(OUTPUT_DIR)" --exclude="release.tar.gz" .

# Install
install:
	mkdir -p "$(DESTDIR)$(WWWROOT)$(WWWPREFIX)"
	cp -rf "$(OUTPUT_DIR)/." "$(DESTDIR)$(WWWROOT)$(WWWPREFIX)"

# Uninstall
uninstall:
	rm -rf "$(DESTDIR)$(WWWROOT)$(WWWPREFIX)"

# Run
run:
	mdbook serve

# Dev
dev:
	mdbook watch --open

# Clean
clean:
	rm -rf "$(OUTPUT_DIR)"
