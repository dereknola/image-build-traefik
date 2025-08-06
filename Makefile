SEVERITIES = HIGH,CRITICAL

UNAME_M = $(shell uname -m)
ifndef TARGET_PLATFORMS
	ifeq ($(UNAME_M), x86_64)
		TARGET_PLATFORMS:=linux/amd64
	else ifeq ($(UNAME_M), aarch64)
		TARGET_PLATFORMS:=linux/arm64
	else 
		TARGET_PLATFORMS:=linux/$(UNAME_M)
	endif
endif

REPO ?= rancher
PKG ?= github.com/traefik/traefik/v3
BUILD_META=-build$(shell date +%Y%m%d)
TAG ?= $(if $(GITHUB_ACTION_TAG),$(GITHUB_ACTION_TAG),v3.5.0$(BUILD_META))

ifeq (,$(filter %$(BUILD_META),$(TAG)))
$(error TAG needs to end with build metadata: $(BUILD_META))
endif

.PHONY: image-build
image-build:
	docker buildx build \
		--progress=plain \
		--platform=$(TARGET_PLATFORMS) \
		--pull \
		--build-arg PKG=$(PKG) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(REPO)/hardened-traefik:$(TAG) \
		--load \
	.

.PHONY: image-push
image-push:
		docker buildx build \
		--progress=plain \
		--platform=$(TARGET_PLATFORMS) \
		--pull \
		--build-arg PKG=$(PKG) \
		--build-arg TAG=$(TAG:$(BUILD_META)=) \
		--tag $(REPO)/hardened-traefik:$(TAG) \
		--push \
	.

.PHONY: image-scan
image-scan:
	trivy --severity $(SEVERITIES) --no-progress --ignore-unfixed $(REPO)/hardened-traefik:$(TAG)

.PHONY: log
log:
	@echo "TARGET_PLATFORMS=$(TARGET_PLATFORMS)"
	@echo "TAG=$(TAG:$(BUILD_META)=)"
	@echo "REPO=$(REPO)"
	@echo "SRC=$(SRC)"
	@echo "BUILD_META=$(BUILD_META)"
	@echo "UNAME_M=$(UNAME_M)"