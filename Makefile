EXTENSION_DIR   := workshop/04-build/java/hello-extension
INSTALL_DIR     := $(EXTENSION_DIR)/install
COMMON_SCRIPTS  := ../extension-template/examples/common-scripts
JAR_NAME        := hello-extension-1.0.0.jar
EXTENSION_NAME  := hello_extension

.PHONY: help build download-jre package test-local clean

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
	$(MAKE) -C $(EXTENSION_DIR) package

test-local: build ## Build, run the extension locally, verify the HTTP endpoint, then stop
	$(MAKE) -C $(EXTENSION_DIR) test-local

clean: ## Remove build artifacts, install directory, and ZIP files
	$(MAKE) -C $(EXTENSION_DIR) clean
