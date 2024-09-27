##@ General
# The general settings and variables for the project
SHELL := /bin/bash

# TODO: Move CHART_FILE_PATH and VALUES_FILE_PATH here, currently set in multiple places
# The version of the chart
VERSION := $(shell grep "^version:" charts/splunk-synthetics-runner/Chart.yaml | awk '{print $$2}')

##@ Test
# Tasks related to testing the Helm chart

.PHONY: lint
lint: ## Lint the Helm chart with ct
	@echo "Linting Helm chart..."
	ct lint --config=ct.yaml || exit 1

.PHONY: pre-commit
pre-commit: render ## Test the Helm chart with pre-commit
	@echo "Checking the Helm chart with pre-commit..."
	pre-commit run --all-files || exit 1

.PHONY: unittest
unittest: ## Run unittests on the Helm chart
	@echo "Running unit tests on helm chart..."
	cd charts/splunk-synthetics-runner && helm unittest --strict -f "../../tests/unittests/*.yaml" . || exit 1
