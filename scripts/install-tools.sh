#!/bin/bash
# Purpose: Installs or upgrades essential development tools.
# Notes:
#   - Should be executed via the `make install-tools` command.
#   - Supports macOS for installations via `brew install`
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to install a tool
install() {
  local tool=$1
  local type=$2

  case $type in
    brew)
      install_brew "$tool"
      ;;
    helm_plugin)
      install_helm_plugin "$tool"
      ;;
    *)
      echo "Unsupported tool type: $type"
      exit 1
      ;;
  esac
}

# Function to install a Homebrew-based tool
install_brew() {
  if ! command -v brew &> /dev/null
  then
      echo "Homebrew could not be found. Please install Homebrew and try again."
      return
  fi

  local tool=$1
  local installed_version=$(brew list $tool --versions | awk '{print $2}')
  local latest_version=$(brew info --json=v1 "$tool" | jq -r '.[0].versions.stable')

  if [ "$installed_version" == "$latest_version" ]; then
    echo "$tool is already up to date (version $installed_version)."
    return
  elif [ ! -z "$installed_version" ] && [ "$installed_version" != "$latest_version" ]; then
    echo "$tool $installed_version is installed. A new version $latest_version is available. Continuing for now..."
    return
  fi
  echo "$tool (version $latest_version) is not installed, installing now..."
  brew install $tool || echo "Failed to install $tool. Continuing..."
}

# Function to install a helm plugin
install_helm_plugin() {
  if ! command -v helm &> /dev/null
  then
      echo "Helm could not be found. Please install Helm and try again."
      return
  fi
  local plugin="${1%%=*}"
  local repo="${1#*=}"
  local installed_version=$(helm plugin list | grep ${plugin} | awk '{print $2}')

  if [ -z "$installed_version" ]; then
    echo "Helm plugin ${plugin} is not installed, installing now..."
    helm plugin install ${repo} || echo "Failed to install plugin ${plugin}. Continuing..."
  else
    echo "Helm plugin ${plugin} (version: ${installed_version}) already installed."
  fi
}

# install brew-based tools
for tool in yq jq yamllint chart-testing helm kubectl pre-commit norwoodj/tap/helm-docs; do
  install "$tool" brew
done

# install helm plugin
install "unittest=https://github.com/helm-unittest/helm-unittest.git" helm_plugin

echo "Tool installation process completed!"
exit 0
