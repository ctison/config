include ../../x/make/docker.mk

DOCKER_IMAGE_NAME    := ctison/socat
DOCKER_BUILD_OPTIONS += --no-cache --pull

rund-docker:
	docker network create docker || true
	docker run -d \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--network docker \
		--name docker \
		$(DOCKER_IMAGE_NAME) \
		TCP-LISTEN:2375,reuseaddr,fork UNIX-CLIENT:/var/run/docker.sock