SLIDE_DIR  := docs/asciidoc
SITE_DIR := build/site
RESOURCE_SOURCE_DIR := static
RESOURCE_TARGET_DIR := $(SITE_DIR)/

# Reveal.js
REVEALJS_CACHE_DIR := build/.cache/reveal.js
REVEALJS_DIR := $(SITE_DIR)/reveal.js
REVEAL := https://cdn.jsdelivr.net/npm/reveal.js@6.0.2

SLIDE_SOURCES := $(wildcard $(SLIDE_DIR)/*.adoc)
SLIDE_TARGETS := $(patsubst $(SLIDE_DIR)/%.adoc, $(SITE_DIR)/%.html, $(SLIDE_SOURCES))

.PHONY: clean slides serve install update site

site: slides

$(SITE_DIR)/%.html: $(SLIDE_DIR)/%.adoc 
	@echo '[Generating Reveal.js website]'
	npx asciidoctor-revealjs \
		--attribute revealjs_customtheme=css/stereopticon.css \
		--attribute customcss=css/custom.css \
		--attribute revealjs_width=1880 \
		--attribute revealjs_height=1080 \
		--attribute revealjs_center=false \
		--attribute revealjs_display=flex \
		--attribute revealjs_transition=none \
		--attribute revealjs_slideNumber=c/t \
		--attribute revealjs_theme=black \
		--attribute revealjs_history=true \
		--attribute revealjs_margin=0 \
		--attribute revealjs_progress=true \
		--attribute revealjsdir=$(REVEAL) \
		-v \
		-o $@ $<


slides: resources $(SLIDE_TARGETS)
#slides: $(SLIDE_TARGETS)
	bundle exec asciidoctor-revealjs --version


resources: prepare 
	@echo '[Preparing resources]'
	rsync -r $(RESOURCE_SOURCE_DIR)/  $(RESOURCE_TARGET_DIR)

prepare: $(REVEALJS_DIR)

$(REVEALJS_CACHE_DIR):
	git clone -b 4.5.0 --depth 1 https://github.com/hakimel/reveal.js.git $(REVEALJS_CACHE_DIR) 2> /dev/null || (cd $(REVEALJS_CACHE_DIR) ; git pull)
	mkdir -p $(SITE_DIR)/reveal.js

$(REVEALJS_DIR): $(REVEALJS_CACHE_DIR)
	rsync -r -r $(REVEALJS_CACHE_DIR)/dist $(REVEALJS_DIR)
	rsync -r -r $(REVEALJS_CACHE_DIR)/plugin $(REVEALJS_DIR)

clean:
	rm -rf build

serve:
	bundle exec adsf  -L -r ./build/site

install:
	bundle install

update:
	git submodule update --remote --merge
	git submodule update --init --recursive
