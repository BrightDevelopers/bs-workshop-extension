IMAGE           := ghcr.io/brightdevelopers/bs-extension-workshop-devenv:latest
GHCR_ORG        := brightdevelopers
GHCR_PKG        := bs-extension-workshop-devenv

CONTAINER_TOOL  := $(shell command -v podman 2>/dev/null || command -v docker 2>/dev/null)
GITHUB_USER     ?= $(shell gh api user --jq .login 2>/dev/null)

.PHONY: help build-container pull-container

help: ## Print available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-14s %s\n", $$1, $$2}'

build-container: ## Build dev container and push to GHCR as public image (requires GITHUB_TOKEN with write:packages)
	@if [ -z "$(CONTAINER_TOOL)" ]; then echo "ERROR: neither podman nor docker found in PATH."; exit 1; fi
	@if [ -z "$(GITHUB_TOKEN)" ]; then \
		echo "ERROR: GITHUB_TOKEN is not set."; \
		echo "       Export a token with write:packages scope and retry."; \
		exit 1; \
	fi
	@if [ -z "$(GITHUB_USER)" ]; then \
		echo "ERROR: could not determine GitHub username."; \
		echo "       Run: GITHUB_USER=<your-github-username> make build-container"; \
		exit 1; \
	fi
	@echo "Building as GitHub user: $(GITHUB_USER)"
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
