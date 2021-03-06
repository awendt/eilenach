.PHONY: clean deploy guard-%

SITE_PACKAGES = env/lib/python3.7/site-packages
FINTS_LIBRARY = $(SITE_PACKAGES)/fints
COMMIT_SHA = $(shell git rev-parse --short head)
ZIPFILE = $(abspath ./bookkeeper.zip)
DEFAULT_PACKAGES = __pycache__ easy_install pip pkg_resources setuptools

bookkeeper.zip: $(FINTS_LIBRARY) bookkeeper.py
	rm -f $(ZIPFILE)
	zip -9 -r $(ZIPFILE) bookkeeper.py
	cd $(SITE_PACKAGES) && zip -q -9 -r $(ZIPFILE) *
	zip -q -9 -d $(ZIPFILE) $(addsuffix \*, $(DEFAULT_PACKAGES))
	cp $(ZIPFILE) $(ZIPFILE:.zip=-$(COMMIT_SHA).zip)

install: $(FINTS_LIBRARY)

$(FINTS_LIBRARY): env/bin/pip3 requirements-freeze.txt
	env/bin/pip3 install -r requirements-freeze.txt

clean:
	python3 -m venv env --clear

upgrade:
	python3 -m venv env --clear
	env/bin/pip3 install -r requirements.txt
	env/bin/pip3 freeze > requirements-freeze.txt
	python3 -m venv env --clear

env/bin/pip3:
	python3 -m venv env

# inspired by https://stackoverflow.com/a/7367903/473467
guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

PACKAGE ?= $(ZIPFILE)

deploy: guard-AWS_PROFILE $(PACKAGE)
	aws lambda update-function-code --function-name bookkeeper --zip-file fileb://$(PACKAGE)
