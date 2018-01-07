.PHONY: deploy guard-%

all: bookkeeper.zip

tmp:
	mkdir tmp

tmp/phantomjs-1.9.8-linux-x86_64:
	cd tmp && wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-1.9.8-linux-x86_64.tar.bz2
	tar -C tmp -xvzf tmp/phantomjs-1.9.8-linux-x86_64.tar.bz2

tmp/phantomjs: tmp tmp/phantomjs-1.9.8-linux-x86_64
	cp tmp/phantomjs-1.9.8-linux-x86_64/bin/phantomjs tmp

node_modules:
	npm install --production

bookkeeper.zip: node_modules tmp/phantomjs balance.js index.js
	zip -9 -r bookkeeper.zip balance.js index.js package.json package-lock.json node_modules
	zip -9 --junk-paths bookkeeper.zip tmp/phantomjs

# inspired by https://stackoverflow.com/a/7367903/473467
guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

deploy: guard-AWS_PROFILE bookkeeper.zip
	aws lambda update-function-code --function-name bookkeeper-mailer --zip-file fileb://bookkeeper.zip
