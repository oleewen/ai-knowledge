import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from session_spec_paths import (
    is_session_spec_path,
    iter_session_spec_files,
    session_specs_from_payload,
)


class SessionSpecPathTests(unittest.TestCase):
    def test_accepts_docroot_superpowers(self) -> None:
        self.assertTrue(
            is_session_spec_path("application/superpowers/2026-05-18-x-sdx-prd.md")
        )
        self.assertTrue(
            is_session_spec_path("system/superpowers/2026-05-18-x-docs-distill.md")
        )

    def test_rejects_legacy_specs_dir(self) -> None:
        self.assertFalse(is_session_spec_path("application/specs/2026-05-18-x-sdx-prd.md"))
        self.assertFalse(is_session_spec_path("system/specs/2026-05-18-x-docs-extract.md"))

    def test_rejects_superpowers_nested_specs(self) -> None:
        self.assertFalse(is_session_spec_path("docs/superpowers/specs/x.md"))

    def test_rejects_requirements_specs(self) -> None:
        self.assertFalse(
            is_session_spec_path(
                "application/requirements/REQUIREMENT-1/MVP-Phase-1/specs/spec-asd-1.md"
            )
        )

    def test_extract_from_strings_superpowers(self) -> None:
        strings = ["write application/superpowers/2026-05-18-a-sdx-design.md"]
        self.assertEqual(
            session_specs_from_payload(strings),
            ["application/superpowers/2026-05-18-a-sdx-design.md"],
        )

    def test_iter_session_spec_files(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            good = repo / "application" / "superpowers"
            good.mkdir(parents=True)
            (good / "a.md").write_text("# a", encoding="utf-8")
            legacy = repo / "application" / "specs"
            legacy.mkdir(parents=True)
            (legacy / "b.md").write_text("# b", encoding="utf-8")
            bad = repo / "docs" / "superpowers" / "specs"
            bad.mkdir(parents=True)
            (bad / "c.md").write_text("# c", encoding="utf-8")
            paths = {p.name for p in iter_session_spec_files(repo)}
            self.assertEqual(paths, {"a.md"})


if __name__ == "__main__":
    unittest.main()
