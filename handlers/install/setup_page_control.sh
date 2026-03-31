# shellcheck shell=bash


stop_setup_instructions_page() {
    local setup_pid_file="/tmp/avatary-setup-page.pid"

    if [ -f "$setup_pid_file" ]; then
        local pid
        pid="$(cat "$setup_pid_file" 2>/dev/null || true)"
        if [ -n "$pid" ] && kill -0 "$pid" 2>/dev/null; then
            kill "$pid" 2>/dev/null || true
        fi
        rm -f "$setup_pid_file"
    fi

    # Fallback for stale pid files or previous launch attempts.
    if command -v pgrep > /dev/null 2>&1; then
        local pids
        pids="$(pgrep -f "python3 -m http.server 8188.*avatary-setup-page" || true)"
        if [ -n "$pids" ]; then
            echo "$pids" | xargs kill 2>/dev/null || true
        fi
    fi
}
