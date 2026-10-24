"""Shared output guards and real Markdown block locations for OKF artifacts."""
from pathlib import Path
import argparse
import re

from generate_knowledge_index import markdown_body
import okf_lib


def check_output(path: Path, bundle_root: Path) -> None:
    if path.is_symlink():
        raise ValueError(f"refuse-output-symlink: {path}")
    if not path.parent.resolve().is_relative_to(bundle_root.resolve()):
        raise ValueError(f"output-outside-bundle: {path}")
    if path.exists() and not path.is_file():
        raise ValueError(f"output-not-file: {path}")


def okf_block_span(text: str):
    body = markdown_body(text)
    begins = list(re.finditer(r"<!--\s*okf:begin\s*-->", body))
    ends = list(re.finditer(r"<!--\s*okf:end\s*-->", body))
    if not begins and not ends:
        return None
    if len(begins) != 1 or len(ends) != 1 or ends[0].start() < begins[0].end():
        raise ValueError("invalid-okf-block: markers must form one ordered pair")
    return begins[0].start(), ends[0].end()


def preflight(bundle_root: Path, viz_path: Path) -> None:
    # Check every planned output before the refresh pipeline's first write.
    check_output(viz_path, bundle_root)
    for directory in okf_lib.iter_bundle_directories(bundle_root):
        check_output(directory / "index.md", bundle_root)
    for path in okf_lib.iter_bundle_markdown_files(bundle_root):
        check_output(path, bundle_root)
    index = bundle_root / "index.md"
    if index.is_file():
        with index.open(encoding="utf-8", newline="") as stream:
            okf_block_span(stream.read())


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--bundle", type=Path, required=True)
    parser.add_argument("--viz", type=Path, required=True)
    args = parser.parse_args()
    try:
        preflight(args.bundle, args.viz)
    except (OSError, ValueError) as exc:
        parser.exit(1, f"error: {exc}\n")
