"""Real artifacts must preserve source boundaries and expose stale output."""
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
import generate_index
import validate_viz_index
import visualize


class ArtifactSafetyTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.bundle = self.root / "docs"
        (self.bundle / "knowledge").mkdir(parents=True)
        self.index = self.bundle / "index.md"
        self.index.write_text("# Root\n<!-- okf:begin -->\nold\n<!-- okf:end -->\n")
        (self.bundle / "knowledge/index.md").write_text("## 目录文件\n")
        (self.bundle / "knowledge/real.md").write_text("---\ntitle: Real\ntype: Documentation\n---\n# Real\n")
        self.guide = self.bundle / "INDEX-GUIDE.md"
        self.guide.write_text("## 四、领域模型\n<!-- docs-build:entity-index:begin -->\n### 视角入口\n<!-- docs-build:entity-index:end -->\n")
        self.viz = self.bundle / "viz.html"
        visualize.generate_visualization(self.bundle, self.viz, "Fixture")

    def test_leaf_symlinks_never_write_external_file(self):
        for target in (self.index, self.viz, self.bundle / "knowledge/index.md"):
            with self.subTest(target=target):
                sentinel = self.root / "sentinel"
                sentinel.write_text("KEEP")
                target.unlink()
                target.symlink_to(sentinel)
                with self.assertRaises((ValueError, OSError)):
                    if target == self.viz:
                        visualize.generate_visualization(self.bundle, target, "Fixture")
                    else:
                        generate_index.write_index(target.parent, self.bundle)
                self.assertEqual(sentinel.read_text(), "KEEP")

    def test_viz_cli_keeps_symlink_visible_to_guard(self):
        sentinel = self.root / "sentinel"
        sentinel.write_text("KEEP")
        self.viz.unlink()
        self.viz.symlink_to(sentinel)
        result = subprocess.run([sys.executable, str(SCRIPTS / "visualize.py"),
                                 "--repo", str(self.root), "--bundle", "docs",
                                 "--out", "docs/viz.html"], capture_output=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(sentinel.read_text(), "KEEP")

    def test_root_example_and_outside_bytes_preserved(self):
        example = "```markdown\n<!-- okf:begin -->\nEXAMPLE\n<!-- okf:end -->\n```\n"
        original = example + self.index.read_text() + "\nTAIL 中文 😀  \n\n"
        self.index.write_bytes(original.replace("\n", "\r\n").encode())
        before = self.index.read_bytes()
        generate_index.write_index(self.bundle, self.bundle)
        after = self.index.read_bytes()
        self.assertTrue(after.startswith(example.replace("\n", "\r\n").encode()))
        self.assertEqual(before.rsplit(b"<!-- okf:end -->", 1)[1], after.rsplit(b"<!-- okf:end -->", 1)[1])
        self.assertNotIn(b"\r\nold\r\n", after)

    def test_invalid_real_blocks_reject_without_write(self):
        original = self.index.read_text()
        for bad in (original + original, original.replace("<!-- okf:end -->", ""),
                    original.replace("old", "```\nunfinished")):
            self.index.write_text(bad)
            with self.assertRaises(ValueError):
                generate_index.write_index(self.bundle, self.bundle)
            self.assertEqual(self.index.read_text(), bad)

    def test_generated_viz_and_identity_mismatch(self):
        self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 0)
        data = visualize.build_bundle_data(self.bundle, "Fixture")
        original = dict(data["concepts"])
        for concepts in ({}, {"knowledge/missing": next(iter(original.values()))},
                         dict(original, **{"knowledge/extra": {}})):
            data["concepts"] = concepts
            self.viz.write_text(visualize.render_html(data))
            self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)
        self.viz.write_text('<html> "concepts" "edges" "knowledge/fake": {}')
        self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)

    def test_invalid_navigation_block_fails(self):
        original = self.guide.read_text()
        for bad in (original.replace("<!-- docs-build:entity-index:end -->", ""),
                    "```markdown\n" + original + "```\n"):
            self.guide.write_text(bad)
            self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)

    def test_stale_same_identity_and_invalid_json_fail(self):
        concept = self.bundle / "knowledge/real.md"
        concept.write_text(concept.read_text() + "\nNew fact\n")
        self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)
        for payload in ('{"concepts":{},"concepts":{},"edges":[]}', '{invalid}', '[]'):
            self.viz.write_text('<html><script id="okf-bundle-data" type="application/json">' + payload + '</script></html>')
            self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)

    def test_parent_symlink_outside_bundle_is_rejected(self):
        outside = self.root / "external"
        outside.mkdir()
        link = self.bundle / "linked"
        link.symlink_to(outside, target_is_directory=True)
        with self.assertRaises(ValueError):
            visualize.generate_visualization(self.bundle, link / "viz.html", "Fixture")
        self.assertEqual(list(outside.iterdir()), [])

    def test_duplicate_data_node_attributes_fail(self):
        original = self.viz.read_text()
        for old, new in (
            ('id="okf-bundle-data"', 'id="wrong" id="okf-bundle-data"'),
            ('type="application/json"', 'type="text/plain" type="application/json"'),
        ):
            self.viz.write_text(original.replace(old, new))
            self.assertEqual(validate_viz_index.validate(self.bundle, self.viz), 1)


if __name__ == "__main__":
    unittest.main()
