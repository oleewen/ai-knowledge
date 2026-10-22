"""Exercise the public shell command with complete documents and real files."""

import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


SKILL = Path(__file__).resolve().parents[1]
SCRIPT = SKILL / "scripts" / "validate-feature.sh"
FIXTURE = SKILL / "tests" / "fixtures" / "FEATURE-261022-审批提效.md"
VALID = FIXTURE.read_text(encoding="utf-8")
CONTEXT_VALID = (FIXTURE.parent / "CONTEXT.md").read_text(encoding="utf-8")


def bash5():
    candidates = [os.environ.get("BASH5"), shutil.which("bash"),
                  "/opt/homebrew/bin/bash", "/usr/local/bin/bash"]
    for candidate in candidates:
        if candidate and Path(candidate).is_file():
            result = subprocess.run([candidate, "-c", "test ${BASH_VERSINFO[0]} -ge 5"],
                                    check=False, capture_output=True)
            if result.returncode == 0:
                return candidate
    raise unittest.SkipTest("Bash 5+ is required")


class ValidateFeatureTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.bash = bash5()

    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="sdx-feature-", dir="/tmp")
        self.addCleanup(self.temporary.cleanup)
        self.root = Path(self.temporary.name).resolve()
        self.repo = self.root / "repo"
        self.features = self.repo / "docs" / "features"
        self.features.mkdir(parents=True)
        self.file = self.features / FIXTURE.name
        self.file.write_text(VALID, encoding="utf-8")
        store = self.root / "agent-home" / "agents"
        store.mkdir(parents=True)
        (store / "configs").write_text(f"WORK_SPACE={self.root}\n", encoding="utf-8")
        (self.repo / ".docsconfig").write_text(
            f"AGENT_ROOT={store.parent}\nAGENT_DIR=agents\nREPO_DIR=repo\n"
            "DOC_DIR=docs\nKNOWLEDGE_TYPE=application\n", encoding="utf-8")

    def command(self, *args, cwd=None):
        return subprocess.run([self.bash, str(SCRIPT), *map(str, args)],
                              cwd=cwd or self.repo, capture_output=True,
                              text=True, check=False)

    def validate(self, text=VALID, strict=False):
        self.file.write_text(text, encoding="utf-8")
        args = ["--file", self.file]
        if strict:
            args.append("--strict")
        return self.command(*args)

    def assert_clean(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("[WARN]", result.stdout)
        self.assertNotIn("[ERROR]", result.stdout)

    def assert_warning(self, text, topic):
        loose = self.validate(text)
        self.assertEqual(loose.returncode, 0, loose.stdout + loose.stderr)
        warnings = "\n".join(line for line in loose.stdout.splitlines() if "[WARN]" in line)
        self.assertIn(topic, warnings, loose.stdout + loose.stderr)
        strict = self.validate(text, strict=True)
        self.assertNotEqual(strict.returncode, 0, strict.stdout + strict.stderr)
        self.assertIn(topic, strict.stdout + strict.stderr)

    def test_valid_feature_has_no_warning_and_mvp_detail_is_not_double_counted(self):
        self.assert_clean(self.validate(strict=True))

    def test_wrong_id_and_unrelated_parent_are_content_warnings(self):
        for before, after, topic in [
            ('id: "FEATURE-', 'id: "ANALYSIS-', "id"),
            ('id: "FEATURE-261022-审批提效"', 'id: "FEATURE-261022-另一主题"', "文件名"),
            ('parent: "ANALYSIS-261022-审批提效"', 'parent: "ANALYSIS-261022-另一主题"', "parent"),
        ]:
            with self.subTest(topic=topic):
                self.assert_warning(VALID.replace(before, after, 1), topic)

    def test_file_option_is_independent_of_config_and_relative_to_calling_directory(self):
        self.assert_clean(self.command("--strict", "--file", "repo/docs/features/" + FIXTURE.name,
                                       cwd=self.root))
        self.assert_clean(self.command("--file", FIXTURE.name, cwd=self.features))

    def test_help_and_missing_argument_work_without_config(self):
        help_result = self.command("--help", cwd=self.root)
        self.assertEqual(help_result.returncode, 0, help_result.stderr)
        self.assertIn("--strict", help_result.stdout)
        for args in [("--file",), ("--file", "--strict"), ("--unknown",)]:
            with self.subTest(args=args):
                result = self.command(*args, cwd=self.root)
                self.assertNotEqual(result.returncode, 0)
                self.assertNotIn("unbound variable", result.stderr)
                self.assertIn("用法", result.stdout + result.stderr)

    def test_missing_file_and_unclosed_frontmatter_are_fatal_in_default_mode(self):
        self.assertNotEqual(self.command("--file", "missing.md").returncode, 0)
        self.assertNotEqual(self.validate(VALID.replace("---\n\n# 审批提效", "\n# 审批提效", 1)).returncode, 0)
        self.assertNotEqual(self.validate(VALID.split("---", 2)[2]).returncode, 0)

    def test_utf8_read_failure_is_fatal_and_bom_crlf_is_supported(self):
        self.file.write_bytes(b"\xff\xfe invalid UTF-8")
        result = self.command("--file", self.file)
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("Traceback", result.stderr)
        self.file.write_bytes(("\ufeff" + VALID.replace("\n", "\r\n")).encode("utf-8"))
        self.assert_clean(self.command("--strict", "--file", self.file))

    def test_scan_uses_docsconfig_and_missing_directory_stays_nonfatal_by_default(self):
        self.assert_clean(self.command("--strict"))
        (self.repo / ".docsconfig").write_text(
            (self.repo / ".docsconfig").read_text().replace("DOC_DIR=docs", "DOC_DIR=empty"),
            encoding="utf-8")
        result = self.command()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("features/", result.stdout)
        self.assertNotIn("analysis/", result.stdout)

    def test_empty_scan_warns_and_strict_mode_fails(self):
        self.file.rename(self.features / "notes.md")
        loose = self.command()
        self.assertEqual(loose.returncode, 0)
        self.assertIn("未检查任何文档", loose.stdout)
        self.assertNotIn("校验通过", loose.stdout)
        self.assertNotEqual(self.command("--strict").returncode, 0)

    def test_headers_inside_comments_or_fences_do_not_satisfy_structure(self):
        for wrapper in ["<!--\n{}\n-->", "```markdown\n{}\n```", "~~~markdown\n{}\n~~~"]:
            with self.subTest(wrapper=wrapper):
                text = VALID.replace("## 3. 非功能需求", wrapper.format("## 3. 非功能需求"), 1)
                self.assert_warning(text, "3. 非功能需求")

    def test_subheading_must_be_under_its_own_section(self):
        text = VALID.replace("### 3.1 体验与性能", "体验与性能", 1)
        text += "\n### 3.1 体验与性能\n附录中的示例。\n"
        self.assert_warning(text, "3.1 体验与性能")

    def test_overview_columns_cannot_be_satisfied_by_other_sections(self):
        self.assert_warning(VALID.replace("| 所属模块 |", "| 模块 |", 1) + "\n所属模块\n", "所属模块")
        self.assert_warning(VALID.replace("| G-1 |\n| FR-002", "| G-1 | 多余 |\n| FR-002", 1), "列数")

    def test_row_cell_rules_are_checked_per_fr(self):
        for before, after, topic in [
            ("| 待办管理 |", "| |", "所属模块"),
            ("| 待办管理 |", "| 待办管理，审批管理 |", "所属模块"),
            ("| M1（待办可见） |", "| |", "所属里程碑"),
            ("| M1（待办可见） |", "| MVP1（待办可见） |", "所属里程碑"),
            ("| M1（待办可见） |", "| M1（ ） |", "所属里程碑"),
            ("| M1（待办可见） |", "| M1（待办可见）, M2（审批闭环） |", "所属里程碑"),
            ("| G-1 |\n| FR-002", "| 无 |\n| FR-002", "关联目标"),
        ]:
            with self.subTest(after=after):
                self.assert_warning(VALID.replace(before, after, 1), topic)

    def test_unicode_lengths_include_punctuation_and_accept_exact_boundaries(self):
        name = "审" * 29 + "🙂"
        summary = "查" * 59 + "。"
        text = VALID.replace("查看待办", name).replace("审批人查看待处理事项", summary)
        self.assert_clean(self.validate(text, strict=True))
        self.assert_warning(text.replace(name, name + "！"), "30")
        self.assert_warning(text.replace(summary, summary + "！"), "60")

    def test_overview_and_fr_headings_have_one_to_one_ids_and_equal_names(self):
        for before, after, topic in [
            ("### FR-001: 查看待办", "### FR-001: 查看积压", "名称"),
            ("### FR-001: 查看待办", "### FR-003: 查看待办", "FR-001"),
            ("### FR-002: 完成审批", "### FR-001: 完成审批", "重复"),
            ("| FR-002 | 完成审批", "| FR-001 | 完成审批", "重复"),
        ]:
            with self.subTest(after=after):
                self.assert_warning(VALID.replace(before, after, 1), topic)

    def test_table_accepts_reordered_columns_and_escaped_pipes(self):
        text = VALID.replace("| 优先级 | 所属模块 |", "| 所属模块 | 优先级 |", 1)
        text = text.replace("| P0 | 待办管理 |", "| 待办管理 | P0 |", 1)
        text = text.replace("| P1 | 审批管理 |", "| 审批管理 | P1 |", 1)
        text = text.replace("审批人查看待处理事项", "查看待办\\|积压")
        self.assert_clean(self.validate(text, strict=True))

    def test_mvp_loads_every_overview_fr_once_and_rejects_unknown_fr(self):
        for include, topic in [("FR-001", "FR-002"),
                               ("FR-001, FR-001, FR-002", "FR-001"),
                               ("FR-001, FR-002, FR-099", "FR-099")]:
            with self.subTest(include=include):
                self.assert_warning(VALID.replace("| FR-001, FR-002 |", f"| {include} |", 1), topic)
        duplicate = "| MVP2（复查） | 再审 | FR-001 | 复查 | 待共拟 | MVP1 |\n"
        self.assert_warning(VALID.replace("| 待共拟 | 无 |\n", "| 待共拟 | 无 |\n" + duplicate, 1), "FR-001")

    def test_delivery_rows_cannot_be_replaced_by_appendix_example(self):
        row = "| MVP1（待办闭环） | 可查看并审批 | FR-001, FR-002 | 缩短等待 | 待共拟 | 无 |"
        self.assert_warning(VALID.replace(row, "", 1) + "\n" + row, "MVP")

    def test_second_overview_table_cannot_hide_an_extra_requirement(self):
        extra = ("| 需求编号 | 需求名称 | 需求概要 | 优先级 | 所属模块 | 所属里程碑 | 关联目标 |\n"
                 "| --- | --- | --- | --- | --- | --- | --- |\n"
                 "| FR-003 | 复查审批 | 复查已审批事项 | P2 | 审批管理 | M2（审批闭环） | G-1 |\n")
        self.assert_warning(VALID.replace("### FR-001: 查看待办", extra + "\n### FR-001: 查看待办", 1), "FR-003")

    def test_adr_checks_real_reference_section_files_and_exact_context_id(self):
        text = VALID.replace("### 6.3 变更历史", "[决策](../adr/ADR-1-审批.md)\n"
                             "[决策索引](../adr/CONTEXT.md)\n\n### 6.3 变更历史", 1)
        adr = self.repo / "docs" / "adr"
        adr.mkdir()
        (adr / "ADR-1-审批.md").write_text("# 审批决策\n", encoding="utf-8")
        (adr / "CONTEXT.md").write_text(CONTEXT_VALID.replace("ADR-1", "ADR-10"), encoding="utf-8")
        self.assert_warning(text, "CONTEXT 未登记 ADR-1")
        (adr / "CONTEXT.md").write_text(CONTEXT_VALID, encoding="utf-8")
        self.assert_clean(self.validate(text, strict=True))
        self.assert_warning(text.replace("[决策索引](../adr/CONTEXT.md)", ""), "CONTEXT")
        self.assert_warning(text.replace("[决策索引](../adr/CONTEXT.md)", "`../adr/CONTEXT.md`"), "CONTEXT")
        self.assert_warning(text.replace("[决策索引](../adr/CONTEXT.md)", "`[决策索引](../adr/CONTEXT.md)`"), "CONTEXT")
        self.assert_warning(text.replace("[决策索引](../adr/CONTEXT.md)", "[决策索引](../other/CONTEXT.md)"), "CONTEXT")
        self.assert_warning(text.replace("ADR-1-审批.md", "ADR-2-审批.md"), "ADR-2")

    def test_commented_adr_and_fake_bad_rows_are_ignored(self):
        text = VALID + "\n<!-- ADR-待定 ADR-1 -->\n```markdown\n"
        text += "### FR-999: 错误示例\n| FR-999 | | | P0 | | MVP1 | |\n```\n"
        self.assert_clean(self.validate(text, strict=True))

    def test_adr_link_checks_exact_file_even_when_same_id_file_exists(self):
        adr = self.repo / "docs" / "adr"
        adr.mkdir()
        (adr / "ADR-1-实际决策.md").write_text("# 审批决策\n", encoding="utf-8")
        (adr / "CONTEXT.md").write_text(CONTEXT_VALID.replace("ADR-1-审批.md", "ADR-1-实际决策.md"), encoding="utf-8")
        other = self.repo / "docs" / "other"
        other.mkdir()
        (other / "ADR-1-其他层.md").write_text("# 其他层决策\n", encoding="utf-8")
        (adr / "ADR-1-目录.md").mkdir()
        for target in ["../adr/ADR-1-不存在.md", "../other/ADR-1-其他层.md", "../adr/ADR-1-目录.md"]:
            with self.subTest(target=target):
                text = VALID.replace("### 6.3 变更历史", f"[决策]({target})\n"
                                     "[决策索引](../adr/CONTEXT.md)\n\n### 6.3 变更历史", 1)
                self.assert_warning(text, target)

    def test_adr_exact_link_and_context_with_identifier_remain_valid(self):
        adr = self.repo / "docs" / "adr"
        adr.mkdir()
        (adr / "ADR-1-实际决策.md").write_text("# 审批决策\n", encoding="utf-8")
        (adr / "CONTEXT.md").write_text(CONTEXT_VALID.replace("ADR-1-审批.md", "ADR-1-实际决策.md"), encoding="utf-8")
        for reference in ["[决策](../adr/ADR-1-实际决策.md)", "审批决策见 ADR-1。"]:
            with self.subTest(reference=reference):
                text = VALID.replace("### 6.3 变更历史", reference + "\n"
                                     "[决策索引](../adr/CONTEXT.md)\n\n### 6.3 变更历史", 1)
                self.assert_clean(self.validate(text, strict=True))

    def test_adr_mention_in_other_context_columns_is_not_a_registration(self):
        adr = self.repo / "docs" / "adr"
        adr.mkdir()
        (adr / "ADR-1-审批.md").write_text("# 审批决策\n", encoding="utf-8")
        text = VALID.replace("### 6.3 变更历史", "审批决策见 ADR-1。\n"
                             "[决策索引](../adr/CONTEXT.md)\n\n### 6.3 变更历史", 1)
        contexts = [CONTEXT_VALID.replace("ADR-1", "ADR-2").replace("审批决策", "替代 ADR-1"),
                    CONTEXT_VALID.replace("| ADR-1 |", "| ADR-2 |")]
        for context in contexts:
            with self.subTest(context=context):
                (adr / "CONTEXT.md").write_text(context, encoding="utf-8")
                self.assert_warning(text, "CONTEXT 未登记 ADR-1")

    def test_external_adr_link_is_not_replaced_by_existing_local_file(self):
        adr = self.repo / "docs" / "adr"
        adr.mkdir()
        (adr / "ADR-1-审批.md").write_text("# 审批决策\n", encoding="utf-8")
        (adr / "CONTEXT.md").write_text(CONTEXT_VALID, encoding="utf-8")
        for target in ["https://example.invalid/ADR-1-审批.md", "//example.invalid/ADR-1-审批.md"]:
            with self.subTest(target=target):
                text = VALID.replace("### 6.3 变更历史", f"[决策]({target})\n"
                                     "[决策索引](../adr/CONTEXT.md)\n\n### 6.3 变更历史", 1)
                self.assert_warning(text, target)


if __name__ == "__main__":
    unittest.main()
