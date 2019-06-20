USERNAME ?= seanstone
REPO ?= arch-on-github
PKG_LIST ?= package-lists/packages.txt

docker_run = docker run --rm --tty \
	--mount=type=bind,source=$(shell pwd),destination=/root/ \
	-w /root/ \
	-e USERNAME=$(USERNAME) -e REPO=$(REPO) -e GITHUB_TOKEN=$(GITHUB_TOKEN) \
	archlinux/base:latest

.PHONY: pkg-list
pkg-list:
	mkdir -p build
	chmod 777 build
	$(docker_run) scripts/build-package rtl-sdr-git

.PHONY: image
image:
	docker build -t arch-on-github - < Dockerfile

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