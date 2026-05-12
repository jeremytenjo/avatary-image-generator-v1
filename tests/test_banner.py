from __future__ import annotations

import unittest

from dynamic_comfyui_runtime.runtime.banner import project_name_from_manifest_url, render_ascii_banner


class BannerTests(unittest.TestCase):
    def test_project_name_from_manifest_url(self) -> None:
        source_url = "https://github.com/jeremytenjo/avatary-dynamic-comfyui-projects/blob/main/qwen-image-2512.json"
        self.assertEqual(project_name_from_manifest_url(source_url), "qwen-image-2512")

    def test_project_name_fallback_when_path_empty(self) -> None:
        self.assertEqual(project_name_from_manifest_url("https://example.com/"), "project")

    def test_render_ascii_banner_is_multiline_and_contains_ink(self) -> None:
        banner = render_ascii_banner("qwen-image-2512")
        lines = banner.splitlines()
        self.assertEqual(len(lines), 6)
        self.assertTrue(any("#" in line for line in lines))


if __name__ == "__main__":
    unittest.main()
