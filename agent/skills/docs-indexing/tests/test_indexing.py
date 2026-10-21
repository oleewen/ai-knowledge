"""Behavior tests for candidate scans and explicit completion anchors."""

from __future__ import annotations

import os
from pathlib import Path
import shutil
import stat
import subprocess
import sys
import tempfile
import unittest


SKILL = Path(__file__).resolve().parents[1]
AGENT_HOME = SKILL.parents[1]
BASH = os.environ.get("INDEXING_TEST_BASH", "/opt/homebrew/bin/bash")
if not Path(BASH).exists():
    BASH = shutil.which("bash") or "bash"
SCRIPT = SKILL / "scripts/indexing.sh"
ANCHOR = SKILL / "scripts/indexing_log.py"


class IndexingTest(unittest.TestCase):
    def setUp(self):
        self.temporary = tempfile.TemporaryDirectory(prefix="docs-indexing-test-")
        self.addCleanup(self.temporary.cleanup)
        self.base = Path(self.temporary.name)
        self.repo = self.base / "project space [x]"
        self.repo.mkdir()
        self.docs = self.repo / "docs"
        self.docs.mkdir()
        self.guide = self.docs / "INDEX-GUIDE.md"
        agent_home = self.base / "agent home"
        (agent_home / ".agents").mkdir(parents=True)
        (agent_home / ".agents/configs").write_text(f"WORK_SPACE={self.base}\n")
        (self.repo / ".docsconfig").write_text(
            f"REPO_DIR={self.repo.name}\nDOC_DIR=docs\nKNOWLEDGE_TYPE=company\n"
            f"AGENT_ROOT={agent_home}\nAGENT_DIR=.agents\n"
        )

    def scan(self, *args, cwd=None, script=SCRIPT):
        return subprocess.run(
            [BASH, str(script), *args], cwd=cwd or self.repo,
            text=True, capture_output=True, check=False,
        )

    def anchor(self, *args):
        return subprocess.run(
            [sys.executable, "-B", str(ANCHOR), *map(str, args)],
            text=True, capture_output=True, check=False,
        )

    def assert_ok(self, result):
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def assert_error(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertNotIn("completed successfully", result.stdout)

    def test_scan_only_preserves_every_existing_byte(self):
        original = b"---\r\ntitle: guide\r\n---\r\n\r\n# Guide\r\n  \r\n"
        self.guide.write_bytes(original)
        self.assert_ok(self.scan("--mode", "full", "--depth", "3"))
        self.assertEqual(self.guide.read_bytes(), original)

    def test_scan_only_does_not_create_output_directory(self):
        output = "new/nested/INDEX-GUIDE.md"
        self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--output", output))
        self.assertFalse((self.repo / "new").exists())

    def test_dry_run_wins_over_rewrite(self):
        self.guide.write_bytes(b"# Existing guide\n")
        original = self.guide.read_bytes()
        self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--rewrite", "--dry-run"))
        self.assertEqual(self.guide.read_bytes(), original)
        self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--dry-run", "--rewrite",
                                 "--output", "new/INDEX-GUIDE.md"))
        self.assertFalse((self.repo / "new").exists())

    def test_help_works_without_configuration(self):
        result = self.scan("--help", cwd=self.base)
        self.assert_ok(result)
        self.assertIn("--dry-run", result.stdout)

    def test_missing_option_values_are_reported_before_bootstrap(self):
        for option in ("--mode", "--depth", "--output", "--since"):
            with self.subTest(option=option):
                result = self.scan(option, cwd=self.base)
                self.assert_error(result)
                self.assertIn(option, result.stderr)
                self.assertNotIn("unbound variable", result.stderr)
                self.assertNotIn(".docsconfig", result.stderr)

    def test_invalid_since_is_rejected_without_writes(self):
        for since in ("abc", "-1", "0", "000", "1.5", ""):
            with self.subTest(since=since):
                result = self.scan("--mode", "i", "--depth", "1", "--since", since)
                self.assert_error(result)
                self.assertFalse(self.guide.exists())

    def test_invalid_output_is_rejected_before_creating_directories(self):
        for output in ("new/wrong.md", "../outside/INDEX-GUIDE.md"):
            with self.subTest(output=output):
                self.assert_error(self.scan("--mode", "f", "--depth", "1", "--output", output,
                                            "--rewrite"))
        self.assertFalse((self.repo / "new").exists())
        self.assertFalse((self.base / "outside").exists())

    def test_missing_scan_root_fails_without_creating_output(self):
        self.docs.rmdir()
        self.assert_error(self.scan("--mode", "f", "--depth", "3", "--rewrite"))
        self.assertFalse(self.docs.exists())

    def test_unreadable_directory_fails_without_rewriting_guide(self):
        restricted = self.docs / "restricted"
        restricted.mkdir()
        (restricted / "secret.md").write_text("not readable")
        self.guide.write_bytes(b"# Existing\n")
        restricted.chmod(0)
        self.addCleanup(restricted.chmod, 0o700)
        if os.access(restricted, os.R_OK):
            self.skipTest("current user can bypass directory permissions")
        result = self.scan("--mode", "f", "--depth", "3", "--rewrite")
        self.assert_error(result)
        self.assertEqual(self.guide.read_bytes(), b"# Existing\n")

    def test_absolute_output_normalizes_dot_segments(self):
        output = self.repo / "docs/../custom/INDEX-GUIDE.md"
        result = self.scan("--mode", "f", "--depth", "1", "--rewrite", "--output", str(output))
        self.assert_ok(result)
        self.assertIn("`./custom/INDEX-GUIDE.md`", (self.repo / "custom/INDEX-GUIDE.md").read_text())

    def test_output_parent_symlink_cannot_escape_repository(self):
        outside = self.base / "outside"
        outside.mkdir()
        (self.repo / "escape").symlink_to(outside)
        self.assert_error(self.scan("--mode", "f", "--depth", "1", "--rewrite",
                                    "--output", "escape/INDEX-GUIDE.md"))
        self.assertEqual(list(outside.iterdir()), [])

    def test_scan_filters_noise_and_reports_root_directory(self):
        (self.docs / "README.md").write_text("root")
        (self.docs / "folder space [x]").mkdir()
        (self.docs / "folder space [x]/business.md").write_text("business")
        for name in ("app.log", "App.class", "app.jar", "viz.html", ".DS_Store"):
            (self.docs / name).write_text("ignored")
        for name in (".hidden", "target", "build", "node_modules"):
            directory = self.docs / name
            directory.mkdir()
            (directory / "ignored.md").write_text("ignored")
        (self.docs / "linked.md").symlink_to(self.docs / "README.md")
        (self.docs / "linked-dir").symlink_to(self.docs / "folder space [x]")
        result = self.scan("--mode", "full", "--depth", "3")
        self.assert_ok(result)
        self.assertIn("| 文件总数 | `2` |", result.stdout)
        self.assertIn("- `.`", result.stdout)
        self.assertIn("folder space [x]", result.stdout)
        self.assertNotIn("- `README.md`", result.stdout)

    def test_depth_filters_remain_compatible(self):
        for name in ("README.md", "config.yaml", "service.py", "App.java", "other.txt"):
            (self.docs / name).write_text("candidate")
        for depth, count in (("1", 2), ("2", 4), ("3", 5)):
            with self.subTest(depth=depth):
                result = self.scan("--mode", "f", "--depth", depth)
                self.assert_ok(result)
                self.assertIn(f"| 文件总数 | `{count}` |", result.stdout)

    def test_incremental_requires_baseline_without_writing(self):
        self.guide.write_bytes(b"# Guide without anchor\n")
        self.assert_error(self.scan("--mode", "i", "--depth", "2", "--rewrite"))
        self.assertEqual(self.guide.read_bytes(), b"# Guide without anchor\n")

    def test_adding_runtime_block_preserves_original_suffix(self):
        original = b"---\r\ntitle: guide\r\n---\r\n# Guide\r\nTrailing spaces  "
        self.guide.write_bytes(original)
        self.assert_ok(self.scan("--mode", "f", "--depth", "2", "--rewrite"))
        self.assertTrue(self.guide.read_bytes().startswith(original + b"\r\n\r\n"))

    def test_rewrite_preserves_bytes_outside_runtime_block(self):
        before = b"---\r\ntitle: untouched\r\n---\r\n\r\n# Guide\r\n<!-- okf:begin -->\r\nOKF\r\n<!-- okf:end -->\r\n"
        after = b"\r\n<!-- docs-build:entity-index:begin -->\r\nentities\r\n<!-- docs-build:entity-index:end -->\r\n## Nine chapters\r\n   "
        self.guide.write_bytes(before + b"<!-- docs-indexing:begin -->\nold\n<!-- docs-indexing:end -->" + after)
        self.guide.chmod(0o640)
        self.assert_ok(self.scan("--mode", "f", "--depth", "3", "--rewrite"))
        result = self.guide.read_bytes()
        self.assertTrue(result.startswith(before))
        self.assertTrue(result.endswith(after))
        self.assertNotIn(b"indexing_finished_ms=", result)
        self.assertEqual(stat.S_IMODE(self.guide.stat().st_mode), 0o640)

    def test_custom_output_is_relative_to_repository_from_nested_cwd(self):
        nested = self.docs / "nested"
        nested.mkdir()
        self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--rewrite", "--output",
                                 "custom/INDEX-GUIDE.md", cwd=nested))
        output = self.repo / "custom/INDEX-GUIDE.md"
        self.assertIn("./custom/INDEX-GUIDE.md", output.read_text())
        self.assertNotIn("./docs/INDEX-GUIDE.md", output.read_text())
        self.assertFalse(self.guide.exists())

    def test_rewrite_rejects_output_symlink(self):
        target = self.repo / "existing.md"
        target.write_bytes(b"unchanged\n")
        self.guide.symlink_to(target)
        self.assert_error(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
        self.assertEqual(target.read_bytes(), b"unchanged\n")

    def test_incremental_reports_baseline_and_does_not_claim_filtered_scan(self):
        self.guide.write_text("# Guide\n<!-- sdx-indexing:indexing_finished_ms=1 -->\n")
        result = self.scan("--mode", "incremental", "--depth", "1", "--since", "2")
        self.assert_ok(result)
        self.assertIn("`2`", result.stdout)
        self.assertIn("未按 since 过滤", result.stdout)
        self.assertIn("1970-01-01 08:00:00 +08（2）", result.stdout)
        self.assertEqual(self.guide.read_text(), "# Guide\n<!-- sdx-indexing:indexing_finished_ms=1 -->\n")

    def test_installed_layout_uses_its_shared_library(self):
        installed = self.base / "installed agent"
        shutil.copytree(SKILL / "scripts", installed / "skills/docs-indexing/scripts")
        shutil.copytree(AGENT_HOME / "scripts/lib", installed / "scripts/lib")
        result = self.scan("--mode", "f", "--depth", "1", "--dry-run",
                           script=installed / "skills/docs-indexing/scripts/indexing.sh")
        self.assert_ok(result)
        self.assertFalse(self.guide.exists())
        self.assertEqual(list(installed.rglob("__pycache__")), [])

    def test_installed_bash_case_runs_outside_repository_layout(self):
        installed = self.base / "installed agent"
        skill = installed / "skills/docs-indexing"
        shutil.copytree(SKILL / "scripts", skill / "scripts")
        shutil.copytree(SKILL / "tests", skill / "tests")
        shutil.copytree(AGENT_HOME / "scripts/lib", installed / "scripts/lib")
        result = subprocess.run(
            [BASH, str(skill / "tests/cases/01_preserve_guide_and_scan_doc_root.sh")],
            cwd=self.base, text=True, capture_output=True, check=False,
        )
        self.assert_ok(result)
        self.assertIn("PASS:", result.stdout)

    def test_read_baseline_uses_first_real_anchor_and_ignores_fences(self):
        self.guide.write_text(
            "# Guide\n```html\n<!-- sdx-indexing:indexing_finished_ms=90 -->\n```\n"
            "<!-- sdx-indexing:indexing_finished_ms=11 -->\n"
            "~~~html\n<!-- sdx-indexing:indexing_finished_ms=91 -->\n~~~\n"
            "<!-- sdx-indexing:indexing_finished_ms=22 -->\n"
        )
        result = self.anchor("read-baseline", self.guide)
        self.assert_ok(result)
        self.assertEqual(result.stdout, "11\n")

    def test_read_missing_returns_zero_but_invalid_content_fails(self):
        missing = self.anchor("read-baseline", self.guide)
        self.assert_ok(missing)
        self.assertEqual(missing.stdout, "0\n")
        self.guide.write_bytes(b"\xff")
        self.assert_error(self.anchor("read-baseline", self.guide))
        self.assert_error(self.anchor("read-baseline", self.docs))

    def test_anchor_preserves_frontmatter_and_uses_body_anchor(self):
        frontmatter = (
            b"---\r\ntitle: Guide\r\nexample: |\r\n"
            b"  <!-- sdx-indexing:indexing_finished_ms=90 -->\r\n---\r\n"
        )
        body = b"# Guide\r\n<!-- sdx-indexing:indexing_finished_ms=11 -->\r\n"
        self.guide.write_bytes(frontmatter + body)
        result = self.anchor("read-baseline", self.guide)
        self.assert_ok(result)
        self.assertEqual(result.stdout, "11\n")
        self.assert_ok(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
        self.assertEqual(self.guide.read_bytes(), frontmatter + body.replace(b"=11", b"=123"))

    def test_anchor_preserves_blockquote_fence_examples(self):
        for prefix, fence in ((b"> ", b"```"), (b"> > ", b"~~~")):
            with self.subTest(prefix=prefix, fence=fence):
                example = (prefix + fence + b"html\n" + prefix
                           + b"<!-- sdx-indexing:indexing_finished_ms=90 -->\n"
                           + prefix + fence + b"\n")
                body = b"# Guide\n<!-- sdx-indexing:indexing_finished_ms=11 -->\n"
                self.guide.write_bytes(example + body)
                result = self.anchor("read-baseline", self.guide)
                self.assert_ok(result)
                self.assertEqual(result.stdout, "11\n")
                self.assert_ok(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
                self.assertEqual(self.guide.read_bytes(), example + body.replace(b"=11", b"=123"))

    def test_indented_yaml_delimiters_remain_inside_frontmatter(self):
        for delimiter in (b"---", b"..."):
            with self.subTest(delimiter=delimiter):
                metadata = (b"---\nexample: |\n  " + delimiter + b"\n"
                            b"  <!-- sdx-indexing:indexing_finished_ms=90 -->\n"
                            b"  <!-- docs-indexing:begin -->\n  example\n"
                            b"  <!-- docs-indexing:end -->\n---\n")
                body = b"# Guide\n<!-- sdx-indexing:indexing_finished_ms=11 -->\n"
                self.guide.write_bytes(metadata + body)
                result = self.anchor("read-baseline", self.guide)
                self.assert_ok(result)
                self.assertEqual(result.stdout, "11\n")
                self.assert_ok(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
                self.assertEqual(self.guide.read_bytes(), metadata + body.replace(b"=11", b"=123"))
                self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
                self.assertTrue(self.guide.read_bytes().startswith(metadata + body.replace(b"=11", b"=123")))

    def test_unclosed_frontmatter_or_fence_rejects_appends_without_writes(self):
        for original in (b"---\ntitle: Guide\n", b"# Guide\n```html\nexample\n"):
            with self.subTest(original=original):
                self.guide.write_bytes(original)
                self.assert_error(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
                self.assertEqual(self.guide.read_bytes(), original)
                self.assert_error(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
                self.assertEqual(self.guide.read_bytes(), original)

    def test_rewrite_skips_runtime_examples_in_frontmatter_and_quotes(self):
        frontmatter = (b"---\nexample: |\n  <!-- docs-indexing:begin -->\n"
                       b"  yaml example\n  <!-- docs-indexing:end -->\n---\n")
        example = (b"> ```html\n> <!-- docs-indexing:begin -->\n> quote example\n"
                   b"> <!-- docs-indexing:end -->\n> ```\n")
        original = frontmatter + example + b"# Guide\n"
        self.guide.write_bytes(original)
        self.assert_ok(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
        self.assertTrue(self.guide.read_bytes().startswith(original))
        self.assertIn(b"| mode / depth |", self.guide.read_bytes()[len(original):])

    def test_rewrite_rejects_ambiguous_runtime_marker_sequences(self):
        begin = b"<!-- docs-indexing:begin -->\n"
        end = b"<!-- docs-indexing:end -->\n"
        protected = (b"<!-- docs-build:entity-index:begin -->\nKEEP ENTITIES\n"
                     b"<!-- docs-build:entity-index:end -->\n")
        for original in (begin, end, end + begin, begin + end + begin + end,
                         begin + b"partial\n" + protected + begin + b"runtime\n" + end):
            with self.subTest(original=original):
                self.guide.write_bytes(original)
                self.assert_error(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
                self.assertEqual(self.guide.read_bytes(), original)

    def test_rewrite_rejects_overlap_with_protected_blocks(self):
        begin = b"<!-- docs-indexing:begin -->\n"
        end = b"<!-- docs-indexing:end -->\n"
        for owner in (b"okf", b"docs-build:entity-index"):
            protected_begin = b"<!-- " + owner + b":begin -->\n"
            protected_end = b"<!-- " + owner + b":end -->\n"
            for original in (protected_begin + begin + b"runtime\n" + end + protected_end,
                             begin + protected_begin + b"content\n" + protected_end + end):
                with self.subTest(original=original):
                    self.guide.write_bytes(original)
                    self.assert_error(self.scan("--mode", "f", "--depth", "1", "--rewrite"))
                    self.assertEqual(self.guide.read_bytes(), original)

    def test_write_anchor_rejects_missing_and_empty_guide(self):
        self.assert_error(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
        self.assertFalse(self.guide.exists())
        self.guide.write_bytes(b"  \n\t")
        self.assert_error(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
        self.assertEqual(self.guide.read_bytes(), b"  \n\t")

    def test_write_anchor_rejects_invalid_time_and_symlinks(self):
        self.guide.write_bytes(b"# Guide\n")
        for value in ("abc", "-1", "0", "000", "1.5", "+2", "9" * 30):
            with self.subTest(value=value):
                self.assert_error(self.anchor("write-anchor", self.guide, "--finished-ms", value))
                self.assertEqual(self.guide.read_bytes(), b"# Guide\n")
        link = self.repo / "linked-guide.md"
        link.symlink_to(self.guide)
        self.assert_error(self.anchor("write-anchor", link, "--finished-ms", "1"))
        self.assertEqual(self.guide.read_bytes(), b"# Guide\n")

    def test_write_anchor_preserves_other_bytes_and_fenced_examples(self):
        before = b"# Guide\r\n```html\r\n<!-- sdx-indexing:indexing_finished_ms=90 -->\r\n```\r\n"
        between = b"\r\n## Details\r\n  \r\n"
        after = b"\r\nlast bytes   "
        self.guide.write_bytes(before + b"<!-- sdx-indexing:indexing_finished_ms=11 -->" + between
                               + b"<!-- sdx-indexing:indexing_finished_ms=22 -->" + after)
        self.guide.chmod(0o640)
        old_inode = self.guide.stat().st_ino
        self.assert_ok(self.anchor("write-anchor", self.guide, "--finished-ms", "123"))
        self.assertEqual(self.guide.read_bytes(), before + b"<!-- sdx-indexing:indexing_finished_ms=123 -->" + between + after)
        self.assertEqual(stat.S_IMODE(self.guide.stat().st_mode), 0o640)
        self.assertNotEqual(self.guide.stat().st_ino, old_inode)

    def test_anchor_append_compatibility_and_human_time(self):
        self.guide.write_bytes(b"# Guide\n\nTrailing spaces  ")
        result = self.anchor("append", self.guide, "--finished-ms", "123",
                             "--indexed-at", "legacy", "--mode", "full", "--depth", "3",
                             "--since-ms", "0", "--output-path", "docs/INDEX-GUIDE.md",
                             "--file-count", "2", "--duration-ms", "10", "--summary", "legacy")
        self.assert_ok(result)
        self.assertTrue(self.guide.read_bytes().startswith(b"# Guide\n\nTrailing spaces  "))
        self.assertIn("1970-01-01 08:00:00 +08（123）", result.stdout)

    def test_human_time_uses_fixed_eight_hour_offset(self):
        self.guide.write_bytes(b"# Guide\n")
        result = self.anchor("write-anchor", self.guide, "--finished-ms", "520560000000")
        self.assert_ok(result)
        self.assertIn("1986-07-01 08:00:00 +08（520560000000）", result.stdout)


if __name__ == "__main__":
    unittest.main()
