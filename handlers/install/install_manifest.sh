# shellcheck shell=bash


load_install_manifest() {
    if ! fetch_project_manifest; then
        return 1
    fi

    local manifest_tmp_dir
    manifest_tmp_dir="$(install_manifest_tmp_dir)"
    rm -f "$manifest_tmp_dir/custom_nodes.tsv" "$manifest_tmp_dir/models.tsv"

    local default_nodes_manifest_path=""
    if [ -n "${SCRIPT_DIR:-}" ]; then
        default_nodes_manifest_path="$SCRIPT_DIR/default-resources.yaml"
    fi

    local exports_output
    if ! exports_output="$(
        python3 - "$INSTALL_MANIFEST_PATH" "$manifest_tmp_dir" "$default_nodes_manifest_path" <<'PY'
import shlex
import sys
from pathlib import Path

import yaml


def fail(msg: str) -> None:
    print(f"❌ {msg}", file=sys.stderr)
    raise SystemExit(1)


if len(sys.argv) != 4:
    fail("Internal error: expected manifest path, output directory, and default manifest path arguments.")

manifest_path = Path(sys.argv[1])
out_dir = Path(sys.argv[2])
defaults_path_arg = sys.argv[3].strip()
defaults_manifest_path = Path(defaults_path_arg) if defaults_path_arg else None


def load_yaml_mapping(path: Path, label: str) -> dict:
    try:
        data = yaml.safe_load(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"Failed to parse YAML for {label} ({path}): {exc}")
    if data is None:
        return {}
    if not isinstance(data, dict):
        fail(f"{label} root must be a mapping.")
    return data


def parse_custom_nodes(raw_custom_nodes, label: str) -> list[tuple[str, str]]:
    if raw_custom_nodes is None:
        return []
    if not isinstance(raw_custom_nodes, list):
        fail(f"{label} must be a list")

    parsed: list[tuple[str, str]] = []
    for idx, item in enumerate(raw_custom_nodes):
        if not isinstance(item, dict):
            fail(f"{label}[{idx}] must be a mapping")

        repo_dir = item.get("repo_dir")
        repo = item.get("repo")
        if not isinstance(repo_dir, str) or not repo_dir.strip():
            fail(f"{label}[{idx}] requires non-empty string field: repo_dir")
        if not isinstance(repo, str) or not repo.strip():
            fail(f"{label}[{idx}] requires non-empty string field: repo")

        repo_dir = repo_dir.strip()
        repo = repo.strip()
        if "\t" in repo_dir or "\t" in repo:
            fail(f"{label}[{idx}] fields must not contain tabs")

        parsed.append((repo_dir, repo))
    return parsed


def parse_models(raw_models, label: str) -> list[tuple[str, str]]:
    if raw_models is None:
        return []
    if not isinstance(raw_models, list):
        fail(f"{label} must be a list")

    parsed: list[tuple[str, str]] = []
    for idx, item in enumerate(raw_models):
        if not isinstance(item, dict):
            fail(f"{label}[{idx}] must be a mapping")

        url = item.get("url")
        target = item.get("target")
        if not isinstance(url, str) or not url.strip():
            fail(f"{label}[{idx}] requires non-empty string field: url")
        if not isinstance(target, str) or not target.strip():
            fail(f"{label}[{idx}] requires non-empty string field: target")

        target_value = target.strip()
        target_path = Path(target_value)
        if target_path.is_absolute():
            fail(f"{label}[{idx}].target must be relative to ComfyUI root, got: {target_value}")
        if ".." in target_path.parts:
            fail(f"{label}[{idx}].target must not contain '..', got: {target_value}")

        url_value = url.strip()
        if "\t" in url_value or "\t" in target_value:
            fail(f"{label}[{idx}] fields must not contain tabs")

        parsed.append((url_value, target_value))
    return parsed

project_manifest = load_yaml_mapping(manifest_path, "Project manifest")

default_manifest = {}
if defaults_manifest_path and defaults_manifest_path.exists():
    if not defaults_manifest_path.is_file():
        fail(f"Default custom node manifest path is not a file: {defaults_manifest_path}")
    default_manifest = load_yaml_mapping(defaults_manifest_path, "Default custom node manifest")

default_custom_nodes = parse_custom_nodes(default_manifest.get("custom_nodes"), "default custom_nodes")
project_custom_nodes = parse_custom_nodes(project_manifest.get("custom_nodes"), "project custom_nodes")

merged_custom_nodes_by_repo_dir: dict[str, str] = {}
for repo_dir, repo in default_custom_nodes:
    merged_custom_nodes_by_repo_dir[repo_dir] = repo
for repo_dir, repo in project_custom_nodes:
    merged_custom_nodes_by_repo_dir[repo_dir] = repo

default_models = parse_models(default_manifest.get("models"), "default models")
project_models = parse_models(project_manifest.get("models"), "project models")

merged_models_by_target: dict[str, str] = {}
for url, target in default_models:
    merged_models_by_target[target] = url
for url, target in project_models:
    merged_models_by_target[target] = url

nodes_file = out_dir / "custom_nodes.tsv"
models_file = out_dir / "models.tsv"

with nodes_file.open("w", encoding="utf-8") as nf:
    for repo_dir, repo in merged_custom_nodes_by_repo_dir.items():
        nf.write(f"{repo_dir}\t{repo}\n")

with models_file.open("w", encoding="utf-8") as mf:
    for target, url in merged_models_by_target.items():
        mf.write(f"{url}\t{target}\n")

print(f"export INSTALL_MANIFEST_CUSTOM_NODES_FILE={shlex.quote(str(nodes_file))}")
print(f"export INSTALL_MANIFEST_MODELS_FILE={shlex.quote(str(models_file))}")
PY
    )"; then
        return 1
    fi

    eval "$exports_output"

    if [ ! -f "$INSTALL_MANIFEST_CUSTOM_NODES_FILE" ] || [ ! -f "$INSTALL_MANIFEST_MODELS_FILE" ]; then
        echo "❌ Manifest loader failed to generate normalized data files."
        return 1
    fi

    echo "Loaded install manifest: $INSTALL_MANIFEST_PATH"
    if [ -n "$default_nodes_manifest_path" ] && [ -f "$default_nodes_manifest_path" ]; then
        echo "Loaded default resources manifest: $default_nodes_manifest_path"
    fi
    return 0
}
