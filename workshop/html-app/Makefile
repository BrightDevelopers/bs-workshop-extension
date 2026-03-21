.DEFAULT_GOAL := help

SD_DIR   := sd
DIST_DIR := dist

.PHONY: help prep build publish clean

help: ## Print available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*##"}; {printf "  %-12s %s\n", $$1, $$2}'

prep: ## Install Node dependencies (npm install)
	npm install

build: ## Bundle src/ into dist/ via webpack
	npm run build

publish: build ## Copy dist/ and autorun.brs into sd/ for SD card deployment
	mkdir -p $(SD_DIR)/dist
	cp -r $(DIST_DIR)/. $(SD_DIR)/dist/
	cp src/autorun.brs $(SD_DIR)/autorun.brs
	@echo ""
	@echo "SD card contents ready at $(SD_DIR)/"
	@echo "Copy to your SD card root: cp -r $(SD_DIR)/. /path/to/sdcard/"

clean: ## Remove dist/, sd/, and node_modules/
	rm -rf $(DIST_DIR) $(SD_DIR) node_modules
