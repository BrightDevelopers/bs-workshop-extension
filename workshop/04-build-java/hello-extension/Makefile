.DEFAULT_GOAL := help

INSTALL_DIR := install
JAR_NAME    := hello-extension-1.0.0.jar
JAR_PATH    := target/$(JAR_NAME)

.PHONY: help build package test-local clean

help:
	@echo "Targets:"
	@echo "  build       - build the fat JAR (mvn clean package)"
	@echo "  package     - copy artifacts into install/ and create extension package"
	@echo "  test-local  - run the extension locally and verify the HTTP endpoint"
	@echo "  clean       - remove build artifacts, install/, and *.zip"

build:
	mvn clean package -q

package: build
	mkdir -p $(INSTALL_DIR)
	cp $(JAR_PATH) $(INSTALL_DIR)/$(JAR_NAME)
	cp bsext_init $(INSTALL_DIR)/bsext_init
	../../common-scripts/pkg-dev.sh install lvm hello_extension

test-local: build
	@echo "Starting extension in background..." ; \
	java -jar $(JAR_PATH) & EXT_PID=$$! ; \
	sleep 3 ; \
	echo "Sending test request..." ; \
	curl -sf http://localhost:8080/ | python3 -m json.tool ; \
	echo "Stopping extension..." ; \
	kill $$EXT_PID 2>/dev/null ; \
	true

clean:
	mvn clean -q
	rm -rf $(INSTALL_DIR) *.zip
