#!/usr/bin/env python3
"""Run docs-archive response evaluations through explicit command adapters.

Natural-language judgments come from the grader. This runner validates evidence
records and computes scores; it does not infer semantics from response keywords.
"""

import argparse
import hashlib
import json
import math
import os
from pathlib import Path
import signal
import subprocess
import sys


ROOT = Path(__file__).resolve().parents[1]
CATEGORIES = {"should-trigger", "should-not-trigger"}
PRIORITIES = {"P0", "P1", "P2"}
ASSERTION_TYPES = {"must_include", "must_not_conflict", "should_include"}


class EvalError(ValueError):
    """An input or adapter error, never a successful evaluation."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise EvalError(message)


def nonempty(value) -> bool:
    return isinstance(value, str) and bool(value.strip())


def unique_object(pairs: list) -> dict:
    obj = {}
    for key, value in pairs:
        require(key not in obj, f"Duplicate JSON key: {key}")
        obj[key] = value
    return obj


def reject_constant(value: str) -> None:
    raise EvalError(f"Non-standard JSON value: {value}")


def finite_float(value: str) -> float:
    number = float(value)
    require(math.isfinite(number), f"Non-standard JSON number: {value} overflows")
    return number


def parse_json(text: str):
    try:
        parsed = json.loads(text, object_pairs_hook=unique_object,
                            parse_constant=reject_constant, parse_float=finite_float)
        # Escaped, unpaired surrogates decode successfully but cannot travel over
        # the UTF-8 adapter channel or appear in a UTF-8 report.
        json.dumps(parsed, ensure_ascii=False, allow_nan=False).encode("utf-8")
        return parsed
    except EvalError:
        raise
    except (ValueError, RecursionError, UnicodeError) as exc:
        raise EvalError(f"Invalid JSON: {exc}") from exc


def read_json(path: Path):
    return parse_json(path.read_text(encoding="utf-8"))


def keyed(items, field: str, label: str) -> dict:
    require(isinstance(items, list), f"{label} must be an array")
    mapping = {}
    for item in items:
        require(isinstance(item, dict), f"{label} entry must be an object")
        key = item.get(field)
        require(nonempty(key), f"{label}.{field} must be a nonempty string")
        require(key not in mapping, f"Duplicate {label} {field}: {key}")
        mapping[key] = item
    return mapping


def validate_suite(suite: dict) -> dict:
    require(isinstance(suite, dict), "Suite must be an object")
    for field in ("skill_name", "version"):
        require(nonempty(suite.get(field)), f"Suite.{field} is required")
    cases = keyed(suite.get("evals"), "id", "evals")
    require(bool(cases), "Suite must contain at least one case")
    for case_id, case in cases.items():
        require(case.get("category") in tuple(CATEGORIES), f"{case_id}: invalid category")
        for field in ("prompt", "expected_output"):
            require(nonempty(case.get(field)), f"{case_id}: missing {field}")
        assertions = keyed(case.get("assertions"), "id", f"{case_id}.assertions")
        require(bool(assertions), f"{case_id}: assertions cannot be empty")
        for assertion in assertions.values():
            for field in ("name", "check"):
                require(nonempty(assertion.get(field)), f"{case_id}: missing assertion {field}")
            require(assertion.get("priority") in tuple(PRIORITIES), f"{case_id}: invalid priority")
            require(assertion.get("type") in tuple(ASSERTION_TYPES), f"{case_id}: invalid assertion type")
        require(any(a["priority"] == "P0" for a in assertions.values()),
                f"{case_id}: at least one P0 is required")
    return cases


def fingerprint(suite: dict) -> str:
    canonical = json.dumps(suite, ensure_ascii=False, sort_keys=True, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def score_case(case: dict, result: dict) -> dict:
    case_id = case["id"]
    require(isinstance(result, dict), f"{case_id}: missing result")
    if "error" in result:
        require(nonempty(result["error"]), f"{case_id}: error must be nonempty")
        require("judgments" not in result, f"{case_id}: error and judgments are mutually exclusive")
        return {"eval_id": case_id, "status": "error", "error": result["error"]}
    require(nonempty(result.get("response")), f"{case_id}: response must be nonempty")
    judgments = keyed(result.get("judgments"), "id", f"{case_id}.judgments")
    assertions = {a["id"]: a for a in case["assertions"]}
    require(judgments.keys() == assertions.keys(),
            f"{case_id}: missing judgments={sorted(assertions.keys() - judgments.keys())}; "
            f"unknown judgments={sorted(judgments.keys() - assertions.keys())}")
    for judgment in judgments.values():
        require(type(judgment.get("passed")) is bool, f"{case_id}: passed must be a JSON boolean")
        require(nonempty(judgment.get("evidence")), f"{case_id}: evidence must be nonempty")
    failed = [key for key, j in judgments.items() if not j["passed"]]
    p0_ok = all(judgments[key]["passed"] for key, a in assertions.items() if a["priority"] == "P0")
    p1 = [judgments[key]["passed"] for key, a in assertions.items() if a["priority"] == "P1"]
    p1_ok = case["category"] != "should-trigger" or not p1 or any(p1)
    return {
        "eval_id": case_id, "status": "passed" if p0_ok and p1_ok else "failed",
        "failed_assertions": failed, "p0_passed": p0_ok, "p1_requirement_met": p1_ok,
    }


def score_results(suite: dict, payload: dict) -> dict:
    cases = validate_suite(suite)
    require(isinstance(payload, dict), "Results must be an object")
    digest = fingerprint(suite)
    require(payload.get("suite_sha256") == digest, "suite_sha256 does not match the current suite")
    results = keyed(payload.get("results"), "eval_id", "results")
    require(results.keys() <= cases.keys(), f"Unknown result cases: {sorted(results.keys() - cases.keys())}")
    outcomes = []
    for case_id, case in cases.items():
        try:
            outcomes.append(score_case(case, results.get(case_id)))
        except EvalError as exc:
            outcomes.append({"eval_id": case_id, "status": "error", "error": str(exc)})
    return {
        "skill_name": suite["skill_name"], "suite_version": suite["version"],
        "suite_sha256": digest,
        "summary": {status: sum(o["status"] == status for o in outcomes)
                    for status in ("passed", "failed", "error")},
        "cases": outcomes, "results": payload["results"],
    }


def command_argv(text: str) -> list:
    argv = parse_json(text)
    require(isinstance(argv, list) and bool(argv) and all(nonempty(arg) for arg in argv),
            "Adapter must be a nonempty JSON array of string arguments")
    require(all("\x00" not in arg for arg in argv), "Adapter arguments cannot contain NUL")
    return argv


def stop_process(process: subprocess.Popen) -> None:
    if os.name == "posix":
        if process.returncode is not None:
            try:
                os.getpgid(process.pid)
            except ProcessLookupError:
                pass
            else:
                # The leader was already reaped; an existing PID now belongs
                # to a different process. Do not signal its group.
                return
        try:
            os.killpg(process.pid, signal.SIGKILL)
        except ProcessLookupError:
            pass
    else:
        process.kill()
    process.communicate()


def interrupt_on_termination(signum, _frame):
    # Python already unwinds SIGINT. Give ordinary termination the same cleanup
    # path instead of exiting with an active adapter or CLI process group.
    raise KeyboardInterrupt(f"Terminated by signal {signum}")


def call_adapter(argv: list, payload: dict, timeout: float) -> dict:
    input_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")
    if os.name == "posix":
        # Record the actual group after setsid, then replace the launcher. Shell
        # wrappers inherit this identity even when they do not exec the adapter.
        argv = [sys.executable, "-c", (
            "import os,sys; "
            "os.environ['DOCS_ARCHIVE_RUNNER_GROUP']=str(os.getpgrp()); "
            "os.execvpe(sys.argv[1],sys.argv[1:],os.environ)"
        ), *argv]
    with subprocess.Popen(
        argv, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
        start_new_session=(os.name == "posix"),
    ) as process:
        try:
            stdout, stderr = process.communicate(input_bytes, timeout=timeout)
        except subprocess.TimeoutExpired as exc:
            raise EvalError(f"Adapter timed out after {timeout:g}s") from exc
        finally:
            # Also collect ordinary children left after success or failure;
            # on interruption this runs before Popen.__exit__ can wait.
            stop_process(process)
        require(process.returncode == 0,
                f"Adapter exited {process.returncode}: {stderr.decode('utf-8', errors='replace').strip()[:1500]}")
    output = parse_json(stdout.decode("utf-8"))
    require(isinstance(output, dict), "Adapter output must be a JSON object")
    return output


def run_suite(suite: dict, executor: list, grader: list, timeout: float) -> dict:
    cases = validate_suite(suite)
    records = []
    for index, (case_id, case) in enumerate(cases.items(), 1):
        print(f"[{index}/{len(cases)}] {case_id}", file=sys.stderr, flush=True)
        record = {"eval_id": case_id}
        stage = "executor"
        try:
            answer = call_adapter(executor, {
                "eval_id": case_id, "prompt": case["prompt"],
                "skill_path": str(ROOT / "SKILL.md"),
            }, timeout)
            require(answer.get("eval_id") == case_id, "Executor returned the wrong eval_id")
            require(nonempty(answer.get("response")), "Executor response must be nonempty")
            record["response"] = answer["response"]
            stage = "grader"
            grade = call_adapter(grader, {
                "case": case, "response": answer["response"],
                "grader_path": str(ROOT / "agents" / "grader.md"),
            }, timeout)
            require(grade.get("eval_id") == case_id, "Grader returned the wrong eval_id")
            record["judgments"] = grade.get("judgments")
        except (EvalError, OSError, UnicodeError) as exc:
            record["error"] = f"{stage}: {exc}"
        records.append(record)
    return score_results(suite, {"suite_sha256": fingerprint(suite), "results": records})


def main(argv=None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite", type=Path, default=ROOT / "evals" / "evals.json")
    actions = parser.add_subparsers(dest="action", required=True)
    actions.add_parser("validate", help="Validate suite structure only; no behavioral pass")
    score = actions.add_parser("score", help="Score recorded responses and per-assertion judgments")
    score.add_argument("--results", type=Path, required=True)
    run = actions.add_parser("run", help="Run explicit executor and grader commands")
    run.add_argument("--executor", required=True, help="JSON argv array; receives JSON on stdin")
    run.add_argument("--grader", required=True, help="JSON argv array; receives JSON on stdin")
    run.add_argument("--timeout", type=float, default=60, help="Seconds per call: 0 < timeout <= 3600 (default: 60)")
    args = parser.parse_args(argv)
    try:
        suite = read_json(args.suite)
        cases = validate_suite(suite)
        if args.action == "validate":
            report = {"status": "validated", "cases": len(cases), "suite_sha256": fingerprint(suite)}
            code = 0
        else:
            if args.action == "score":
                report = score_results(suite, read_json(args.results))
            else:
                require(math.isfinite(args.timeout) and 0 < args.timeout <= 3600,
                        "timeout must be finite and in (0, 3600] seconds")
                report = run_suite(suite, command_argv(args.executor),
                                   command_argv(args.grader), args.timeout)
            report["mode"] = args.action
            summary = report["summary"]
            code = 2 if summary["error"] else (1 if summary["failed"] else 0)
    except (EvalError, OSError, UnicodeError) as exc:
        report, code = {"status": "error", "error": str(exc)}, 2
    print(json.dumps(report, ensure_ascii=False, indent=2))
    return code


if __name__ == "__main__":
    signal.signal(signal.SIGTERM, interrupt_on_termination)
    sys.exit(main())
