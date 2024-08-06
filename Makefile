.PHONY: ${MAKECMDGOALS}

HOST_DISTRO = $$(grep ^ID /etc/os-release | cut -d '=' -f 2)
PKGMAN = $$(if [ "$(HOST_DISTRO)" = "fedora" ]; then echo "dnf" ; else echo "apt-get"; fi)
MOLECULE_SCENARIO ?= install
MOLECULE_DOCKER_IMAGE ?= ubuntu2204
MOLECULE_DOCKER_COMMAND ?= /lib/systemd/systemd
MOLECULE_KVM_IMAGE ?= https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img
GALAXY_API_KEY ?=
GITHUB_REPOSITORY ?= $$(git config --get remote.origin.url | cut -d: -f 2 | cut -d. -f 1)
GITHUB_ORG = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 1)
GITHUB_REPO = $$(echo ${GITHUB_REPOSITORY} | cut -d/ -f 2)
REQUIREMENTS = requirements.yml
ROLE_DIR = roles
ROLE_FILE = roles.yml
COLLECTION_NAMESPACE = $$(yq '.namespace' < galaxy.yml)
COLLECTION_NAME = $$(yq '.name' < galaxy.yml)
COLLECTION_VERSION = $$(yq '.version' < galaxy.yml)

all: install version lint test

test: lint
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

install:
	@type poetry >/dev/null 2>/dev/null 2>/dev/null || pip3 install poetry
	@type yq >/dev/null 2>/dev/null || sudo ${PKGMAN} install -y yq
	@type expect >/dev/null 2>/dev/null || sudo ${PKGMAN} install -y expect
	@type nmcli >/dev/null 2>/dev/null || sudo ${PKGMAN} install -y $$(if [[ "${HOST_DISTRO}" == "fedora" ]]; then echo NetworkManager; else echo network-manager; fi)
	@sudo ${PKGMAN} install -y xfsprogs
	@sudo ${PKGMAN} install -y $$(if [[ "${HOST_DISTRO}" == "fedora" ]]; then echo libvirt-devel; else echo libvirt-dev; fi)
	@poetry install --no-root

lint: install
	poetry run yamllint .
	poetry run ansible-lint .

requirements: install
	@rm -rf ${ROLE_DIR}/*
	@python --version
	[ -f ${ROLE_FILE} ] && \
		poetry run ansible-galaxy role install \
			--force --no-deps \
			--roles-path ${ROLE_DIR} \
			--role-file ${ROLE_FILE}
	@poetry run ansible-galaxy collection install \
		--force-with-deps .
	@\find ./ -name "*.ymle*" -delete

build: requirements
	@poetry run ansible-galaxy collection build --force

dependency create prepare converge idempotence side-effect verify destroy cleanup reset list:
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO}

ifeq (login,$(firstword $(MAKECMDGOALS)))
    LOGIN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
    $(eval $(subst $(space),,$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))):;@:)
endif

login:
	MOLECULE_KVM_IMAGE=${MOLECULE_KVM_IMAGE} \
	MOLECULE_DOCKER_COMMAND=${MOLECULE_DOCKER_COMMAND} \
	MOLECULE_DOCKER_IMAGE=${MOLECULE_DOCKER_IMAGE} \
	poetry run molecule $@ -s ${MOLECULE_SCENARIO} ${LOGIN_ARGS}

ignore:
	@poetry run ansible-lint --generate-ignore

clean: destroy reset
	@poetry env remove $$(which python) >/dev/null 2>&1 || exit 0

publish: build
	poetry run ansible-galaxy collection publish --api-key ${GALAXY_API_KEY} \
		"${COLLECTION_NAMESPACE}-${COLLECTION_NAME}-${COLLECTION_VERSION}.tar.gz"

version:
	@poetry run molecule --version

debug: version
	@poetry export --dev --without-hashes
