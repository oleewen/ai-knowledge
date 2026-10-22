"""HTML 安全回归；OKF_BROWSER_TESTS=1 时另跑真实 Chromium/Chrome DOM 回归。

浏览器回归需要 Node.js 的 playwright 模块（可用 NODE_PATH 指定），并设置
OKF_VIZ_ASSETS 为 cytoscape.min.js、marked.min.js、purify.min.js 所在临时目录。
这些文件应来自 visualize.py 中固定版本的 CDN；浏览器仍检查生产页面的 SRI。
可用 OKF_BROWSER_EXECUTABLE 指定现有 Chromium/Chrome，避免安装全局依赖。
"""
from __future__ import annotations

from html.parser import HTMLParser
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
import visualize


class PageParser(HTMLParser):
    def __init__(self):
        super().__init__()
        self.elements = []
        self.data_script = False
        self.bundle_json = ""
        self.heading = False
        self.heading_text = ""

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        self.elements.append((tag, attrs))
        if tag == "script" and attrs.get("id") == "okf-bundle-data":
            self.data_script = True
        if tag == "h1":
            self.heading = True

    def handle_endtag(self, tag):
        if tag == "script":
            self.data_script = False
        if tag == "h1":
            self.heading = False

    def handle_data(self, data):
        if self.data_script:
            self.bundle_json += data
        if self.heading:
            self.heading_text += data


def bundle(body="", name="OKF 安全回归"):
    return {
        "name": name,
        "concepts": {
            "target": {
                "id": "target", "title": "Target", "type": "Concept",
                "description": "描述", "tags": ["安全"], "body": body,
                "backlinks": ["source"],
            },
            "source": {
                "id": "source", "title": "Source", "type": "Concept",
                "description": "", "tags": [], "body": "[Target](target.md)",
                "backlinks": [],
            },
        },
        "types": ["Concept"], "typeColors": {"Concept": "#4e79a7"},
        "edges": [{"source": "source", "target": "target"}],
    }


class SerializationTests(unittest.TestCase):
    def test_script_terminators_remain_json_data(self):
        for payload in (
            '</script><img id="injected" src=x onerror="window.__xss=1">',
            '</ScRiPt><script id="injected">window.__xss=1</script>',
            '<!--<script>中文 & < > " \\ \u2028\u2029',
        ):
            with self.subTest(payload=payload):
                data = bundle(payload)
                parser = PageParser()
                parser.feed(visualize.render_html(data))
                self.assertFalse(any(a.get("id") == "injected" for _, a in parser.elements))
                try:
                    decoded = json.loads(parser.bundle_json)
                except json.JSONDecodeError as exc:
                    self.fail(f"HTML parser truncated embedded JSON: {exc}")
                self.assertEqual(decoded, data)

    def test_page_name_is_literal_text(self):
        name = '</title><img id="injected" src=x onerror="window.__xss=1">& 中文'
        parser = PageParser()
        parser.feed(visualize.render_html(bundle(name=name)))
        self.assertFalse(any(a.get("id") == "injected" for _, a in parser.elements))
        self.assertEqual(parser.heading_text, name)

    def test_metadata_survives_json_roundtrip(self):
        data = bundle()
        data["concepts"]["target"].update({
            "title": '<img src=x onerror="window.__xss=1">',
            "description": '</script><script>window.__xss=1</script>',
            "tags": ["<tag>&'\"", "中文"],
        })
        parser = PageParser()
        parser.feed(visualize.render_html(data))
        try:
            decoded = json.loads(parser.bundle_json)
        except json.JSONDecodeError as exc:
            self.fail(f"HTML parser truncated embedded JSON: {exc}")
        self.assertEqual(decoded, data)


@unittest.skipUnless(os.environ.get("OKF_BROWSER_TESTS") == "1", "set OKF_BROWSER_TESTS=1 for browser regression")
class BrowserTests(unittest.TestCase):
    def test_metadata_markdown_navigation_and_safe_fallback(self):
        payload = '<img src=x onerror="window.__xss=1">'
        data = bundle(
            '# Markdown heading\n\n**Bold** [Source](source.md) '
            '[HTTPS](https://example.com/path) [Mail](mailto:test@example.com)\n\n'
            '[bad](javascript:window.__xss=1)\n\n'
            '<a href="java&#x73;cript:window.__xss=1">encoded</a>\n\n'
            '<img src=x onerror="window.__xss=1">\n'
            '<svg onload="window.__xss=1"></svg>\n'
            '<iframe srcdoc="<script>parent.__xss=1</script>"></iframe>\n'
            '<script>window.__xss=1</script>\n'
            '<form id="detail"><input name="DOMPurify"></form>\n'
        )
        data["name"] = '</title>' + payload
        data["concepts"]["target"].update({
            "title": payload, "description": payload, "tags": [payload], "type": payload,
        })
        source_id = 'source" data-injected="yes'
        data["concepts"][source_id] = {
            **data["concepts"]["source"], "id": source_id, "title": payload,
        }
        data["concepts"]["target"]["backlinks"] = [source_id]
        data["types"].append(payload)
        data["typeColors"][payload] = "#4e79a7"
        with tempfile.TemporaryDirectory(prefix="okf-viz-browser-") as temp:
            page = Path(temp) / "viz.html"
            page.write_text(visualize.render_html(data), encoding="utf-8")
            result = subprocess.run(
                [os.environ.get("NODE", "node"), str(Path(__file__).with_name("test_visualize_browser.cjs")), str(page)],
                text=True, capture_output=True, timeout=120,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            print(result.stdout.strip())


if __name__ == "__main__":
    unittest.main()
