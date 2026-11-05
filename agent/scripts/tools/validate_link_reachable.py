#!/usr/bin/env python3
"""检查 Agent 或仓根与四层 Markdown；配置路径由 Shell 入口传入。"""
import argparse
import html
import os
import re
import sys
import unicodedata
from collections import Counter
from html.parser import HTMLParser
from pathlib import Path
from urllib.parse import unquote, urlsplit

link_re = re.compile(r"\]\(([^)]+)\)")
bare_app_or_docs_re = re.compile(r"^(application|docs)/")

errs: list[str] = []
warns: list[str] = []
exists_cache: dict[str, bool] = {}
skipped_fixtures = 0
checked_templates = 0

# 模板中的链接相对生成文件，而非 assets 目录；只登记已核实的生成器契约。
template_outputs = {
    "skills/docs-build/assets/knowledge-index-template.md": [
        f"{layer}/INDEX-GUIDE.md"
        for layer in ("application", "system", "solution", "company")
    ],
}


def strip_code_spans(paragraph: str) -> str:
    """只配对完整且等长的反引号串；代码外的转义反引号不作为起点。"""
    runs = list(re.finditer(r"`+", paragraph))
    pieces = []
    cursor = 0
    index = 0
    while index < len(runs):
        opening = runs[index]
        before = paragraph[:opening.start()]
        backslashes = len(before) - len(before.rstrip("\\"))
        if backslashes % 2:
            index += 1
            continue
        closing = next(
            (other for other in range(index + 1, len(runs))
             if len(runs[other].group()) == len(opening.group())),
            None,
        )
        if closing is None:
            index += 1
            continue
        pieces.extend((paragraph[cursor:opening.start()], " "))
        cursor = runs[closing].end()
        index = closing + 1
    pieces.append(paragraph[cursor:])
    return "".join(pieces)


def prose_only(text: str, keep_inline_code: bool = False) -> str:
    """排除 fenced code 与行内代码，避免将 Markdown 写法示例当作链接。"""
    lines = []
    fence = ""
    for line in text.splitlines(keepends=True):
        match = re.match(r"^ {0,3}(`{3,}|~{3,})(.*)$", line.rstrip())
        if fence:
            if match:
                token, rest = match.groups()
                if token[0] == fence[0] and len(token) >= len(fence) and not rest.strip():
                    fence = ""
            lines.append("\n")
        elif match:
            token, rest = match.groups()
            if token[0] == "~" or "`" not in rest:
                fence = token
                lines.append("\n\n")
            else:
                lines.append(line)
        else:
            lines.append(line)
    text = "".join(lines)
    if keep_inline_code:
        return text
    # 空行分隔 Markdown 段落，未闭合代码不能吞掉后续段落的链接。
    return "\n\n".join(strip_code_spans(part) for part in re.split(r"\n[ \t]*\n", text))


def is_test_fixture(relative: str) -> bool:
    parts = relative.split(os.sep)
    if parts[:2] == ["scripts", "tests"]:
        remaining = parts[2:-1]
    elif len(parts) > 3 and parts[0] == "skills" and parts[2] == "tests":
        remaining = parts[3:-1]
    else:
        return False
    return any(part == "fixtures" or part.startswith("fixtures-") for part in remaining)


def norm(p: str) -> str:
    return os.path.normpath(p)


def path_exists(path: str) -> bool:
    key = norm(path)
    if key not in exists_cache:
        exists_cache[key] = os.path.exists(path)
    return exists_cache[key]


def is_under(path: str, root: str) -> bool:
    a, b = norm(path), norm(root)
    return a == b or a.startswith(b + os.sep)


def is_external(p: str) -> bool:
    p = p.strip()
    return not p or p.startswith(("#", "http://", "https://", "mailto:"))


def missing_target_err(rel_md: str, target: str) -> str:
    return f"{rel_md}: 目标不存在 → ({target})"


def check_cross_agent_link(rel_md: str, target: str, joined: str) -> None:
    if not (is_under(joined, repo) or is_under(joined, doc_abs)):
        errs.append(
            f"{rel_md}: 跨出 agent 的链接须指向仓库路径或文档路径 → ({target})"
        )
        return
    if is_under(joined, git_dir):
        errs.append(f"{rel_md}: 禁止链接到 .git → ({target})")
        return
    if not path_exists(joined):
        errs.append(missing_target_err(rel_md, target))


def check_l3_bare_root_link(rel_md: str, target: str) -> None:
    rel_slash = rel_md.replace("\\", "/")
    if "/reference/" not in rel_slash:
        return
    target_slash = target.replace("\\", "/")
    if bare_app_or_docs_re.match(target_slash):
        errs.append(
            f"{rel_md}: 深层 reference 禁止使用裸 ({target})，须 ../../../ 等到仓库根"
        )


def check_link(rel_md: str, md_path: str, raw_target: str) -> None:
    target = raw_target.strip().split("#", 1)[0].strip()
    if is_external(target):
        return

    joined = norm(os.path.join(os.path.dirname(md_path), target))
    if is_under(joined, agent):
        if not path_exists(joined):
            errs.append(missing_target_err(rel_md, target))
    else:
        check_cross_agent_link(rel_md, target, joined)

    check_l3_bare_root_link(rel_md, target)


def scan_agent_markdown() -> None:
    global skipped_fixtures, checked_templates
    for dirpath, _, files in os.walk(agent):
        for name in files:
            if not name.endswith(".md"):
                continue
            path = os.path.join(dirpath, name)
            rel_md = os.path.relpath(path, repo)
            rel_agent = os.path.relpath(path, agent)
            if is_test_fixture(rel_agent):
                skipped_fixtures += 1
                continue
            try:
                with open(path, encoding="utf-8") as f:
                    text = f.read()
            except (OSError, UnicodeDecodeError) as e:
                warns.append(f"{rel_md}: 无法读取 ({e})")
                continue
            outputs = template_outputs.get(rel_agent.replace(os.sep, "/"))
            if outputs:
                checked_templates += 1
            for m in link_re.finditer(prose_only(text)):
                if outputs:
                    for output in outputs:
                        check_link(f"{rel_md}（输出 {output}）", os.path.join(repo, output), m.group(1))
                else:
                    check_link(rel_md, path, m.group(1))


def report() -> int:
    print(f"[INFO] 跳过测试夹具 {skipped_fixtures} 份；按产物位置校验模板 {checked_templates} 份")
    for w in warns:
        print("[WARN]", w, file=sys.stderr)
    if not errs:
        print(
            "[OK] agent Markdown 链接检查通过"
            f"（agent 内互链 + 跨边界须落在仓库路径或文档路径；文档路径={doc_abs}）"
        )
        return 0
    print(f"校验失败（{len(errs)}）:", file=sys.stderr)
    for e in errs:
        print(" ", e, file=sys.stderr)
    return 1


LAYERS = ("application", "system", "solution", "company")
SLOTS = ("application-slots", "system-slots", "solution-slots")
LABEL = re.compile(r"(?<!\\)\[((?:\\.|[^\[\]\\]|\[[^\[\]]*\])*)\]")


def markdown_body(text: str, keep_inline_code: bool = False) -> str:
    """根/四层模式：不把 frontmatter、注释与代码示例当正文。"""
    text = re.sub(r"\A---\s*\n.*?\n---\s*(?:\n|$)", "\n", text, count=1, flags=re.S)
    text = re.sub(r"<!--.*?-->", "", text, flags=re.S)
    text = prose_only(text, keep_inline_code)
    lines = []
    indented = False
    in_list = False
    previous_blank = True
    for line in text.splitlines(keepends=True):
        list_item = re.match(r"^ {0,3}(?:[-+*]|\d+[.)])[ \t]+", line)
        if list_item:
            in_list = True
        elif line.strip() and not line.startswith((" ", "\t")):
            in_list = False
        is_indented = line.startswith(("    ", "\t"))
        if is_indented and not in_list and (previous_blank or indented):
            lines.append("\n")
            indented = True
        else:
            lines.append(line)
            if line.strip():
                indented = False
        previous_blank = not line.strip()
    return "".join(lines)


def destination(text: str, start: int) -> tuple[str, int]:
    """读取 Markdown 目标，保留平衡括号；返回目标与其后的偏移。"""
    index = start
    if index < len(text) and text[index] == "<":
        end = text.find(">", index + 1)
        if end != -1:
            return text[index + 1:end], end + 1
        return "", start
    depth = 0
    while index < len(text):
        char = text[index]
        if char == "\\" and index + 1 < len(text):
            index += 2
            continue
        if char.isspace() or (char == ")" and depth == 0):
            break
        if char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
        index += 1
    return text[start:index], index


def reference_key(label: str) -> str:
    return " ".join(label.split()).casefold()


def link_definitions(text: str) -> tuple[str, dict[str, str]]:
    definitions: dict[str, str] = {}

    def define(match: re.Match) -> str:
        target, _ = destination(match[2].lstrip(), 0)
        definitions.setdefault(reference_key(match[1]), target)
        return "\n"

    text = re.sub(r"^ {0,3}\[([^\]\n]+)\]:[ \t]*(?:\n[ \t]*)?([^\n]+)$", define, text, flags=re.M)
    return text, definitions


def inline_links(text: str, definitions: dict[str, str]):
    """产出有效链接的文本范围、显示标签与目标；供链接检查和标题文本共用。"""
    cursor = 0
    while match := LABEL.search(text, cursor):
        end = match.end()
        target = None
        if text[end:end + 1] == "(":
            start = end + 1
            while start < len(text) and text[start].isspace():
                start += 1
            target, end_target = destination(text, start)
            # 可选标题不属于路径；无闭合括号不是有效的行内链接。
            tail = re.match(r'''\s*(?:"[^"\n]*"|'[^'\n]*'|\([^()\n]*\))?\s*\)''', text[end_target:])
            if tail:
                end = end_target + tail.end()
            else:
                target = None
        elif text[end:end + 1] == "[":
            closing = text.find("]", end + 1)
            if closing != -1:
                key = text[end + 1:closing] or match[1]
                target = definitions.get(reference_key(key))
                end = closing + 1
        else:
            target = definitions.get(reference_key(match[1]))
        if target is not None:
            yield match.start(), end, match[1], target
        cursor = end


def markdown_links(text: str) -> list[str]:
    """提取行内/引用式链接；裸路径和未定义的 [标签] 是普通文本。"""
    text, definitions = link_definitions(markdown_body(text))
    targets = []
    for _, _, _, target in inline_links(text, definitions):
        targets.append(html.unescape(re.sub(r"\\([!\"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~])", r"\1", target)))
    return targets


def heading_slug(title: str, definitions: dict[str, str]) -> str:
    """仓库采用的 GitHub 风格标题锚点：内联文本、小写、去标点、空格转连字符。"""
    protected = []

    def protect(value: str) -> str:
        protected.append(value)
        return f"\x00{len(protected) - 1}\x00"

    # 代码内的 HTML、下划线及实体保持字面文本，不走后面的格式清理。
    def code(match: re.Match) -> str:
        value = match[2].replace("\n", " ")
        if value.startswith(" ") and value.endswith(" ") and value.strip():
            value = value[1:-1]
        return protect(value)

    title = re.sub(r"(?<![\\`])(`+)(?!`)(.+?)(?<!`)\1(?!`)", code, title)
    pieces = []
    cursor = 0
    for start, end, label, _ in inline_links(title, definitions):
        pieces.extend((title[cursor:start], label))
        cursor = end
    pieces.append(title[cursor:])
    title = "".join(pieces)
    title = re.sub(r"<[^>]*>", "", title)
    title = re.sub(r"\\([!\"#$%&'()*+,\-./:;<=>?@\[\\\]^_`{|}~])", lambda m: protect(m[1]), title)
    title = re.sub(r"(?<!\w)__([^_]+)__(?!\w)", r"\1", title)
    title = re.sub(r"(?<!\w)_([^_]+)_(?!\w)", r"\1", title)
    title = html.unescape(title).replace("*", "").replace("~", "")
    title = re.sub("\x00([0-9]+)\x00", lambda m: protected[int(m[1])], title).lower()
    return "".join(
        char for char in title
        if char in " _-" or unicodedata.category(char)[0] in "LNM"
    ).replace(" ", "-")


class ExplicitAnchors(HTMLParser):
    """按完整属性名读取 HTML 锚点，不接受 data-id 等后缀碰巧相同的属性。"""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids: set[str] = set()

    def handle_starttag(self, tag, attrs):
        for name, value in attrs:
            if value is not None and (name == "id" or (tag == "a" and name == "name")):
                self.ids.add(value)


def markdown_anchors(text: str) -> set[str]:
    text = markdown_body(text, keep_inline_code=True)
    text, definitions = link_definitions(text)
    # HTML id/name 区分大小写；行内代码中的 HTML 不创建锚点。
    explicit = ExplicitAnchors()
    explicit.feed(prose_only(text))
    generated = set()
    lines = text.splitlines()
    for index, line in enumerate(lines):
        match = re.match(r"^ {0,3}#{1,6}(?:[ \t]+(.*?)|[ \t]*)$", line)
        if match:
            title = re.sub(r"[ \t]+#+[ \t]*$", "", match[1] or "").strip()
        elif index + 1 < len(lines) and line.strip() and re.fullmatch(r" {0,3}(?:=+|-+)[ \t]*", lines[index + 1]):
            title = line.strip()
        else:
            continue
        slug = heading_slug(title, definitions)
        unique = slug
        count = 0
        while unique in generated:
            count += 1
            unique = f"{slug}-{count}"
        generated.add(unique)
    return explicit.ids | generated


class RootLayerCheck:
    """限定扫描维护正文；外仓槽位只报告排除，不读取其文件或锚点。"""

    def __init__(self, root: Path, docs: Path):
        self.root = root.resolve()
        self.docs = Path(os.path.abspath(docs))
        self.installed = Path(os.environ.get("INSTALLED_AGENT", str(docs / ".agents"))).resolve()
        self.errors: list[str] = []
        self.pending: list[str] = []
        self.excluded: Counter = Counter()
        self.anchors: dict[Path, set[str]] = {}
        self.files = self.checked = 0

    def sources(self) -> list[Path]:
        paths = list(self.root.glob("*.md"))
        bases = [self.root / layer for layer in LAYERS]
        if self.docs != self.root and not any(is_under(str(self.docs), str(base)) for base in bases):
            if is_under(str(self.docs.resolve()), str(self.root)):
                bases.append(self.docs)
            else:
                self.errors.append(f"配置文档根越界：{self.docs}")
        for base in bases:
            if any(name in candidate.parts for candidate in (base, base.resolve())
                   for name in ("superpowers", ".superpowers")):
                self.excluded["会话材料文档根"] += 1
                continue
            if base.is_symlink() or not base.is_dir():
                self.excluded["缺失或软链层目录"] += 1
                continue
            def walk_error(error: OSError) -> None:
                self.errors.append(f"无法扫描目录：{error}")

            for directory, dirs, names in os.walk(base, onerror=walk_error):
                kept = []
                for name in dirs:
                    path = Path(directory) / name
                    if name in (".git", ".agents", "agent", "node_modules", "superpowers", ".superpowers") or path.is_symlink():
                        self.excluded["Agent/工作稿/依赖/软链目录"] += 1
                    else:
                        kept.append(name)
                dirs[:] = sorted(kept)
                paths.extend(Path(directory) / name for name in names if name.endswith(".md"))
        kept_paths = []
        for path in paths:
            if any(name in path.resolve().parts for name in ("superpowers", ".superpowers")):
                self.excluded["会话材料文件或别名"] += 1
            else:
                kept_paths.append(path)
        return sorted(kept_paths)

    def slot_link(self, path: Path) -> bool:
        # 这里只识别槽位的词法位置；实际目标仍由原始路径 resolve，不能提前消去软链后的 ..。
        path = Path(os.path.abspath(path))
        if not is_under(str(path), str(self.root)):
            return False
        parts = path.relative_to(self.root).parts
        # 槽位根 README 是本地维护文档；其下命名 child 才是联邦边界。
        return (
            len(parts) >= 3 and parts[0] in LAYERS and parts[1] in SLOTS
            and (self.root / parts[0] / parts[1] / parts[2]).is_symlink()
        )

    def check(self, source: Path, target: str) -> None:
        label = f"{source.relative_to(self.root)}: ({target})"
        try:
            url = urlsplit(target)
        except ValueError:
            self.pending.append(f"{label} 无法解析 URL")
            return
        if url.scheme or url.netloc:
            self.excluded["外部 URL"] += 1
            return
        path = unquote(url.path)
        fragment = unquote(url.fragment)
        if re.search(r"\{[^}]+\}|\$[A-Za-z_(]", path):
            self.pending.append(f"{label} 未登记的模板目标")
            return
        joined = source.parent / path if path else source
        if self.slot_link(joined):
            self.excluded["联邦槽位链接"] += 1
            return
        try:
            actual = joined.resolve()
        except (OSError, RuntimeError) as error:
            self.errors.append(f"{label} 无法解析目标：{error}")
            return
        installed_link = (
            is_under(str(joined), str(self.docs / ".agents"))
            and is_under(str(actual), str(self.installed))
        )
        if not is_under(str(actual), str(self.root)) and not installed_link:
            self.errors.append(f"{label} 目标越界（含软链）")
            return
        if ".git" in actual.parts:
            self.errors.append(f"{label} 禁止链接到 .git")
            return
        self.checked += 1
        if not actual.exists():
            self.errors.append(f"{label} 目标不存在")
            return
        if fragment:
            if actual.suffix.lower() != ".md" or not actual.is_file():
                self.pending.append(f"{label} 非 Markdown 锚点尚不支持")
                return
            try:
                if actual not in self.anchors:
                    self.anchors[actual] = markdown_anchors(actual.read_text(encoding="utf-8"))
            except (OSError, UnicodeError) as error:
                self.errors.append(f"{label} 无法读取锚点：{error}")
                return
            if fragment not in self.anchors[actual]:
                self.errors.append(f"{label} 锚点不存在")

    def run(self) -> int:
        for source in self.sources():
            if source.is_symlink():
                self.excluded["软链 Markdown 源文件"] += 1
                continue
            self.files += 1
            try:
                content = source.read_text(encoding="utf-8")
                for target in markdown_links(content):
                    self.check(source, target)
            except (OSError, UnicodeError) as error:
                self.errors.append(f"{source.relative_to(self.root)}: 无法读取：{error}")
        print(f"[INFO] root-layers：{self.files} 份 Markdown（含 TODO），{self.checked} 个本地目标；配置文档根={self.docs}")
        print("[INFO] 明确排除：代码示例/frontmatter/注释；" + "；".join(f"{key} {value}" for key, value in sorted(self.excluded.items())))
        print(f"[INFO] 错误 {len(self.errors)}；待判断 {len(self.pending)}；未扫描 Agent 全树及其他根目录子树")
        for message in self.errors:
            print(f"[ERROR] {message}", file=sys.stderr)
        for message in self.pending:
            print(f"[待判断] {message}", file=sys.stderr)
        if self.errors or self.pending:
            return 1
        print("[OK] root-layers 本地文件与 Markdown 锚点检查通过（明确排除范围除外）")
        return 0


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--scope", choices=("agent", "root-layers"), default="agent")
    args = parser.parse_args()
    global repo, agent, doc_abs, git_dir
    repo = os.environ["REPO_ABS"]
    agent = os.environ["AGENT_TREE"]
    doc_abs = os.environ["DOC_ABS"]
    git_dir = os.path.join(repo, ".git")
    if args.scope == "root-layers":
        return RootLayerCheck(Path(repo), Path(doc_abs)).run()
    if not os.path.isdir(agent):
        print(f"[ERROR] 未找到 {agent}", file=sys.stderr)
        return 1
    scan_agent_markdown()
    return report()


if __name__ == "__main__":
    sys.exit(main())
