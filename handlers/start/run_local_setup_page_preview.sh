#!/usr/bin/env bash
set -euo pipefail

run_local_setup_page_preview() {
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local preview_dir="$script_dir/local-setup-page-preview"
    local default_port=8188
    local port_input="${1:-$default_port}"
    local port="$default_port"

    if [[ "$port_input" =~ ^[0-9]+$ ]] && [ "$port_input" -ge 1 ] && [ "$port_input" -le 65535 ]; then
        port="$port_input"
    fi

    if [ ! -f "$preview_dir/index.html" ]; then
        echo "❌ Preview page not found: $preview_dir/index.html"
        return 1
    fi

    echo "Serving local setup-page preview at http://127.0.0.1:${port}"
    echo "Press Ctrl+C to stop."
    python3 -m http.server "$port" --directory "$preview_dir"
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
    run_local_setup_page_preview "${1:-}"
fi
