"""运行真实 CLI，验证 docs-build 的写入边界与校验结果。"""
from __future__ import annotations

import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

SCRIPTS = Path(__file__).resolve().parents[1] / "scripts"
sys.path.insert(0, str(SCRIPTS))
import generate_knowledge_index as generator

GUIDE = "# Guide\n\n## 四、领域模型\n\n### 4.5 视角导航\n\nold\n\n### 4.6 人工说明\n\nKEEP\n\n## 五、业务\n\nTAIL\n"
BLOCK = "<!-- docs-build:entity-index:begin -->\nnew\n<!-- docs-build:entity-index:end -->\n"


class BuildToolsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "consumer"
        self.doc = self.repo / "docs"
        self.doc.mkdir(parents=True)
        agent = self.root / "agent-home" / ".agents"
        agent.mkdir(parents=True)
        (agent / "configs").write_text(f"WORK_SPACE={self.root}\n")
        (self.repo / ".docsconfig").write_text(
            f"AGENT_ROOT={agent.parent}\nAGENT_DIR=.agents\nREPO_DIR=consumer\n"
            "DOC_DIR=docs\nKNOWLEDGE_TYPE=application\n"
        )
        (self.doc / "INDEX-GUIDE.md").write_text(GUIDE.replace("old", BLOCK))
        for p in ("application", "data", "business", "product", "technical"):
            directory = self.doc / "knowledge" / p
            directory.mkdir(parents=True)
            (directory / "README.md").write_text("# 导航\n")
        for name in ("README.md", "index.md"):
            (self.doc / "knowledge" / name).write_text("# 知识库\n")

    def command(self, *args):
        env = dict(os.environ, PYTHONDONTWRITEBYTECODE="1")
        env.pop("DOCS_OKF_REPO_ABS", None)
        return subprocess.run(args, cwd=self.repo, env=env, capture_output=True, text=True)

    def generate(self, *args):
        return self.command(sys.executable, str(SCRIPTS / "generate_knowledge_index.py"),
                            "--bundle", "docs", "--layer-scope", "application", *args)

    def validate(self, *args):
        return self.command("bash", str(SCRIPTS / "validate-extraction.sh"), *args)

    def entity(self, name="API-DEMO", directory="application"):
        p = self.doc / "knowledge" / directory / f"{name}.md"
        p.write_text(
            "---\ntype: API Endpoint\ntitle: 示例\ndescription: 示例接口\n"
            f"tags: [application, API]\ntimestamp: \"2026-10-22T00:00:00+08:00\"\nid: {name}\n"
            "perspective: application\nhierarchy: API\nlayer_scope: application\n---\n"
            "<!-- markdownlint-disable-next-line MD025 -->\n# 示例\n\n"
            "## 关系\n\nimplements_to: MS-DEMO\n\n## 跨视角\n\n尚无\n\n"
            "## 详细说明\n\n接口\n\n## 依据与证据\n\n已核实 API 名称。\n"
        )
        with (p.parent / "README.md").open("a") as f:
            f.write(f"\n- [{name}]({p.name})\n")
        return p

    def test_unmarked_section_keeps_following_subsection(self):
        updated = generator.patch_index_guide(GUIDE, BLOCK)
        self.assertIn("### 4.6 人工说明\n\nKEEP", updated)
        self.assertIn("TAIL", updated)
        self.assertNotIn("\nold\n", updated)
        self.assertEqual(updated, generator.patch_index_guide(updated, BLOCK))

    def test_ambiguous_markers_rejected(self):
        for content in (GUIDE.replace("old", BLOCK + BLOCK),
                        GUIDE.replace("old", generator.ENTITY_BEGIN),
                        GUIDE.replace("old", generator.ENTITY_END + generator.ENTITY_BEGIN)):
            with self.subTest(content=content):
                with self.assertRaises(ValueError):
                    generator.patch_index_guide(content, BLOCK)

    def test_generator_does_not_delete_legacy_files(self):
        # 旧 CLI 保持兼容；只替换仓库定位，全部写入发生在临时仓。
        legacy = self.doc / "knowledge" / "KNOWLEDGE-INDEX.md"
        legacy.write_text("KEEP LEGACY")
        with patch.object(generator, "_repo_root", return_value=self.repo):
            self.assertEqual(generator.main(["--bundle", "docs", "--layer-scope", "application"]), 0)
        self.assertEqual(legacy.read_text(), "KEEP LEGACY")

    def test_consumer_cwd_and_dry_run(self):
        before = (self.doc / "INDEX-GUIDE.md").read_bytes()
        preview = self.generate("--dry-run")
        self.assertEqual(preview.returncode, 0, preview.stderr)
        self.assertIn("API / TBL / MW / CMP", preview.stdout)
        self.assertEqual((self.doc / "INDEX-GUIDE.md").read_bytes(), before)
        result = self.generate()
        self.assertEqual(result.returncode, 0, result.stderr)
        written = (self.doc / "INDEX-GUIDE.md").read_bytes()
        self.assertNotEqual(written, before)
        self.assertEqual(self.generate().returncode, 0)
        self.assertEqual((self.doc / "INDEX-GUIDE.md").read_bytes(), written)

    def test_unknown_layer_and_outside_bundle_rejected(self):
        for args in (["--bundle", "docs", "--dry-run"],
                     ["--bundle", "../", "--layer-scope", "application", "--dry-run"]):
            result = self.command(sys.executable, str(SCRIPTS / "generate_knowledge_index.py"), *args)
            self.assertNotEqual(result.returncode, 0)

    def test_valid_entities_and_empty_unowned_perspectives_pass(self):
        self.entity()
        result = self.validate()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("每视角至少一个", result.stdout)

    def test_missing_end_marker_fails(self):
        self.entity()
        guide = self.doc / "INDEX-GUIDE.md"
        guide.write_text(guide.read_text().replace(generator.ENTITY_END, ""))
        self.assertNotEqual(self.validate().returncode, 0)

    def test_body_id_cannot_pass_as_entity(self):
        p = self.doc / "knowledge/application/API-DEMO.md"
        p.write_text("# Example\nid: API-DEMO\n")
        self.assertNotEqual(self.validate().returncode, 0)

    def test_duplicate_id_fails(self):
        p = self.entity()
        duplicate = p.parent / "duplicate"
        duplicate.mkdir()
        (duplicate / p.name).write_text(p.read_text())
        self.assertNotEqual(self.validate().returncode, 0)

    def test_wrong_layer_or_perspective_fails(self):
        p = self.entity()
        original = p.read_text()
        for text in (original.replace("layer_scope: application", "layer_scope: system"),
                     original.replace("perspective: application", "perspective: data")):
            p.write_text(text)
            self.assertNotEqual(self.validate().returncode, 0)

    def test_entities_only_allows_navigation_to_be_built_later(self):
        self.entity()
        (self.doc / "INDEX-GUIDE.md").write_text(GUIDE)
        result = self.validate("--entities-only", "--perspectives", "application")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotEqual(self.validate().returncode, 0)

    def test_broken_readme_link_fails(self):
        self.entity()
        (self.doc / "knowledge/application/README.md").write_text("# 导航\n[API](missing.md)\n")
        self.assertNotEqual(self.validate().returncode, 0)

    def test_cross_chapter_markers_rejected(self):
        for content in (
            GUIDE.replace("old", generator.ENTITY_BEGIN) + generator.ENTITY_END,
            GUIDE + BLOCK,
        ):
            with self.subTest(content=content):
                with self.assertRaises(ValueError):
                    generator.patch_index_guide(content, BLOCK)

    def test_crlf_preserved_outside_block(self):
        guide = self.doc / "INDEX-GUIDE.md"
        original = guide.read_text().replace("\n", "\r\n").encode()
        guide.write_bytes(original)
        result = self.generate()
        self.assertEqual(result.returncode, 0, result.stderr)
        written = guide.read_bytes()
        begin, end = generator.ENTITY_BEGIN.encode(), generator.ENTITY_END.encode()
        self.assertEqual(original.split(begin)[0], written.split(begin)[0])
        self.assertEqual(original.split(end)[1], written.split(end)[1])

    def test_markdown_title_and_fenced_example_are_valid(self):
        p = self.entity()
        p.write_text(p.read_text().replace("## 详细说明\n", "## 详细说明\n\n```markdown\n## example\n[demo](missing.md)\n```\n"))
        (p.parent / "README.md").write_text('# 导航\n[API](API-DEMO.md "示例接口")\n')
        result = self.validate()
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_invalid_frontmatter_values_fail_with_diagnostics(self):
        p = self.entity()
        original = p.read_text()
        for field, old, new in (
            ("title", "title: 示例", "title: null"),
            ("tags", "tags: [application, API]", "tags: invalid"),
            ("timestamp", 'timestamp: "2026-10-22T00:00:00+08:00"', "timestamp: invalid"),
        ):
            with self.subTest(field=field):
                p.write_text(original.replace(old, new))
                result = self.validate()
                self.assertEqual(result.returncode, 1)
                self.assertIn(field, result.stderr)

    def test_missing_h1_fails(self):
        p = self.entity()
        p.write_text(p.read_text().replace("# 示例\n", ""))
        result = self.validate()
        self.assertEqual(result.returncode, 1)
        self.assertIn("H1", result.stderr)


if __name__ == "__main__":
    unittest.main()
