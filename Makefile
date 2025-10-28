include ${MAKEFILE}

MOLECULE_DOCKER_IMAGE ?= ubuntu2204
MOLECULE_DOCKER_COMMAND ?= /lib/systemd/systemd

all: install version lint test
