from __future__ import annotations

import os
from pathlib import Path
from typing import Optional
import subprocess
import shutil
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "run-docs-distill.sh"


class RunDocsDistillTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name) / "repo"
        self.root.mkdir()
        (self.root / ".git").mkdir()
        self.env = dict(os.environ)
        self.env.pop("DOC_DIR", None)
        self.env.pop("KNOWLEDGE_TYPE", None)

    def run_script(self, *args: str, cwd: Optional[Path] = None) -> subprocess.CompletedProcess[str]:
        return subprocess.run(
            [os.environ.get("DOCS_DISTILL_TEST_BASH", "bash"), str(SCRIPT), *args],
            cwd=cwd or self.root,
            env=self.env,
            text=True,
            capture_output=True,
            check=False,
        )

    def make_layer(self, layer: str, name: str = "billing-appeal", *, readme: bool = True) -> Path:
        if layer == "system":
            slot = self.root / "system/application-slots" / f"application-{name}"
            overview = self.root / "system/knowledge/overview"
        elif layer == "solution":
            slot = self.root / "solution/system-slots" / f"system-{name}"
            overview = self.root / "solution/knowledge/overview"
        else:
            slot = self.root / "company/solution-slots" / f"solution-{name}"
            overview = self.root / "company/knowledge/overview"
        slot.mkdir(parents=True)
        (slot / "knowledge").mkdir()
        (slot / "knowledge/source.md").write_text("# Source\n", encoding="utf-8")
        if readme:
            (slot / "README.md").write_text("# Contract\n", encoding="utf-8")
        overview.mkdir(parents=True)
        (overview / "NAME-overview.md").write_text("# NAME 架构概览\n", encoding="utf-8")
        return slot

    def test_system_edge_reads_docsconfig_and_does_not_write(self) -> None:
        self.make_layer("system")
        (self.root / ".docsconfig").write_text('DOC_DIR="system"\n', encoding="utf-8")
        result = self.run_script("--name", "billing-appeal", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("doc_dir  : system", result.stdout)
        self.assertIn("mode     : full", result.stdout)
        self.assertIn("dry_run  : true", result.stdout)
        self.assertFalse((self.root / "system/knowledge/overview/billing-appeal-overview.md").exists())

    def test_federated_slot_symlink_is_not_mistaken_for_empty(self) -> None:
        slot = self.make_layer("system")
        source = self.root / "linked-application"
        slot.rename(source)
        slot.symlink_to(source, target_is_directory=True)
        before = {p.relative_to(source): p.read_bytes() for p in source.rglob("*") if p.is_file()}
        result = self.run_script("--doc-dir", "system", "--name", "billing-appeal", "--dry-run")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(before, {p.relative_to(source): p.read_bytes() for p in source.rglob("*") if p.is_file()})
        self.assertFalse((self.root / "system/knowledge/overview/billing-appeal-overview.md").exists())

    def test_non_dry_run_still_never_writes(self) -> None:
        self.make_layer("system")
        result = self.run_script("--doc-dir", "system", "--name", "billing-appeal")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("write    : 本脚本不写 overview", result.stdout)
        self.assertFalse((self.root / "system/knowledge/overview/billing-appeal-overview.md").exists())

    def test_solution_and_company_edges(self) -> None:
        self.make_layer("solution", "order-service")
        self.make_layer("company", "payment-platform")
        for layer, name, expected in (
            ("solution", "order-service", "solution/system-slots/system-order-service"),
            ("company", "payment-platform", "company/solution-slots/solution-payment-platform"),
        ):
            with self.subTest(layer=layer):
                result = self.run_script("--doc-dir", layer, "--name", name)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(expected, result.stdout)

    def test_missing_contract_fails_before_done(self) -> None:
        self.make_layer("system", readme=False)
        result = self.run_script("--doc-dir", "system", "--name", "billing-appeal", "--dry-run")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("README.md", result.stderr)
        self.assertIn("[FAIL]", result.stderr)

    def test_unknown_layer_and_deprecated_flags_fail(self) -> None:
        self.make_layer("system")
        for args, needle in (
            (("--doc-dir", "application", "--name", "billing-appeal"), "DOC_DIR"),
            (("--doc-dir", "system", "--name", "billing-appeal", "--since", "x"), "已废止参数"),
        ):
            with self.subTest(args=args):
                result = self.run_script(*args)
                self.assertNotEqual(result.returncode, 0)
                self.assertIn(needle, result.stderr)

    def test_root_is_found_from_nested_cwd(self) -> None:
        self.make_layer("system")
        nested = self.root / "work/subdir"
        nested.mkdir(parents=True)
        (self.root / ".docsconfig").write_text("DOC_DIR=system\n", encoding="utf-8")
        result = self.run_script("--name", "billing-appeal", cwd=nested)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn(f"root     : {self.root.resolve()}", result.stdout)

    def test_custom_doc_directory_uses_explicit_layer(self) -> None:
        for layer in ("system", "solution", "company"):
            with self.subTest(layer=layer):
                self.make_layer(layer)
                custom = self.root / "nested" / layer / "docs space"
                custom.parent.mkdir(parents=True)
                (self.root / layer).rename(custom)
                relative = custom.relative_to(self.root).as_posix()
                (self.root / ".docsconfig").write_text(
                    f'DOC_DIR="{relative}"\nKNOWLEDGE_TYPE={layer}\n')
                result = self.run_script("--name", "billing-appeal", "--dry-run")
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertIn(relative + "/knowledge/overview", result.stdout)
                self.assertFalse((custom / "knowledge/overview/billing-appeal-overview.md").exists())

    def test_custom_directory_without_layer_does_not_guess(self) -> None:
        self.make_layer("system")
        (self.root / "system").rename(self.root / "docs")
        (self.root / ".docsconfig").write_text("DOC_DIR=docs\n")
        result = self.run_script("--name", "billing-appeal")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("KNOWLEDGE_TYPE", result.stderr)

    def test_conflicting_target_types_fail(self) -> None:
        self.make_layer("system")
        target = self.root / "system/knowledge/overview/billing-appeal-overview.md"
        outside = self.root / "outside.md"
        outside.write_text("KEEP")
        target.mkdir()
        result = self.run_script("--doc-dir", "system", "--name", "billing-appeal")
        self.assertNotEqual(result.returncode, 0)
        target.rmdir()
        for destination in (self.root / "missing", outside):
            target.symlink_to(destination)
            result = self.run_script("--doc-dir", "system", "--name", "billing-appeal")
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(outside.read_text(), "KEEP")
            target.unlink()

    def test_layer_override_and_path_escape(self) -> None:
        self.make_layer("system")
        (self.root / "system").rename(self.root / "docs")
        self.env.update(DOC_DIR="wrong-env-dir", KNOWLEDGE_TYPE="company")
        (self.root / ".docsconfig").write_text("DOC_DIR=wrong-config-dir\nKNOWLEDGE_TYPE=solution\n")
        result = self.run_script("--doc-dir", "docs", "--layer", "system", "--name", "billing-appeal")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn("layer    : system", result.stdout)
        shutil.copytree(self.root / "docs", self.root.parent / "docs")
        for path in ("../docs", str(self.root / "docs"), "docs/../docs"):
            result = self.run_script("--doc-dir", path, "--layer", "system", "--name", "billing-appeal")
            self.assertNotEqual(result.returncode, 0)
            self.assertIn("DOC_DIR", result.stderr)

    def test_physical_directory_escapes_are_rejected(self) -> None:
        self.make_layer("system")
        outside = self.root.parent / "outside"
        shutil.copytree(self.root / "system", outside)
        (self.root / "linked").symlink_to(outside, target_is_directory=True)
        before = {p.relative_to(outside): p.read_bytes() for p in outside.rglob("*") if p.is_file()}
        result = self.run_script("--doc-dir", "linked", "--layer", "system", "--name", "billing-appeal")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("DOC_DIR 越出目标仓", result.stderr)
        overview = self.root / "system/knowledge/overview"
        overview.rename(self.root / "saved-overview")
        overview.symlink_to(outside / "knowledge/overview", target_is_directory=True)
        result = self.run_script("--doc-dir", "system", "--name", "billing-appeal")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("overview 目录越出文档根", result.stderr)
        self.assertEqual(before, {p.relative_to(outside): p.read_bytes() for p in outside.rglob("*") if p.is_file()})


if __name__ == "__main__":
    unittest.main()
