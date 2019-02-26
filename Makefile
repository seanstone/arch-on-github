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

create-release:
	@CREATE_RELEASE=$$(curl -s -o /dev/null -w "%{http_code}" -u $(USERNAME) -d '{"tag_name": "latest"}' 'https://api.github.com/repos/$(USERNAME)/$(REPO)/releases');\
	case $$CREATE_RELEASE in\
		"422")\
			echo "Release already created"\
			;;\
		"201")\
			echo "Release created successfully"\
			;;\
	esac

define upload
	RELEASE_TAG=$$(curl -X GET https://api.github.com/repos/$(USERNAME)/$(REPO)/releases/tags/latest | jq -r '.id');\
	for f in $(1); do\
		curl \
			-u $(USERNAME) \
			-H "Content-Type: $$(file --mime-type -b $$f)" \
			--data-binary "@$$f" \
			"https://uploads.github.com/repos/$(USERNAME)/$(REPO)/releases/$$RELEASE_TAG/assets?name=$$(basename $$f)";\
	done
endef

asset:
	$(call upload,build/packages/*.pkg.tar.xz)