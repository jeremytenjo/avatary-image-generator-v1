# shellcheck shell=bash


ensure_comfyui_workspace() {
    COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"
    CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"
    export COMFYUI_DIR CUSTOM_NODES_DIR

    mkdir -p "$NETWORK_VOLUME" "$COMFYUI_DIR" "$CUSTOM_NODES_DIR"
    return 0
}
