rwildcard=$(wildcard $1$2) $(foreach d,$(wildcard $1*),$(call rwildcard,$d/,$2))
PWD ?= $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
ifeq ($(UNAME),Darwin)
	SHELL := /opt/local/bin/bash
	OS_X  := true
else ifneq (,$(wildcard /etc/redhat-release))
	OS_RHEL := true
else
	OS_DEB  := true
	SHELL := /bin/bash
endif 
bold := $(shell tput bold)
sgr0 := $(shell tput sgr0)
THIS_FILE := $(firstword $(MAKEFILE_LIST))
SELF_DIR := $(dir $(THIS_FILE))
PROJECT_NAME := $(notdir $(CURDIR))
GIT_USER_NAME ?= $(shell git config user.name)
VERSION   ?= $(shell git describe --tags)
REVISION  ?= $(shell git rev-parse HEAD)
BRANCH    ?= $(shell git rev-parse --abbrev-ref HEAD)
BUILDUSER ?= $(shell id -un)
BUILDTIME ?= $(shell date '+%Y%m%d-%H:%M:%S')
MAJORVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// |  awk -F. '{print $$1+1".0.0"}')
MINORVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// | awk -F. '{print $$1"."$$2+1".0"}')
PATCHVERSION ?= $(shell git describe --tags --abbrev=0 | sed s/v// | awk -F. '{print $$1"."$$2"."$$3+1}')
.PHONY: git
.SILENT: git
git:
	- $(info VERSION = $(VERSION))
	- $(info REVISION = $(REVISION))
	- $(info BRANCH = $(BRANCH))
	- $(info BUILDUSER = $(BUILDUSER))
	- $(info BUILDTIME = $(BUILDTIME))
	- $(info MAJORVERSION = $(MAJORVERSION))
	- $(info MINORVERSION = $(MINORVERSION))
	- $(info PATCHVERSION = $(PATCHVERSION))
.PHONY: release-major
.SILENT: release-major
release-major:
	- git checkout master
	- git pull
	- git tag -a v$(MAJORVERSION) -m 'release $(MAJORVERSION)'
	- git push origin --tags
.PHONY: release-minor
.SILENT: release-minor
release-minor:
	- git checkout master
	- git pull
	- git tag -a v$(MINORVERSION) -m 'release $(MINORVERSION)'
	- git push origin --tags
.PHONY :release-patch
.SILENT :release-patch
release-patch:
	- git checkout master
	- git pull
	- git tag -a v$(PATCHVERSION) -m 'release $(PATCHVERSION)'
	- git push origin --tags
.PHONY: clean
.SILENT: clean
clean:
	- $(eval command=rm -rf $(PWD)/target)
	-@printf 'about to run the following command in '$(SHELL)' shell\n$(bold)${command}$(sgr0)\n'
	$(command)
.PHONY: build
.SILENT: build
build: clean
ifeq (, $(shell  which cargo))
	- $(error "'cargo'not found in path. aborting ...")
endif
ifeq (, $(shell  which upx))
	- $(error "'upx'not found in path. aborting ...")
endif
	- $(eval command=cargo build --release)
	- $(eval command=$(command) && strip $(PWD)/target/release/http-echo)
	- $(eval command=$(command) && upx)
	- $(eval command=$(command) --best $(PWD)/target/release/http-echo)
	- $(eval command=$(command) -o $(PWD)/target/release/entrypoint)
	- $(eval command=$(command) && $(PWD)/target/release/entrypoint --version)
	-@printf 'about to run the following command in '$(SHELL)' shell\n$(bold)${command}$(sgr0)\n'
	$(command)
.PHONY: image
.SILENT: image
image:
ifeq (, $(shell which docker))
	- $(error "'docker' not found in path. aborting ...")
endif
	- $(eval command=docker rmi fjolsvin/$(PROJECT_NAME):$(VERSION) --force || true)
	- $(eval command=$(command) && docker rmi fjolsvin/$(PROJECT_NAME):latest --force || true)
	- $(eval command=$(command) && docker system prune --force)
	- $(eval command=$(command) && [ -r $(PWD)/.env ] && source $(PWD)/.env || true )
	- $(eval command=$(command) && docker build)
	- $(eval command=$(command) --build-arg GITHUB_REPOSITORY_OWNER=$(GIT_USER_NAME))
	- $(eval command=$(command) --build-arg GITHUB_REPOSITORY=$(PROJECT_NAME))
	- $(eval command=$(command) --build-arg GITHUB_ACTOR=$(GIT_USER_NAME))
	- $(eval command=$(command) --build-arg GITHUB_TOKEN=`printenv "GITHUB_TOKEN"`)
	- $(eval command=$(command) -t fjolsvin/$(PROJECT_NAME):$(VERSION))
	- $(eval command=$(command) -t fjolsvin/$(PROJECT_NAME):latest)
	- $(eval command=$(command) $(PWD)/contrib/docker)
	- $(eval command=$(command) && unset GITHUB_TOKEN)
	- $(eval command=$(command) && docker run --rm -it fjolsvin/$(PROJECT_NAME):$(VERSION) --version)
	-@printf 'about to run the following command in '$(SHELL)' shell\n$(bold)$(command)$(sgr0)\n'
	$(command)
push-image:
.PHONY: push-image
.SILENT: push-image
ifeq (, $(shell which docker))
	- $(error "'docker' not found in path. aborting ...")
endif
	- $(eval command=[ -r ~/.docker/config.json ] && docker push fjolsvin/$(PROJECT_NAME):$(VERSION))
	- $(eval command=$(command) && [ -r ~/.docker/config.json ] && docker push fjolsvin/$(PROJECT_NAME):latest)
	-@printf 'about to run the following command in '$(SHELL)' shell\n$(bold)$(command)$(sgr0)\n'
	$(command)
.AFTER :
	%if $(MAKESTATUS) == 2
	%echo Make: The final shell line exited with status: $(status)
	%endif