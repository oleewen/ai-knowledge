"""Exercise the controller CLI; agents never receive this suite or future turns."""

import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "eval_case.py"


class EvalCaseTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.run = self.root / "run"
        self.suite = self.root / "suite.json"
        self.case = {
            "id": "sample",
            "prompt": "Simplify guide.md; ask before writing.",
            "turns": ["C FUTURE_AUTHORIZATION", "M FUTURE_TARGET"],
            "fixtures": {"docs/guide.md": "Original requirement.\n"},
            "expected_output": "SECRET_EXPECTATION",
            "assertions": [{"id": "SECRET_ASSERTION"}],
        }
        self.write_suite()
        self.response = self.root / "response.md"
        self.response.write_text("Please confirm the scope.\n", encoding="utf-8")

    def write_suite(self):
        self.suite.write_text(json.dumps({"evals": [self.case]}), encoding="utf-8")

    def cli(self, command, *args, ok=True):
        result = subprocess.run(
            [sys.executable, str(SCRIPT), command, "--run-dir", str(self.run), *args],
            text=True, capture_output=True,
        )
        if ok:
            self.assertEqual(result.returncode, 0, result.stderr)
            return json.loads(result.stdout)
        self.assertNotEqual(result.returncode, 0, result.stdout)
        self.assertNotIn("Traceback", result.stderr)
        self.assertIn("error:", result.stderr)
        return result

    def initialize(self):
        return self.cli("init", "--suite", str(self.suite), "--case", "sample")

    def record(self, ok=True):
        return self.cli("record", "--response-file", str(self.response),
                        "--agent-id", "agent-1", ok=ok)

    def test_current_packet_and_runtime_exclude_future_messages_and_answers(self):
        self.initialize()
        packet = self.cli("next")
        self.assertEqual(set(packet), {"message", "turn_index", "workdir", "skill_path"})
        self.assertEqual(packet["message"], self.case["prompt"])
        self.assertEqual(packet["turn_index"], 0)
        serialized = json.dumps(packet)
        for secret in ("FUTURE_AUTHORIZATION", "FUTURE_TARGET", "SECRET_EXPECTATION", "SECRET_ASSERTION"):
            self.assertNotIn(secret, serialized)
        skill = Path(packet["skill_path"]).parent
        self.assertTrue((skill / "references" / "workflow.md").is_file())
        self.assertTrue((skill / "assets" / "docs-simplify-scope-ack-template.md").is_file())
        for omitted in ("evals", "scripts", "tests", "agents", "references/evaluation.md"):
            self.assertFalse((skill / omitted).exists(), omitted)
        self.assertTrue((skill.parent.parent / "references" / "unit-cycle-protocol.md").is_file())
        self.assertEqual((Path(packet["workdir"]) / "docs/guide.md").read_text(), "Original requirement.\n")

    def test_only_record_advances_and_repeated_next_is_idempotent(self):
        self.initialize()
        self.assertEqual(self.cli("next"), self.cli("next"))
        self.record()
        packet = self.cli("next")
        self.assertEqual(packet["turn_index"], 1)
        self.assertEqual(packet["message"], "C FUTURE_AUTHORIZATION")
        self.assertEqual(packet, self.cli("next"))

    def test_record_requires_delivery_and_cannot_skip_or_record_after_completion(self):
        self.initialize()
        self.record(ok=False)
        for index in range(3):
            self.assertEqual(self.cli("next")["turn_index"], index)
            self.record()
            self.record(ok=False)
        self.assertEqual(self.cli("next"), {"done": True})
        self.assertEqual(self.cli("next"), {"done": True})

    def test_record_preserves_actual_response_and_each_round_snapshot(self):
        self.initialize()
        self.cli("next")
        self.record()
        self.cli("next")
        work = self.run / "work" / "docs" / "guide.md"
        work.write_text("Changed after authorization.\n", encoding="utf-8")
        self.response.write_text("Completed the authorized edit.\n", encoding="utf-8")
        self.record()
        first = self.run / "evidence" / "turn-0"
        second = self.run / "evidence" / "turn-1"
        self.assertEqual((first / "snapshot/docs/guide.md").read_text(), "Original requirement.\n")
        self.assertEqual((second / "snapshot/docs/guide.md").read_text(), "Changed after authorization.\n")
        self.assertEqual((first / "response.md").read_text(), "Please confirm the scope.\n")
        metadata = json.loads((second / "record.json").read_text())
        self.assertEqual(metadata["agent_id"], "agent-1")
        self.assertEqual(metadata["turn_index"], 1)
        self.assertEqual(metadata["message"], "C FUTURE_AUTHORIZATION")

    def test_empty_response_does_not_advance(self):
        self.initialize()
        original_packet = self.cli("next")
        self.response.write_text(" \n", encoding="utf-8")
        self.record(ok=False)
        self.assertEqual(self.cli("next"), original_packet)
        self.assertFalse((self.run / "evidence" / "turn-0").exists())

    def test_invalid_fixture_paths_are_rejected_before_creating_run(self):
        for path in ("../escape.md", "/tmp/escape.md", "docs/../../escape.md", ".", "C:\\escape.md"):
            with self.subTest(path=path):
                self.case["fixtures"] = {path: "invalid"}
                self.write_suite()
                self.cli("init", "--suite", str(self.suite), "--case", "sample", ok=False)
                self.assertFalse(self.run.exists())

    def test_existing_run_is_not_overwritten(self):
        self.run.mkdir()
        sentinel = self.run / "sentinel"
        sentinel.write_text("Keep me.", encoding="utf-8")
        self.cli("init", "--suite", str(self.suite), "--case", "sample", ok=False)
        self.assertEqual(sentinel.read_text(), "Keep me.")
        self.assertEqual(list(self.run.iterdir()), [sentinel])

    def test_symlink_snapshot_is_rejected_without_advancing(self):
        self.initialize()
        packet = self.cli("next")
        (self.run / "work" / "external").symlink_to(self.response)
        self.record(ok=False)
        self.assertEqual(self.cli("next"), packet)
        self.assertFalse((self.run / "evidence" / "turn-0").exists())

    def test_unreadable_directory_is_rejected_without_advancing(self):
        self.initialize()
        packet = self.cli("next")
        directory = self.run / "work" / "docs"
        directory.chmod(0)
        try:
            if os.access(directory, os.R_OK):
                self.skipTest("user can read directories without read permission")
            self.record(ok=False)
        finally:
            directory.chmod(0o755)
        self.assertEqual(self.cli("next"), packet)
        self.assertFalse((self.run / "evidence" / "turn-0").exists())

    def test_missing_work_directory_is_rejected_without_advancing(self):
        self.initialize()
        packet = self.cli("next")
        (self.run / "work").rename(self.run / "saved-work")
        self.record(ok=False)
        self.assertEqual(self.cli("next"), packet)

    def test_filesystem_alias_fixture_is_never_overwritten(self):
        probe = self.root / "case-probe"
        probe.write_text("probe", encoding="utf-8")
        if not (self.root / "CASE-PROBE").exists():
            self.skipTest("filesystem is case sensitive")
        self.case["fixtures"] = {"guide.md": "First", "GUIDE.md": "Second"}
        self.write_suite()
        self.cli("init", "--suite", str(self.suite), "--case", "sample", ok=False)
        self.assertEqual((self.run / "work" / "guide.md").read_text(), "First")

    def test_failed_copy_can_be_retried_without_partial_evidence(self):
        self.initialize()
        packet = self.cli("next")
        fixture = self.run / "work" / "docs" / "guide.md"
        fixture.chmod(0)
        try:
            if os.access(fixture, os.R_OK):
                self.skipTest("user can read files without read permission")
            self.record(ok=False)
        finally:
            fixture.chmod(0o644)
        self.assertEqual(self.cli("next"), packet)
        self.assertEqual(list((self.run / "evidence").iterdir()), [])
        self.assertEqual(self.record()["recorded_turn"], 0)

    def test_published_evidence_survives_failed_state_write_and_retry(self):
        self.initialize()
        self.cli("next")
        control = self.run / "control"
        control.chmod(0o555)
        try:
            if os.access(control, os.W_OK):
                self.skipTest("user can write directories without write permission")
            self.record(ok=False)
        finally:
            control.chmod(0o755)
        evidence = self.run / "evidence" / "turn-0"
        self.assertTrue((evidence / "record.json").is_file())
        original_metadata = (evidence / "record.json").read_text()
        original_response = self.response.read_text()
        self.response.write_text("Different response", encoding="utf-8")
        self.record(ok=False)
        self.response.write_text(original_response, encoding="utf-8")
        self.cli("record", "--response-file", str(self.response),
                 "--agent-id", "different-agent", ok=False)
        self.assertEqual(self.record()["recorded_turn"], 0)
        self.assertEqual((evidence / "record.json").read_text(), original_metadata)
        self.record(ok=False)
        self.assertEqual(self.cli("next")["turn_index"], 1)

    def test_unknown_case_and_malformed_suite_are_reported(self):
        self.cli("init", "--suite", str(self.suite), "--case", "missing", ok=False)
        self.assertFalse(self.run.exists())
        self.suite.write_text("not json", encoding="utf-8")
        self.cli("init", "--suite", str(self.suite), "--case", "sample", ok=False)
        self.assertFalse(self.run.exists())


if __name__ == "__main__":
    unittest.main()
