#!/usr/bin/env bash
set -euo pipefail

if [[ "${BASH_VERSINFO[0]:-0}" -lt 5 ]]; then
  printf 'sdx-domains 测试需要 Bash 5+（当前 %s）\n' "${BASH_VERSION:-?}" >&2
  exit 1
fi

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../scripts" && pwd)/validate-domains.sh"
PYTHONUTF8=1 python3 - "$SCRIPT" "$BASH" <<'PY'
from pathlib import Path
import os
import subprocess
import sys
import tempfile
import unittest

SCRIPT, BASH = sys.argv[1:]
sys.argv = [sys.argv[0]]


class DomainsValidation(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix="sdx-domains-test-")
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.repo = self.root / "company repo"
        self.domains = self.repo / "docs" / "domains"
        self.domains.mkdir(parents=True)
        agents = self.root / "agent home" / ".agents"
        agents.mkdir(parents=True)
        (agents / "configs").write_text(f"WORK_SPACE={self.root}\n")
        self.config = self.repo / ".docsconfig"
        self.config.write_text(
            f"AGENT_ROOT={agents.parent}\nAGENT_DIR=.agents\n"
            "REPO_DIR=company repo\nDOC_DIR=docs\nKNOWLEDGE_TYPE=company\n"
        )
        self.domain = self.domains / "DOMAIN-EXAMPLE.md"
        self.domain.write_text(
            '---\nid: "DOMAIN-EXAMPLE"\ntitle: 示例域\n---\n'
            "# 示例域\n\nBD-EXAMPLE 支撑 VC-EXAMPLE。\n"
        )
        self.map = self.domains / "DOMAIN-MAP.md"
        self.map.write_text(
            "---\ntype: Domain Map\ntitle: 公司域架构总图\n---\n"
            "# 公司域架构总图\n\n[分域](DOMAIN-EXAMPLE.md#范围)\n"
        )

    def run_validator(self, *args, cwd=None, env=None):
        return subprocess.run(
            [BASH, SCRIPT, *args], cwd=cwd or self.repo,
            text=True, capture_output=True, env=env,
        )

    def assert_result(self, expected, *args):
        result = self.run_validator(*args)
        self.assertEqual(expected, result.returncode, result.stdout + result.stderr)
        return result

    def test_valid_full_directory(self):
        self.assert_result(0)

    def test_valid_map_needs_no_id(self):
        self.assert_result(0, "--file", str(self.map))

    def test_valid_domain_needs_no_type_or_status(self):
        self.assert_result(0, "--file", "docs/domains/DOMAIN-EXAMPLE.md")

    def test_map_can_have_no_domain_links(self):
        self.map.write_text("---\ntype: Domain Map\ntitle: 总图\n---\n# 总图\n")
        self.assert_result(0, "--file", str(self.map))

    def test_full_mode_allows_a_map_without_domains(self):
        self.domain.rename(self.domains / "saved-domain.md")
        self.map.write_text("---\ntype: Domain Map\ntitle: 总图\n---\n# 总图\n")
        self.assert_result(0)

    def test_help_does_not_need_configuration(self):
        result = self.run_validator("--help", cwd=self.root)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        self.assertIn("--file", result.stdout)

    def test_missing_file_value_is_a_usage_error(self):
        result = self.assert_result(1, "--file")
        self.assertIn("--file", result.stdout + result.stderr)
        self.assertNotIn("unbound variable", result.stderr)

    def test_empty_file_value_is_rejected(self):
        self.assert_result(1, "--file", "")

    def test_unknown_option_is_rejected(self):
        self.assert_result(1, "--unknown")

    def test_body_id_cannot_replace_frontmatter(self):
        self.domain.write_text("# 示例域\nid: DOMAIN-EXAMPLE\ntitle: 示例域\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_frontmatter_must_close(self):
        self.domain.write_text("---\nid: DOMAIN-EXAMPLE\ntitle: 示例域\n# 示例域\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_empty_title_is_rejected(self):
        self.domain.write_text('---\nid: DOMAIN-EXAMPLE\ntitle: ""\n---\n# 示例域\n')
        self.assert_result(1, "--file", str(self.domain))

    def test_null_title_is_rejected(self):
        self.domain.write_text("---\nid: DOMAIN-EXAMPLE\ntitle: null\n---\n# 示例域\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_whitespace_title_is_rejected(self):
        self.domain.write_text('---\nid: DOMAIN-EXAMPLE\ntitle: "   "\n---\n# 示例域\n')
        self.assert_result(1, "--file", str(self.domain))

    def test_escaped_whitespace_title_is_rejected(self):
        for title in (r'"\t"', r'"\u0020"'):
            with self.subTest(title=title):
                self.domain.write_text(f"---\nid: DOMAIN-EXAMPLE\ntitle: {title}\n---\n# 示例域\n")
                self.assert_result(1, "--file", str(self.domain))

    def test_invalid_double_quote_escape_is_rejected(self):
        self.domain.write_text('---\nid: DOMAIN-EXAMPLE\ntitle: "\\q"\n---\n# 示例域\n')
        result = self.assert_result(1, "--file", str(self.domain))
        self.assertNotIn("Traceback", result.stderr)

    def test_double_quoted_title_keeps_escaped_quote_before_hash(self):
        self.domain.write_text(
            '---\nid: DOMAIN-EXAMPLE\ntitle: "Heading \\" # title"\n---\n# 示例域\n'
        )
        self.assert_result(0, "--file", str(self.domain))

    def test_single_quoted_id_keeps_paired_quote_before_hash(self):
        domain = self.domains / "DOMAIN-Heading ' # title.md"
        domain.write_text(
            "---\nid: 'DOMAIN-Heading '' # title'\ntitle: 示例域\n---\n# 示例域\n"
        )
        self.assert_result(0, "--file", str(domain))

    def test_quoted_scalar_trailing_comments_need_whitespace(self):
        for value in ('"示例域" # comment', "'示例域' # comment"):
            with self.subTest(value=value):
                self.domain.write_text(f"---\nid: DOMAIN-EXAMPLE\ntitle: {value}\n---\n# 示例域\n")
                self.assert_result(0, "--file", str(self.domain))
        for value in ('"示例域"#comment', "'示例域'#comment", '"示例域" garbage'):
            with self.subTest(value=value):
                self.domain.write_text(f"---\nid: DOMAIN-EXAMPLE\ntitle: {value}\n---\n# 示例域\n")
                self.assert_result(1, "--file", str(self.domain))

    def test_decoded_title_must_remain_single_line(self):
        self.domain.write_text('---\nid: DOMAIN-EXAMPLE\ntitle: "first\\nsecond"\n---\n# 示例域\n')
        self.assert_result(1, "--file", str(self.domain))

    def test_block_scalar_title_is_rejected(self):
        for title in ("|2", ">2-"):
            with self.subTest(title=title):
                self.domain.write_text(f"---\nid: DOMAIN-EXAMPLE\ntitle: {title}\n---\n# 示例域\n")
                self.assert_result(1, "--file", str(self.domain))

    def test_id_must_match_filename(self):
        self.domain.write_text("---\nid: DOMAIN-OTHER\ntitle: 示例域\n---\n# 示例域\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_quoted_id_whitespace_is_not_removed(self):
        self.domain.write_text('---\nid: " DOMAIN-EXAMPLE "\ntitle: 示例域\n---\n# 示例域\n')
        self.assert_result(1, "--file", str(self.domain))

    def test_indented_id_continuation_is_rejected(self):
        self.domain.write_text("---\nid: DOMAIN-EXAMPLE\n  OTHER\ntitle: 示例域\n---\n# 示例域\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_comments_and_other_nested_metadata_are_allowed(self):
        self.domain.write_text(
            "---\nid: DOMAIN-EXAMPLE\n  # ID 注释\ntitle: 示例域\n"
            "tags:\n  - business\n  - architecture\n---\n# 示例域\n"
        )
        self.assert_result(0, "--file", str(self.domain))

    def test_map_type_is_checked(self):
        self.map.write_text("---\nid: DOMAIN-MAP\ntype: Other\ntitle: 总图\n---\n# 总图\n")
        self.assert_result(1, "--file", str(self.map))

    def test_full_mode_checks_each_domain(self):
        self.domain.write_text("garbage\n")
        self.assert_result(1)

    def test_empty_map_is_rejected(self):
        self.map.write_text("")
        self.assert_result(1)

    def test_frontmatter_only_is_rejected(self):
        self.domain.write_text("---\nid: DOMAIN-EXAMPLE\ntitle: 示例域\n---\n")
        self.assert_result(1, "--file", str(self.domain))

    def test_outside_file_is_rejected(self):
        outside = self.repo / "DOMAIN-EXAMPLE.md"
        outside.write_text(self.domain.read_text())
        self.assert_result(1, "--file", str(outside))

    def test_wrong_filename_is_rejected(self):
        other = self.domains / "other.md"
        other.write_text("---\nid: other\ntitle: 示例\n---\n# 示例\n")
        self.assert_result(1, "--file", str(other))

    def test_nested_domain_is_rejected(self):
        nested = self.domains / "nested" / "DOMAIN-NESTED.md"
        nested.parent.mkdir()
        nested.write_text("---\nid: DOMAIN-NESTED\ntitle: 嵌套域\n---\n# 嵌套域\n")
        self.assert_result(1)

    def test_directory_symlink_is_rejected_without_following(self):
        archive = self.repo / "archive"
        archive.mkdir()
        (archive / "DOMAIN-NESTED.md").write_text(
            "---\nid: DOMAIN-NESTED\ntitle: 嵌套域\n---\n# 嵌套域\n"
        )
        (self.domains / "nested").symlink_to(archive, target_is_directory=True)
        self.assert_result(1)

    def test_regular_subdirectory_without_domain_files_is_allowed(self):
        assets = self.domains / "assets"
        assets.mkdir()
        (assets / "note.md").write_text("插图说明。\n")
        self.assert_result(0)

    def test_file_symlink_cannot_escape_domains(self):
        outside = self.repo / "DOMAIN-OUTSIDE.md"
        outside.write_text("---\nid: DOMAIN-OUTSIDE\ntitle: 外部域\n---\n# 外部域\n")
        linked = self.domains / outside.name
        linked.symlink_to(outside)
        self.assert_result(1, "--file", str(linked))
        self.assert_result(1)

    def test_symlink_alias_cannot_change_domain_identity(self):
        alias = self.domains / "DOMAIN-OTHER.md"
        alias.symlink_to(self.domain)
        self.assert_result(1, "--file", str(alias))
        self.assert_result(1)

    def test_missing_map_link_is_rejected(self):
        self.map.write_text(self.map.read_text().replace("type:", "id: DOMAIN-MAP\ntype:", 1))
        with self.map.open("a") as out:
            out.write("\n[缺失分域](DOMAIN-MISSING.md)\n")
        self.assert_result(1, "--file", str(self.map))

    def test_nested_link_label_still_checks_destination(self):
        with self.map.open("a") as out:
            out.write("\n[domain [BD-MISSING]](DOMAIN-MISSING.md)\n")
        self.assert_result(1, "--file", str(self.map))

    def test_inline_code_is_not_a_domain_link(self):
        with self.map.open("a") as out:
            out.write("\n示例：`[x](DOMAIN-MISSING.md)`\n")
        self.assert_result(0, "--file", str(self.map))

    def test_longer_closing_fence_ends_code_example(self):
        with self.map.open("a") as out:
            out.write("\n```md\n[x](DOMAIN-MISSING.md)\n````\n")
        self.assert_result(0, "--file", str(self.map))
        with self.map.open("a") as out:
            out.write("\n[真实链接](DOMAIN-MISSING.md)\n")
        self.assert_result(1, "--file", str(self.map))

    def test_map_link_cannot_escape_domains(self):
        self.map.write_text(self.map.read_text().replace("type:", "id: DOMAIN-MAP\ntype:", 1))
        outside = self.repo / "docs" / "DOMAIN-OUTSIDE.md"
        outside.write_text("---\nid: DOMAIN-OUTSIDE\ntitle: 外部域\n---\n# 外部域\n")
        with self.map.open("a") as out:
            out.write("\n[外部域](../DOMAIN-OUTSIDE.md)\n")
        self.assert_result(1, "--file", str(self.map))

    def test_noncompany_configuration_is_rejected(self):
        self.config.write_text(self.config.read_text().replace("=company\n", "=solution\n"))
        self.assert_result(1)

    def test_missing_configuration_is_rejected(self):
        result = self.run_validator(cwd=self.root)
        self.assertEqual(1, result.returncode, result.stdout + result.stderr)

    def test_validator_handles_c_locale(self):
        environment = os.environ.copy()
        environment.update(LC_ALL="C", PYTHONUTF8="0", PYTHONCOERCECLOCALE="0")
        result = self.run_validator(env=environment)
        self.assertEqual(0, result.returncode, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)
        self.domain.write_text("正文缺 frontmatter。\n")
        result = self.run_validator(env=environment)
        self.assertEqual(1, result.returncode, result.stdout + result.stderr)
        self.assertNotIn("Traceback", result.stderr)

    def test_missing_map_is_rejected(self):
        self.map.rename(self.domains / "saved-map.md")
        self.assert_result(1)


unittest.main(verbosity=2)
PY
