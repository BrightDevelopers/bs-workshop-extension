IMAGE := ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest

CONTAINER_TOOL := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)

.PHONY: help pull-container

help: ## Print available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-14s %s\n", $$1, $$2}'

pull-container: ## Pull (or update) the dev container image from GHCR
	@if [ -z "$(CONTAINER_TOOL)" ]; then echo "ERROR: neither podman nor docker found in PATH."; exit 1; fi
	$(CONTAINER_TOOL) pull $(IMAGE)
