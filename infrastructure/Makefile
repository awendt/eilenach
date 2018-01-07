.PHONY: all check-env

all: check-env
	terraform apply

# inspired by https://stackoverflow.com/a/4731504/473467
# ifndef and endif are not indented
check-env: 
ifndef AWS_PROFILE
    $(error env variable AWS_PROFILE is undefined)
endif
