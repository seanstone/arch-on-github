
REPOSITORY ?= github
REPO_DB := build/repo/$(REPOSITORY).db.tar.xz

all: repo

repo: $(REPO_DB)
	mkdir -p repo
	cp build/packages/* repo
	cp build/repo/* repo

$(REPO_DB): build-repo packages.txt
	docker run \
		--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
		--name=arch-repo-builder \
		--rm \
		--tty \
			alexandrecarlton/arch-repo-builder \
			./build-repo $(REPOSITORY)

build-image:
	docker build \
		--pull \
		--tag=alexandrecarlton/arch-repo-builder \
		.
.PHONY: build-image

clean:
	rm -rf build repo
.PHONY: clean
