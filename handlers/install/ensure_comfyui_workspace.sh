# shellcheck shell=bash


ensure_comfyui_workspace() {
    COMFYUI_DIR="$NETWORK_VOLUME/ComfyUI"
    CUSTOM_NODES_DIR="$COMFYUI_DIR/custom_nodes"
    export COMFYUI_DIR CUSTOM_NODES_DIR

    mkdir -p "$NETWORK_VOLUME"

    if [ ! -d "$COMFYUI_DIR" ] && [ -d "/ComfyUI" ] && [ ! -L "/ComfyUI" ]; then
        echo "Moving image ComfyUI workspace to persistent volume: $COMFYUI_DIR"
        if ! mv "/ComfyUI" "$COMFYUI_DIR"; then
            echo "❌ Failed to move /ComfyUI to $COMFYUI_DIR"
            return 1
        fi
    fi

    if [ -d "$COMFYUI_DIR" ]; then
        mkdir -p "$CUSTOM_NODES_DIR"
    fi

    if [ -L "/ComfyUI" ]; then
        local current_target
        current_target="$(readlink "/ComfyUI" || true)"
        if [ "$current_target" != "$COMFYUI_DIR" ]; then
            rm -f "/ComfyUI"
            ln -s "$COMFYUI_DIR" "/ComfyUI"
        fi
    elif [ ! -e "/ComfyUI" ] && [ -d "$COMFYUI_DIR" ]; then
        ln -s "$COMFYUI_DIR" "/ComfyUI"
    fi

    return 0
}
