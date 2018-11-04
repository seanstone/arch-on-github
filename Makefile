REPOSITORY ?= github
DOCKER_USERNAME ?= seanstone
DOCKER_IMAGE ?= arch-on-github
PKG_LIST ?= packages.txt

.PHONY: pkg-list
pkg-list:
	mkdir -p build
	chmod 777 build
	docker run --tty \
		--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
		$(DOCKER_USERNAME)/$(DOCKER_IMAGE) ./build-package-list $(PKG_LIST)

.PHONY: image
image:
	@echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
	docker build --pull --tag=$(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest .
	docker push $(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest

.PHONY: repo
repo:
	mkdir -p repo
	chmod 777 repo
	cd repo && curl -s https://api.github.com/repos/seanstone/arch-on-github/releases/latest \
		| grep "browser_download_url.*" \
		| cut -d : -f 2,3 \
		| tr -d \" \
		| wget -qi -
	docker run --tty \
		--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
		$(DOCKER_USERNAME)/$(DOCKER_IMAGE) ./build-repo $(REPOSITORY)

.PHONY: clean
clean:
	rm -rf build repo
