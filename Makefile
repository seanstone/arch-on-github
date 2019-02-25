USERNAME ?= seanstone
REPO ?= arch-on-github
PKG_LIST ?= package-lists/packages.txt

docker_run = docker run --tty \
	--mount=type=bind,source=$(shell pwd),destination=/home/builduser \
	-e USERNAME=$(USERNAME) \
	-e REPO=$(REPO) \
	$(USERNAME)/$(REPO)

ifndef DOCKER_PASSWORD
docker_login = docker login -u "$(USERNAME)"
else
docker_login = @echo "$(DOCKER_PASSWORD)" | docker login -u "$(USERNAME)" --password-stdin
endif

.PHONY: pkg-list
pkg-list:
	mkdir -p build
	chmod 777 build
	$(docker_run) scripts/build-package-list $(PKG_LIST)

.PHONY: image
image:
	$(docker_login)
	docker build --pull --tag=$(USERNAME)/$(REPO):latest --cache-from $(USERNAME)/$(REPO):latest .
	docker push $(USERNAME)/$(REPO):latest

%:
	$(docker_run) scripts/build-package $@

.PHONY: repo
repo:
	$(docker_run) scripts/build-repo $(USERNAME)

.PHONY: clean
clean:
	rm -rf build

release:
	curl -u $(USERNAME) -d '{"tag_name": "latest"}' 'https://api.github.com/repos/$(USERNAME)/$(REPO)/releases'

asset:
	RELEASE_TAG=$$(curl -X GET https://api.github.com/repos/$(USERNAME)/$(REPO)/releases/tags/latest | jq -r '.id');\
	cd build/packages;\
	for f in *.pkg.tar.xz; do\
		echo $$f;\
		curl \
			-u $(USERNAME) \
			-H "Content-Type: $$(file --mime-type -b $$f)" \
			--data-binary $$f \
			"https://uploads.github.com/repos/$(USERNAME)/$(REPO)/releases/$$RELEASE_TAG/assets?name=$$f";\
	done