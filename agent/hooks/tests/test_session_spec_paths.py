import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from session_spec_paths import (
    is_session_spec_path,
    iter_session_spec_files,
    resolve_session_spec_doc_dir,
    session_specs_from_payload,
)


def _write_docsconfig(repo: Path, doc_dir: str) -> None:
    (repo / ".docsconfig").write_text(
        f"DOC_ROOT={repo}\nREPO_ROOT={repo}\nDOC_DIR={doc_dir}\n",
        encoding="utf-8",
    )


class SessionSpecPathTests(unittest.TestCase):
    def test_shape_accepts_superpowers_specs(self) -> None:
        self.assertTrue(
            is_session_spec_path(
                "application/superpowers/specs/2026-05-18-x-sdx-prd.md"
            )
        )

    def test_docsconfig_application_only_allows_application(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _write_docsconfig(repo, "application")
            rel = "application/superpowers/specs/x.md"
            self.assertEqual(resolve_session_spec_doc_dir(repo), "application")
            self.assertTrue(is_session_spec_path(rel, repo=repo))
            self.assertFalse(
                is_session_spec_path("docs/superpowers/specs/x.md", repo=repo)
            )
            self.assertFalse(
                is_session_spec_path("system/superpowers/specs/x.md", repo=repo)
            )

    def test_no_docsconfig_defaults_docs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            self.assertEqual(resolve_session_spec_doc_dir(repo), "docs")
            self.assertTrue(
                is_session_spec_path("docs/superpowers/specs/x.md", repo=repo)
            )
            self.assertFalse(
                is_session_spec_path(
                    "application/superpowers/specs/x.md", repo=repo
                )
            )

    def test_invalid_doc_dir_in_config_defaults_docs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _write_docsconfig(repo, ".")
            self.assertEqual(resolve_session_spec_doc_dir(repo), "docs")

    def test_rejects_legacy_docroot_specs(self) -> None:
        self.assertFalse(
            is_session_spec_path("application/specs/2026-05-18-x-sdx-prd.md")
        )

    def test_rejects_legacy_superpower_specs(self) -> None:
        self.assertFalse(
            is_session_spec_path(
                "application/superpower/specs/2026-05-18-x-sdx-prd.md"
            )
        )

    def test_rejects_flat_superpowers(self) -> None:
        self.assertFalse(
            is_session_spec_path("application/superpowers/2026-05-18-x-sdx-prd.md")
        )

    def test_rejects_requirements_specs(self) -> None:
        self.assertFalse(
            is_session_spec_path(
                "application/requirements/REQUIREMENT-1/MVP-Phase-1/specs/spec-asd-1.md"
            )
        )

    def test_extract_from_strings(self) -> None:
        strings = ["write application/superpowers/specs/2026-05-18-a-sdx-design.md"]
        self.assertEqual(
            session_specs_from_payload(strings),
            ["application/superpowers/specs/2026-05-18-a-sdx-design.md"],
        )

    def test_iter_session_spec_files_respects_docsconfig(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            _write_docsconfig(repo, "application")
            app_specs = repo / "application" / "superpowers" / "specs"
            app_specs.mkdir(parents=True)
            (app_specs / "a.md").write_text("# a", encoding="utf-8")
            legacy = repo / "application" / "specs"
            legacy.mkdir(parents=True)
            (legacy / "b.md").write_text("# b", encoding="utf-8")
            docs_specs = repo / "docs" / "superpowers" / "specs"
            docs_specs.mkdir(parents=True)
            (docs_specs / "d.md").write_text("# d", encoding="utf-8")
            paths = {p.name for p in iter_session_spec_files(repo)}
            self.assertEqual(paths, {"a.md"})

    def test_iter_session_spec_files_defaults_docs(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            app_specs = repo / "application" / "superpowers" / "specs"
            app_specs.mkdir(parents=True)
            (app_specs / "a.md").write_text("# a", encoding="utf-8")
            docs_specs = repo / "docs" / "superpowers" / "specs"
            docs_specs.mkdir(parents=True)
            (docs_specs / "d.md").write_text("# d", encoding="utf-8")
            paths = {p.name for p in iter_session_spec_files(repo)}
            self.assertEqual(paths, {"d.md"})


if __name__ == "__main__":
    unittest.main()
