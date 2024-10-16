#!/bin/bash

# Description: Checks if new runner image tag is available and
# updates the appVersion and version in the Chart.yaml file if necessary.
# User can override the new appVersion and chart version by setting the
# APP_VERSION and CHART_VERSION environment variables respectively.

# Requires yq and jq to be installed.

set -euo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
CHART_YAML_PATH="${SCRIPT_DIR}/../charts/splunk-synthetics-runner/Chart.yaml"

CURRENT_APP_VERSION=$(yq eval '.appVersion' ${CHART_YAML_PATH})
CURRENT_CHART_VERSION=$(yq eval '.version' ${CHART_YAML_PATH})
NEW_APP_VERSION=""

# Fetch the latest runner image tag from Quay.io
LATEST_RUNNER_TAG=$(curl -s "https://quay.io/api/v1/repository/signalfx/splunk-synthetics-runner/tag/?onlyActiveTags=true" \
-H "Accept: application/json" | \
jq -r '. as $orig |
.tags[] | select (.name == "latest") |
.manifest_digest as $latest | $orig.tags[] |
select(.manifest_digest == $latest and .name != "latest") | .name')
echo "The latest runner image tag available in quay.io is $LATEST_RUNNER_TAG"

NEW_APP_VERSION=${APP_VERSION:-$LATEST_RUNNER_TAG}

# Exit if current and new app versions are the same
if [ "$CURRENT_APP_VERSION" == "$NEW_APP_VERSION" ]; then
  echo "Runner image tag is already up to date (appVersion $CURRENT_APP_VERSION)."
  if [[ -n "${GITHUB_ACTIONS-}" ]]; then
    echo "NEEDS_UPDATE=0" >> "$GITHUB_OUTPUT"
  fi
  exit 0
else
  echo "Runner image tag is not up to date. Current appVersion is $CURRENT_APP_VERSION and the new appVersion is $NEW_APP_VERSION."
  if [[ -n "${GITHUB_ACTIONS-}" ]]; then
    echo "NEEDS_UPDATE=1" >> "$GITHUB_OUTPUT"
    echo "NEW_APP_VERSION=$NEW_APP_VERSION" >> "$GITHUB_OUTPUT"
  fi
fi

# Update the appVersion
NEW_APP_VERSION=${NEW_APP_VERSION} yq eval -i '.appVersion = strenv(NEW_APP_VERSION)' ${CHART_YAML_PATH}

# Update the chart version by bumping up the patch version
BUMPED_PATCH_VERSION=$(echo ${CURRENT_CHART_VERSION} | awk -F. '{$NF = $NF + 1;} 1' | sed 's/ /./g')
NEW_CHART_VERSION=${CHART_VERSION:-$BUMPED_PATCH_VERSION}

echo "Updating the chart version to $NEW_CHART_VERSION"
NEW_CHART_VERSION=${NEW_CHART_VERSION} yq eval -i '.version = strenv(NEW_CHART_VERSION)' ${CHART_YAML_PATH}

if [[ -n "${GITHUB_ACTIONS-}" ]]; then
  echo "NEW_CHART_VERSION=$NEW_CHART_VERSION" >> "$GITHUB_OUTPUT"
fi
