from __future__ import annotations

import tempfile
import unittest
from pathlib import Path

from dynamic_comfyui_runtime.runtime.default_manifest_url import (
    clear_default_manifest_url_override,
    read_default_manifest_url_override,
    write_default_manifest_url_override,
)


class DefaultManifestUrlTests(unittest.TestCase):
    def test_missing_override_returns_none(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            network_volume = Path(td)
            self.assertIsNone(read_default_manifest_url_override(network_volume))

    def test_set_and_read_override(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            network_volume = Path(td)
            write_default_manifest_url_override(network_volume, "https://example.com/defaults.json")
            self.assertEqual(read_default_manifest_url_override(network_volume), "https://example.com/defaults.json")

    def test_clear_override(self) -> None:
        with tempfile.TemporaryDirectory() as td:
            network_volume = Path(td)
            write_default_manifest_url_override(network_volume, "https://example.com/defaults.json")
            self.assertTrue(clear_default_manifest_url_override(network_volume))
            self.assertIsNone(read_default_manifest_url_override(network_volume))
            self.assertFalse(clear_default_manifest_url_override(network_volume))

    def test_read_uses_fallback_volume(self) -> None:
        with tempfile.TemporaryDirectory() as td_primary, tempfile.TemporaryDirectory() as td_fallback:
            primary = Path(td_primary)
            fallback = Path(td_fallback)
            write_default_manifest_url_override(fallback, "https://example.com/defaults.json")
            self.assertEqual(
                read_default_manifest_url_override(primary, fallback_network_volume=fallback),
                "https://example.com/defaults.json",
            )


if __name__ == "__main__":
    unittest.main()
