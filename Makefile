export USERNAME ?= seanstone
export REPO ?= arch-on-github

docker_run = docker run --rm --tty \
	--mount=type=bind,source=$(shell pwd),destination=/home/builduser/ \
	-e USERNAME=$(USERNAME) -e REPO=$(REPO) -e GITHUB_TOKEN=$(GITHUB_TOKEN) \
	$(USERNAME)/$(REPO):latest

.PHONY: pkg
pkg:
	mkdir -p build
	chmod 777 build
	for pkg in $(PKG); do \
		$(docker_run) ./build-package $$pkg; \
	done

.PHONY: clean
clean:
	rm -rf build

################################## Docker Image ###################################

ifndef DOCKER_PASSWORD
docker_login = docker login -u "$(USERNAME)"
else
docker_login = @echo "$(DOCKER_PASSWORD)" | docker login -u "$(USERNAME)" --password-stdin
endif

.PHONY: image
image:
	docker build --pull --tag=$(USERNAME)/$(REPO):latest --build-arg USERNAME=$(USERNAME) --build-arg REPO=$(REPO) - < Dockerfile
	$(docker_login)
	docker push $(USERNAME)/$(REPO):latest