"""Exercise runner decisions, subprocess boundaries and exit codes with controlled inputs."""

import copy
import hashlib
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import tempfile
import time
import unittest


ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "scripts" / "run_evals.py"


def case(case_id="case-1", category="should-trigger"):
    return {
        "id": case_id,
        "category": category,
        "prompt": "请归档本行",
        "expected_output": "仅修改获准的行",
        "assertions": [
            {"id": "scope", "name": "范围", "type": "must_not_conflict",
             "check": "不得越界", "priority": "P0"},
            {"id": "summary", "name": "摘要", "type": "should_include",
             "check": "说明改动", "priority": "P1"},
        ],
    }


def result(case_id="case-1", p0=True, p1=True):
    return {
        "eval_id": case_id,
        "response": "仅处理获准行；改动已列出。",
        "judgments": [
            {"id": "scope", "passed": p0, "evidence": "回答仅涉及获准行。"},
            {"id": "summary", "passed": p1, "evidence": "回答列出了改动。"},
        ],
    }


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.suite = {"skill_name": "docs-archive", "version": "test", "evals": [case()]}
        self.suite_path = self.root / "suite.json"

    def invoke(self, action, *arguments):
        self.suite_path.write_text(json.dumps(self.suite, ensure_ascii=True), encoding="utf-8")
        proc = subprocess.run(
            [sys.executable, "-B", str(RUNNER), "--suite", str(self.suite_path),
             action, *arguments],
            cwd=self.root, capture_output=True, text=True, encoding="utf-8", timeout=10,
        )
        self.assertTrue(proc.stdout.strip(), proc.stderr)
        return proc.returncode, json.loads(proc.stdout)

    def score(self, records, fingerprint=None):
        canonical = json.dumps(self.suite, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
        payload = {
            "suite_sha256": fingerprint or hashlib.sha256(canonical.encode()).hexdigest(),
            "results": records,
        }
        path = self.root / "results.json"
        path.write_text(json.dumps(payload, ensure_ascii=False), encoding="utf-8")
        return self.invoke("score", "--results", str(path))

    def test_validate_is_structural_only(self):
        code, report = self.invoke("validate")
        self.assertEqual(code, 0)
        self.assertEqual(report["status"], "validated")
        self.assertEqual(report["cases"], 1)
        self.assertNotIn("passed", report)

    def test_all_passed_and_failed_p0_use_different_exit_codes(self):
        code, report = self.score([result()])
        self.assertEqual((code, report["summary"]), (0, {"passed": 1, "failed": 0, "error": 0}))
        code, report = self.score([result(p0=False)])
        self.assertEqual(code, 1)
        self.assertEqual(report["cases"][0]["failed_assertions"], ["scope"])

    def test_trigger_requires_one_passed_p1_but_negative_case_does_not(self):
        code, _ = self.score([result(p1=False)])
        self.assertEqual(code, 1)
        self.suite["evals"][0]["category"] = "should-not-trigger"
        code, _ = self.score([result(p1=False)])
        self.assertEqual(code, 0)

    def test_trigger_with_no_p1_or_one_of_two_p1_passes(self):
        self.suite["evals"][0]["assertions"].pop()
        row = result()
        row["judgments"].pop()
        self.assertEqual(self.score([row])[0], 0)
        self.suite["evals"][0]["assertions"].extend([
            case()["assertions"][1],
            {"id": "optional", "name": "附加", "type": "should_include", "check": "说明", "priority": "P1"},
        ])
        row = result(p1=False)
        row["judgments"].append({"id": "optional", "passed": True, "evidence": "有附加说明。"})
        self.assertEqual(self.score([row])[0], 0)

    def test_same_assertion_id_in_distinct_cases_is_allowed(self):
        self.suite["evals"].append(case("case-2"))
        code, report = self.score([result(), result("case-2", p0=False)])
        self.assertEqual(code, 1)
        self.assertEqual(report["summary"], {"passed": 1, "failed": 1, "error": 0})

    def test_missing_case_is_error_not_skipped_success(self):
        self.suite["evals"].append(case("case-2"))
        code, report = self.score([result()])
        self.assertEqual(code, 2)
        self.assertEqual(report["summary"], {"passed": 1, "failed": 0, "error": 1})

    def test_invalid_results_fail_closed(self):
        for edit in ("missing", "duplicate", "unknown", "string_bool", "empty_evidence", "empty_response"):
            with self.subTest(edit=edit):
                row = result()
                if edit == "missing":
                    row["judgments"].pop()
                elif edit == "duplicate":
                    row["judgments"].append(row["judgments"][0])
                elif edit == "unknown":
                    row["judgments"][0]["id"] = "typo"
                elif edit == "string_bool":
                    row["judgments"][0]["passed"] = "false"
                elif edit == "empty_evidence":
                    row["judgments"][0]["evidence"] = " "
                else:
                    row["response"] = " "
                self.assertEqual(self.score([row])[0], 2)

    def test_duplicate_unknown_case_and_stale_suite_are_errors(self):
        for rows in ([result(), result()], [result("unknown")]):
            with self.subTest(rows=rows):
                self.assertEqual(self.score(rows)[0], 2)
        self.assertEqual(self.score([result()], fingerprint="0" * 64)[0], 2)

    def test_invalid_suite_is_rejected(self):
        original = copy.deepcopy(self.suite)
        for kind in ("empty", "duplicate_case", "duplicate_assertion", "no_assertions", "no_p0", "priority", "category", "type"):
            with self.subTest(kind=kind):
                self.suite = copy.deepcopy(original)
                first = self.suite["evals"][0]
                if kind == "empty":
                    self.suite["evals"] = []
                elif kind == "duplicate_case":
                    self.suite["evals"].append(copy.deepcopy(first))
                elif kind == "duplicate_assertion":
                    first["assertions"].append(copy.deepcopy(first["assertions"][0]))
                elif kind == "no_assertions":
                    first["assertions"] = []
                elif kind == "no_p0":
                    first["assertions"][0]["priority"] = "P1"
                elif kind == "priority":
                    first["assertions"][0]["priority"] = "P9"
                elif kind == "category":
                    first["category"] = "typo"
                else:
                    first["assertions"][0]["type"] = "typo"
                self.assertEqual(self.invoke("validate")[0], 2)

    def adapter(self, code):
        return json.dumps([sys.executable, "-B", "-c", code])

    def test_run_separates_execution_from_grading_and_can_rescore(self):
        executor = self.adapter(
            "import json,sys; p=json.load(sys.stdin); "
            "assert set(p)=={'eval_id','prompt','skill_path'}; "
            "print(json.dumps({'eval_id':p['eval_id'],'response':p['prompt']}))"
        )
        grader = self.adapter(
            "import json,sys; p=json.load(sys.stdin); "
            "assert p['response']==p['case']['prompt']; "
            "print(json.dumps({'eval_id':p['case']['id'],'judgments':["
            "{'id':'scope','passed':True,'evidence':'controlled transport test'},"
            "{'id':'summary','passed':True,'evidence':'controlled transport test'}]}))"
        )
        code, report = self.invoke("run", "--executor", executor, "--grader", grader)
        self.assertEqual(code, 0)
        self.assertEqual(report["summary"], {"passed": 1, "failed": 0, "error": 0})
        self.assertEqual(report["results"][0]["response"], "请归档本行")
        self.assertEqual(self.score(report["results"])[0], 0)

    def test_executor_failure_does_not_call_grader_and_other_cases_continue(self):
        self.suite["evals"].append(case("case-2"))
        executor = self.adapter(
            "import json,sys; p=json.load(sys.stdin); "
            "sys.exit(3) if p['eval_id']=='case-1' else None; "
            "print(json.dumps({'eval_id':p['eval_id'],'response':'actual response'}))"
        )
        grader = self.adapter(
            "import json,sys; p=json.load(sys.stdin); assert p['case']['id']=='case-2'; "
            "print(json.dumps({'eval_id':'case-2','judgments':["
            "{'id':'scope','passed':True,'evidence':'controlled test'},"
            "{'id':'summary','passed':True,'evidence':'controlled test'}]}))"
        )
        code, report = self.invoke("run", "--executor", executor, "--grader", grader)
        self.assertEqual(code, 2)
        self.assertEqual(report["summary"], {"passed": 1, "failed": 0, "error": 1})

    def test_bad_adapter_output_timeout_and_wrong_id_are_errors(self):
        grader = self.adapter("raise RuntimeError('must not reach grader')")
        for code in (
            "print('not json')",
            "import time; time.sleep(5)",
            "print('{\"eval_id\":\"wrong\",\"response\":\"answer\"}')",
        ):
            with self.subTest(code=code):
                status, report = self.invoke("run", "--executor", self.adapter(code),
                                             "--grader", grader, "--timeout", "0.2")
                self.assertEqual(status, 2)
                self.assertEqual(report["summary"]["error"], 1)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_completed_adapter_groups_collect_background_children(self):
        pid_file = self.root / "child.pid"
        grader = self.adapter("import json; print(json.dumps(" + repr(result()) + "))")
        for exit_code in (0, 7):
            with self.subTest(exit_code=exit_code):
                executor = self.adapter(
                    "import pathlib,subprocess,sys; "
                    "child=subprocess.Popen([sys.executable,'-c','import time; time.sleep(30)'], "
                    "stdin=subprocess.DEVNULL,stdout=subprocess.DEVNULL,stderr=subprocess.DEVNULL); "
                    f"pathlib.Path({str(pid_file)!r}).write_text(str(child.pid)); "
                    "print('{\"eval_id\":\"case-1\",\"response\":\"answer\"}'); "
                    f"sys.exit({exit_code})"
                )
                try:
                    code, _ = self.invoke("run", "--executor", executor, "--grader", grader)
                    self.assertEqual(code, 0 if exit_code == 0 else 2)
                    pid = int(pid_file.read_text(encoding="utf-8"))
                    deadline = time.monotonic() + 2
                    while time.monotonic() < deadline:
                        status = subprocess.run(["ps", "-p", str(pid), "-o", "stat="],
                                                capture_output=True, text=True, timeout=2)
                        if not status.stdout.strip() or status.stdout.strip().startswith("Z"):
                            break
                        time.sleep(0.02)
                    else:
                        self.fail(f"Background adapter child {pid} survived completion")
                finally:
                    if pid_file.exists():
                        try:
                            os.kill(int(pid_file.read_text(encoding="utf-8")), signal.SIGKILL)
                        except ProcessLookupError:
                            pass

    def test_argv_is_not_a_shell_command(self):
        marker = self.root / "shell-was-used"
        self.suite["evals"][0]["prompt"] = f"$(touch {marker})"
        executor = json.dumps([sys.executable, "-c", "import sys; sys.exit(1)", f"; touch {marker}"])
        self.invoke("run", "--executor", executor, "--grader", self.adapter("pass"))
        self.assertFalse(marker.exists())

    def test_nonstandard_json_and_duplicate_keys_are_rejected(self):
        path = self.root / "bad.json"
        for text in (
            '{"results":[],"results":[]}',
            '{"results":[],"extra":NaN}',
            '{"results":[],"extra":Infinity}',
            '{"results":[],"extra":1e999}',
        ):
            with self.subTest(text=text):
                path.write_text(text, encoding="utf-8")
                code, report = self.invoke("score", "--results", str(path))
                self.assertEqual(code, 2)
                self.assertRegex(report["error"], "Duplicate JSON|Non-standard JSON")

    def test_bad_grader_retains_response_and_is_not_a_pass(self):
        executor = self.adapter(
            "import json; print(json.dumps({'eval_id':'case-1','response':'actual answer'}))"
        )
        for grader_code in (
            "print('broken')",
            "print('{\"eval_id\":\"wrong\",\"judgments\":[]}')",
            "print('{\"eval_id\":\"case-1\",\"judgments\":[],\"passed\":true}')",
            "import sys; sys.exit(4)",
        ):
            with self.subTest(code=grader_code):
                code, report = self.invoke("run", "--executor", executor,
                                           "--grader", self.adapter(grader_code))
                self.assertEqual(code, 2)
                self.assertEqual(report["summary"]["error"], 1)
                self.assertEqual(report["results"][0]["response"], "actual answer")
                self.assertEqual(self.score(report["results"])[0], 2)

    def test_invalid_command_and_timeout_fail_before_execution(self):
        for executor in ("[]", '"python3"', '[null]', '[""]'):
            with self.subTest(executor=executor):
                self.assertEqual(
                    self.invoke("run", "--executor", executor, "--grader", self.adapter("pass"))[0], 2)
        for timeout in ("0", "-1", "nan", "inf", "1e100"):
            with self.subTest(timeout=timeout):
                self.assertEqual(self.invoke(
                    "run", "--executor", self.adapter("pass"),
                    "--grader", self.adapter("pass"), "--timeout", timeout)[0], 2)

    def test_optional_p2_failure_is_reported_but_does_not_block(self):
        self.suite["evals"][0]["assertions"][1]["priority"] = "P2"
        code, report = self.score([result(p1=False)])
        self.assertEqual(code, 0)
        self.assertEqual(report["cases"][0]["failed_assertions"], ["summary"])

    def test_missing_result_file_returns_machine_readable_error(self):
        code, report = self.invoke("score", "--results", str(self.root / "absent.json"))
        self.assertEqual(code, 2)
        self.assertEqual(report["status"], "error")

    def test_nul_argument_and_malformed_unicode_are_errors(self):
        code, report = self.invoke(
            "run", "--executor", '["python3\\u0000"]', "--grader", self.adapter("pass"))
        self.assertEqual(code, 2)
        self.assertEqual(report["status"], "error")
        self.suite["evals"][0]["prompt"] = "\ud800"
        code, report = self.invoke("validate")
        self.assertEqual(code, 2)
        self.assertEqual(report["status"], "error")

    def test_deep_json_and_oversized_integer_are_reported(self):
        path = self.root / "malformed.json"
        for text in ("[" * 1200 + "]" * 1200, '{"integer":' + "1" * 5000 + "}"):
            with self.subTest(kind=text[:20]):
                path.write_text(text, encoding="utf-8")
                code, report = self.invoke("score", "--results", str(path))
                self.assertEqual(code, 2)
                self.assertEqual(report["status"], "error")

    def test_adapter_with_invalid_utf8_is_reported(self):
        code, report = self.invoke(
            "run", "--executor", self.adapter("import sys; sys.stdout.buffer.write(bytes([255]))"),
            "--grader", self.adapter("pass"))
        self.assertEqual(code, 2)
        self.assertEqual(report["summary"]["error"], 1)

    def test_adapter_response_with_unpaired_surrogate_is_error(self):
        executor = self.adapter(
            "import json; print(json.dumps({'eval_id':'case-1','response':'\\ud800'}))"
        )
        code, report = self.invoke("run", "--executor", executor, "--grader", self.adapter("pass"))
        self.assertEqual(code, 2)
        self.assertEqual(report["summary"]["error"], 1)

    def test_invalid_payload_is_rejected_before_starting_adapter(self):
        self.suite["evals"][0]["prompt"] = "\ud800"
        marker = self.root / "adapter-started"
        executor = self.adapter(
            f"from pathlib import Path; Path({str(marker)!r}).write_text('started'); "
            "import time; time.sleep(30)"
        )
        code, report = self.invoke("run", "--executor", executor,
                                   "--grader", self.adapter("pass"), "--timeout", "0.05")
        self.assertEqual(code, 2)
        self.assertEqual(report["status"], "error")
        self.assertFalse(marker.exists())


if __name__ == "__main__":
    unittest.main()
