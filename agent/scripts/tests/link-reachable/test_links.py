"""用隔离消费仓验证链接检查入口，不修改真实文档或全局配置。"""
from pathlib import Path
import os
import shutil
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[4]


class LinkReachabilityTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="link-reachable-")
        self.addCleanup(self.temp.cleanup)
        self.workspace = Path(self.temp.name).resolve()
        self.repo = self.workspace / "sample"
        self.agent = self.repo / "agent"
        scripts = self.agent / "scripts"
        (scripts / "tools").mkdir(parents=True)
        shutil.copytree(ROOT / "agent/scripts/lib", scripts / "lib")
        for tool in ("validate-link-reachable.sh", "validate_link_reachable.py"):
            shutil.copy2(ROOT / "agent/scripts/tools" / tool, scripts / "tools")
        config_home = self.workspace / "settings"
        (config_home / ".agents").mkdir(parents=True)
        (config_home / ".agents/configs").write_text(f"WORK_SPACE={self.workspace}\n")
        (self.repo / ".docsconfig").write_text(
            f"AGENT_ROOT={config_home}\nAGENT_DIR=.agents\nREPO_DIR=sample\n"
            "DOC_DIR=application\nKNOWLEDGE_TYPE=meta\n"
        )
        for layer in ("application", "system", "solution", "company"):
            self.write(f"{layer}/knowledge/README.md", "# 知识库\n")

    def write(self, relative, text):
        path = self.repo / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def check(self):
        return subprocess.run(
            [os.environ.get("TEST_BASH", "bash"), str(self.agent / "scripts/tools/validate-link-reachable.sh")],
            cwd=self.repo, capture_output=True, text=True,
        )

    def test_import_does_not_require_config_or_scan(self):
        environment = os.environ.copy()
        for key in ("DOC_ABS", "REPO_ABS", "AGENT_TREE"):
            environment.pop(key, None)
        result = subprocess.run(
            [sys.executable, "-B", "-c",
             "import importlib.util, sys; "
             "spec = importlib.util.spec_from_file_location('link_scanner', sys.argv[1]); "
             "scanner = importlib.util.module_from_spec(spec); "
             "spec.loader.exec_module(scanner)",
             str(self.agent / "scripts/tools/validate_link_reachable.py")],
            cwd=self.repo, env=environment, capture_output=True, text=True,
        )
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stdout, "")
        self.assertEqual(result.stderr, "")

    def test_code_examples_are_not_links(self):
        self.write("agent/example.md", """# 文档
`[inline](missing-inline.md)`
``[two](missing-two.md) and `inner` ``
```markdown
[fenced](missing-fenced.md)
```
~~~markdown
[tilde](missing-tilde.md)
~~~
""")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_real_link_after_fence_still_fails(self):
        self.write("agent/example.md", "```markdown\n[fake](fake.md)\n```\n[real](broken.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)
        self.assertNotIn("fake.md", result.stderr)

    def test_escaped_backticks_do_not_hide_links(self):
        self.write("agent/example.md", r"\` [real](broken.md) \`" + "\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_backticks_do_not_pair_across_paragraphs(self):
        self.write("agent/example.md", "`unclosed\n\n[real](broken.md)\n\n`another paragraph\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_inline_triple_backticks_do_not_open_a_fence(self):
        self.write("agent/example.md", "```inline code```\n[real](broken.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_backtick_delimiters_must_have_equal_lengths(self):
        self.write("agent/example.md", "`unclosed [real](broken.md) ``other``\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_test_fixture_is_excluded_but_test_readme_is_checked(self):
        self.write("agent/scripts/tests/okf/fixtures-v1/pass/EXAMPLE.md", "[id](/knowledge/example.md)\n")
        self.write("agent/skills/example/tests/fixtures/input.md", "[invalid](absent.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("agent/scripts/tests/okf/README.md", "[real](broken.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_fixture_named_production_directory_is_checked(self):
        self.write("agent/knowledge/fixtures/sample.md", "[real](broken.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_navigation_template_resolves_each_output_root(self):
        self.write("agent/skills/docs-build/assets/knowledge-index-template.md", "[知识库](knowledge/README.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("agent/skills/docs-build/assets/knowledge-index-template.md", "[知识库](knowledge/ONLY.md)\n")
        for layer in ("application", "system", "solution"):
            self.write(f"{layer}/knowledge/ONLY.md", "# 已有\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("company", result.stderr)
        self.assertIn("ONLY.md", result.stderr)

    def test_other_asset_links_still_checked(self):
        self.write("agent/skills/example/assets/guide.md", "[real](broken.md)\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("broken.md", result.stderr)

    def test_real_relative_links_and_boundary(self):
        self.write("agent/guide.md", "[内部](knowledge/README.md)\n[应用](../application/knowledge/README.md)\n")
        self.write("agent/knowledge/README.md", "# 导航\n")
        result = self.check()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("agent/guide.md", "[越界](../../outside.md)\n")
        self.write("../outside.md", "# 外部\n")
        result = self.check()
        self.assertEqual(result.returncode, 1)
        self.assertIn("跨出 agent", result.stderr)


if __name__ == "__main__":
    unittest.main()
