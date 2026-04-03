#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR"/handlers/shared/entrypoint_utils.sh

enable_tcmalloc_preload
source_start_handlers "$SCRIPT_DIR"
source_install_handlers "$SCRIPT_DIR"

NETWORK_VOLUME="/workspace"
export NETWORK_VOLUME

mark_failed_setup_progress_on_exit() {
    local exit_code="$1"
    if [ "$exit_code" -eq 0 ]; then
        return 0
    fi
    if declare -F setup_progress_mark_failed >/dev/null 2>&1; then
        setup_progress_mark_failed "Installation failed. Check terminal logs for the exact error." || true
    fi
}

trap 'exit_code=$?; mark_failed_setup_progress_on_exit "$exit_code"' EXIT

if ! prompt_and_prepare_project_manifest_from_url; then
    exit 1
fi

save_selected_project_manifest "$SELECTED_PROJECT_KEY" "$SELECTED_PROJECT_MANIFEST_PATH" "$SELECTED_PROJECT_SOURCE_URL"
echo "Selected project: $SELECTED_PROJECT_KEY"

if ! run_comfyui_install_flow; then
    exit 1
fi
