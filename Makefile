# All these targets do not refer to actual files,
# see https://stackoverflow.com/a/2145605/473467
.PHONY: all beacon bookkeeper infrastructure

all: beacon bookkeeper infrastructure

beacon:
	$(MAKE) -C src/beacon

bookkeeper:
	$(MAKE) -C src/bookkeeper

infrastructure:
	$(MAKE) -C infrastructure
