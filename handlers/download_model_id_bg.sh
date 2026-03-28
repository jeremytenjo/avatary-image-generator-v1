# shellcheck shell=bash


download_model_id_bg() {
    local target_dir="$1"
    local model_id="$2"
    (
        local start_ts=$(date +%s)
        cd "$target_dir" || exit 1
        download_with_aria.py -m "$model_id"
        local rc=$?
        local end_ts=$(date +%s)
        if [ $rc -eq 0 ]; then
            log_timing "model_id_download" "$model_id" "success" "$start_ts" "$end_ts" "0" "$target_dir"
        else
            log_timing "model_id_download" "$model_id" "failed" "$start_ts" "$end_ts" "0" "$target_dir"
        fi
        exit $rc
    ) &
    MODEL_ID_DOWNLOAD_PIDS+=($!)
    MODEL_ID_DOWNLOAD_LABELS+=("$model_id")
}
