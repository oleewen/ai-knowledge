import json
import sys
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from agent.hooks.sdx_gate_common import LEGACY_GATES, run_gate


class GateCommonTests(unittest.TestCase):
    def test_legacy_gate_list_keeps_old_ids_for_compatibility(self) -> None:
        self.assertIn("distill", LEGACY_GATES)
        self.assertIn("extract", LEGACY_GATES)
        self.assertIn("archive", LEGACY_GATES)
        self.assertIn("build", LEGACY_GATES)
        self.assertIn("indexing", LEGACY_GATES)
        self.assertIn("prd", LEGACY_GATES)
        self.assertIn("architect", LEGACY_GATES)
        self.assertIn("design", LEGACY_GATES)
        self.assertIn("test", LEGACY_GATES)

    def test_run_gate_allows_legacy_docs_gate(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/knowledge/overview/billing-overview.md"},
            "sessionId": "legacy-distill",
        }
        with patch("builtins.print") as mock_print:
            code = run_gate("distill", stdin=json.dumps(payload), environ={})

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_run_gate_allows_legacy_sdx_gate(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-demo.md"},
            "sessionId": "legacy-prd",
        }
        with patch("builtins.print") as mock_print:
            code = run_gate("prd", stdin=json.dumps(payload), environ={})

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_run_gate_debug_logs_retired_message(self) -> None:
        with patch("sys.stderr.write") as mock_write:
            code = run_gate("indexing", stdin="{}", environ={"DEBUG": "1"})

        self.assertEqual(code, 0)
        self.assertTrue(mock_write.called)


if __name__ == "__main__":
    unittest.main()
