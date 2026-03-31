# shellcheck shell=bash


default_install_manifest_url() {
    printf '%s\n' "https://raw.githubusercontent.com/jeremytenjo/avatary-image-generator-v1/main/dependencies.yaml"
}

install_manifest_tmp_dir() {
    printf '%s\n' "/tmp/avatary-install-manifest"
}

install_manifest_download_path() {
    printf '%s/dependencies.yaml\n' "$(install_manifest_tmp_dir)"
}


set_install_manifest_url_default() {
    if [ -z "${INSTALL_MANIFEST_URL:-}" ]; then
        INSTALL_MANIFEST_URL="$(default_install_manifest_url)"
        export INSTALL_MANIFEST_URL
    fi
}


fetch_dependencies() {
    set_install_manifest_url_default

    if [ -z "${INSTALL_MANIFEST_URL:-}" ]; then
        echo "❌ INSTALL_MANIFEST_URL is not set."
        return 1
    fi

    local manifest_tmp_dir
    manifest_tmp_dir="$(install_manifest_tmp_dir)"
    mkdir -p "$manifest_tmp_dir"
    local downloaded_manifest
    downloaded_manifest="$(install_manifest_download_path)"

    echo "Fetching install manifest from: $INSTALL_MANIFEST_URL"
    if ! curl --fail --show-error --silent --location \
        --retry 3 --retry-delay 2 --connect-timeout 10 --max-time 60 \
        "$INSTALL_MANIFEST_URL" \
        --output "$downloaded_manifest"; then
        echo "❌ Failed to download install manifest from GitHub raw URL."
        return 1
    fi

    if [ ! -s "$downloaded_manifest" ]; then
        echo "❌ Downloaded install manifest is empty: $downloaded_manifest"
        return 1
    fi

    INSTALL_MANIFEST_PATH="$downloaded_manifest"
    export INSTALL_MANIFEST_PATH
    return 0
}
