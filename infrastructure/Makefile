.PHONY: all require-aws-profile

all: require-aws-profile
	terraform apply

# inspired by https://stackoverflow.com/a/4731504/473467
# ifndef and endif are not indented
require-aws-profile:
ifndef AWS_PROFILE
    $(error env variable AWS_PROFILE is undefined)
endif
