# shellcheck shell=bash


ensure_comfyui_workspace() {
    COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"
    CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"
    export COMFYUI_DIR CUSTOM_NODES_DIR

    # Do not pre-create COMFYUI_DIR before `comfy install`; comfy-cli expects to
    # initialize or update a valid repo at that path.
    mkdir -p "$NETWORK_VOLUME"
    return 0
}
