.PHONY: deploy require-aws-profile

mailgun.zip: mailgun.js
	zip mailgun mailgun.js

# inspired by https://stackoverflow.com/a/4731504/473467
# ifndef and endif are not indented
require-aws-profile:
ifndef AWS_PROFILE
    $(error env variable AWS_PROFILE is undefined)
endif

deploy: require-aws-profile mailgun.zip
	aws lambda update-function-code --function-name bookkeeper-mailer --zip-file fileb://mailgun.zip
