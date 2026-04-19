#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
keyword_tag.py — 关键词驱动的文档标记工具

用法（Skill 层调用）：
  python keyword_tag.py --file FILE --phase 1-scan --keywords 计费 费用类型 --scan-dir docs/architecture/ --top-n 30
  python keyword_tag.py --file FILE --phase 1-write --keywords 计费 费用类型 --selected 计费规则,PolicyType
  python keyword_tag.py --file FILE --phase 2

用法（命令行直接使用，向后兼容）：
  python keyword_tag.py --file FILE --phase 1 --keywords 计费 费用类型
  python keyword_tag.py --file FILE --phase 2
  python keyword_tag.py --file FILE --phase all --keywords 计费 费用类型
"""

import re
import os
import sys
import json
import argparse
import urllib.parse
from collections import Counter

CACHE_FILE = '/tmp/keyword_tag_cache.json'


# ─────────────────────────────────────────────
# 命令行解析
# ─────────────────────────────────────────────

def positive_int(value):
    """argparse 类型校验：正整数"""
    try:
        ivalue = int(value)
    except ValueError:
        raise argparse.ArgumentTypeError(f'{value} 不是有效整数')
    if ivalue < 1:
        raise argparse.ArgumentTypeError(f'{value} 必须大于 0')
    return ivalue


def parse_args():
    parser = argparse.ArgumentParser(description='文档关键词标记工具')
    parser.add_argument('--file', required=True, help='目标文件路径')
    parser.add_argument('--phase',
                        choices=['1', '2', 'all', '1-scan', '1-write'],
                        required=True,
                        help='执行阶段：1=关键词扩展(终端交互), 2=表格标记, all=两阶段连续执行, '
                             '1-scan=扫描输出JSON(供Skill层使用), 1-write=写入选中词(供Skill层使用)')
    parser.add_argument('--keywords', nargs='+', default=[],
                        help='种子关键词（phase 1/1-scan/1-write/all 时必填）')
    parser.add_argument('--scan-dir', default='docs/architecture/',
                        help='候选词扫描目录（默认：docs/architecture/）')
    parser.add_argument('--top-n', type=positive_int, default=30,
                        help='候选词展示数量上限（默认：30，必须为正整数）')
    parser.add_argument('--selected', default=None,
                        help='已选中的关键词（逗号分隔，--phase 1-write 时必填）')
    return parser.parse_args()


# ─────────────────────────────────────────────
# 第一阶段：候选词提取（上下文共现算法）
# ─────────────────────────────────────────────

def split_sections(content):
    """将 md 文件内容按标题切分为 [(heading_text, section_body), ...] 列表"""
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
    """
    扫描 scan_dir 下所有 md 文件，找到包含任意种子关键词的章节，
    返回这些章节的全部文本内容（合并）。
    同时将扫描结果缓存到临时文件。

    排除逻辑：计算 target_file 所在目录相对于 scan_dir 的直接子目录名，
    在 os.walk 的 dirs 过滤中排除该子目录名。
    示例：target_file=docs/architecture/overview/spec-overview.md，
          scan_dir=docs/architecture/，则排除 overview 子目录。
    """
    matched_texts = []
    cache = {}  # filepath -> sections

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

    for root, dirs, files in os.walk(scan_dir):
        if exclude_subdir:
            dirs[:] = [d for d in dirs if d != exclude_subdir]
        for fname in files:
            if not fname.endswith('.md'):
                continue
            fpath = os.path.join(root, fname)
            try:
                with open(fpath, 'r', encoding='utf-8') as f:
                    content = f.read()
            except Exception:
                continue

            sections = split_sections(content)
            cache[fpath] = [(h, b[:200]) for h, b in sections]  # 缓存截断版本

            for heading, body in sections:
                combined = heading + '\n' + body
                if any(kw in combined for kw in seed_keywords):
                    matched_texts.append(combined)

    # 写临时缓存文件（供调试）
    try:
        with open(CACHE_FILE, 'w', encoding='utf-8') as f:
            json.dump({
                'seed_keywords': seed_keywords,
                'matched_section_count': len(matched_texts),
                'file_count': len(cache),
                'files': list(cache.keys()),
            }, f, ensure_ascii=False, indent=2)
        print(f'  [缓存] 扫描结果已写入 {CACHE_FILE}（匹配章节 {len(matched_texts)} 个）')
    except Exception:
        pass

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
    print(f'  正在查找包含关键词的章节...')
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

    # 新格式：## 附录 / ### 文档关键词 / ```yaml ... ```
    match = re.search(
        r'## 附录\s*\n+###\s*文档关键词\s*\n+```yaml\s*\nkeywords:\s*\n((?:-\s+.+\n?)*)\s*```',
        content
    )
    if match:
        keywords = re.findall(r'^-\s+(.+)', match.group(1), re.MULTILINE)
        return [k.strip() for k in keywords if k.strip()]

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

    # 构建新的 Markdown 附录块
    kw_lines = '\n'.join(f'- {k}' for k in keywords)
    new_block = f'\n\n## 附录\n\n### 文档关键词\n\n```yaml\nkeywords:\n{kw_lines}\n```\n'

    # 移除已有的新格式附录块
    content = re.sub(
        r'\n\n## 附录\n\n### 文档关键词\n\n```yaml\nkeywords:.*?```\n?',
        '',
        content,
        flags=re.DOTALL
    )

    # 同时移除旧格式附录块（兼容迁移）
    content = re.sub(
        r'\n---\n\n<!--\s*spec-tags\s*\nkeywords:.*?-->\n?',
        '',
        content,
        flags=re.DOTALL
    )

    # 追加新块
    content = content.rstrip('\n') + new_block

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
        return

    selected = interactive_select(scored_candidates, top_n)

    if not selected:
        print('未选择任何关键词，退出。')
        return

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
    """阶段1写入：接收选中词列表，合并种子词，写入 Markdown 附录"""
    selected = [s.strip() for s in selected_str.split(',') if s.strip()]

    # 构建分数映射（种子词优先级最高）
    score_map = {}
    for seed in seed_keywords:
        score_map[seed] = 999999

    # 合并种子词 + 选中词，去重
    all_keywords = list(dict.fromkeys(seed_keywords + selected))

    # 按分数降序排序
    merged = sorted(all_keywords, key=lambda k: -score_map.get(k, 0))

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

    for line in lines:
        h_match = re.match(r'^(#{1,6})\s+(.*)', line)

        if in_section:
            if h_match and len(h_match.group(1)) <= heading_level:
                break
            section_lines.append(line)
        else:
            # HTML 锚点
            a_match = re.search(r'<a\s+id="([^"]+)"', line)
            if a_match and a_match.group(1) == anchor:
                in_section = True
                heading_level = 100
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
    """移除行中已有的 ✅ 标记（幂等预处理）"""
    return re.sub(r'\s*✅', '', line)


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
        print('错误：未找到关键词标签，请先执行 --phase 1', file=sys.stderr)
        sys.exit(1)

    print(f'读取到 {len(keywords)} 个关键词')

    with open(overview_file, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    new_lines = []
    marked_count = 0
    skipped_count = 0

    for line in lines:
        if not is_table_data_row(line):
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

        # 判断相关性：任意关键词出现在章节内容中（大小写不敏感）
        content_lower = section_content.lower()
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
# 入口
# ─────────────────────────────────────────────

def main():
    args = parse_args()

    if not os.path.exists(args.file):
        print(f'错误：文件不存在：{args.file}', file=sys.stderr)
        sys.exit(1)

    if args.scan_dir and not os.path.exists(args.scan_dir):
        print(f'错误：扫描目录不存在：{args.scan_dir}', file=sys.stderr)
        sys.exit(1)

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
        phase1(args.file, args.keywords, args.scan_dir, args.top_n)
        if args.phase == 'all':
            phase2(args.file)

    elif args.phase == '2':
        phase2(args.file)


if __name__ == '__main__':
    main()
