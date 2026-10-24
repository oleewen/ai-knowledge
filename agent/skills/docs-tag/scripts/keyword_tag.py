#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
关键词附录 + 表行 ✅ + 架构摘录。Skill：仓库根执行；勿在非 TTY 用 --phase 1。
  python3 agent/skills/docs-tag/scripts/keyword_tag.py --file F --phase 1-scan --keywords … [--scan-dir] [--top-n]
  python3 … --phase 1-write --keywords … --selected A,B
  python3 … --phase 2
  python3 … --phase 3   # 或 excerpt：从五视角表 ✅ 行生成 ## 架构摘录
本地兼容：--phase 1 | 2 | 3 | all（1 含 input；all = 1→2→3）
"""

import re
import os
import sys
import json
import argparse
import urllib.parse
from collections import Counter

PERSPECTIVE_ORDER = (
    '业务架构', '产品架构', '应用架构', '技术架构', '数据架构',
)
_PERSPECTIVE_ALT = '|'.join(re.escape(p) for p in PERSPECTIVE_ORDER)
PERSPECTIVE_H2_RE = re.compile(
    rf'^##\s+\[({_PERSPECTIVE_ALT})\]\([^)]+\)\s*$'
)
EXCERPT_HEADING = '架构摘录'
EXCERPT_EMPTY_ROW = '| <!-- excerpt:empty --> | | |'
KEYWORD_BLOCK_RE = re.compile(
    r'^###[ \t]+文档关键词[ \t]*\n\s*```yaml[ \t]*\nkeywords:[ \t]*\n'
    r'(?P<items>(?:[ \t]*-[ \t]+[^\n]+\n)*)\s*```[^\S\n]*\n?',
    re.MULTILINE,
)
LEGACY_TAGS_RE = re.compile(r'<!--\s*spec-tags\s*\nkeywords:.*?-->', re.DOTALL)
APPENDIX_RE = re.compile(r'^##[ \t]+附录[ \t]*\n.*?(?=^##[ \t]+|\Z)', re.MULTILINE | re.DOTALL)


# ─────────────────────────────────────────────
# 命令行解析
# ─────────────────────────────────────────────

def positive_int(value):
    """argparse：正整数"""
    try:
        ivalue = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f'{value} 不是有效整数')
    if ivalue < 1:
        raise argparse.ArgumentTypeError(f'{value} 必须大于 0')
    return ivalue


def parse_args():
    parser = argparse.ArgumentParser(description='概览关键词标记（spec-tags + ✅）')
    parser.add_argument('--file', required=True, help='目标 Markdown')
    parser.add_argument('--phase',
                        choices=['1', '2', '3', 'excerpt', 'all', '1-scan', '1-write'],
                        required=True,
                        help='1=交互候选; 2=打勾; 3/excerpt=架构摘录; all=1→2→3; 1-scan/1-write=Skill')
    parser.add_argument('--keywords', nargs='+', default=[],
                        help='种子词（phase 含 1/1-scan/1-write/all 时必填）')
    parser.add_argument('--scan-dir', default=None,
                        help='共现扫描目录；默认取 overview/ 的父级 knowledge/；无法推断时须显式指定')
    parser.add_argument('--top-n', type=positive_int, default=30,
                        help='Top-N 候选（正整数）')
    parser.add_argument('--selected', default=None,
                        help='1-write：逗号分隔选中词')
    return parser.parse_args()


def infer_knowledge_scan_dir(overview_file):
    """从任意 {DOC_DIR}/knowledge/overview/ 推断同库扫描根。"""
    abs_dir = os.path.abspath(os.path.dirname(overview_file))
    if os.path.basename(abs_dir) != 'overview':
        return None
    knowledge_dir = os.path.dirname(abs_dir)
    if os.path.basename(knowledge_dir) != 'knowledge':
        return None
    return knowledge_dir + os.sep


def resolve_scan_dir(scan_dir, overview_file):
    """显式路径优先；无法推断时拒绝扫描其他知识库。"""
    if scan_dir:
        if not scan_dir.endswith(('/', '\\')):
            scan_dir = scan_dir + os.sep
        return scan_dir
    inferred = infer_knowledge_scan_dir(overview_file)
    if inferred:
        return inferred
    raise ValueError('无法推断扫描目录，请提供 --scan-dir')


# ─────────────────────────────────────────────
# 第一阶段：候选词提取（上下文共现算法）
# ─────────────────────────────────────────────

def split_sections(content):
    """按 # 标题切 [(heading, body), …]"""
    sections = []
    lines = content.split('\n')
    current_heading = ''
    current_body = []

    for line in lines:
        h_match = re.match(r'^#{1,6}\s+(.+)', line)
        if h_match:
            if current_heading or current_body:
                sections.append((current_heading, '\n'.join(current_body)))
            current_heading = h_match.group(1).strip()
            current_body = []
        else:
            current_body.append(line)

    if current_heading or current_body:
        sections.append((current_heading, '\n'.join(current_body)))

    return sections


def extract_terms(text):
    """从文本中提取中文词组（2-8字）和英文术语"""
    terms = []
    # 中文词组：2~8个连续汉字
    terms += re.findall(r'[\u4e00-\u9fff]{2,8}', text)
    # 英文术语：驼峰、全大写缩写、或普通英文单词（3字母以上）
    terms += re.findall(r'[A-Z][a-zA-Z]{2,}|[A-Z]{2,}', text)
    return terms


def find_relevant_sections(seed_keywords, scan_dir, target_file):
    """只读扫描；排除目标及其所在的扫描根直属子树，读取失败则报错。"""
    matched_texts = []

    # 动态计算需排除的子目录名
    exclude_subdir = None
    abs_scan_dir = os.path.abspath(scan_dir)
    abs_target_dir = os.path.abspath(os.path.dirname(target_file))
    try:
        rel = os.path.relpath(abs_target_dir, abs_scan_dir)
        # rel 的第一个路径分量即为直接子目录名
        parts = rel.split(os.sep)
        if parts and parts[0] not in ('', '.', '..'):
            exclude_subdir = parts[0]
    except ValueError:
        # Windows 跨盘符时 relpath 可能抛出 ValueError，忽略排除逻辑
        pass

    def raise_walk_error(error):
        raise error

    target_path = os.path.realpath(target_file)
    for root, dirs, files in os.walk(abs_scan_dir, onerror=raise_walk_error):
        if root == abs_scan_dir and exclude_subdir:
            dirs[:] = [d for d in dirs if d != exclude_subdir]
        dirs.sort()
        for fname in sorted(files):
            if not fname.endswith('.md'):
                continue
            fpath = os.path.join(root, fname)
            if os.path.realpath(fpath) == target_path:
                continue
            try:
                with open(fpath, 'r', encoding='utf-8') as f:
                    content = f.read()
            except (OSError, UnicodeError) as error:
                raise ValueError(f'无法读取扫描文档 {fpath}: {error}') from error

            sections = split_sections(content)

            for heading, body in sections:
                combined = heading + '\n' + body
                if any(kw in combined for kw in seed_keywords):
                    matched_texts.append(combined)

    return matched_texts


def collect_candidates(seed_keywords, scan_dir, target_file, top_n):
    """
    上下文共现算法：
    1. 找到包含种子关键词的所有章节
    2. 提取这些章节中出现的所有词语
    3. 统计词频作为相关性分数
    4. 排除种子词本身及过于通用的短词
    5. 返回按频率降序排列的 (term, count) 列表，最多 top_n 个
    """
    matched_texts = find_relevant_sections(seed_keywords, scan_dir, target_file)

    if not matched_texts:
        return []

    # 统计所有匹配章节中的词频
    counter = Counter()
    for text in matched_texts:
        terms = extract_terms(text)
        counter.update(terms)

    # 过滤：排除种子词本身、单字、过于通用的词
    stopwords = set(seed_keywords) | {
        # 中文虚词 / 连接词
        '的', '了', '在', '是', '和', '与', '或', '及', '等', '对', '为',
        '中', '上', '下', '内', '外', '前', '后', '该', '其', '此',
        '通过', '进行', '实现', '支持', '包含', '关联', '定义', '描述',
        '查询', '获取', '更新', '删除', '创建', '配置', '处理', '生成',
        # 过于宽泛的架构/业务词
        '管理', '系统', '服务', '数据', '业务', '应用', '技术', '架构',
        '设计', '方案', '策略', '规则', '模块', '功能', '接口', '流程',
        '信息', '内容', '说明', '概述', '概览', '文档', '章节', '小节',
        '业务架构', '应用架构', '技术架构', '数据架构', '产品架构',
        # Java / 编程通用词
        'String', 'List', 'Map', 'Set', 'Object', 'Class', 'Type',
        'ID', 'Id', 'Key', 'Value', 'Code', 'Name', 'Flag', 'Status',
        'Basic', 'Unit', 'Condition', 'Element', 'Base', 'Item',
        'Request', 'Response', 'Result', 'Error', 'Exception',
        'Service', 'Manager', 'Handler', 'Factory', 'Builder',
        'Controller', 'Repository', 'Entity', 'Model', 'DTO', 'VO',
        'NULL', 'TRUE', 'FALSE', 'GET', 'POST', 'PUT', 'DELETE',
        # 通用编程描述词（中文）
        '入参', '出参', '返回值', '参数', '字段', '属性', '方法', '函数',
        '唯一标识', '编码', '枚举', '聚合根', '值类型', '对象类型',
        '单位', '类型', '名称', '标识', '状态', '标志', '编号',
        # 噪音 / 占位符
        'README', 'TODO', 'TBD', 'XX', 'YY', 'ZZ', 'Xxx',
    }

    scored = [
        (term, count)
        for term, count in counter.most_common()
        if term not in stopwords and len(term) >= 2
    ]

    return scored[:top_n]


def interactive_select(scored_candidates, top_n):
    """终端展示候选词列表（含共现频率），用户多选后返回选中词列表"""
    if not scored_candidates:
        print('未找到相关候选词。')
        return []

    max_count = scored_candidates[0][1] if scored_candidates else 1

    print(f'\n=== 候选关键词列表（按共现频率排序，Top {top_n}）===')
    for i, (c, count) in enumerate(scored_candidates, 1):
        # 归一化为 1-6 格的方块条
        bar_len = max(1, round(count / max_count * 6))
        bar = '█' * bar_len
        print(f'  {i:3d}. [{bar:<6}] ({count:3d}次)  {c}')
    print('\n输入编号选择（逗号分隔，如 1,3,5），输入 all 全选，输入 q 退出：')

    candidates = [c for c, _ in scored_candidates]

    while True:
        try:
            raw = input('> ').strip()
        except (EOFError, KeyboardInterrupt):
            return []

        if raw.lower() == 'q':
            return []
        if raw.lower() == 'all':
            return list(candidates)
        try:
            indices = [int(x.strip()) for x in raw.split(',') if x.strip()]
            selected = []
            valid = True
            for idx in indices:
                if 1 <= idx <= len(candidates):
                    selected.append(candidates[idx - 1])
                else:
                    print(f'编号 {idx} 超出范围（1–{len(candidates)}），请重新输入。')
                    valid = False
                    break
            if valid:
                return selected
        except ValueError:
            print('输入格式错误，请输入数字编号（逗号分隔）或 all。')


# ─────────────────────────────────────────────
# Markdown 附录读写
# ─────────────────────────────────────────────

def read_tags_from_file(filepath):
    """读取文件末尾 Markdown 附录中的 keywords 列表，不存在则返回空列表"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        return []

    appendix = APPENDIX_RE.search(content)
    match = KEYWORD_BLOCK_RE.search(appendix.group() if appendix else '')
    if match:
        keywords = re.findall(r'^[ \t]*-[ \t]+(.+)', match.group('items'), re.MULTILINE)
        decoded = []
        for keyword in keywords:
            keyword = keyword.strip()
            if keyword.startswith('"'):
                try:
                    keyword = json.loads(keyword)
                except json.JSONDecodeError:
                    pass  # 旧版 writer 原样写入词，例如 '"API"模式'。
            elif keyword.startswith("'"):
                quoted = re.fullmatch(r"'((?:[^']|'')*)'(?:[ \t]+#.*)?", keyword)
                if not quoted:
                    raise ValueError('关键词单引号字符串未闭合或含不支持的尾部语法')
                keyword = quoted.group(1).replace("''", "'")
            if keyword:
                decoded.append(keyword)
        return decoded

    # 兼容旧格式：<!-- spec-tags ... -->
    match_old = re.search(
        r'<!--\s*spec-tags\s*\nkeywords:\s*\n((?:\s+-\s+.+\n?)*)\s*-->',
        content
    )
    if match_old:
        keywords = re.findall(r'^\s+-\s+(.+)', match_old.group(1), re.MULTILINE)
        return [k.strip() for k in keywords if k.strip()]

    return []


def write_tags_to_file(filepath, keywords):
    """将 keywords 写入文件末尾 Markdown 附录（幂等：已存在则替换，不存在则追加）"""
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # 只替换关键词小节；其他附录正文保持原位。
    # JSON 字符串也是 YAML 字符串，避免 yes、数字、冒号等被解释为其他类型。
    kw_lines = '\n'.join('- ' + json.dumps(k, ensure_ascii=False) for k in keywords)
    new_block = f'### 文档关键词\n\n```yaml\nkeywords:\n{kw_lines}\n```\n'
    content = LEGACY_TAGS_RE.sub('', content)
    appendix = APPENDIX_RE.search(content)
    if appendix:
        block = appendix.group()
        matches = list(KEYWORD_BLOCK_RE.finditer(block))
        if matches:
            # 首块原位替换，后续重复块移除。
            for match in reversed(matches):
                replacement = new_block if match == matches[0] else ''
                block = block[:match.start()] + replacement + block[match.end():]
        else:
            block = block.rstrip('\n') + '\n\n' + new_block + '\n'
        content = content[:appendix.start()] + block + content[appendix.end():]
    else:
        content = content.rstrip('\n') + '\n\n## 附录\n\n' + new_block

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)


# ─────────────────────────────────────────────
# 第一阶段主函数
# ─────────────────────────────────────────────

def phase1(overview_file, seed_keywords, scan_dir, top_n):
    print(f'种子关键词：{seed_keywords}')
    print(f'正在扫描 {scan_dir} ...')

    scored_candidates = collect_candidates(seed_keywords, scan_dir, overview_file, top_n)

    if not scored_candidates:
        print('未找到相关候选词，请尝试其他关键词。')
        return False

    selected = interactive_select(scored_candidates, top_n)

    if not selected:
        print('未选择任何关键词，退出。')
        return False

    # 构建选中词的分数映射（共现频率，用于排序写入）
    score_map = {c: count for c, count in scored_candidates}
    # 种子词赋予最高优先级
    for seed in seed_keywords:
        score_map[seed] = 999999

    # 仅保留本次种子词 + 选中词，不合并旧词（替换模式）
    all_keywords = list(dict.fromkeys(seed_keywords + selected))

    # 按相关性分数降序排序写入
    merged = sorted(all_keywords, key=lambda k: -score_map.get(k, 0))

    write_tags_to_file(overview_file, merged)
    print(f'\n已写入 {len(merged)} 个关键词到 {overview_file}（按相关性排序）')
    print('关键词列表：' + ', '.join(merged))
    return True


def phase1_scan(overview_file, scan_dir, seed_keywords, top_n):
    """阶段1扫描：输出候选词 JSON 到 stdout，不做交互，不写文件"""
    scored_candidates = collect_candidates(seed_keywords, scan_dir, overview_file, top_n)
    result = {
        "candidates": [
            {"term": term, "count": count}
            for term, count in scored_candidates
        ]
    }
    print(json.dumps(result, ensure_ascii=False))


def phase1_write(overview_file, seed_keywords, selected_str):
    """替换关键词附录：种子优先，选中词保持用户顺序，稳定去重。"""
    selected = [s.strip() for s in selected_str.split(',') if s.strip()]
    if not selected:
        raise ValueError('--selected 至少需要一个非空关键词')
    merged = list(dict.fromkeys(seed_keywords + selected))

    write_tags_to_file(overview_file, merged)
    print(f'已写入 {len(merged)} 个关键词到 {overview_file}')
    print('关键词列表：' + ', '.join(merged))


# ─────────────────────────────────────────────
# 第二阶段：章节内容读取
# ─────────────────────────────────────────────

def get_section_content(filepath, anchor):
    """读取 filepath 中 anchor 对应章节的文本内容"""
    if not os.path.exists(filepath):
        return ''
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    if not anchor:
        return content

    lines = content.split('\n')
    section_lines = []
    in_section = False
    heading_level = 0
    pending_html_heading = False

    for line in lines:
        h_match = re.match(r'^(#{1,6})\s+(.*)', line)

        if in_section:
            if pending_html_heading and h_match:
                heading_level = len(h_match.group(1))
                pending_html_heading = False
                continue
            if h_match and len(h_match.group(1)) <= heading_level:
                break
            section_lines.append(line)
            if line.strip():
                pending_html_heading = False
        else:
            # HTML 锚点
            a_match = re.search(r'<a\s+id="([^"]+)"', line)
            if a_match and a_match.group(1) == anchor:
                in_section = True
                heading_level = 100
                pending_html_heading = True
                continue

            if h_match:
                h_text = h_match.group(2).lower()
                # GitHub Markdown 锚点规则：
                # 1. 全角括号（）、半角括号()、空格、/ 等标点直接删除（不转 -）
                # 2. 半角空格转 -
                # 3. 连续 - 保留（不合并），与 GitHub 实际行为一致
                h_text_github = re.sub(r'[（）\(\)、。，：:「」『』【】《》""''\'\"]', '', h_text)
                h_text_github = re.sub(r'[ /]', '-', h_text_github).strip('-')
                # 兼容旧逻辑（合并连续 -）
                h_text_merged = re.sub(r'-+', '-', h_text_github).strip('-')

                unquoted = urllib.parse.unquote(anchor)
                if anchor in (h_text_github, h_text_merged) or unquoted in (h_text_github, h_text_merged):
                    in_section = True
                    heading_level = len(h_match.group(1))

    return '\n'.join(section_lines)


def content_for_keyword_match(text):
    """phase 2 相关性判定用文本：去掉 HTML 注释，避免 <!-- … --> 误触发 ✅。"""
    if not text:
        return ''
    return re.sub(r'<!--.*?-->', '', text, flags=re.DOTALL)


def resolve_link(url, overview_dir):
    """将副标题列的相对 URL 解析为 (绝对文件路径, 锚点)"""
    if '#' in url:
        file_part, anchor = url.split('#', 1)
    else:
        file_part, anchor = url, ''

    abs_path = os.path.normpath(os.path.join(overview_dir, file_part))
    return abs_path, anchor


# ─────────────────────────────────────────────
# 第二阶段：表格行遍历与标记
# ─────────────────────────────────────────────

def is_table_data_row(line):
    """判断是否为表格数据行（非表头、非分隔行）"""
    stripped = line.strip()
    if not stripped.startswith('|'):
        return False
    if re.match(r'^\|\s*[-:]+\s*\|', stripped):
        return False  # 分隔行
    if '主标题' in stripped and '副标题' in stripped:
        return False  # 表头行
    return True


def extract_link_from_cell(cell):
    """从表格单元格中提取第一个 Markdown 链接的 URL"""
    match = re.search(r'\]\(([^)]+)\)', cell)
    return match.group(1) if match else None


def strip_check_mark(line):
    """只移除副标题列的 ✅，保留其他列的业务内容。"""
    parts = line.split('|')
    if len(parts) >= 4:
        parts[2] = re.sub(r'\s*✅', '', parts[2])
    return '|'.join(parts)


def add_check_mark(line):
    """在副标题列的链接文字后追加 ✅"""
    parts = line.split('|')
    if len(parts) >= 3:
        col2 = parts[2]
        col2_new = re.sub(r'(\]\([^)]+\))', r'\1 ✅', col2, count=1)
        parts[2] = col2_new
        return '|'.join(parts)
    return line


def phase2(overview_file):
    overview_dir = os.path.dirname(os.path.abspath(overview_file))

    keywords = read_tags_from_file(overview_file)
    if not keywords:
        print('错误：未找到关键词附录，请先执行 --phase 1-scan 和 --phase 1-write', file=sys.stderr)
        sys.exit(1)

    print(f'读取到 {len(keywords)} 个关键词')

    with open(overview_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    marked_count = 0
    skipped_count = 0
    tag_table = False

    for line in lines:
        cells = line.strip().split('|')
        if len(cells) >= 4 and cells[1].strip() == '主标题' and cells[2].strip() == '副标题':
            tag_table = True
            new_lines.append(line)
            continue
        if not line.strip().startswith('|'):
            tag_table = False
        if not tag_table or not is_table_data_row(line):
            new_lines.append(line)
            continue

        # 幂等：先去除已有 ✅
        clean_line = strip_check_mark(line)

        # 解析副标题列链接
        parts = clean_line.split('|')
        if len(parts) < 3:
            new_lines.append(clean_line)
            continue

        url = extract_link_from_cell(parts[2])
        if not url:
            new_lines.append(clean_line)
            continue

        filepath, anchor = resolve_link(url, overview_dir)
        section_content = get_section_content(filepath, anchor)
        matchable = content_for_keyword_match(section_content)

        # 判断相关性：任意关键词出现在章节正文（不含 HTML 注释）中（大小写不敏感）
        content_lower = matchable.lower()
        is_relevant = any(kw.lower() in content_lower for kw in keywords)

        if is_relevant:
            new_line = add_check_mark(clean_line)
            new_lines.append(new_line)
            marked_count += 1
        else:
            new_lines.append(clean_line)
            skipped_count += 1

    with open(overview_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    print(f'完成：标记 {marked_count} 行 ✅，跳过 {skipped_count} 行')


# ─────────────────────────────────────────────
# 第三阶段：架构摘录（五视角 ✅ → ## 架构摘录）
# ─────────────────────────────────────────────

def is_perspective_section_boundary(line):
    """节结束：下一 H2、--- 或 ## 附录"""
    stripped = line.strip()
    if re.match(r'^---\s*$', stripped):
        return True
    if re.match(r'^##\s+附录', stripped):
        return True
    if re.match(r'^##\s+', stripped):
        return True
    return False


def parse_perspective_sections(lines):
    """
    解析五视角 H2 节正文行。
    返回 (sections: {视角名: [行…]}, found: set[视角名])。
    """
    sections = {p: [] for p in PERSPECTIVE_ORDER}
    found = set()
    current = None

    for line in lines:
        stripped = line.rstrip('\n')
        m = PERSPECTIVE_H2_RE.match(stripped)
        if m:
            current = m.group(1)
            found.add(current)
            continue
        if current is not None:
            if is_perspective_section_boundary(line):
                current = None
                continue
            sections[current].append(line)

    for perspective in PERSPECTIVE_ORDER:
        if perspective not in found:
            print(f'警告：未找到视角 H2 [{perspective}]', file=sys.stderr)

    return sections, found


def row_has_check_in_subtitle(line):
    parts = line.split('|')
    return len(parts) >= 3 and '✅' in parts[2]


def excerpt_row_from_table_line(perspective, line):
    clean = strip_check_mark(line)
    parts = clean.split('|')
    if len(parts) < 3:
        return None
    col1 = parts[1].strip()
    col2 = parts[2].strip()
    return f'| {perspective} | {col1} | {col2} |'


def collect_excerpt_rows(lines):
    """按固定视角顺序收集摘录行；返回 (行字符串列表, 各视角计数)。"""
    sections, _found = parse_perspective_sections(lines)
    rows = []
    counts = {p: 0 for p in PERSPECTIVE_ORDER}

    for perspective in PERSPECTIVE_ORDER:
        tag_table = False
        for line in sections.get(perspective, []):
            cells = line.strip().split('|')
            if len(cells) >= 4 and cells[1].strip() == '主标题' and cells[2].strip() == '副标题':
                tag_table = True
                continue
            if not line.strip().startswith('|'):
                tag_table = False
            if not tag_table or not is_table_data_row(line):
                continue
            if not row_has_check_in_subtitle(line):
                continue
            row = excerpt_row_from_table_line(perspective, line)
            if row:
                rows.append(row)
                counts[perspective] += 1

    return rows, counts


def replace_excerpt_table(lines, excerpt_rows):
    """
    替换 ## 架构摘录 下表格数据区（保留节标题、表头、分隔行）。
    成功返回新 lines；缺少架构摘录节返回 None。
    """
    excerpt_start = None
    for i, line in enumerate(lines):
        stripped = line.strip()
        if re.match(r'^##\s+', stripped) and EXCERPT_HEADING in stripped:
            excerpt_start = i
            break

    if excerpt_start is None:
        return None

    excerpt_end = len(lines)
    for j in range(excerpt_start + 1, len(lines)):
        if re.match(r'^##\s+', lines[j].strip()):
            excerpt_end = j
            break

    sep_idx = None
    for j in range(excerpt_start, excerpt_end):
        if re.match(r'^\|\s*[-:]+\s*\|', lines[j].strip()):
            sep_idx = j
            break

    if sep_idx is None:
        return None

    data_start = sep_idx + 1
    new_lines = list(lines[:data_start])
    if excerpt_rows:
        for row in excerpt_rows:
            new_lines.append(row if row.endswith('\n') else row + '\n')
    else:
        new_lines.append(EXCERPT_EMPTY_ROW + '\n')
    data_end = data_start
    while data_end < excerpt_end and lines[data_end].strip().startswith('|'):
        data_end += 1
    new_lines.extend(lines[data_end:])
    return new_lines


def phase3(overview_file):
    with open(overview_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    excerpt_rows, counts = collect_excerpt_rows(lines)
    new_lines = replace_excerpt_table(lines, excerpt_rows)
    if new_lines is None:
        print(f'错误：未找到 ## {EXCERPT_HEADING} 或其表格分隔行', file=sys.stderr)
        sys.exit(1)

    with open(overview_file, 'w', encoding='utf-8') as f:
        f.writelines(new_lines)

    total = sum(counts.values())
    if total == 0:
        print('摘录 0 行（empty）')
        return

    parts = [f'{p} {counts[p]}' for p in PERSPECTIVE_ORDER if counts[p]]
    print(f'完成：摘录 {total} 行（{" / ".join(parts)}）')


# ─────────────────────────────────────────────
# 入口
# ─────────────────────────────────────────────

def main():
    args = parse_args()

    if not os.path.isfile(args.file):
        print(f'错误：文件不存在：{args.file}', file=sys.stderr)
        sys.exit(1)

    if args.phase in ('1-scan', '1', 'all'):
        args.scan_dir = resolve_scan_dir(args.scan_dir, args.file)
        if not os.path.isdir(args.scan_dir):
            raise ValueError(f'扫描目录不存在：{args.scan_dir}')

    if args.phase == '1-scan':
        if not args.keywords:
            print('错误：--phase 1-scan 时必须提供 --keywords', file=sys.stderr)
            sys.exit(1)
        phase1_scan(args.file, args.scan_dir, args.keywords, args.top_n)

    elif args.phase == '1-write':
        if not args.keywords:
            print('错误：--phase 1-write 时必须提供 --keywords', file=sys.stderr)
            sys.exit(1)
        if not args.selected:
            print('错误：--phase 1-write 时必须提供 --selected', file=sys.stderr)
            sys.exit(1)
        phase1_write(args.file, args.keywords, args.selected)

    elif args.phase in ('1', 'all'):
        if not args.keywords:
            print('错误：--phase 1 或 --phase all 时必须提供 --keywords', file=sys.stderr)
            sys.exit(1)
        written = phase1(args.file, args.keywords, args.scan_dir, args.top_n)
        if args.phase == 'all' and written:
            phase2(args.file)
            phase3(args.file)

    elif args.phase == '2':
        phase2(args.file)

    elif args.phase in ('3', 'excerpt'):
        phase3(args.file)


if __name__ == '__main__':
    try:
        main()
    except (OSError, UnicodeError, ValueError) as error:
        print(f'错误：{error}', file=sys.stderr)
        sys.exit(1)
