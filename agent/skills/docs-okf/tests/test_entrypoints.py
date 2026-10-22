"""在临时安装工程中验证真实入口；不改仓库知识产物。"""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import shlex
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]
SCRIPTS = ROOT / "agent/skills/docs-okf/scripts"


class EntrypointTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="docs-okf-entrypoints-")
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name).resolve()
        self.project = self.workspace / "project"
        self.project.mkdir()
        self.agent_home = self.workspace / "agent-home"
        (self.agent_home / ".agents").mkdir(parents=True)
        (self.agent_home / ".agents/configs").write_text(
            f"WORK_SPACE={self.workspace}\n", encoding="utf-8"
        )
        (self.project / ".docsconfig").write_text(
            f"REPO_DIR=project\nDOC_DIR=docs\nKNOWLEDGE_TYPE=application\n"
            f"AGENT_ROOT={self.agent_home}\nAGENT_DIR=.agents\n", encoding="utf-8"
        )
        self.default = self.make_bundle("docs")
        (self.default / ".agents").symlink_to(ROOT / "agent", target_is_directory=True)
        self.env = os.environ.copy()
        self.env.pop("BUNDLE", None)
        self.env.pop("DOCS_OKF_REPO_ABS", None)
        self.env["PYTHONDONTWRITEBYTECODE"] = "1"
        self.bash = os.environ.get("BASH") or shutil.which("bash") or "/bin/bash"

    def make_bundle(self, name):
        bundle = self.project / name
        business = bundle / "knowledge/business"
        business.mkdir(parents=True)
        (bundle / "index.md").write_text('---\nokf_version: "0.1"\n---\n# Root\n', encoding="utf-8")
        (bundle / "INDEX-GUIDE.md").write_text(
            "# INDEX-GUIDE\n<!-- docs-build:entity-index:begin -->\n"
            "### 视角入口\n<!-- docs-build:entity-index:end -->\n", encoding="utf-8"
        )
        (business / "BD-EXAMPLE.md").write_text(
            "---\ntype: Business Domain\ntitle: 示例业务域\ndescription: 示例\n"
            'tags: [business, BD]\ntimestamp: "2026-06-16T00:00:00+08:00"\n'
            "id: BD-EXAMPLE\nperspective: business\nhierarchy: BD\nlayer_scope: application\n---\n"
            "## 关系\n\n- (none)\n\n## 跨视角\n\n- (none)\n\n"
            "## 详细说明\n\n示例\n\n## 依据与证据\n\n示例\n", encoding="utf-8"
        )
        return bundle

    def run_entry(self, script, *args, env=None):
        return subprocess.run(
            [self.bash, str(SCRIPTS / script), *args], cwd=self.project,
            env=env or self.env, text=True, capture_output=True
        )

    def snapshot(self):
        return {p.relative_to(self.project): p.read_bytes()
                for p in self.project.rglob("*") if p.is_file()}

    def assert_success(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def test_refresh_cli_nested_bundle_writes_viz_inside_target(self):
        target = self.make_bundle("nested/alternate bundle")
        result = self.run_entry("okf-indexing.sh", "--bundle", "nested/alternate bundle/")
        self.assert_success(result)
        self.assertTrue((target / "viz.html").is_file())
        self.assertFalse((self.project / "alternate bundle").exists())
        self.assertFalse((self.default / "viz.html").exists())
        self.assert_success(self.run_entry("okf-validate.sh", "--bundle", str(target)))

    def test_refresh_absolute_bundle_writes_viz_inside_target(self):
        target = self.make_bundle("nested/absolute")
        self.assert_success(self.run_entry("okf-indexing.sh", f"--bundle={target}/"))
        self.assertTrue((target / "viz.html").is_file())
        self.assertFalse((self.project / "absolute").exists())

    def test_env_override_keeps_full_viz_path(self):
        target = self.make_bundle("nested/from-env")
        env = dict(self.env, BUNDLE="nested/from-env/")
        self.assert_success(self.run_entry("okf-indexing.sh", env=env))
        self.assertTrue((target / "viz.html").is_file())

    def test_cli_overrides_env_and_dry_run_has_no_writes(self):
        self.make_bundle("nested/preview bundle")
        before = self.snapshot()
        result = self.run_entry("okf-indexing.sh", "--bundle=nested/preview bundle", "--dry-run",
                                env=dict(self.env, BUNDLE="missing-env-target"))
        self.assert_success(result)
        commands = [shlex.split(line[4:]) for line in result.stdout.splitlines()
                    if line.startswith(">>> ")]
        self.assertTrue(commands)
        for command in commands:
            self.assertEqual(command[command.index("--bundle") + 1], "nested/preview bundle")
        viz_command = next(command for command in commands if "--out" in command)
        self.assertEqual(viz_command[viz_command.index("--out") + 1], "nested/preview bundle/viz.html")
        self.assertEqual(before, self.snapshot())
        self.assertNotIn("okf-refresh 完成", result.stdout)

    def test_first_refresh_has_child_navigation_and_validate_is_read_only(self):
        self.assert_success(self.run_entry("okf-indexing.sh"))
        self.assertIn("knowledge/index.md", (self.default / "index.md").read_text())
        self.assertIn("business/index.md", (self.default / "knowledge/index.md").read_text())
        self.assertIn("../index.md", (self.default / "knowledge/business/index.md").read_text())
        self.assert_success(self.run_entry("okf-indexing.sh"))
        before = self.snapshot()
        self.assert_success(self.run_entry("okf-validate.sh"))
        self.assertEqual(before, self.snapshot())

    def test_knowledge_navigation_stays_within_knowledge(self):
        knowledge = self.default / "knowledge"
        # 旧生成器留下的上一级导航应被清理，同层自定义导航须保留。
        (knowledge / "index.md").write_text(
            "# knowledge\n\n## 关联索引\n\n"
            "- 上一级索引：[../index.md](../index.md)\n"
            "- 上一级说明：[../README.md](../README.md)\n"
            "- 业务：[business/index.md](business/index.md)\n", encoding="utf-8"
        )
        self.assert_success(self.run_entry("okf-indexing.sh"))
        text = (knowledge / "index.md").read_text(encoding="utf-8")
        self.assertNotIn("../INDEX-GUIDE.md", text)
        self.assertNotIn("../index.md", text)
        self.assertNotIn("../README.md", text)
        self.assertIn("[business/index.md](business/index.md)", text)

    def test_empty_bundle_rejected_without_writes(self):
        before = self.snapshot()
        for script in ("okf-indexing.sh", "okf-validate.sh"):
            for args in (("--bundle=",), ("--bundle", ""), ("--bundle",), ("--bundle", "--dry-run")):
                with self.subTest(script=script, args=args):
                    result = self.run_entry(script, *args)
                    self.assertNotEqual(result.returncode, 0)
                    self.assertEqual(before, self.snapshot())

    def test_validation_error_stops_remaining_refresh_steps(self):
        entity = self.default / "knowledge/business/BD-EXAMPLE.md"
        entity.write_text("# 没有 frontmatter 的实体\n", encoding="utf-8")
        result = self.run_entry("okf-indexing.sh")
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("=== validate-viz-index ===", result.stdout)
        self.assertNotIn("okf-refresh 完成", result.stdout)


if __name__ == "__main__":
    unittest.main()
