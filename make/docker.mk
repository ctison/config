.PHONY: help build list push run rund rmi

DOCKER_IMAGE_NAME    ?= ctison/example
DOCKER_IMAGE_TAGS    ?= latest
DOCKER_REGISTRIES    ?= docker.io
DOCKER_BUILD_OPTIONS ?= # --squash
DOCKER_PUSH_OPTIONS  ?=
DOCKER_RUN_OPTIONS   ?= --rm
DOCKER_RUN_ARGS      ?=
DOCKER_RUND_OPTIONS  ?=
DOCKER_RUND_ARGS     ?=
DOCKER_RMI_OPTIONS   ?=

help:
	$(info $(USAGE))
	@true
define USAGE
usage: make COMMAND
make build            # build docker image: $(DOCKER_IMAGE_NAME) with tags: $(DOCKER_IMAGE_TAGS)
make list             # list all images named: $(DOCKER_IMAGE_NAME)
make push             # push all images named: $(DOCKER_IMAGE_NAME)
make run              # run interactively docker image: $(DOCKER_IMAGE_NAME)
make rund             # run as a daemon docker image: $(DOCKER_IMAGE_NAME)
make rmi              # remove docker image named $(DOCKER_IMAGE_NAME)
endef

build: ; $(call build,$(DOCKER_BUILD_OPTIONS),$(DOCKER_IMAGE_TAGS),$(DOCKER_IMAGE_NAME))
define build
	docker build $(1) $(foreach TAG,$(2),-t $(3):$(TAG)) .
endef

list: ; $(call list,$(DOCKER_IMAGE_NAME))
define list
	docker images $(1)
endef

push: ; $(call push,$(DOCKER_REGISTRIES),$(DOCKER_IMAGE_NAME),$(DOCKER_PUSH_OPTIONS))
define push
	@for REGISTRY in $(1) ; do \
		for IMAGE in `docker images $(2) --format '{{.Repository}}:{{.Tag}}'` ; do \
			[ "$${REGISTRY}" != "docker.io" ] && docker tag $${IMAGE} $${REGISTRY}/$${IMAGE} ; \
			docker push $(3) $${REGISTRY}/$${IMAGE} ; \
			[ "$${REGISTRY}" != "docker.io" ] && docker rmi $${REGISTRY}/$${IMAGE} ; \
		done ; \
	done
endef

run: ; $(call run,$(DOCKER_RUN_OPTIONS),$(DOCKER_IMAGE_NAME),$(DOCKER_RUN_ARGS))
define run
	docker run -it $(1) $(2) $(3)
endef

rund: ; $(call rund,$(DOCKER_RUND_OPTIONS),$(DOCKER_IMAGE_NAME),$(DOCKER_RUND_ARGS))
define rund
	docker run -d $(1) $(2) $(3)
endef

rmi: ; $(call rmi,$(DOCKER_RMI_OPTIONS),$(DOCKER_IMAGE_TAGS),$(DOCKER_IMAGE_NAME))
define rmi
	docker rmi $(1) $(foreach TAG,$(2),$(3):$(TAG))
endef