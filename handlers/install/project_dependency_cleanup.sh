# shellcheck shell=bash


remove_project_resources_from_manifest() {
    local manifest_path="$1"

    if [ -z "$manifest_path" ] || [ ! -f "$manifest_path" ]; then
        echo "❌ Cannot remove project resources. Manifest not found: $manifest_path"
        return 1
    fi

    local cleanup_tmp_dir
    cleanup_tmp_dir="$(mktemp -d /tmp/dynamic-comfyui-project-cleanup.XXXXXX)"

    local handler_dir
    handler_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local manifest_parser_script
    manifest_parser_script="$handler_dir/manifest_resources.py"
    if [ ! -f "$manifest_parser_script" ]; then
        echo "❌ Manifest parser script not found: $manifest_parser_script"
        rm -rf "$cleanup_tmp_dir"
        return 1
    fi

    local parse_rc=0
    if python3 "$manifest_parser_script" cleanup \
        --manifest "$manifest_path" \
        --out-dir "$cleanup_tmp_dir"
    then
        parse_rc=0
    else
        parse_rc=$?
    fi

    if [ "$parse_rc" -ne 0 ]; then
        rm -rf "$cleanup_tmp_dir"
        return 1
    fi

    local nodes_file="$cleanup_tmp_dir/custom_nodes.tsv"
    local models_file="$cleanup_tmp_dir/models.tsv"
    local files_file="$cleanup_tmp_dir/files.tsv"

    if [ -f "$nodes_file" ]; then
        local repo_dir
        while IFS= read -r repo_dir; do
            [ -n "$repo_dir" ] || continue
            local node_path="$CUSTOM_NODES_DIR/$repo_dir"
            if [ -d "$node_path" ]; then
                echo "Removing old custom node: $repo_dir"
                rm -rf "$node_path"
            fi
        done < "$nodes_file"
    fi

    if [ -f "$models_file" ]; then
        local model_target
        while IFS= read -r model_target; do
            [ -n "$model_target" ] || continue
            local model_path="$COMFYUI_DIR/$model_target"
            if [ -f "$model_path" ]; then
                echo "Removing old model: $model_target"
                rm -f "$model_path"
            fi
        done < "$models_file"
    fi

    if [ -f "$files_file" ]; then
        local file_target
        while IFS= read -r file_target; do
            [ -n "$file_target" ] || continue
            local file_path="$COMFYUI_DIR/$file_target"
            if [ -f "$file_path" ]; then
                echo "Removing old file: $file_target"
                rm -f "$file_path"
            fi
        done < "$files_file"
    fi

    rm -rf "$cleanup_tmp_dir"
    return 0
}
