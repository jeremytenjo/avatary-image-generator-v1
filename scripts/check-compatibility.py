#!/usr/bin/env python3

import json
import re
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
COMPAT_PATH = ROOT / ".compatibility.json"
REQS_PATH = ROOT / "requirements.txt"
DOCKERFILE_PATH = ROOT / "Dockerfile"


def fail(message: str) -> None:
    print(f"[compatibility-check] ERROR: {message}")
    sys.exit(1)


def load_json(path: Path) -> dict:
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"Failed to parse {path}: {exc}")


def parse_requirements(path: Path) -> dict:
    pins: dict[str, str] = {}
    pattern = re.compile(r"^([A-Za-z0-9_.-]+)==(.+)$")
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        match = pattern.match(line)
        if not match:
            continue
        pins[match.group(1).lower()] = match.group(2).strip()
    return pins


def parse_base_image(path: Path) -> str | None:
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if line.startswith("FROM "):
            return line.split(" ", 1)[1].strip()
    return None


def main() -> None:
    compat = load_json(COMPAT_PATH)
    required_pins = compat.get("requiredPins", {})
    expected_base = compat.get("baseImage")
    actual_base = parse_base_image(DOCKERFILE_PATH)
    req_pins = parse_requirements(REQS_PATH)

    if expected_base and actual_base != expected_base:
        fail(
            f"Docker base image mismatch. expected='{expected_base}', actual='{actual_base}'."
        )

    for pkg, expected_version in required_pins.items():
        actual_version = req_pins.get(pkg.lower())
        if actual_version is None:
            fail(f"Missing required pin in requirements.txt: {pkg}=={expected_version}")
        if actual_version != expected_version:
            fail(
                f"Pin mismatch for {pkg}. expected='{expected_version}', actual='{actual_version}'."
            )

    print("[compatibility-check] OK: compatibility policy satisfied.")


if __name__ == "__main__":
    main()
