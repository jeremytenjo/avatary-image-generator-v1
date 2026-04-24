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


if __name__ == "__main__":
    unittest.main()
