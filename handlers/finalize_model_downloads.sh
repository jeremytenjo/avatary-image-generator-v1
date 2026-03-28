# shellcheck shell=bash


finalize_model_downloads() {
    local install_finish_start_ts=$(date +%s)
    if ! wait_for_all_model_downloads; then
        return 1
    fi
    cd "$LORAS_DIR"
    for file in *.zip; do
        [ -f "$file" ] || continue
        mv "$file" "${file%.zip}.safetensors"
    done
    local install_end_ts=$(date +%s)
    log_timing "installation" "all_downloads" "completed" "$INSTALL_START_TS" "$install_end_ts" "0" "all_downloads"
    log_timing "installation" "finalize_step" "completed" "$install_finish_start_ts" "$install_end_ts" "0" "finalize_step"
}
