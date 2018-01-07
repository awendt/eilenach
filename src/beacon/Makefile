.PHONY: deploy guard-%

mailgun.zip: mailgun.js
	zip mailgun mailgun.js

# inspired by https://stackoverflow.com/a/7367903/473467
guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

deploy: guard-AWS_PROFILE mailgun.zip
	aws lambda update-function-code --function-name bookkeeper-mailer --zip-file fileb://mailgun.zip
