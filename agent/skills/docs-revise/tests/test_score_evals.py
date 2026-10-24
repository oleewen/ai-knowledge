"""Verify evidence completeness and scoring, not the wording of model answers."""

import importlib.util
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "score_evals.py"


class ScoreEvalsTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        if not SCRIPT.exists():
            return
        spec = importlib.util.spec_from_file_location("score_evals", SCRIPT)
        cls.module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(cls.module)

    def setUp(self):
        self.assertTrue(SCRIPT.is_file(), "Missing evidence-aware evaluation scorer")
        self.suite = {
            "skill_name": "docs-revise",
            "evals": [{
                "id": "case-1", "category": "should-trigger", "prompt": "修订",
                "expected_output": "限定范围",
                "assertions": [
                    {"id": "scope", "priority": "P0", "check": "仅本文件"},
                    {"id": "hint", "priority": "P1", "check": "可选提示"},
                ],
            }],
        }

    def result(self, scope="pass", hint="not_run"):
        digest = hashlib.sha256(json.dumps(self.suite, sort_keys=True, ensure_ascii=False,
                                          separators=(",", ":")).encode("utf-8")).hexdigest()
        return {"skill_name": "docs-revise", "suite_sha256": digest, "results": [{
            "eval_id": "case-1", "assertions": [
                {"id": "scope", "status": scope, "evidence": "trace:1 仅编辑 README"},
                {"id": "hint", "status": hint, "evidence": "未执行"},
            ],
        }]}

    def test_optional_assertion_does_not_block_p0_pass(self):
        report = self.module.score(self.suite, self.result())
        self.assertEqual(report["summary"], {"pass": 1, "fail": 0, "not_run": 0})
        self.assertEqual(report["results"][0]["assertions"][1]["status"], "not_run")

    def test_p0_failure_cannot_be_overridden_by_optional_pass(self):
        report = self.module.score(self.suite, self.result("fail", "pass"))
        self.assertEqual(report["summary"]["fail"], 1)

    def test_missing_run_and_missing_assertion_are_not_run(self):
        empty = self.result()
        empty["results"] = []
        self.assertEqual(self.module.score(self.suite, empty)["summary"]["not_run"], 1)
        result = self.result()
        result["results"][0]["assertions"] = []
        self.assertEqual(self.module.score(self.suite, result)["summary"]["not_run"], 1)

    def test_missing_or_stale_suite_binding_is_rejected(self):
        original = self.result()
        missing = dict(original)
        missing.pop("suite_sha256")
        with self.assertRaisesRegex(ValueError, "suite_sha256"):
            self.module.score(self.suite, missing)
        self.suite["evals"][0]["assertions"][0]["check"] = "允许扩展多个文件"
        with self.assertRaisesRegex(ValueError, "suite_sha256"):
            self.module.score(self.suite, original)

    def test_suite_binding_ignores_json_key_order(self):
        reordered = dict(reversed(list(self.suite.items())))
        report = self.module.score(reordered, self.result())
        self.assertEqual(report["summary"]["pass"], 1)

    def test_claim_without_evidence_is_rejected(self):
        for status in ("pass", "fail"):
            result = self.result(status)
            result["results"][0]["assertions"][0]["evidence"] = " "
            with self.subTest(status=status), self.assertRaises(ValueError):
                self.module.score(self.suite, result)

    def test_unknown_or_duplicate_result_is_rejected(self):
        for mutation in ("unknown_case", "duplicate_case", "unknown_assertion", "duplicate_assertion"):
            result = self.result()
            case = result["results"][0]
            if mutation == "unknown_case":
                case["eval_id"] = "typo"
            elif mutation == "duplicate_case":
                result["results"].append(case)
            elif mutation == "unknown_assertion":
                case["assertions"][0]["id"] = "typo"
            else:
                case["assertions"].append(case["assertions"][0])
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                self.module.score(self.suite, result)

    def test_bad_status_and_wrong_skill_are_rejected(self):
        for mutation in ("status", "skill"):
            result = self.result()
            if mutation == "status":
                result["results"][0]["assertions"][0]["status"] = "passed"
            else:
                result["skill_name"] = "other"
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                self.module.score(self.suite, result)

    def test_suite_rejects_empty_duplicate_and_no_p0_cases(self):
        for mutation in ("empty", "duplicate", "no_p0", "bad_category"):
            suite = json.loads(json.dumps(self.suite))
            if mutation == "empty":
                suite["evals"] = []
            elif mutation == "duplicate":
                suite["evals"].append(suite["evals"][0])
            elif mutation == "no_p0":
                suite["evals"][0]["assertions"] = []
            else:
                suite["evals"][0]["category"] = "unknown"
            with self.subTest(mutation=mutation), self.assertRaises(ValueError):
                self.module.validate_suite(suite)

    def test_cli_exit_codes_and_read_only_behavior(self):
        with tempfile.TemporaryDirectory() as directory:
            suite_path = Path(directory) / "suite.json"
            result_path = Path(directory) / "result.json"
            suite_path.write_text(json.dumps(self.suite))
            before = suite_path.read_bytes()
            command = [sys.executable, str(SCRIPT), "--suite", str(suite_path)]
            self.assertEqual(subprocess.run(command, capture_output=True).returncode, 0)
            for status, code in (("pass", 0), ("fail", 1), ("not_run", 1)):
                result_path.write_text(json.dumps(self.result(status)))
                run = subprocess.run(command + ["--results", str(result_path)], capture_output=True)
                self.assertEqual(run.returncode, code, run.stderr)
                self.assertIn("summary", json.loads(run.stdout))
            result_path.write_text("{")
            self.assertEqual(subprocess.run(command + ["--results", str(result_path)], capture_output=True).returncode, 2)
            self.assertEqual(suite_path.read_bytes(), before)

    def test_cli_rejects_duplicate_json_keys(self):
        with tempfile.TemporaryDirectory() as directory:
            suite_path = Path(directory) / "suite.json"
            result_path = Path(directory) / "result.json"
            command = [sys.executable, str(SCRIPT), "--suite", str(suite_path),
                       "--results", str(result_path)]
            for field in ("status", "priority", "results"):
                suite_text = json.dumps(self.suite)
                result_text = json.dumps(self.result())
                if field == "status":
                    result_text = result_text.replace('"status": "pass"', '"status": "fail", "status": "pass"')
                elif field == "priority":
                    suite_text = suite_text.replace('"priority": "P0"', '"priority": "P1", "priority": "P0"')
                else:
                    result_text = result_text.replace('"results":', '"results": [], "results":')
                suite_path.write_text(suite_text)
                result_path.write_text(result_text)
                with self.subTest(field=field):
                    run = subprocess.run(command, capture_output=True)
                    self.assertEqual(run.returncode, 2, run.stdout)
                    self.assertIn(b"duplicate", run.stderr)


if __name__ == "__main__":
    unittest.main()
