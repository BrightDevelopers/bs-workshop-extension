EXTENSION_DIR   := workshop/04-build-java/hello-extension
INSTALL_DIR     := $(EXTENSION_DIR)/install
COMMON_SCRIPTS  := ../extension-template/examples/common-scripts
JAR_NAME        := hello-extension-1.0.0.jar
EXTENSION_NAME  := hello_extension

.PHONY: help build package test-local clean

## Print available targets
help:
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-14s %s\n", $$1, $$2}'

## Build the extension JAR
build:
	cd $(EXTENSION_DIR) && mvn clean package -q

## Build and produce the deployable extension ZIP
package: build
	@if [ ! -d "$(COMMON_SCRIPTS)" ]; then \
		echo ""; \
		echo "ERROR: common-scripts not found at $(COMMON_SCRIPTS)"; \
		echo "       Run: git clone https://github.com/brightsign/extension-template"; \
		echo "       alongside this repository (one level up), then retry."; \
		echo ""; \
		exit 1; \
	fi
	mkdir -p $(INSTALL_DIR)
	cp $(EXTENSION_DIR)/target/$(JAR_NAME) $(INSTALL_DIR)/
	cp $(EXTENSION_DIR)/bsext_init $(INSTALL_DIR)/
	cd $(EXTENSION_DIR) && ../../$(COMMON_SCRIPTS)/pkg-dev.sh install lvm $(EXTENSION_NAME)

## Build, run locally, curl the endpoint, then stop
test-local: build
	java -jar $(EXTENSION_DIR)/target/$(JAR_NAME) & \
	BSX_PID=$$!; \
	sleep 2; \
	curl -sf http://localhost:8080/ ; \
	CURL_EXIT=$$?; \
	kill $$BSX_PID 2>/dev/null; \
	exit $$CURL_EXIT

## Remove build artifacts, install directory, and ZIP files
clean:
	cd $(EXTENSION_DIR) && mvn clean -q
	rm -rf $(INSTALL_DIR)
	rm -f $(EXTENSION_DIR)/$(EXTENSION_NAME)-*.zip
