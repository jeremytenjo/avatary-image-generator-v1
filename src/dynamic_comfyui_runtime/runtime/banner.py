from __future__ import annotations

import re
from urllib.parse import urlparse

from pyfiglet import Figlet

from .ui import console

def project_name_from_manifest_url(source_url: str) -> str:
    raw_name = urlparse(source_url).path.rsplit("/", 1)[-1]
    if raw_name.lower().endswith(".json"):
        raw_name = raw_name[:-5]
    normalized = re.sub(r"[^a-zA-Z0-9-]+", "-", raw_name).strip("-").lower()
    return normalized or "project"


def render_ascii_banner(text: str, width: int | None = None) -> str:
    normalized = re.sub(r"[^a-zA-Z0-9-]+", "-", text).strip("-").lower()
    figlet = Figlet(font="ansi_shadow", width=max(40, width or 80))
    return figlet.renderText(normalized or "project").rstrip("\n")


def print_project_banner(source_url: str) -> None:
    project_name = project_name_from_manifest_url(source_url)
    term_console = console()
    banner = render_ascii_banner(project_name, width=term_console.size.width)
    term_console.print()
    term_console.print(banner, style="black", no_wrap=True, overflow="ignore")
    term_console.print()
