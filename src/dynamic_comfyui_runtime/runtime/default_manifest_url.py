from __future__ import annotations

from pathlib import Path

from .common import ensure_dir


def default_manifest_url_override_path(network_volume: Path) -> Path:
    return network_volume / ".dynamic-comfyui_default_manifest_url"


def read_default_manifest_url_override(network_volume: Path, fallback_network_volume: Path | None = None) -> str | None:
    candidates: list[Path] = [default_manifest_url_override_path(network_volume)]
    if fallback_network_volume is not None:
        fallback_path = default_manifest_url_override_path(fallback_network_volume)
        if fallback_path not in candidates:
            candidates.append(fallback_path)
    for path in candidates:
        if not path.is_file():
            continue
        value = path.read_text(encoding="utf-8").strip()
        if value:
            return value
    return None


def write_default_manifest_url_override(network_volume: Path, url: str) -> None:
    ensure_dir(network_volume)
    default_manifest_url_override_path(network_volume).write_text(f"{url}\n", encoding="utf-8")


def clear_default_manifest_url_override(network_volume: Path) -> bool:
    path = default_manifest_url_override_path(network_volume)
    existed = path.exists()
    path.unlink(missing_ok=True)
    return existed
