##@ General
# The general settings and variables for the project
SHELL := /bin/bash

# The version of the chart
VERSION := $(shell grep "^version:" charts/splunk-synthetics-runner/Chart.yaml | awk '{print $$2}')

##@ Test
# Tasks related to testing the Helm chart

.PHONY: lint
lint: ## Lint the Helm chart with ct
	@echo "Linting Helm chart..."
	ct lint --config=ct.yaml || exit 1

.PHONY: pre-commit
pre-commit: ## Test the Helm chart with pre-commit
	@echo "Checking the Helm chart with pre-commit..."
	pre-commit run --all-files || exit 1

.PHONY: unittest
unittest: ## Run unittests on the Helm chart
	@echo "Running unit tests on helm chart..."
	helm unittest --strict -f "../../tests/unittests/*.yaml" charts/splunk-synthetics-runner || exit 1

.PHONY: docs
docs: ## Run unittests on the Helm chart
	@echo "Update docs for helm chart..."
	helm-docs --chart-search-root=charts/ || exit 1

.PHONY: install-tools
install-tools: ## Install tools (macOS)
	LOCALBIN=$(LOCALBIN) scripts/install-tools.sh || exit 1
