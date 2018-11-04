REPOSITORY ?= github
REPO_DB := build/repo/$(REPOSITORY).db.tar.xz

.PHONY: image
image:
	@echo "$(DOCKER_PASSWORD)" | docker login -u "$(DOCKER_USERNAME)" --password-stdin
	docker build --pull --tag=$(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest .
	docker push $(DOCKER_USERNAME)/$(DOCKER_IMAGE):latest

.PHONY: pkg-%
pkg-%: build-package
	mkdir -p build
	chmod 777 build
	docker run --tty \
	--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
	$(DOCKER_USERNAME)/$(DOCKER_IMAGE) ./build-package $*

.PHONY: pkg
pkg: packages.txt
	while read -r package; do \
      $(MAKE) pkg-$$package; \
    done < packages.txt

$(REPO_DB): pkg
	docker run --tty \
	--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
	$(DOCKER_USERNAME)/$(DOCKER_IMAGE) ./build-repo $(REPOSITORY)

.PHONY: repo
repo: $(REPO_DB)
	mkdir -p repo
	cp build/packages/* repo
	cp build/repo/* repo

.PHONY: clean
clean:
	rm -rf build repo
