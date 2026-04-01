#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR"/handlers/shared/entrypoint_utils.sh

enable_tcmalloc_preload
source_start_handlers "$SCRIPT_DIR"
source_install_handlers "$SCRIPT_DIR"

NETWORK_VOLUME="/workspace"
export NETWORK_VOLUME

capture_previous_project_state_for_switch
trap cleanup_previous_project_snapshot_file EXIT

if ! prompt_and_prepare_project_manifest_from_url; then
    exit 1
fi

cleanup_previous_project_resources="no"
if [ -n "$PREVIOUS_PROJECT_SOURCE_URL" ] && [ "$PREVIOUS_PROJECT_SOURCE_URL" != "$SELECTED_PROJECT_SOURCE_URL" ]; then
    echo "Previous project: $PREVIOUS_PROJECT_KEY"
    echo "Selected project: $SELECTED_PROJECT_KEY"
    while true; do
        read -r -p "Remove resources from previous project? (y/n): " remove_choice
        case "$remove_choice" in
            y|Y|yes|YES)
                cleanup_previous_project_resources="yes"
                break
                ;;
            n|N|no|NO)
                cleanup_previous_project_resources="no"
                break
                ;;
            *)
                echo "Invalid choice. Enter 'y' or 'n'."
                ;;
        esac
    done
fi

save_selected_project_manifest "$SELECTED_PROJECT_KEY" "$SELECTED_PROJECT_MANIFEST_PATH" "$SELECTED_PROJECT_SOURCE_URL"
echo "Selected project: $SELECTED_PROJECT_KEY"

if ! run_comfyui_install_flow; then
    exit 1
fi

if [ "$cleanup_previous_project_resources" = "yes" ]; then
    if ! remove_previous_project_resources_and_reinstall_selected; then
        exit 1
    fi
fi
