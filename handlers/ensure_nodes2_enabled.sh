# shellcheck shell=bash


ensure_nodes2_enabled() {
    local settings_dir="$NETWORK_VOLUME/ComfyUI/user/default"
    local settings_file="$settings_dir/comfy.settings.json"
    mkdir -p "$settings_dir"

    python3 - "$settings_file" <<'PY'
import json
import os
import sys

settings_file = sys.argv[1]
data = {}

if os.path.exists(settings_file):
    try:
        with open(settings_file, "r", encoding="utf-8") as f:
            loaded = json.load(f)
        if isinstance(loaded, dict):
            data = loaded
    except Exception:
        data = {}

data["Comfy.VueNodes.Enabled"] = True

with open(settings_file, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=4)
    f.write("\n")
PY
}
