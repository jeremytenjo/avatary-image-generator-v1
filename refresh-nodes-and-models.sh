#!/usr/bin/env bash

set -euo pipefail

TCMALLOC="$(ldconfig -p | grep -Po "libtcmalloc.so.\d" | head -n 1 || true)"
if [ -n "${TCMALLOC:-}" ]; then
    export LD_PRELOAD="${TCMALLOC}"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
for handler_file in "$SCRIPT_DIR"/handlers/install/*.sh; do
    # shellcheck source=/dev/null
    source "$handler_file"
done

NETWORK_VOLUME="/workspace"
export NETWORK_VOLUME

set_install_manifest_url_default
set_network_volume_default

if ! load_install_manifest; then
    exit 1
fi

if ! ensure_comfyui_workspace; then
    exit 1
fi

set_model_directories

if ! require_install_tools; then
    exit 1
fi

echo "Ensuring required custom nodes are installed via latest manifest..."
if ! install_custom_nodes; then
    echo "❌ Custom node refresh failed."
    exit 1
fi

echo "Ensuring required models are installed via latest manifest..."
if ! install_models_with_comfy_cli; then
    echo "❌ Model refresh failed."
    exit 1
fi

echo "✅ Node and model refresh complete."
