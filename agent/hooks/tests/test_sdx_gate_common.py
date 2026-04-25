import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from agent.hooks.sdx_gate_common import _has_confirmed_spec, run_gate


class GateCommonTests(unittest.TestCase):
    def test_has_confirmed_spec_avoids_substring_false_positive(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            specs_dir = repo / "docs" / "superpowers" / "specs"
            specs_dir.mkdir(parents=True, exist_ok=True)
            spec = specs_dir / "S-1.md"
            spec.write_text(
                "<!-- sdx-prd-gate: CONFIRMED -->\n"
                "本次确认文件：PRD-2026-foo-v2.md\n",
                encoding="utf-8",
            )

            self.assertFalse(
                _has_confirmed_spec(
                    repo,
                    "<!-- sdx-prd-gate: CONFIRMED -->",
                    "PRD-2026-foo.md",
                )
            )

    def test_has_confirmed_spec_accepts_exact_basename(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            specs_dir = repo / "docs" / "superpowers" / "specs"
            specs_dir.mkdir(parents=True, exist_ok=True)
            spec = specs_dir / "S-2.md"
            spec.write_text(
                "<!-- sdx-prd-gate: CONFIRMED -->\n"
                "- PRD-2026-foo.md\n",
                encoding="utf-8",
            )

            self.assertTrue(
                _has_confirmed_spec(
                    repo,
                    "<!-- sdx-prd-gate: CONFIRMED -->",
                    "PRD-2026-foo.md",
                )
            )

    def test_run_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-abc.md"},
            "sessionId": "s1",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "docs" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("prd", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_run_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-abc.md"},
            "sessionId": "s2",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "docs" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "ok.md").write_text(
                    "<!-- sdx-prd-gate: CONFIRMED -->\nPRD-abc.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("prd", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))


if __name__ == "__main__":
    unittest.main()
