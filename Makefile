EXTENSION_DIR   := workshop/04-build/java/hello-extension
INSTALL_DIR     := $(EXTENSION_DIR)/install
COMMON_SCRIPTS  := ../extension-template/examples/common-scripts
JAR_NAME        := hello-extension-1.0.0.jar
EXTENSION_NAME  := hello_extension

IMAGE           := ghcr.io/brightsign-playground/bs-extension-workshop-devenv:latest
GHCR_ORG        := brightsign-playground
GHCR_PKG        := bs-extension-workshop-devenv

CONTAINER_TOOL  := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)

.PHONY: help build download-jre package test-local clean build-container pull-container

help: ## Print available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-14s %s\n", $$1, $$2}'

build: ## Build the extension JAR
	$(MAKE) -C $(EXTENSION_DIR) build

download-jre: ## Download Temurin JRE 11 for linux/aarch64 (required for packaging)
	$(MAKE) -C $(EXTENSION_DIR) download-jre

package: download-jre ## Build JAR, bundle JRE, and produce the deployable extension ZIP
	@if [ ! -d "$(COMMON_SCRIPTS)" ]; then \
		echo ""; \
		echo "ERROR: common-scripts not found at $(COMMON_SCRIPTS)"; \
		echo "       Run: git clone https://github.com/brightsign/extension-template"; \
		echo "       alongside this repository (one level up), then retry."; \
		echo ""; \
		exit 1; \
	fi
	$(MAKE) -C $(EXTENSION_DIR) package COMMON_SCRIPTS=$(abspath $(COMMON_SCRIPTS))

test-local: build ## Build, run the extension locally, verify the HTTP endpoint, then stop
	$(MAKE) -C $(EXTENSION_DIR) test-local

clean: ## Remove build artifacts, install directory, and ZIP files
	$(MAKE) -C $(EXTENSION_DIR) clean

build-container: ## Build dev container and push to GHCR as public image (requires GITHUB_TOKEN with write:packages)
	@if [ -z "$(CONTAINER_TOOL)" ]; then echo "ERROR: neither podman nor docker found in PATH."; exit 1; fi
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "ERROR: GITHUB_TOKEN is not set."; \
		echo "       Export a token with write:packages scope and retry."; \
		exit 1; \
	fi
	echo "$(GITHUB_TOKEN)" | $(CONTAINER_TOOL) login ghcr.io -u "$(GITHUB_USER)" --password-stdin
	$(CONTAINER_TOOL) build --platform linux/amd64 -t $(IMAGE) docker/
	$(CONTAINER_TOOL) push $(IMAGE)
	curl -sf -X PATCH \
		-H "Authorization: Bearer $(GITHUB_TOKEN)" \
		-H "Accept: application/vnd.github+json" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/orgs/$(GHCR_ORG)/packages/container/$(GHCR_PKG)" \
		-d '{"visibility":"public"}' \
		| jq .
	@echo "Done: $(IMAGE) is public."

pull-container: ## Pull the dev container image from GHCR
	@if [ -z "$(CONTAINER_TOOL)" ]; then echo "ERROR: neither podman nor docker found in PATH."; exit 1; fi
	$(CONTAINER_TOOL) pull $(IMAGE)
