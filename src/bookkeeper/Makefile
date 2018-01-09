.PHONY: deploy guard-%

bookkeeper.zip: tmp/fints bookkeeper.py
	zip -9 -r bookkeeper bookkeeper.py
	cd tmp && zip -9 -r ../bookkeeper *

tmp:
	mkdir tmp

tmp/fints: tmp requirements.txt
	pip3 install -r requirements.txt -t tmp

# inspired by https://stackoverflow.com/a/7367903/473467
guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

deploy: guard-AWS_PROFILE bookkeeper.zip
	aws lambda update-function-code --function-name bookkeeper-mailer --zip-file fileb://bookkeeper.zip
