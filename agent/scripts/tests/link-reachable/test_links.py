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

    def check(self, *args):
        return subprocess.run(
            [os.environ.get("TEST_BASH", "bash"), str(self.agent / "scripts/tools/validate-link-reachable.sh"), *args],
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

    def test_root_layers_checks_all_layers_and_todos(self):
        self.write("TODO-LIST.md", "[待办](root-missing.md)\n")
        for layer in ("application", "system", "solution", "company"):
            self.write(f"{layer}/TODO-LIST.md", f"[待办]({layer}-missing.md)\n")
        self.assertEqual(self.check().returncode, 0)
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        for name in ("root", "application", "system", "solution", "company"):
            self.assertIn(f"{name}-missing.md", result.stderr)

    def test_session_material_is_not_scanned_as_knowledge(self):
        self.write("application/.superpowers/" "specs/note.md", "[draft](absent.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_explicit_session_docs_root_is_excluded(self):
        self.write(".superpowers/" "specs/note.md", "[draft](absent.md)\n")
        config = self.repo / ".docsconfig"
        config.write_text(config.read_text().replace("DOC_DIR=application", "DOC_DIR=.superpowers"))
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_session_file_alias_is_not_scanned(self):
        draft = self.write(".superpowers/" "specs/note.md", "[draft](absent.md)\n")
        (self.repo / "alias.md").symlink_to(draft)
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)

    def test_wrong_depth_is_not_rescued_by_root_candidate(self):
        self.write("target.md", "# 存在\n")
        self.write("system/knowledge/deep/README.md", "[错层](target.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("target.md", result.stderr)

    def test_anchors_decode_and_match_heading_text_and_duplicates(self):
        self.write("README.md", """# IaC
## 本方案产品线（PL）
## **Bold** `Code` [Link](#iac)
## repeat
## repeat
## repeat-1
## repeat
<a id="Case-ID"></a>
Setext
------
[a](#iac) [b](#本方案产品线pl) [c](#bold-code-link)
[d](#repeat-1) [e](#repeat-1-1) [f](#repeat-2)
[g](#Case-ID) [h](#setext) [i](#%69ac)
""")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("TODO-LIST.md", "[大小写错误](README.md#IaC)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("#IaC", result.stderr)

    def test_code_and_comments_cannot_create_anchors(self):
        self.write("README.md", "# Real\n```md\n# Fake\n```\n<!-- <a id='fake-id'></a> -->\n")
        self.write("TODO-LIST.md", "[缺失](README.md#fake) [缺失](README.md#fake-id)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("#fake)", result.stderr)
        self.assertIn("#fake-id)", result.stderr)

    def test_reference_links_titles_and_parenthesized_paths(self):
        self.write("guide (v1).md", "# 目标\n")
        self.write("guide(v2).md", "# 目标\n")
        self.write("README.md", """[全引用][doc] [doc][] [doc]
[doc]: <guide (v1).md#目标> "标题"
[行内](<guide (v1).md#目标> '标题')
[括号](guide(v2).md#目标 "标题")
[编码](guide%20%28v1%29.md#%E7%9B%AE%E6%A0%87)
""")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("README.md", "[缺失][bad]\n\n[bad]: absent.md\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("absent.md", result.stderr)

    def test_root_examples_and_external_urls_are_not_local_links(self):
        self.write("README.md", """`[示例](inline.md)`
```md
[示例](fenced.md)
```
<!-- [注释](comment.md) -->
[外链](https://example.invalid/path#fragment)
[邮箱](mailto:nobody@example.invalid)
""")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("root-layers", result.stdout)

    def test_examples_and_assets_are_not_exempt(self):
        self.write("system/assets/EXAMPLE.md", "[真实](absent.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("absent.md", result.stderr)

    def test_unknown_placeholder_requires_judgment(self):
        self.write("README.md", "[模板]({UNKNOWN}/target.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("待判断", result.stderr)
        self.assertIn("{UNKNOWN}", result.stderr)

    def test_slot_readme_is_checked_without_scanning_child_repository(self):
        self.write("../child/README.md", "[不扫描](external-broken.md)\n")
        slot = self.repo / "system/application-slots"
        slot.mkdir(parents=True)
        (slot / "child").symlink_to(self.workspace / "child", target_is_directory=True)
        self.write("system/application-slots/README.md", "[槽位](child/README.md#unknown)\n")
        self.write("system/knowledge/README.md", "[相邻槽位](../application-slots/child/README.md#unknown)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("排除", result.stdout)
        self.write("system/application-slots/README.md", "[本地坏链](missing.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing.md", result.stderr)
        self.assertNotIn("external-broken.md", result.stderr)

    def test_symlink_escape_is_not_read_as_local_document(self):
        self.write("../outside.md", "# 外部\n")
        (self.repo / "application/escape.md").symlink_to(self.workspace / "outside.md")
        self.write("README.md", "[越界](application/escape.md#外部)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("越界", result.stderr)

    def test_meta_agent_paths_do_not_bypass_relative_depth(self):
        self.write("agent/knowledge/guide.md", "# 规则\n")
        self.write("system/knowledge/README.md", "[规则](../../agent/knowledge/guide.md#规则)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("system/knowledge/README.md", "[错层](../agent/knowledge/guide.md#规则)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("../agent/knowledge/guide.md", result.stderr)

    def test_installed_agent_links_use_actual_layout(self):
        self.write("../settings/.agents/knowledge/guide.md", "# 已安装\n")
        (self.repo / "application/.agents").symlink_to(self.workspace / "settings/.agents", target_is_directory=True)
        self.write("application/README.md", "[安装树](.agents/knowledge/guide.md#已安装)\n")
        config = self.repo / ".docsconfig"
        config.write_text(config.read_text().replace("KNOWLEDGE_TYPE=meta", "KNOWLEDGE_TYPE=application"))
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.write("application/README.md", "[安装树](.agents/knowledge/guide.md#未安装)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("#未安装", result.stderr)

    def test_unknown_scope_is_rejected(self):
        result = self.check("--scope", "typo")
        self.assertNotEqual(result.returncode, 0)

    def test_multiline_reference_definitions_are_checked(self):
        self.write("README.md", "[文档][doc]\n\n[doc]:\n  missing.md\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("missing.md", result.stderr)

    def test_data_id_does_not_create_an_anchor(self):
        self.write("README.md", '<div data-id="fake"></div>\n[坏锚点](#fake)\n')
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("#fake", result.stderr)

    def test_indented_code_is_ignored_but_list_links_are_checked(self):
        self.write("README.md", "# 说明\n\n    [代码](fake.md)\n\n- 列表\n    - [真实](missing.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertNotIn("fake.md", result.stderr)
        self.assertIn("missing.md", result.stderr)

    def test_configured_consumer_doc_root_is_scanned(self):
        config = self.repo / ".docsconfig"
        config.write_text(config.read_text().replace("DOC_DIR=application", "DOC_DIR=team/manual")
                          .replace("KNOWLEDGE_TYPE=meta", "KNOWLEDGE_TYPE=application"))
        self.write("team/manual/TODO-LIST.md", "[待办](missing.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("team/manual/TODO-LIST.md", result.stderr)

    def test_heading_inline_markup_preserves_rendered_text(self):
        self.write("target(v1).md", "# 目标\n")
        self.write("README.md", """# __Bold__
## `_under_`
## `<Type>`
## [Visible](target(v1).md)
## [Guide][doc]

[doc]: target(v1).md
[a](#bold) [b](#_under_) [c](#type) [d](#visible) [e](#guide)
""")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 0, result.stderr)

    @unittest.skipIf(os.geteuid() == 0, "root 可绕过文件权限")
    def test_unreadable_directory_fails_instead_of_passing_empty_scan(self):
        directory = self.repo / "application"
        directory.chmod(0)
        try:
            result = self.check("--scope", "root-layers")
        finally:
            directory.chmod(0o755)
        self.assertEqual(result.returncode, 1)
        self.assertIn("application", result.stderr)

    def test_parent_segment_after_symlink_cannot_hide_escape(self):
        self.write("../foreign/child/README.md", "# 外部\n")
        self.write("../foreign/outside.md", "# 外部\n")
        self.write("application/outside.md", "# 错误的兜底候选\n")
        (self.repo / "application/portal").symlink_to(self.workspace / "foreign/child", target_is_directory=True)
        self.write("application/README.md", "[越界](portal/../outside.md)\n")
        result = self.check("--scope", "root-layers")
        self.assertEqual(result.returncode, 1)
        self.assertIn("越界", result.stderr)


if __name__ == "__main__":
    unittest.main()
