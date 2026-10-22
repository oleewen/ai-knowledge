"""Exercise the public Bash command against isolated documents and configuration."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest


SKILL = Path(__file__).resolve().parents[1]
SCRIPT = SKILL / "scripts" / "validate-prd.sh"
AGENT = SKILL.parents[1]

FRONTMATTER = """---
id: "PRD-ORDER-01-1"
title: "订单需求"
version: "1.0.0"
status: "draft"
created: "2026-10-22"
updated: "2026-10-22"
author: "产品"
reviewers: []
parent: "FEATURE-ORDER-01"
mvp_phase: "MVP-Phase-1"
---
"""
BODY = """# 订单需求
## 1. 产品概述
### 1.2 成功标准
## 2. 业务流程
### 2.1 核心业务流程
```mermaid
flowchart LR
    A --> B
```
## 3. 产品交互
## 4. 用例模型
### 4.1 用例图
UC-001
## 5. 用户故事
### 5.1 用户故事清单
US-001 关联 FR-001
## 6. 功能模块设计
## 7. 业务规则汇总
## 8. 数据字典
## 9. 非功能需求
## 10. 验收标准
### 10.1 功能验收标准
AC-001
## 11. 附录
### 11.3 质量自查表
"""


class ValidatorTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="prd tests ")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.repo = self.root / "repo"
        self.repo.mkdir()
        self.docs = self.repo / "docs"
        self.docs.mkdir()
        self.outside = self.root / "outside"
        self.outside.mkdir()
        agents = self.root / "agents"
        agents.mkdir()
        (agents / "configs").write_text(f"WORK_SPACE={self.root}\n", encoding="utf-8")
        (self.repo / ".docsconfig").write_text(
            f"AGENT_ROOT={self.root}\nAGENT_DIR=agents\nREPO_DIR=repo\n"
            "DOC_DIR=docs\nKNOWLEDGE_TYPE=application\n", encoding="utf-8"
        )

    def document(self, content=None, directory=None, name="PRD-ORDER-01-1.md"):
        directory = self.docs if directory is None else directory
        directory.mkdir(parents=True, exist_ok=True)
        path = directory / name
        path.write_text(FRONTMATTER + BODY if content is None else content, encoding="utf-8")
        return path

    def command(self, *args, cwd=None, script=SCRIPT):
        return subprocess.run(
            [os.environ.get("BASH", "bash"), str(script), *map(str, args)],
            cwd=self.repo if cwd is None else cwd,
            text=True, capture_output=True, check=False,
        )

    def assert_code(self, expected, result):
        self.assertEqual(expected, result.returncode, result.stdout + result.stderr)

    def test_valid_feature_document_has_no_warnings(self):
        result = self.command("--file", self.document())
        self.assert_code(0, result)
        self.assertIn("warnings=0", result.stdout)

    def test_real_repository_template_passes_after_identity_substitution(self):
        content = (SKILL / "assets" / "prd-template.md").read_text(encoding="utf-8")
        content = content.replace("{IDEA-ID}", "ORDER-01").replace("{N}", "1")
        content = content.replace("{YYYY-MM-DD}", "2026-10-22")
        path = self.document(content)
        original = path.read_bytes()
        self.assert_code(0, self.command("--file", path))
        self.assertEqual(original, path.read_bytes())

    def test_template_subheading_labels_and_shorthand_share_one_identity(self):
        aliases = [("10.1 功能验收标准", "10.1 功能验收标准（FAC）"),
                   ("11.3 质量自查表", "11.3 质量自查表 (Self-Check)")]
        for short, full in aliases:
            with self.subTest(full=full):
                text = FRONTMATTER + BODY.replace("### " + short, "### " + full)
                self.assert_code(0, self.command("--file", self.document(text)))
                self.assert_code(1, self.command("--file", self.document(text + "\n### " + short + "\n")))

    def test_standalone_file_needs_no_configuration(self):
        result = self.command("--file", self.document(directory=self.outside), cwd=self.outside)
        self.assert_code(0, result)

    def test_relative_file_uses_calling_directory_and_preserves_bytes(self):
        path = self.document(directory=self.docs / "目录 有空格")
        original = path.read_bytes()
        result = self.command("--file", "PRD-ORDER-01-1.md", cwd=path.parent)
        self.assert_code(0, result)
        self.assertEqual(original, path.read_bytes())

    def test_relative_script_from_subdirectory(self):
        (self.repo / "agent").symlink_to(AGENT, target_is_directory=True)
        path = self.document()
        result = self.command("--file", path, cwd=self.docs,
                              script="../agent/skills/sdx-prd/scripts/validate-prd.sh")
        self.assert_code(0, result)

    def test_help_without_configuration(self):
        self.assert_code(0, self.command("--help", cwd=self.outside))

    def test_invalid_arguments_have_usage_exit(self):
        for args in [("--file",), ("--unknown",), ("--file", ""),
                     ("--file", "a", "--file", "b"), ("--help", "extra")]:
            with self.subTest(args=args):
                self.assert_code(2, self.command(*args, cwd=self.outside))

    def test_missing_file_and_missing_config_have_environment_exit(self):
        result = self.command("--file", self.outside / "missing.md")
        self.assert_code(2, result)
        self.assertIn("status=ERROR validated=0 errors=1", result.stdout)
        self.assert_code(2, self.command(cwd=self.outside))

    @unittest.skipUnless(hasattr(os, "mkfifo"), "命名管道仅在 POSIX 上可用")
    def test_named_pipe_is_rejected_without_blocking(self):
        directory = self.docs / "requirements"
        directory.mkdir()
        pipe = directory / "PRD-ORDER-01-1.md"
        os.mkfifo(pipe)
        for args in [("--file", str(pipe)), ()]:
            with self.subTest(args=args):
                try:
                    result = subprocess.run(
                        [os.environ.get("BASH", "bash"), str(SCRIPT), *args],
                        cwd=self.repo, text=True, capture_output=True, timeout=1,
                    )
                except subprocess.TimeoutExpired:
                    self.fail("校验器读取命名管道时阻塞")
                self.assert_code(2, result)

    def test_empty_scan_is_not_validation(self):
        result = self.command()
        self.assert_code(0, result)
        self.assertIn("status=NOT_VALIDATED", result.stdout)
        (self.docs / "requirements").mkdir()
        result = self.command()
        self.assert_code(0, result)
        self.assertIn("validated=0", result.stdout)

    def test_scan_validates_real_files_and_ignores_named_directories(self):
        directory = self.docs / "requirements" / "REQUIREMENT-ORDER-01" / "MVP-Phase-1"
        self.document(directory=directory)
        (directory / "PRD-not-a-file.md").mkdir()
        result = self.command()
        self.assert_code(0, result)
        self.assertIn("validated=1", result.stdout)

    def test_scan_reports_any_invalid_document(self):
        directory = self.docs / "requirements"
        self.document(directory=directory)
        self.document("---\n---\n", directory=directory, name="PRD-BAD-1.md")
        result = self.command()
        self.assert_code(1, result)
        self.assertIn("validated=2", result.stdout)

    def test_missing_metadata_or_empty_values_are_errors(self):
        for field in ["id", "title", "version", "status", "created", "updated",
                      "author", "reviewers", "parent", "mvp_phase"]:
            with self.subTest(field=field):
                lines = [line for line in FRONTMATTER.splitlines() if not line.startswith(field + ":")]
                self.assert_code(1, self.command("--file", self.document("\n".join(lines) + "\n" + BODY)))
        self.assert_code(1, self.command("--file", self.document(FRONTMATTER.replace('title: "订单需求"', 'title: ""') + BODY)))

    def test_bad_identity_parent_and_phase_are_errors(self):
        for old, new in [('id: "PRD-ORDER-01-1"', 'id: "PRD-WRONG-1"'),
                         ('parent: "FEATURE-ORDER-01"', 'parent: "ANALYSIS-ORDER-01"'),
                         ('mvp_phase: "MVP-Phase-1"', 'mvp_phase: "MVP-Phase-2"')]:
            with self.subTest(new=new):
                self.assert_code(1, self.command("--file", self.document(FRONTMATTER.replace(old, new) + BODY)))

    def test_inherited_unicode_and_legacy_idea_ids_are_preserved(self):
        for idea in ["261022-审批提效", "legacy_订单.v2", "OPS-order-99"]:
            with self.subTest(idea=idea):
                metadata = FRONTMATTER.replace("ORDER-01", idea)
                metadata = metadata.replace(f"PRD-{idea}-1", f"PRD-{idea}-12")
                metadata = metadata.replace("MVP-Phase-1", "MVP-Phase-12")
                path = self.document(metadata + BODY, name=f"PRD-{idea}-12.md",
                                     directory=self.docs / f"REQUIREMENT-{idea}" / "MVP-Phase-12")
                self.assert_code(0, self.command("--file", path))
                path.write_text((metadata + BODY).replace(f"FEATURE-{idea}", "FEATURE-WRONG"), encoding="utf-8")
                self.assert_code(1, self.command("--file", path))

    def test_phase_suffix_must_still_be_a_positive_integer(self):
        for phase in ["0", "01", "-1", "1.5"]:
            with self.subTest(phase=phase):
                name = f"PRD-261022-审批提效-{phase}"
                metadata = FRONTMATTER.replace("PRD-ORDER-01-1", name)
                metadata = metadata.replace("FEATURE-ORDER-01", "FEATURE-261022-审批提效")
                metadata = metadata.replace("MVP-Phase-1", "MVP-Phase-" + phase)
                self.assert_code(1, self.command("--file", self.document(metadata + BODY, name=name + ".md")))

    def test_recognizable_layout_must_match_identity(self):
        for requirement, phase in [("REQUIREMENT-OTHER", "MVP-Phase-1"),
                                   ("REQUIREMENT-ORDER-01", "MVP-Phase-2")]:
            with self.subTest(requirement=requirement, phase=phase):
                path = self.document(directory=self.docs / requirement / phase)
                self.assert_code(1, self.command("--file", path))
                via_parent = path.parent / ".." / path.parent.name / path.name
                self.assert_code(1, self.command("--file", via_parent))

    def test_crlf_and_single_quoted_metadata_are_valid(self):
        path = self.document()
        path.write_bytes((FRONTMATTER.replace('"', "'") + BODY).replace("\n", "\r\n").encode("utf-8"))
        original = path.read_bytes()
        result = self.command("--file", path)
        self.assert_code(0, result)
        self.assertIn("warnings=0", result.stdout)
        self.assertEqual(original, path.read_bytes())

    def test_supported_comments_and_reviewer_lists(self):
        variants = ["reviewers: ['产品', \"架构\"] # 已邀请", "reviewers:\n  - '产品'\n  - 架构",
                    "reviewers: [] # [待安排]", "reviewers: ['产品, 订单', \"架构]支持\"]"]
        for reviewers in variants:
            with self.subTest(reviewers=reviewers):
                text = FRONTMATTER.replace("reviewers: []", reviewers)
                text = text.replace('title: "订单需求"', "title: '产品''订单' # 文本")
                self.assert_code(0, self.command("--file", self.document(text + BODY)))

    def test_utf8_bom_is_supported_and_invalid_utf8_is_document_error(self):
        path = self.document()
        path.write_bytes(b"\xef\xbb\xbf" + path.read_bytes())
        self.assert_code(0, self.command("--file", path))
        path.write_bytes(b"\xff\xfe")
        self.assert_code(1, self.command("--file", path))

    def test_malformed_or_unsupported_yaml_is_rejected(self):
        for value in ["[unclosed", "{nested: object}", "|", "&anchor name", '"bad\\q"', "plain: nested"]:
            with self.subTest(value=value):
                text = FRONTMATTER.replace('title: "订单需求"', "title: " + value)
                self.assert_code(1, self.command("--file", self.document(text + BODY)))
        self.assert_code(1, self.command("--file", self.document(FRONTMATTER.replace("reviewers: []", "reviewers: []\nstatus: approved") + BODY)))

    def test_reviewers_cannot_hide_unclosed_or_nested_lists(self):
        variants = ["reviewers: [Alice, Bob]]", "reviewers: [Alice # unfinished]",
                    "reviewers: [a[b]", "reviewers: [a{b]",
                    "reviewers:\n  - Alice\n    - Bob"]
        for reviewers in variants:
            with self.subTest(reviewers=reviewers):
                self.assert_code(1, self.command("--file", self.document(FRONTMATTER.replace("reviewers: []", reviewers) + BODY)))

    def test_literal_comment_marker_in_inline_code_does_not_hide_chapters(self):
        for sentence in ["文档中可以用 `<!--` 编写注释。\n", "文档中可以用 `` `<!--` `` 编写注释。\n",
                         "    <!--\n\n", "> <!--\n\n"]:
            with self.subTest(sentence=sentence):
                self.assert_code(0, self.command("--file", self.document(FRONTMATTER + sentence + BODY)))

    def test_comment_end_line_cannot_supply_a_required_heading(self):
        for hidden in ["<!-- ignore --> ## 1. 产品概述",
                       "<!-- ignore\n--> ## 1. 产品概述",
                       "#<!-- ignore --># 1. 产品概述"]:
            with self.subTest(hidden=hidden):
                text = BODY.replace("## 1. 产品概述", hidden)
                result = self.command("--file", self.document(FRONTMATTER + text))
                self.assert_code(1, result)
                self.assertIn("## 1. 产品概述 应出现一次，实际 0", result.stdout)

    def test_escaped_comment_markers_do_not_hide_chapters(self):
        for marker in [r"\<!--", r"\\\<!--"]:
            with self.subTest(marker=marker):
                text = FRONTMATTER + "文字中的 " + marker + " 标记。\n\n" + BODY
                result = self.command("--file", self.document(text))
                self.assert_code(0, result)
                self.assertIn("warnings=0", result.stdout)

    def test_even_backslashes_still_allow_a_real_comment(self):
        hidden = "文字中的 " + r"\\<!--" + " 注释\n## 1. 产品概述\n-->"
        text = BODY.replace("## 1. 产品概述", hidden)
        result = self.command("--file", self.document(FRONTMATTER + text))
        self.assert_code(1, result)
        self.assertIn("## 1. 产品概述 应出现一次，实际 0", result.stdout)

    def test_single_line_backtick_code_does_not_open_a_fence(self):
        for sentence in ["```example```\n\n", "````example````\n\n"]:
            with self.subTest(sentence=sentence):
                result = self.command("--file", self.document(FRONTMATTER + sentence + BODY))
                self.assert_code(0, result)
                self.assertIn("warnings=0", result.stdout)

    def test_valid_fence_info_keeps_comment_markers_literal(self):
        for opening in ["```text <!--", "~~~text <!--"]:
            with self.subTest(opening=opening):
                text = FRONTMATTER + opening + "\nexample\n" + opening[:3] + "\n" + BODY
                result = self.command("--file", self.document(text))
                self.assert_code(0, result)
                self.assertIn("warnings=0", result.stdout)

    def test_top_level_heading_ends_the_current_section(self):
        for heading in ["# 新主题", "#", "# "]:
            with self.subTest(heading=heading):
                text = BODY.replace("### 1.2 成功标准", heading + "\n### 1.2 成功标准")
                result = self.command("--file", self.document(FRONTMATTER + text))
                self.assert_code(1, result)
                self.assertIn("[subsection.parent]", result.stdout)

    def test_missing_frontmatter_delimiters_are_errors(self):
        for content in [BODY, FRONTMATTER[:-4] + BODY]:
            with self.subTest(content=content[:20]):
                self.assert_code(1, self.command("--file", self.document(content)))

    def test_missing_required_headings_are_errors(self):
        for heading in [line for line in BODY.splitlines() if line.startswith("## ") or line.startswith("### ")]:
            with self.subTest(heading=heading):
                self.assert_code(1, self.command("--file", self.document(FRONTMATTER + BODY.replace(heading + "\n", ""))))

    def test_quoted_fenced_commented_or_indented_headings_do_not_count(self):
        for hidden in ["```text\n## 1. 产品概述\n```", "~~~text\n## 1. 产品概述\n~~~",
                       "````text\n## 1. 产品概述\n````", "~~~text`info\n## 1. 产品概述\n~~~",
                       "> ## 1. 产品概述", "<!--\n## 1. 产品概述\n-->", "    ## 1. 产品概述"]:
            with self.subTest(hidden=hidden):
                text = BODY.replace("## 1. 产品概述", hidden)
                self.assert_code(1, self.command("--file", self.document(FRONTMATTER + text)))

    def test_duplicate_out_of_order_or_misplaced_headings_are_errors(self):
        variants = [BODY + "\n## 1. 产品概述\n",
                    BODY.replace("## 1. 产品概述", "## 2. 业务流程").replace("## 2. 业务流程\n### 2.1", "## 1. 产品概述\n### 2.1"),
                    BODY.replace("### 1.2 成功标准\n", "") + "\n### 1.2 成功标准\n",
                    BODY + "\n### 11.3 质量自查表\n"]
        for text in variants:
            with self.subTest(text=text[:100]):
                self.assert_code(1, self.command("--file", self.document(FRONTMATTER + text)))

    def test_content_hints_warn_without_failing_structure(self):
        text = BODY.replace("US-001 关联 FR-001", "待补充").replace("UC-001", "待补充")
        text = text.replace("```mermaid\nflowchart LR\n    A --> B\n```\n", "")
        result = self.command("--file", self.document(FRONTMATTER + text))
        self.assert_code(0, result)
        self.assertIn("warnings=4", result.stdout)

    def test_nac_does_not_count_as_ac(self):
        result = self.command("--file", self.document(FRONTMATTER + BODY.replace("AC-001", "NAC-001")))
        self.assert_code(0, result)
        self.assertIn("AC=0 NAC=1", result.stdout)

    def test_unclosed_code_fence_is_error(self):
        result = self.command("--file", self.document(FRONTMATTER + BODY + "\n```mermaid\nflowchart LR\n"))
        self.assert_code(1, result)


if __name__ == "__main__":
    unittest.main()
