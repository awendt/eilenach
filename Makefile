# All these targets do not refer to actual files,
# see https://stackoverflow.com/a/2145605/473467
.PHONY: all beacon bookkeeper infrastructure check

all: beacon bookkeeper infrastructure

beacon:
	$(MAKE) -C src/beacon

bookkeeper:
	$(MAKE) -C src/bookkeeper

check: check-aws check-pip3 check-terraform check-zip

RED=\033[0;31m
GREEN=\033[0;32m
NC=\033[0m

check-%:
	@command -v ${*} > /dev/null && echo "${GREEN}✔ $*${NC}" || echo "${RED}✘ $*${NC}"

infrastructure:
	$(MAKE) -C infrastructure
