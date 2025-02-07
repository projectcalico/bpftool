# Shortcut targets
default: all

## Build binary for current platform
all: image

###############################################################################
# Input parameters.
###############################################################################
DOCKER_PLATFORMS ?= linux/amd64,linux/arm64/v8,linux/ppc64le,linux/s390x
VERSION ?= v7.5.0
IMAGE_ORG ?= calico
IMAGE ?= $(IMAGE_ORG)/bpftool:$(VERSION)
SOURCEREF ?= $(VERSION)
SOURCEREPO ?= https://github.com/libbpf/bpftool.git

###############################################################################
# Building the images
###############################################################################

PLATFORM_ARG=--platform $(DOCKER_PLATFORMS)

image-single-platform:
	$(MAKE) image PLATFORM_ARG=

image: register
	docker buildx build \
	       $(PUSH_ARG) \
		   $(PLATFORM_ARG) \
	       --build-arg SOURCE_REF=$(SOURCEREF) \
	       --build-arg SOURCE_REPO=$(SOURCEREPO) \
	       --tag $(IMAGE) .

push:
	$(MAKE) image PUSH_ARG=--push 

# Enable support for non-native binaries so that cross-platform builds can be
# done. This is needed for the buildx build command.
# See https://docs.docker.com/build/building/multi-platform/#install-qemu-manually
.PHONY: register
register:
	docker run --privileged --rm tonistiigi/binfmt --install all

###############################################################################
# UTs
###############################################################################
test:
	docker run --rm $(IMAGE) /bpftool version | grep -q "bpftool v"
	@echo "success"

###############################################################################
# CI
###############################################################################
.PHONY: ci
## Run what CI runs
ci: image test

###############################################################################
# CD
###############################################################################
.PHONY: cd
## Deploys images to registry
cd:
ifndef CONFIRM
	$(error CONFIRM is undefined - run using make <target> CONFIRM=true)
endif
	$(MAKE) push
