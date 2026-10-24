#!/usr/bin/env python3
"""Validate docs-revise cases and aggregate independently graded evidence.

This reads JSON only. It neither runs an agent nor judges semantic correctness.
Exit codes: 0 = valid suite / all required checks pass, 1 = fail or not run,
2 = invalid input. P1/P2 checks are reported but do not block a case.
"""

import argparse
import hashlib
import json
from pathlib import Path
import sys


DEFAULT_SUITE = Path(__file__).resolve().parents[1] / "evals" / "evals.json"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def nonempty_text(value):
    return isinstance(value, str) and bool(value.strip())


def unique_object(pairs):
    """Reject duplicate JSON fields instead of silently replacing evidence."""
    result = {}
    for key, value in pairs:
        require(key not in result, f"JSON: duplicate key {key}")
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(encoding="utf-8"), object_pairs_hook=unique_object)


def suite_sha256(suite):
    """Bind evidence to the entire definition, independent of JSON formatting."""
    canonical = json.dumps(suite, sort_keys=True, ensure_ascii=False, separators=(",", ":"))
    return hashlib.sha256(canonical.encode("utf-8")).hexdigest()


def indexed(items, key, context):
    require(isinstance(items, list), f"{context}: expected a list")
    result = {}
    for item in items:
        require(isinstance(item, dict), f"{context}: expected an object")
        identity = item.get(key)
        require(nonempty_text(identity), f"{context}: missing {key}")
        require(identity not in result, f"{context}: duplicate {identity}")
        result[identity] = item
    return result


def validate_suite(suite):
    """Return cases indexed by ID; reject unusable or ambiguous definitions."""
    require(isinstance(suite, dict), "suite: expected an object")
    require(suite.get("skill_name") == "docs-revise", "suite: wrong skill_name")
    cases = indexed(suite.get("evals"), "id", "evals")
    require(bool(cases), "evals: empty suite")
    for identity, case in cases.items():
        require(case.get("category") in {"should-trigger", "should-not-trigger"}, f"{identity}: invalid category")
        for field in ("prompt", "expected_output"):
            require(nonempty_text(case.get(field)), f"{identity}: missing {field}")
        assertions = indexed(case.get("assertions"), "id", identity)
        require(any(a.get("priority") == "P0" for a in assertions.values()), f"{identity}: needs P0")
        for assertion in assertions.values():
            require(assertion.get("priority") in {"P0", "P1", "P2"}, f"{identity}: invalid priority")
            require(nonempty_text(assertion.get("check")), f"{identity}: missing check")
    return cases


def score(suite, observations):
    """Missing evidence is never a pass; preserve all assertion-level outcomes."""
    cases = validate_suite(suite)
    require(isinstance(observations, dict), "results: expected an object")
    require(observations.get("skill_name") == suite["skill_name"], "results: wrong skill_name")
    digest = suite_sha256(suite)
    require(observations.get("suite_sha256") == digest,
            "results: missing or mismatched suite_sha256; re-evaluate against this suite")
    runs = indexed(observations.get("results"), "eval_id", "results")
    require(not (runs.keys() - cases.keys()), "results: unknown eval_id")
    report = {"skill_name": suite["skill_name"], "suite_sha256": digest,
              "summary": {"pass": 0, "fail": 0, "not_run": 0}, "results": []}
    for identity, case in cases.items():
        definitions = indexed(case["assertions"], "id", identity)
        checks = indexed(runs.get(identity, {}).get("assertions", []), "id", identity)
        require(not (checks.keys() - definitions.keys()), f"{identity}: unknown assertion")
        outcomes = []
        for assertion_id, definition in definitions.items():
            observed = checks.get(assertion_id, {})
            status = observed.get("status", "not_run")
            evidence = observed.get("evidence", "")
            require(status in {"pass", "fail", "not_run"}, f"{identity}/{assertion_id}: invalid status")
            require(isinstance(evidence, str), f"{identity}/{assertion_id}: evidence must be text")
            require(status == "not_run" or nonempty_text(evidence), f"{identity}/{assertion_id}: missing evidence")
            outcomes.append({"id": assertion_id, "priority": definition["priority"], "status": status, "evidence": evidence})
        required = [a["status"] for a in outcomes if a["priority"] == "P0"]
        status = "fail" if "fail" in required else "not_run" if "not_run" in required else "pass"
        report["summary"][status] += 1
        report["results"].append({"eval_id": identity, "status": status, "assertions": outcomes})
    return report


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--suite", type=Path, default=DEFAULT_SUITE)
    parser.add_argument("--results", type=Path, help="independently graded observations JSON")
    args = parser.parse_args()
    try:
        suite = read_json(args.suite)
        cases = validate_suite(suite)
        if args.results is None:
            print(json.dumps({"valid": True, "cases": len(cases),
                              "suite_sha256": suite_sha256(suite), "behavior_evaluated": False}))
            return 0
        report = score(suite, read_json(args.results))
        print(json.dumps(report, ensure_ascii=False, indent=2))
        return 1 if report["summary"]["fail"] or report["summary"]["not_run"] else 0
    except (OSError, UnicodeError, ValueError, TypeError) as error:
        print(f"Invalid evaluation input: {error}", file=sys.stderr)
        return 2


if __name__ == "__main__":
    sys.exit(main())
