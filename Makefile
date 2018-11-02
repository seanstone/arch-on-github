REPOSITORY ?= github
REPO_DB := build/repo/$(REPOSITORY).db.tar.xz
DOCKER_IMAGE := seanstone/arch-repo-builder
DOCKER_CONTAINER := arch-repo-builder

.PHONY: image
image:
	docker build --pull --tag=$(DOCKER_IMAGE) .

.PHONY: container
container:
	docker run -td \
	--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
	--name=$(DOCKER_CONTAINER) $(DOCKER_IMAGE)

.PHONY: makepkg-%
makepkg-%: build-package
	docker exec --tty $(DOCKER_CONTAINER) ./build-package $*

$(REPO_DB): build-repo packages.txt
	docker exec --tty $(DOCKER_CONTAINER) ./build-repo $(REPOSITORY)

.PHONY: repo
repo: $(REPO_DB)
	mkdir -p repo
	cp build/packages/* repo
	cp build/repo/* repo

.PHONY: clean
clean:
	rm -rf build repo
