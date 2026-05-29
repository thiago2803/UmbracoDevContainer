#!/usr/bin/env bash
set -euo pipefail

CERT_PASSWORD="${DEVCONTAINER_CERT_PASSWORD:-devcontainer-local-password}"
CERT_PATH="/workspace/.devcontainer/https/devcontainer-https.pfx"

mkdir -p /workspace/.devcontainer/https
if [ ! -f "$CERT_PATH" ]; then
  echo "Shared development certificate is missing at $CERT_PATH"
  echo "Run the devcontainer initialize command or rebuild the container so the host-side cert setup can export it."
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI not found. Installing..."
  export DEBIAN_FRONTEND=noninteractive
  sudo apt-get update
  sudo apt-get install -y curl ca-certificates lsb-release gnupg
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
fi

for n in $(seq 1 15); do
  set +e
  import_output=$(az appconfig kv import \
    --auth-mode anonymous \
    --endpoint http://appconfig:8483 \
    --source file \
    --path /workspace/infra/appconfig/appconfig.dev.json \
    --format json \
    --profile appconfig/kvset \
    --yes 2>&1)
  import_exit=$?
  set -e

  if [ "$import_exit" -eq 0 ]; then
    echo "App Configuration import completed."
    break
  fi

  if echo "$import_output" | grep -qi "unauthorized"; then
    echo "App Configuration import skipped (Unauthorized with anonymous auth)."
    echo "Container startup will continue; configure emulator credentials if seeding is required."
    break
  fi

  if [ "$n" -ge 15 ]; then
    echo "$import_output"
    echo "App Configuration import failed after 15 attempts"
    exit 1
  fi

  echo "$import_output"
  echo "App Configuration not ready yet, retrying..."
  sleep 2
done
