
REPOSITORY ?= github
REPO_DB := build/repo/$(REPOSITORY).db.tar.xz

all: repo

repo: $(REPO_DB)
	mkdir -p repo
	cp build/packages/* repo
	cp build/repo/* repo

$(REPO_DB): build-repo packages.txt
	docker run \
		--name=arch-repo-builder \
		--tty \
			alexandrecarlton/arch-repo-builder \
			./build-repo $(REPOSITORY)
	docker cp arch-repo-builder:/home/builduser/build .
	docker rm arch-repo-builder

build-image:
	docker build \
		--pull \
		--tag=alexandrecarlton/arch-repo-builder \
		.
.PHONY: build-image

delete-latest:
	docker run \
		--name=arch-repo-builder \
		--rm \
		--tty \
			alexandrecarlton/arch-repo-builder \
			./delete-release latest
	docker

clean:
	rm -rf build repo
.PHONY: clean
