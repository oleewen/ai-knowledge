"""Exercise the real adapter boundary with a deterministic local Codex substitute."""

from contextlib import contextmanager
import hashlib
import json
import os
from pathlib import Path
import shlex
import signal
import subprocess
import sys
import tempfile
import time
import unittest
from unittest import mock


ROOT = Path(__file__).resolve().parents[1]
ADAPTER = ROOT / "scripts" / "codex_adapter.py"
RUNNER = ROOT / "scripts" / "run_evals.py"


class CodexAdapterTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.artifacts = self.directory / "artifacts"
        self.behavior = self.directory / "behavior.json"
        self.calls = self.directory / "calls.jsonl"
        self.pids = self.directory / "pids.json"
        self.addCleanup(self.cleanup_fake_processes)
        self.fake_cli = self.directory / "fake-codex"
        self.fake_cli.write_text(
            "#!" + sys.executable + "\n" + r'''
import json
import os
from pathlib import Path
import subprocess
import sys
import time

root = Path(__file__).resolve().parent
settings = json.loads((root / "behavior.json").read_text(encoding="utf-8"))
mode = settings.get("mode", "ok")

def record_processes(child):
    (root / "adapter.pid").write_text(str(os.getppid()), encoding="utf-8")
    pending = root / "pids.pending"
    pending.write_text(json.dumps([os.getpid(), child.pid]), encoding="utf-8")
    pending.replace(root / "pids.json")

if "--version" in sys.argv:
    if mode in ("version_slow_spawn", "slow_spawn"):
        time.sleep(0.6)
    if mode in ("version_spawn", "version_slow_spawn", "version_exit_child"):
        child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"],
                                 stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print("version diagnostic", file=sys.stderr, flush=True)
        record_processes(child)
        if mode in ("version_spawn", "version_slow_spawn"):
            time.sleep(30)
    print("codex-cli fake-test")
    sys.exit(0)
prompt = sys.stdin.read()
with (root / "calls.jsonl").open("a", encoding="utf-8") as stream:
    stream.write(json.dumps({"argv": sys.argv[1:], "prompt": prompt,
                             "cwd": str(Path.cwd())}) + "\n")
if mode == "slow_spawn":
    time.sleep(0.6)
if mode in ("spawn", "slow_spawn", "exit_child"):
    child = subprocess.Popen([sys.executable, "-c", "import time; time.sleep(30)"])
    print(json.dumps({"type": "turn.started"}), flush=True)
    print("partial diagnostic before timeout", file=sys.stderr, flush=True)
    record_processes(child)
    if mode in ("spawn", "slow_spawn"):
        time.sleep(30)
if mode == "timeout":
    time.sleep(30)
if mode == "exit":
    print("synthetic model unavailable", file=sys.stderr)
    sys.exit(7)
answer = settings["answer"]
raw = "not-json" if mode == "bad_json" else json.dumps(answer, ensure_ascii=False)
if mode != "missing_output":
    output_flag = "--output-last-message" if "--output-last-message" in sys.argv else "-o"
    output = Path(sys.argv[sys.argv.index(output_flag) + 1])
    output.write_text(raw, encoding="utf-8")
print(json.dumps({"type": "thread.started", "thread_id": "fake-thread"}))
print(json.dumps({"type": "turn.started"}))
if mode == "tool":
    print(json.dumps({"type": "item.completed", "item": {
        "id": "tool-1", "type": "command_execution", "command": "pwd",
        "aggregated_output": "/unexpected", "exit_code": 0, "status": "completed"}}))
if mode == "error_event":
    print(json.dumps({"type": "error", "message": "synthetic stream failure"}))
if mode == "bad_events":
    print("not a JSONL event")
print(json.dumps({"type": "item.completed", "item": {
    "id": "message-1", "type": "agent_message", "text": raw}}))
if mode != "no_completion":
    print(json.dumps({"type": "turn.completed", "usage": {
        "input_tokens": 100, "cached_input_tokens": 0, "output_tokens": 10}}))
''', encoding="utf-8",
        )
        self.fake_cli.chmod(0o700)
        self.executor_input = {
            "eval_id": "case-1", "prompt": "请将本行归档，保留索引壳。",
            "skill_path": str(ROOT / "SKILL.md"),
        }
        self.answer = {"eval_id": "case-1", "response": "先核对本行目标并形成确认书。"}
        self.case = {
            "id": "case-1", "category": "should-trigger", "prompt": "仅评此请求。",
            "expected_output": "当前用例专用期望，不应发送到执行器。",
            "assertions": [{"id": "scope", "name": "范围", "priority": "P0",
                            "type": "must_include", "check": "必须限定本行范围。"}],
        }
        self.grade = {"eval_id": "case-1", "judgments": [
            {"id": "scope", "passed": True, "evidence": "回答明确限定为本行。"},
        ]}

    def invoke(self, role="executor", payload=None, answer=None, mode="ok", *args):
        if payload is None:
            payload = self.executor_input if role == "executor" else {
                "case": self.case, "response": "只处理本行。",
                "grader_path": str(ROOT / "agents" / "grader.md"),
            }
        if answer is None:
            answer = {"response": self.answer["response"]} if role == "executor" else self.grade
        self.behavior.write_text(json.dumps({"mode": mode, "answer": answer}), encoding="utf-8")
        return subprocess.run(
            [sys.executable, "-B", str(ADAPTER), role, "--model", "test-model",
             "--codex-bin", str(self.fake_cli), "--artifacts-dir", str(self.artifacts), *args],
            input=json.dumps(payload, ensure_ascii=True), text=True, encoding="utf-8",
            capture_output=True, cwd=self.directory, timeout=15,
        )

    def recorded_calls(self):
        if not self.calls.exists():
            return []
        return [json.loads(line) for line in self.calls.read_text(encoding="utf-8").splitlines()]

    def assert_error(self, process):
        self.assertEqual(process.returncode, 2, process.stdout + process.stderr)
        self.assertTrue(process.stderr.strip())
        self.assertEqual(process.stdout.strip(), "")

    def cleanup_fake_processes(self):
        if self.pids.exists():
            for pid in json.loads(self.pids.read_text(encoding="utf-8")):
                try:
                    os.kill(pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass

    def wait_for_fake_children(self, process):
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if self.pids.exists():
                return json.loads(self.pids.read_text(encoding="utf-8"))
            self.assertIsNone(process.poll(), "Runner exited before launching the fake CLI")
            time.sleep(0.02)
        self.fail("Fake CLI did not start its child")

    def assert_children_stopped(self, pids):
        for pid in pids:
            deadline = time.monotonic() + 2
            while time.monotonic() < deadline:
                status = subprocess.run(["ps", "-p", str(pid), "-o", "stat="],
                                        capture_output=True, text=True, timeout=2)
                if not status.stdout.strip() or status.stdout.strip().startswith("Z"):
                    break
                time.sleep(0.02)
            else:
                self.fail(f"Fake CLI process {pid} survived runner termination")

    def runner_command(self, timeout, wrapped=False, mode="spawn"):
        suite_path = self.directory / "suite.json"
        suite_path.write_text(json.dumps({"skill_name": "docs-archive", "version": "test",
                                          "evals": [self.case]}), encoding="utf-8")
        self.behavior.write_text(json.dumps({"mode": mode, "answer": {"response": "unused"}}),
                                 encoding="utf-8")
        executor = [sys.executable, "-B", str(ADAPTER), "executor", "--model", "test-model",
                    "--codex-bin", str(self.fake_cli), "--artifacts-dir", str(self.artifacts),
                    "--timeout", "30"]
        if wrapped:
            executor = ["bash", "-c", '"$@"; result=$?; exit "$result"', "adapter-wrapper", *executor]
        return [sys.executable, "-B", str(RUNNER), "--suite", str(suite_path), "run",
                "--executor", json.dumps(executor), "--grader", json.dumps(executor),
                "--timeout", str(timeout)]

    @contextmanager
    def standalone_process(self, mode, timeout):
        command = self.runner_command(30, mode=mode)
        argv = json.loads(command[command.index("--executor") + 1])
        argv[argv.index("--timeout") + 1] = str(timeout)
        with subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, text=True, encoding="utf-8",
                              start_new_session=(os.name == "posix")) as process:
            try:
                process.stdin.write(json.dumps(self.executor_input))
                process.stdin.close()
                process.stdin = None
                yield process
            finally:
                if process.poll() is None:
                    process.kill()
                    self.cleanup_fake_processes()
                    process.communicate(timeout=5)

    def assert_standalone_timeout(self, process, timeout):
        pids = self.wait_for_fake_children(process)
        stdout, stderr = process.communicate(timeout=timeout + 5)
        self.assertEqual(process.returncode, 2, stdout + stderr)
        self.assertEqual(stdout.strip(), "")
        self.assertIn(f"Codex timed out after {timeout}s", stderr)
        self.assert_children_stopped(pids)

    def assert_runner_timeout(self, *, wrapped=False, mode="slow_spawn"):
        with subprocess.Popen(self.runner_command(5, wrapped=wrapped, mode=mode),
                              stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                              text=True, encoding="utf-8") as process:
            try:
                pids = self.wait_for_fake_children(process)
                stdout, stderr = process.communicate(timeout=10)
                self.assertEqual(process.returncode, 2, stdout + stderr)
                self.assertIn("Adapter timed out", json.loads(stdout)["results"][0]["error"])
                self.assert_children_stopped(pids)
            finally:
                if process.poll() is None:
                    process.kill()
                    self.cleanup_fake_processes()
                    process.communicate(timeout=5)

    def assert_partial_logs_saved(self):
        event_path, = self.artifacts.rglob("events.jsonl")
        self.assertIn('"turn.started"', event_path.read_text(encoding="utf-8"))
        self.assertIn("partial diagnostic before timeout", (event_path.parent / "stderr.log").read_text(
            encoding="utf-8"))

    def test_executor_loads_runtime_context_without_evaluation_answers(self):
        process = self.invoke()
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(json.loads(process.stdout), self.answer)
        calls = self.recorded_calls()
        self.assertEqual(len(calls), 1)
        prompt = calls[0]["prompt"]
        self.assertIn(self.executor_input["prompt"], prompt)
        self.assertIn("确认书", prompt)
        for forbidden in ("expected_output", '"assertions"', "evals/evals.json",
                          "agents/grader.md", "references/evaluation.md", "archive-trigger-001"):
            self.assertNotIn(forbidden, prompt)
        self.assertNotEqual(Path(calls[0]["cwd"]), ROOT)
        argv = calls[0]["argv"]
        for argument in ("--ignore-user-config", "--ephemeral", "project_doc_max_bytes=0",
                         "features.skip_host_skill_discovery=true", "features.shell_tool=false",
                         "features.plugins=false", "features.apps=false", 'web_search="disabled"'):
            self.assertIn(argument, argv)
        self.assertNotEqual(Path(argv[argv.index("--cd") + 1]), ROOT)

    def test_executor_hides_answer_revealing_eval_id_from_model(self):
        case_id = "archive-not-trigger-distill-001"
        process = self.invoke(payload=dict(self.executor_input, eval_id=case_id))
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(json.loads(process.stdout)["eval_id"], case_id)
        call, = self.recorded_calls()
        self.assertNotIn(case_id, call["prompt"])
        schema = Path(call["argv"][call["argv"].index("--output-schema") + 1]).read_text(
            encoding="utf-8")
        self.assertNotIn(case_id, schema)
        self.assertNotIn("eval_id", schema)

    def test_explicit_base_url_uses_temporary_provider_without_user_config(self):
        for endpoint in ("http://127.0.0.1:9999/v1", "https://proxy.example/v1"):
            with self.subTest(endpoint=endpoint):
                process = self.invoke("executor", None, None, "ok", "--base-url", endpoint)
                self.assertEqual(process.returncode, 0, process.stderr)
                argv = self.recorded_calls()[-1]["argv"]
                for argument in (
                    "--ignore-user-config", 'model_provider="eval_transport"',
                    'model_providers.eval_transport.wire_api="responses"',
                    "model_providers.eval_transport.requires_openai_auth=true",
                    "model_providers.eval_transport.supports_websockets=false",
                    "model_providers.eval_transport.base_url=" + json.dumps(endpoint),
                ):
                    self.assertIn(argument, argv)
                manifests = [json.loads(path.read_text(encoding="utf-8"))
                             for path in self.artifacts.rglob("manifest.json")]
                self.assertTrue(any(record.get("command", [])[1:] == argv for record in manifests))

    def test_invalid_base_urls_fail_before_model_call(self):
        endpoints = (
            "https://user:password@example.com/v1", "https://user@example.com/v1",
            "https://example.com/v1?token=secret", "https://example.com/v1#fragment",
            "https://example.com/\npath", "https://example.com/\tpath",
            "https://example.com/\rpath", "https://example.com/\x01path",
            "https://example.com/\x7fpath", "https:// example.com/v1",
            "ftp://example.com/v1", "file:///tmp/responses", "javascript:alert(1)",
            "//example.com/v1", "http://", "https://[::1", "",
        )
        for endpoint in endpoints:
            with self.subTest(endpoint=repr(endpoint)):
                self.assert_error(self.invoke("executor", None, None, "ok", "--base-url", endpoint))
        self.assertEqual(len(self.recorded_calls()), 0)

    def test_invalid_input_cannot_start_a_model_call(self):
        for payload in ([], {}, dict(self.executor_input, skill_path=str(self.directory / "SKILL.md")),
                        dict(self.executor_input, prompt=" ")):
            with self.subTest(payload=payload):
                self.assert_error(self.invoke(payload=payload))
        self.assertEqual(self.recorded_calls(), [])

    def test_executor_rejects_expected_outputs_before_model_call(self):
        for field, value in (("expected_output", "leaked expectation"), ("assertions", [])):
            with self.subTest(field=field):
                payload = dict(self.executor_input, **{field: value})
                self.assert_error(self.invoke(payload=payload))
        self.assertEqual(self.recorded_calls(), [])

    def test_nul_resource_paths_are_input_errors_without_tracebacks(self):
        for role, payload in (
            ("executor", dict(self.executor_input, skill_path="\x00")),
            ("grader", {"case": self.case, "response": "回答", "grader_path": "\x00"}),
        ):
            with self.subTest(role=role):
                process = self.invoke(role, payload=payload)
                self.assert_error(process)
                self.assertNotIn("Traceback", process.stderr)
        self.assertEqual(self.recorded_calls(), [])

    def test_circular_resource_symlinks_are_input_errors_without_tracebacks(self):
        cycle = self.directory / "cycle"
        cycle.symlink_to(cycle)
        for role, payload in (
            ("executor", dict(self.executor_input, skill_path=str(cycle))),
            ("grader", {"case": self.case, "response": "回答", "grader_path": str(cycle)}),
        ):
            with self.subTest(role=role):
                process = self.invoke(role, payload=payload)
                self.assert_error(process)
                self.assertNotIn("Traceback", process.stderr)
        self.assertEqual(self.recorded_calls(), [])

    def test_relative_cli_path_survives_workspace_change(self):
        process = self.invoke("executor", None, None, "ok", "--codex-bin", "./fake-codex")
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(json.loads(process.stdout), self.answer)

    @unittest.skipUnless(os.name == "posix", "POSIX executable symlink behavior")
    def test_cli_symlink_preserves_invocation_name(self):
        wrapper = self.directory / "multi-call"
        wrapper.write_text(
            '#!/bin/sh\ncase "$0" in\n'
            f'  */codex) exec {shlex.quote(str(self.fake_cli))} "$@" ;;\n'
            '  *) exit 9 ;;\nesac\n', encoding="utf-8",
        )
        wrapper.chmod(0o700)
        link = self.directory / "codex"
        link.symlink_to(wrapper)
        self.behavior.write_text(json.dumps({"answer": {"response": "unused"}}), encoding="utf-8")
        direct = subprocess.run([str(link), "--version"], capture_output=True,
                                text=True, encoding="utf-8", timeout=5)
        self.assertEqual(direct.returncode, 0, direct.stderr)
        process = self.invoke("executor", None, None, "ok", "--codex-bin", "./codex")
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(json.loads(process.stdout), self.answer)

    def test_grader_receives_only_current_case_and_response(self):
        process = self.invoke("grader")
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertEqual(json.loads(process.stdout), self.grade)
        prompt = self.recorded_calls()[0]["prompt"]
        self.assertIn(self.case["expected_output"], prompt)
        self.assertIn("只处理本行。", prompt)
        self.assertNotIn("archive-trigger-001", prompt)

    def test_grader_rejects_missing_duplicate_unknown_and_invalid_judgments(self):
        for kind in ("missing", "duplicate", "unknown", "string_bool", "no_evidence"):
            with self.subTest(kind=kind):
                grade = json.loads(json.dumps(self.grade))
                judgment = grade["judgments"][0]
                if kind == "missing":
                    grade["judgments"] = []
                elif kind == "duplicate":
                    grade["judgments"].append(dict(judgment))
                elif kind == "unknown":
                    judgment["id"] = "not-this-assertion"
                elif kind == "string_bool":
                    judgment["passed"] = "true"
                else:
                    judgment["evidence"] = " "
                self.assert_error(self.invoke("grader", answer=grade))

    def test_false_judgment_is_valid_grader_output(self):
        grade = json.loads(json.dumps(self.grade))
        grade["judgments"][0].update(passed=False, evidence="回答缺少范围限制。")
        process = self.invoke("grader", answer=grade)
        self.assertEqual(process.returncode, 0, process.stderr)
        self.assertFalse(json.loads(process.stdout)["judgments"][0]["passed"])

    def test_unexpected_executor_eval_id_and_empty_response_are_rejected(self):
        for answer in ({"eval_id": "other", "response": "回答"}, {"response": " "}):
            with self.subTest(answer=answer):
                self.assert_error(self.invoke(answer=answer))

    def test_grader_wrong_eval_id_is_rejected(self):
        self.assert_error(self.invoke("grader", answer=dict(self.grade, eval_id="other")))

    def test_cli_failure_missing_output_and_invalid_json_fail_closed(self):
        for mode in ("exit", "missing_output", "bad_json"):
            with self.subTest(mode=mode):
                self.assert_error(self.invoke(mode=mode))

    def test_tool_use_invalidates_response_only_evaluation(self):
        self.assert_error(self.invoke(mode="tool"))

    def test_stream_errors_and_incomplete_events_are_not_success(self):
        for mode in ("error_event", "bad_events", "no_completion"):
            with self.subTest(mode=mode):
                self.assert_error(self.invoke(mode=mode))

    def test_timeout_is_bounded_and_reported(self):
        process = self.invoke("executor", None, None, "timeout", "--timeout", "0.1")
        self.assert_error(process)
        self.assertIn("tim", process.stderr.lower())

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_standalone_timeout_stops_children_and_preserves_partial_logs(self):
        with self.standalone_process("slow_spawn", timeout=5) as process:
            self.assert_standalone_timeout(process, timeout=5)
        self.assert_partial_logs_saved()

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_standalone_version_timeout_stops_children(self):
        # Keep the real 10-second version limit: a subsecond CLI startup budget
        # can expire before the descendant exists and never exercise cleanup.
        with self.standalone_process("version_slow_spawn", timeout=30) as process:
            self.assert_standalone_timeout(process, timeout=10)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_successful_calls_also_stop_background_children(self):
        for mode in ("version_exit_child", "exit_child"):
            with self.subTest(mode=mode):
                try:
                    process = self.invoke(mode=mode)
                    self.assertEqual(process.returncode, 0, process.stderr)
                    self.assert_children_stopped(json.loads(self.pids.read_text(encoding="utf-8")))
                finally:
                    self.cleanup_fake_processes()

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_stale_management_marker_keeps_standalone_timeout(self):
        with mock.patch.dict(os.environ, {"DOCS_ARCHIVE_RUNNER_MANAGED": "1",
                                         "DOCS_ARCHIVE_RUNNER_GROUP": "1"}):
            with self.standalone_process("slow_spawn", timeout=5) as process:
                self.assert_standalone_timeout(process, timeout=5)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_standalone_interrupt_stops_version_and_model_children(self):
        for mode, interrupt in (("spawn", signal.SIGINT), ("version_spawn", signal.SIGINT),
                                ("spawn", signal.SIGTERM), ("version_spawn", signal.SIGTERM)):
            with self.subTest(mode=mode, interrupt=interrupt):
                command = self.runner_command(30, mode=mode)
                argv = json.loads(command[command.index("--executor") + 1])
                with subprocess.Popen(argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE, text=True, encoding="utf-8") as process:
                    try:
                        process.stdin.write(json.dumps(self.executor_input))
                        process.stdin.close()
                        process.stdin = None
                        pids = self.wait_for_fake_children(process)
                        process.send_signal(interrupt)
                        stdout, stderr = process.communicate(timeout=5)
                        self.assertNotEqual(process.returncode, 0, stdout + stderr)
                        self.assert_children_stopped(pids)
                    finally:
                        self.cleanup_fake_processes()
                        self.pids.unlink(missing_ok=True)
                        if process.poll() is None:
                            process.kill()
                            process.communicate(timeout=5)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_runner_timeout_reaches_adapter_cli_and_children(self):
        self.assert_runner_timeout()
        self.assert_partial_logs_saved()

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_runner_interrupt_reaches_adapter_cli_and_children(self):
        with subprocess.Popen(self.runner_command(30), stdout=subprocess.PIPE,
                              stderr=subprocess.PIPE, text=True, encoding="utf-8") as process:
            try:
                pids = self.wait_for_fake_children(process)
                process.send_signal(signal.SIGINT)
                stdout, stderr = process.communicate(timeout=5)
                self.assertNotEqual(process.returncode, 0, stdout + stderr)
                self.assert_children_stopped(pids)
                self.assert_partial_logs_saved()
            finally:
                if process.poll() is None:
                    process.kill()
                    process.communicate(timeout=5)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_wrapped_adapter_timeout_stops_cli_and_children(self):
        self.assert_runner_timeout(wrapped=True)
        self.assert_partial_logs_saved()

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_wrapped_interrupts_stop_cli_and_children(self):
        for target, mode, interrupt in (
            ("runner", "spawn", signal.SIGINT), ("adapter", "spawn", signal.SIGINT),
            ("adapter", "version_spawn", signal.SIGINT), ("runner", "spawn", signal.SIGTERM),
            ("adapter", "spawn", signal.SIGTERM),
        ):
            with self.subTest(target=target, mode=mode, interrupt=interrupt):
                with subprocess.Popen(self.runner_command(30, wrapped=True, mode=mode), stdout=subprocess.PIPE,
                                      stderr=subprocess.PIPE, text=True, encoding="utf-8") as process:
                    try:
                        pids = self.wait_for_fake_children(process)
                        pid = process.pid if target == "runner" else int(
                            (self.directory / "adapter.pid").read_text(encoding="utf-8"))
                        os.kill(pid, interrupt)
                        stdout, stderr = process.communicate(timeout=5)
                        self.assertNotEqual(process.returncode, 0, stdout + stderr)
                        self.assert_children_stopped(pids)
                    finally:
                        self.cleanup_fake_processes()
                        self.pids.unlink(missing_ok=True)
                        if process.poll() is None:
                            process.kill()
                            process.communicate(timeout=5)

    @unittest.skipUnless(os.name == "posix", "POSIX process-group behavior")
    def test_wrapped_version_timeout_stops_children(self):
        self.assert_runner_timeout(wrapped=True, mode="version_slow_spawn")

    def test_failed_call_preserves_error_manifest(self):
        self.assert_error(self.invoke(mode="exit"))
        manifest_path, = self.artifacts.rglob("manifest.json")
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        self.assertEqual(manifest["status"], "error")
        self.assertTrue(manifest["error"])
        self.assertTrue((manifest_path.parent / "prompt.txt").is_file())
        self.assertIn("synthetic model unavailable", (manifest_path.parent / "stderr.log").read_text(
            encoding="utf-8"))
        self.assertFalse((manifest_path.parent / "response.json").exists())

    def test_each_call_preserves_separate_raw_artifacts(self):
        first = self.invoke()
        self.assertEqual(first.returncode, 0, first.stderr)
        prior = {path.relative_to(self.artifacts): path.read_bytes()
                 for path in self.artifacts.rglob("*") if path.is_file()}
        self.assertTrue(prior)
        second = self.invoke()
        self.assertEqual(second.returncode, 0, second.stderr)
        for path, content in prior.items():
            self.assertEqual((self.artifacts / path).read_bytes(), content)
        manifests = list(self.artifacts.rglob("manifest.json"))
        self.assertEqual(len(manifests), 2)
        for manifest_path in manifests:
            record = json.loads(manifest_path.read_text(encoding="utf-8"))
            self.assertIn("test-model", json.dumps(record))
            self.assertEqual(record["status"], "completed")
            self.assertEqual(record["cli_version"], "codex-cli fake-test")
            prompt = (manifest_path.parent / "prompt.txt").read_bytes()
            self.assertTrue(prompt)
            self.assertEqual(record["prompt_sha256"], hashlib.sha256(prompt).hexdigest())
            self.assertTrue(record["context_sha256"])
            self.assertTrue(all(len(value) == 64 for value in record["context_sha256"].values()))
            self.assertEqual(json.loads((manifest_path.parent / "response.json").read_text(
                encoding="utf-8")), self.answer)


if __name__ == "__main__":
    unittest.main()
