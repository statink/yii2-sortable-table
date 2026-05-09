ASSETS := \
	assets/sortable-table.min.js \
	assets/sortable-table.min.js.br \
	assets/sortable-table.min.js.gz

TS_SOURCES := \
	assets/sortable-table.ts \
	assets/types/stupid-table-plugin.d.ts

.PHONY: all php js typecheck lint clean dist-clean
all: php js

php: vendor

dist-clean: clean
	rm -rf composer.phar vendor node_modules

clean:
	rm -rf assets/*.js assets/*.js.gz assets/*.js.br assets/*.tsbuildinfo

vendor: composer.lock composer.phar
	./composer.phar install --prefer-dist

composer.lock: composer.json composer.phar
	./composer.phar update --prefer-dist

composer.phar:
	curl -sSL 'https://getcomposer.org/installer' | php -- --stable
	touch -r composer.json $@

js: $(ASSETS)

typecheck: node_modules
	npx tsc --noEmit

lint: node_modules
	npx eslint .

.PRECIOUS: assets/%.js
assets/sortable-table.js: $(TS_SOURCES) node_modules tsconfig.json
	npx tsc

.PRECIOUS: %.min.js
%.min.js: %.js node_modules
	npx terser --compress --mangle --comments '/^!/' -o $@ -- $<

node_modules: package-lock.json
	npm install
	touch $@

package-lock.json: package.json
	npm update
	touch $@

%.gz: %
	gzip -9 < $< > $@

BROTLI := $(shell if [ -e /usr/bin/brotli ]; then echo brotli; else echo bro; fi )
%.br: %
ifeq ($(BROTLI),bro)
	bro --quality 11 --force --input $< --output $@ --no-copy-stat
else
	brotli -Zfo $@ $<
endif
	@chmod 644 $@
	@touch $@
