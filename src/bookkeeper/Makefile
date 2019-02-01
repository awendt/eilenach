.PHONY: clean deploy guard-%

SITE_PACKAGES = env/lib/python3.7/site-packages
ZIPFILE = $(abspath ./bookkeeper.zip)
DEFAULT_PACKAGES = __pycache__ easy_install pip pkg_resources setuptools

bookkeeper.zip: install bookkeeper.py
	zip -9 -r $(ZIPFILE) bookkeeper.py
	cd $(SITE_PACKAGES) && zip -q -9 -r $(ZIPFILE) *
	zip -q -9 -d $(ZIPFILE) $(addsuffix \*, $(DEFAULT_PACKAGES))

install: env/bin/pip3 requirements-freeze.txt
	env/bin/pip3 install -r requirements-freeze.txt

clean:
	python3 -m venv env --clear

env/bin/pip3:
	python3 -m venv env

# inspired by https://stackoverflow.com/a/7367903/473467
guard-%:
	@ if [ "${${*}}" = "" ]; then \
	    echo "Environment variable $* not set"; \
	    exit 1; \
	fi

deploy: guard-AWS_PROFILE bookkeeper.zip
	aws lambda update-function-code --function-name bookkeeper --zip-file fileb://bookkeeper.zip
