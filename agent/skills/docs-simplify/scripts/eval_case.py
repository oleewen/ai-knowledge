#!/usr/bin/env python3
"""Prepare one case and deliver one message at a time to an external controller.

The controller must await the real agent response before calling ``record``.
Only the packet from ``next``, work/, and runtime/ belong to the tested agent.
control/ and evidence/ are controller-owned; this is not an OS sandbox. Run
commands serially. No LLM calls or semantic grading are performed here.
"""

import argparse
from datetime import datetime, timezone
import json
from pathlib import Path, PurePosixPath
import shutil
import sys
import tempfile


SKILL_DIR = Path(__file__).resolve().parents[1]


def write_json(path, value):
    path.write_text(json.dumps(value, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")


def save_state(run_dir, state):
    """Replace state only after the command's data has been written successfully."""
    temporary = run_dir / "control" / "state.tmp"
    write_json(temporary, state)
    temporary.replace(run_dir / "control" / "state.json")


def load_state(run_dir):
    return json.loads((run_dir / "control" / "state.json").read_text(encoding="utf-8"))


def validate_case(case):
    messages = [case.get("prompt")] + case.get("turns", [])
    if not all(isinstance(message, str) and message.strip() for message in messages):
        raise ValueError("prompt and turns must contain nonempty strings")
    fixtures = case.get("fixtures", {})
    if not isinstance(fixtures, dict):
        raise ValueError("fixtures must be an object")
    normalized = set()
    for name, content in fixtures.items():
        path = PurePosixPath(name)
        if (not name or "\\" in name or path.is_absolute() or ".." in path.parts
                or path == PurePosixPath(".") or not isinstance(content, str)):
            raise ValueError("fixture paths must be relative files without traversal")
        if path in normalized:
            raise ValueError("fixture paths must be unique after normalization")
        normalized.add(path)
    if any(parent in normalized for path in normalized for parent in path.parents):
        raise ValueError("a fixture file cannot also be a parent directory")
    return messages, fixtures


def copy_runtime(run_dir):
    """Copy only the skill's runtime instructions and their shared dependencies."""
    agent_source = SKILL_DIR.parent.parent
    agent_target = run_dir / "runtime" / "agent"
    for name in ("references", "rules", "knowledge"):
        shutil.copytree(agent_source / name, agent_target / name)
    skill_target = agent_target / "skills" / "docs-simplify"
    skill_target.mkdir(parents=True)
    for name in ("SKILL.md", "gotchas.md"):
        shutil.copy2(SKILL_DIR / name, skill_target / name)
    shutil.copytree(SKILL_DIR / "references", skill_target / "references",
                    ignore=shutil.ignore_patterns("evaluation.md"))
    shutil.copytree(SKILL_DIR / "assets", skill_target / "assets")


def initialize(args, run_dir):
    suite = json.loads(args.suite.read_text(encoding="utf-8"))
    matches = [case for case in suite["evals"] if case["id"] == args.case]
    if len(matches) != 1:
        raise ValueError("case ID must identify exactly one case")
    messages, fixtures = validate_case(matches[0])
    # Validation precedes all writes, and existing runs are never reused.
    run_dir.mkdir(parents=True, exist_ok=False)
    (run_dir / "control").mkdir()
    (run_dir / "work").mkdir()
    (run_dir / "evidence").mkdir()
    copy_runtime(run_dir)
    for name, content in fixtures.items():
        target = run_dir / "work" / name
        target.parent.mkdir(parents=True, exist_ok=True)
        with target.open("x", encoding="utf-8") as fixture:
            fixture.write(content)
    save_state(run_dir, {"case_id": args.case, "messages": messages,
                         "turn_index": 0, "awaiting_response": False})
    return {"run_dir": str(run_dir), "case_id": args.case}


def next_message(run_dir):
    state = load_state(run_dir)
    index = state["turn_index"]
    if index == len(state["messages"]):
        return {"done": True}
    state["awaiting_response"] = True
    save_state(run_dir, state)
    return {
        "message": state["messages"][index],
        "turn_index": index,
        "workdir": str(run_dir / "work"),
        "skill_path": str(run_dir / "runtime" / "agent" / "skills"
                          / "docs-simplify" / "SKILL.md"),
    }


def snapshot_files(workdir):
    """Reject symlinks and special files before creating any evidence output."""
    files = []
    if workdir.is_symlink() or not workdir.is_dir():
        raise ValueError("work directory must be an existing directory without symlinks")

    def visit(directory):
        # iterdir propagates permission errors; rglob can silently skip a subtree.
        for path in sorted(directory.iterdir()):
            if path.is_symlink():
                raise ValueError("snapshot cannot contain symlinks: " + str(path))
            if path.is_file():
                files.append(path)
            elif path.is_dir():
                visit(path)
            else:
                raise ValueError("snapshot cannot contain special files: " + str(path))

    visit(workdir)
    return files


def save_evidence(evidence, workdir, files, response, metadata):
    """Publish a complete turn, or reuse it after a failed state-write retry."""
    if evidence.exists():
        stored = json.loads((evidence / "record.json").read_text(encoding="utf-8"))
        if (not isinstance(stored, dict)
                or any(stored.get(key) != value for key, value in metadata.items())
                or (evidence / "response.md").read_text(encoding="utf-8") != response):
            raise ValueError("published evidence does not match this record attempt")
        return
    with tempfile.TemporaryDirectory(prefix=".record-", dir=evidence.parent) as temporary:
        staging = Path(temporary)
        (staging / "snapshot").mkdir()
        for path in files:
            destination = staging / "snapshot" / path.relative_to(workdir)
            destination.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(path, destination)
        (staging / "response.md").write_text(response, encoding="utf-8")
        write_json(staging / "record.json", {
            **metadata, "recorded_at": datetime.now(timezone.utc).isoformat(),
        })
        staging.rename(evidence)


def record(args, run_dir):
    state = load_state(run_dir)
    index = state["turn_index"]
    if not state["awaiting_response"] or index >= len(state["messages"]):
        raise ValueError("record requires a delivered, unrecorded message")
    if not args.agent_id.strip():
        raise ValueError("agent ID must be nonempty")
    response = args.response_file.read_text(encoding="utf-8")
    if not response.strip():
        raise ValueError("response must be nonempty")
    workdir = run_dir / "work"
    files = snapshot_files(workdir)
    evidence = run_dir / "evidence" / ("turn-" + str(index))
    save_evidence(evidence, workdir, files, response, {
        "case_id": state["case_id"], "turn_index": index,
        "agent_id": args.agent_id, "message": state["messages"][index],
    })
    state["turn_index"] += 1
    state["awaiting_response"] = False
    save_state(run_dir, state)
    return {"recorded_turn": index, "done": state["turn_index"] == len(state["messages"])}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest="command", required=True)
    init = commands.add_parser("init", help="create a fresh isolated case")
    init.add_argument("--suite", type=Path, required=True)
    init.add_argument("--case", required=True)
    advance = commands.add_parser("next", help="deliver only the current message")
    capture = commands.add_parser("record", help="save the completed agent turn and snapshot")
    capture.add_argument("--response-file", type=Path, required=True)
    capture.add_argument("--agent-id", required=True)
    for command in (init, advance, capture):
        command.add_argument("--run-dir", type=Path, required=True)
    args = parser.parse_args()
    run_dir = args.run_dir.absolute()
    try:
        if args.command == "init":
            result = initialize(args, run_dir)
        elif args.command == "next":
            result = next_message(run_dir)
        else:
            result = record(args, run_dir)
    except (OSError, ValueError, KeyError, TypeError) as error:
        print("error: " + str(error), file=sys.stderr)
        return 2
    print(json.dumps(result, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
