from __future__ import annotations

from pathlib import Path

from .common import ensure_dir


def default_manifest_url_override_path(network_volume: Path) -> Path:
    return network_volume / ".dynamic-comfyui_default_manifest_url"


def read_default_manifest_url_override(network_volume: Path) -> str | None:
    path = default_manifest_url_override_path(network_volume)
    if not path.is_file():
        return None
    value = path.read_text(encoding="utf-8").strip()
    return value or None


def write_default_manifest_url_override(network_volume: Path, url: str) -> None:
    ensure_dir(network_volume)
    default_manifest_url_override_path(network_volume).write_text(f"{url}\n", encoding="utf-8")


def clear_default_manifest_url_override(network_volume: Path) -> bool:
    path = default_manifest_url_override_path(network_volume)
    existed = path.exists()
    path.unlink(missing_ok=True)
    return existed
