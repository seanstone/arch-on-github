REPOSITORY ?= github
DOCKER_USERNAME ?= seanstone
DOCKER_IMAGE ?= arch-on-github
PKG_LIST ?= package-lists/packages.txt

.PHONY: pkg-list
pkg-list:
	mkdir -p build
	chmod 777 build
	docker run --tty \
		--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
		$(DOCKER_USERNAME)/$(DOCKER_IMAGE) scripts/build-package-list $(PKG_LIST)

ifndef DOCKER_PASSWORD
docker_login = docker login -u "$(DOCKER_USERNAME)"
else
docker_login = @echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
endif

.PHONY: image
image:
	$(docker_login)
	docker build --pull --tag=$(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest .
	docker push $(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest

.PHONY: repo
repo:
	docker run --tty \
		--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
		$(DOCKER_USERNAME)/$(DOCKER_IMAGE) scripts/build-repo $(REPOSITORY)

.PHONY: clean
clean:
	rm -rf build repo
