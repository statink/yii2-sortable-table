ASSETS := \
	assets/sortable-table.min.js \
	assets/sortable-table.min.js.br \
	assets/sortable-table.min.js.gz

.PHONY: all php js clean dist-clean
all: php js

php: vendor

dist-clean: clean
	rm -rf composer.phar vendor node_modules

clean:
	rm -rf assets/*.js assets/*.js.gz assets/*.js.br

vendor: composer.lock composer.phar
	COMPOSER_ALLOW_SUPERUSER=1 ./composer.phar install --prefer-dist -vvv

composer.lock: composer.json composer.phar
	COMPOSER_ALLOW_SUPERUSER=1 ./composer.phar update --prefer-dist -vvv

composer.phar:
	curl -sSL 'https://getcomposer.org/installer' | php -- --stable
	touch -r composer.json $@

js: $(ASSETS)

.PRECIOUS: %.js
%.js: %.es node_modules composer.json
	npx babel --presets=@babel/env -s false -o $@ $<

.PRECIOUS: %.min.js
%.min.js: %.js node_modules
	npx uglifyjs -c -m -o $@ $<

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
