#!/usr/bin/env bash
set -euo pipefail
# 公司域架构结构校验；语义与实体关系仍需人工复核。

TARGET_FILE=""
usage() {
  printf '用法: %s [--file PATH]\n' "${0##*/}"
  printf '在目标公司仓执行；默认检查 DOC_DIR/domains/，--file 仅检查一份直属 DOMAIN-*.md。\n'
}

while [[ $# -gt 0 ]]; do
  case $1 in
    --file)
      if [[ $# -lt 2 || -z "$2" || "$2" == --* || -n "$TARGET_FILE" ]]; then
        printf '[ERROR] --file 需要且只能指定一个非空路径。\n' >&2
        exit 1
      fi
      TARGET_FILE="$2"
      shift 2
      ;;
    --help|-h) usage; exit 0 ;;
    *) printf '[ERROR] 未知参数: %s\n' "$1" >&2; usage >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_AGENT_HOME="$(cd "$SCRIPT_DIR/../../.." && pwd)"
# shellcheck disable=SC1091
source "$_AGENT_HOME/scripts/lib/docsconfig.sh"
docsconfig_bootstrap_validate

if [[ "${KNOWLEDGE_TYPE:-}" != "company" ]]; then
  echo "[ERROR] /sdx-domains 仅允许 KNOWLEDGE_TYPE=company；当前=${KNOWLEDGE_TYPE:-unset}"
  exit 1
fi

doc_abs="$(docsconfig_doc_abs)"
if ! command -v python3 >/dev/null 2>&1; then
  printf '[ERROR] 结构校验需要 Python 3。\n' >&2
  exit 1
fi

PYTHONUTF8=1 python3 - "$doc_abs" "$TARGET_FILE" <<'PY'
from pathlib import Path
import json
import os
import re
import sys
from urllib.parse import unquote, urlsplit

errors = []


def error(message):
    errors.append(message)
    print(f"[ERROR] {message}")


def domain_path(path, domains):
    """Check both the supplied path and the resolved file against the flat directory."""
    resolved = path.resolve()
    if (path.parent.resolve() != domains or resolved.parent != domains
            or not re.fullmatch(r"DOMAIN-.+\.md", path.name)
            or not re.fullmatch(r"DOMAIN-.+\.md", resolved.name)):
        raise ValueError(f"目标须为 domains/ 内平铺的 DOMAIN-*.md: {path}")
    if not resolved.is_file():
        raise ValueError(f"文件不存在或不是普通文件: {path}")
    return resolved


def scalar(value):
    # Required fields use simple YAML scalars; no dependency on a full YAML parser.
    value = value.strip()
    if value.startswith(("'", '"')):
        if value[0] == "'":
            match = re.match(r"'((?:[^']|'')*)'", value)
            if not match:
                raise ValueError("frontmatter 单引号标量未闭合")
            result, end = match[1].replace("''", "'"), match.end()
        else:
            try:
                result, end = json.JSONDecoder().raw_decode(value)
            except ValueError as exc:
                raise ValueError("frontmatter 双引号标量须使用 JSON 兼容转义") from exc
        if value[end:] and not re.fullmatch(r"\s+#.*", value[end:]):
            raise ValueError("frontmatter 引号后仅允许空白或以空白分隔的注释")
        if result and result.splitlines() != [result]:
            raise ValueError("frontmatter 必填字段须为单行标量")
        return result
    value = re.split(r"\s+#", value, maxsplit=1)[0].strip()
    if value.startswith("#") or value in ("null", "Null", "NULL", "~"):
        return ""
    if re.fullmatch(r"[|>](?:[1-9][+-]?|[+-][1-9]?)?", value) or value.startswith(("[", "{")):
        raise ValueError("frontmatter 必填字段须为单行标量")
    return value


def frontmatter(text):
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        raise ValueError("缺首段 YAML frontmatter")
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        raise ValueError("frontmatter 未闭合")
    body = "\n".join(lines[end + 1:])
    if not body.strip():
        raise ValueError("正文为空")
    fields = {}
    required_field = None
    for line in lines[1:end]:
        if not line.strip() or line.lstrip().startswith("#"):
            continue
        if required_field and line[0].isspace():
            raise ValueError(f"frontmatter 必填字段须为单行标量: {required_field}")
        match = re.fullmatch(r"(id|title|type):\s*(.*)", line)
        required_field = match[1] if match else None
        if match:
            key, value = match.groups()
            if key in fields:
                raise ValueError(f"frontmatter 重复字段: {key}")
            fields[key] = scalar(value)
    return fields, body


def escaped(text, position):
    before = text[:position]
    return (len(before) - len(before.rstrip("\\"))) % 2 == 1


def strip_code_spans(paragraph):
    runs = list(re.finditer(r"`+", paragraph))
    pieces, cursor, index = [], 0, 0
    while index < len(runs):
        opening = runs[index]
        if escaped(paragraph, opening.start()):
            index += 1
            continue
        closing = next((j for j in range(index + 1, len(runs))
                        if len(runs[j].group()) == len(opening.group())), None)
        if closing is None:
            index += 1
            continue
        pieces.extend((paragraph[cursor:opening.start()], " "))
        cursor, index = runs[closing].end(), closing + 1
    return "".join(pieces) + paragraph[cursor:]


def prose_only(text):
    # Match fenced blocks and code spans as in the shared link checker.
    lines, fence = [], ""
    for line in text.splitlines(keepends=True):
        match = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line.rstrip())
        if fence:
            if match:
                token, rest = match.groups()
                if token[0] == fence[0] and len(token) >= len(fence) and not rest.strip():
                    fence = ""
            lines.append("\n")
        elif match and (match[1][0] == "~" or "`" not in match[2]):
            fence = match[1]
            lines.append("\n\n")
        else:
            lines.append(line)
    return "\n\n".join(strip_code_spans(part) for part in re.split(r"\n[ \t]*\n", "".join(lines)))


def inline_destinations(body):
    openings = []
    for position, char in enumerate(body):
        if char not in "[]" or escaped(body, position):
            continue
        if char == "[":
            openings.append(position)
        elif openings:
            opening = openings.pop()
            if opening > 0 and body[opening - 1] == "!":
                continue
            match = re.match(r"\(\s*(<[^>\n]+>|[^\s)]+)(?:\s+[^)]+)?\)", body[position + 1:])
            if match:
                yield match[1]


def validate_map_links(body, domains):
    body = prose_only(body)
    references = re.findall(r"(?m)^\s{0,3}\[[^\]\n]+\]:\s*(<[^>\n]+>|\S+)", body)
    for destination in list(inline_destinations(body)) + references:
        url = urlsplit(destination.strip("<>"))
        if url.scheme or url.netloc:
            continue
        path = unquote(url.path)
        if re.fullmatch(r"DOMAIN-.+\.md", Path(path).name):
            domain_path(domains / path, domains)


def validate_file(path, domains):
    try:
        resolved = domain_path(path, domains)
        fields, body = frontmatter(resolved.read_text(encoding="utf-8-sig"))
        if not fields.get("title", "").strip():
            raise ValueError("缺非空 frontmatter title")
        if path.name == "DOMAIN-MAP.md":
            if fields.get("type") != "Domain Map":
                raise ValueError("总图 frontmatter type 须为 Domain Map")
            validate_map_links(body, domains)
        elif fields.get("id") != path.stem:
            raise ValueError(f"分域 frontmatter id 须与文件名一致: {path.stem}")
        print(f"[OK]    {path.name}")
    except (OSError, RuntimeError, UnicodeError, ValueError) as exc:
        error(f"{path}: {exc}")


try:
    doc_root = Path(sys.argv[1]).resolve()
    domains = (doc_root / "domains").resolve()
    if not domains.is_dir() or domains.parent != doc_root:
        raise ValueError(f"domains/ 不存在或指向文档根之外: {doc_root / 'domains'}")
    if sys.argv[2]:
        validate_file(Path(sys.argv[2]), domains)
    else:
        validate_file(domains / "DOMAIN-MAP.md", domains)
        for parent, directories, names in os.walk(domains, followlinks=False, onerror=lambda exc: error(str(exc))):
            parent = Path(parent)
            for name in sorted(directories):
                path = parent / name
                if path.is_symlink():
                    error(f"domains/ 内不支持目录软链: {path}")
                    directories.remove(name)
            for name in sorted(names):
                path = parent / name
                if not path.match("DOMAIN-*.md"):
                    continue
                if parent != domains:
                    error(f"分域文件须平铺，发现嵌套路径: {path}")
                elif name != "DOMAIN-MAP.md":
                    validate_file(path, domains)
except (OSError, RuntimeError, ValueError) as exc:
    error(str(exc))

print(f"错误: {len(errors)}")
sys.exit(1 if errors else 0)
PY
