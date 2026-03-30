# shellcheck shell=bash


pip_install_requirements_file() {
    local requirements_file="$1"
    if ! python3 -m pip install --no-cache-dir --break-system-packages -r "$requirements_file"; then
        python3 -m pip install --no-cache-dir -r "$requirements_file"
    fi
}


clone_or_update_custom_node_repo() {
    local repo_url="$1"
    local repo_dir="$2"
    local pinned_version="$3"
    local node_path="$CUSTOM_NODES_DIR/$repo_dir"

    if [ -d "$node_path/.git" ]; then
        git -C "$node_path" fetch --all --tags --prune
        git -C "$node_path" checkout --quiet main || git -C "$node_path" checkout --quiet master
        git -C "$node_path" pull --ff-only
    else
        rm -rf "$node_path"
        git clone "$repo_url" "$node_path"
    fi

    if [ -f "$node_path/requirements.txt" ]; then
        echo "📦 Installing Python deps for $repo_dir"
        if ! pip_install_requirements_file "$node_path/requirements.txt"; then
            echo "❌ Failed installing requirements for $repo_dir"
            return 1
        fi
    fi

    echo "$pinned_version" > "$node_path/.cnr-version"
    return 0
}


install_custom_nodes_with_git() {
    local -a custom_node_specs=(
        "comfyui-manager|comfyui-manager|https://github.com/Comfy-Org/ComfyUI-Manager.git|3.0.1"
        "was-ns|was-node-suite-comfyui|https://github.com/WASasquatch/was-node-suite-comfyui.git|3.0.1"
        "comfyui-rmbg|ComfyUI-RMBG|https://github.com/1038lab/ComfyUI-RMBG.git|3.0.0"
        "comfyui-inpaint-cropandstitch|ComfyUI-Inpaint-CropAndStitch|https://github.com/lquesada/ComfyUI-Inpaint-CropAndStitch.git|3.0.10"
        "ComfyUI-GGUF|ComfyUI-GGUF|https://github.com/city96/ComfyUI-GGUF.git|1.1.10"
        "comfyui-kjnodes|ComfyUI-KJNodes|https://github.com/kijai/ComfyUI-KJNodes.git|1.3.6"
        "comfyui-easy-use|ComfyUI-Easy-Use|https://github.com/yolain/ComfyUI-Easy-Use.git|1.3.6"
        "seedvr2_videoupscaler|ComfyUI-SeedVR2_VideoUpscaler|https://github.com/numz/ComfyUI-SeedVR2_VideoUpscaler.git|2.5.22"
        "comfyui_essentials|ComfyUI_essentials|https://github.com/cubiq/ComfyUI_essentials.git|1.1.0"
    )

    local total_custom_nodes=${#custom_node_specs[@]}
    local custom_node_idx=0
    local custom_node_spec
    for custom_node_spec in "${custom_node_specs[@]}"; do
        local cnr_id
        local repo_dir
        local repo_url
        local pinned_version
        IFS='|' read -r cnr_id repo_dir repo_url pinned_version <<< "$custom_node_spec"
        custom_node_idx=$((custom_node_idx + 1))
        echo "⬇️ [$custom_node_idx/$total_custom_nodes] Cloning $repo_dir (target $cnr_id@$pinned_version)"
        if ! clone_or_update_custom_node_repo "$repo_url" "$repo_dir" "$pinned_version"; then
            echo "❌ Failed to install custom node via git: $repo_dir"
            return 1
        fi
    done

    return 0
}
