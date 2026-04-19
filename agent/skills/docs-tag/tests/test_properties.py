#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
属性测试：docs-tag-skill
使用 Hypothesis 验证设计文档中定义的 8 个正确性属性。
"""

import io
import json
import os
import re
import subprocess
import sys
import tempfile
from contextlib import redirect_stdout
from pathlib import Path

from hypothesis import HealthCheck, assume, given, settings
from hypothesis import strategies as st

# 将脚本目录加入 sys.path，使 import keyword_tag 可用
_SCRIPTS_DIR = os.path.join(os.path.dirname(__file__), '..', 'scripts')
sys.path.insert(0, os.path.abspath(_SCRIPTS_DIR))

import keyword_tag  # noqa: E402


# ─────────────────────────────────────────────
# 辅助工具
# ─────────────────────────────────────────────

_SCRIPT_PATH = os.path.abspath(os.path.join(_SCRIPTS_DIR, 'keyword_tag.py'))

# 只含字母的文本策略（避免 subprocess 参数注入和 JSON 解析问题）
_alpha_text = st.text(
    min_size=2,
    max_size=8,
    alphabet=st.characters(whitelist_categories=('Lu', 'Ll')),
)

# 中英文混合关键词策略（用于函数直接调用测试）
# 排除空白字符（空格、\r、\n、\t、\xa0 等），因为 read_tags_from_file 会 strip 关键词，
# 含前后空白的关键词写入后读取会不一致，这是合理的业务约束（关键词不应含前后空白）
_keyword_text = st.text(
    min_size=2,
    max_size=8,
    alphabet=st.characters(
        blacklist_categories=('Cc', 'Cs', 'Zs', 'Zl', 'Zp'),  # 排除控制字符、代理字符、空白字符
        blacklist_characters=' \r\n\t\xa0',
    ),
)


def _make_md_with_keywords(path: Path, keywords: list) -> None:
    """在 path 写入包含关键词的 Markdown 文件"""
    content = '# 测试章节\n\n' + ' '.join(keywords) + '\n'
    path.write_text(content, encoding='utf-8')


def _make_target_file(path: Path) -> None:
    """创建一个最小合法目标文件（供 --file 参数使用）"""
    path.write_text('# 目标文件\n\n占位内容\n', encoding='utf-8')


def _count_spec_tags_blocks(content: str) -> int:
    """统计文件中 <!-- spec-tags ... --> 块的数量"""
    return len(re.findall(r'<!--\s*spec-tags', content))


def _build_overview_with_table(
    tmp_dir: Path,
    keywords: list,
    n_relevant: int,
    n_irrelevant: int,
) -> Path:
    """
    构造包含 YAML 附录块 + 表格的目标文件。

    n_relevant：链接指向含关键词章节的行数
    n_irrelevant：链接指向不含关键词章节的行数

    返回目标文件路径。
    """
    # 创建相关章节文件
    for i in range(n_relevant):
        fpath = tmp_dir / f'relevant_{i}.md'
        fpath.write_text(
            f'# 相关章节{i}\n\n' + ' '.join(keywords) + '\n',
            encoding='utf-8',
        )

    # 创建不相关章节文件
    for i in range(n_irrelevant):
        fpath = tmp_dir / f'irrelevant_{i}.md'
        fpath.write_text(
            f'# 无关章节{i}\n\n这里没有任何关键词内容。\n',
            encoding='utf-8',
        )

    # 构建 YAML 附录块
    kw_lines = '\n'.join(f'  - {k}' for k in keywords)
    yaml_block = f'\n---\n\n<!-- spec-tags\nkeywords:\n{kw_lines}\n-->\n'

    # 构建表格
    table_lines = [
        '| 主标题 | 副标题 | 说明 |',
        '| --- | --- | --- |',
    ]
    for i in range(n_relevant):
        table_lines.append(f'| 相关行{i} | [链接](relevant_{i}.md) | 相关 |')
    for i in range(n_irrelevant):
        table_lines.append(f'| 无关行{i} | [链接](irrelevant_{i}.md) | 无关 |')

    content = '# 概览文档\n\n' + '\n'.join(table_lines) + '\n' + yaml_block

    overview = tmp_dir / 'overview.md'
    overview.write_text(content, encoding='utf-8')
    return overview


# ─────────────────────────────────────────────
# 属性 1：1-scan 输出格式合法性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 1: 1-scan 输出格式合法性
@given(
    keywords=st.lists(_alpha_text, min_size=1, max_size=5),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property1_scan_output_format(keywords):
    """
    对于任意种子关键词列表和包含 Markdown 文件的扫描目录，
    --phase 1-scan 的 stdout 输出必须是合法 JSON，
    结构符合 {"candidates": [{"term": str, "count": int}]}，
    且 candidates 数组按 count 降序排列。
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)

        # 在 tmp_path/scan/ 下创建包含种子词的 .md 文件
        scan_dir = tmp_path / 'scan'
        scan_dir.mkdir()
        md_file = scan_dir / 'content.md'
        _make_md_with_keywords(md_file, keywords)

        # 目标文件放在 scan_dir 外，避免被排除逻辑影响
        target_file = tmp_path / 'target.md'
        _make_target_file(target_file)

        result = subprocess.run(
            [
                sys.executable,
                _SCRIPT_PATH,
                '--file', str(target_file),
                '--phase', '1-scan',
                '--keywords', *keywords,
                '--scan-dir', str(scan_dir),
                '--top-n', '30',
            ],
            capture_output=True,
            text=True,
            encoding='utf-8',
        )

        # 从 stdout 中提取 JSON（忽略脚本打印的调试信息行）
        stdout_lines = result.stdout.strip().split('\n')
        json_line = None
        for line in stdout_lines:
            line = line.strip()
            if line.startswith('{'):
                json_line = line
                break

        assert json_line is not None, (
            f'stdout 中未找到 JSON 行，完整输出：{result.stdout!r}'
        )

        # stdout 必须是合法 JSON
        try:
            data = json.loads(json_line)
        except json.JSONDecodeError:
            raise AssertionError(f'stdout 不是合法 JSON：{json_line!r}')

        # 结构验证：顶层必须有 candidates 键
        assert 'candidates' in data, f'缺少 candidates 键：{data}'
        candidates = data['candidates']
        assert isinstance(candidates, list), f'candidates 不是列表：{candidates}'

        # 每个元素必须有 term(str) 和 count(int)
        for item in candidates:
            assert isinstance(item, dict), f'候选词条目不是字典：{item}'
            assert 'term' in item, f'候选词条目缺少 term：{item}'
            assert 'count' in item, f'候选词条目缺少 count：{item}'
            assert isinstance(item['term'], str), f'term 不是字符串：{item}'
            assert isinstance(item['count'], int), f'count 不是整数：{item}'

        # candidates 必须按 count 降序排列
        counts = [item['count'] for item in candidates]
        assert counts == sorted(counts, reverse=True), (
            f'candidates 未按 count 降序排列：{counts}'
        )


# ─────────────────────────────────────────────
# 属性 2：1-scan 候选词数量上限
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 2: 1-scan 候选词数量上限
@given(
    top_n=st.integers(min_value=1, max_value=50),
    keywords=st.lists(_alpha_text, min_size=1, max_size=5),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property2_scan_top_n_limit(top_n, keywords):
    """
    对于任意正整数 N，当 --top-n N 时，
    1-scan 返回的 candidates 数组长度不超过 N。
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        scan_dir = tmp_path / 'scan'
        scan_dir.mkdir()

        # 创建多个 .md 文件，尽量产生足够多的候选词
        for i in range(3):
            md = scan_dir / f'doc{i}.md'
            extra = [f'ExtraWord{i}{j}' for j in range(10)]
            _make_md_with_keywords(md, keywords + extra)

        target_file = tmp_path / 'target.md'
        _make_target_file(target_file)

        result = subprocess.run(
            [
                sys.executable,
                _SCRIPT_PATH,
                '--file', str(target_file),
                '--phase', '1-scan',
                '--keywords', *keywords,
                '--scan-dir', str(scan_dir),
                '--top-n', str(top_n),
            ],
            capture_output=True,
            text=True,
            encoding='utf-8',
        )

        # 提取 JSON 行
        stdout_lines = result.stdout.strip().split('\n')
        json_line = next(
            (l.strip() for l in stdout_lines if l.strip().startswith('{')),
            None,
        )
        assert json_line is not None, f'stdout 中未找到 JSON：{result.stdout!r}'

        data = json.loads(json_line)
        candidates = data['candidates']

        assert len(candidates) <= top_n, (
            f'候选词数量 {len(candidates)} 超过 top_n={top_n}'
        )


# ─────────────────────────────────────────────
# 属性 3：1-write 写入 round-trip
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 3: 1-write 写入 round-trip
@given(
    keywords=st.lists(_keyword_text, min_size=1, max_size=20),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property3_write_round_trip(keywords):
    """
    对于任意关键词列表，调用 write_tags_to_file 后，
    再调用 read_tags_from_file 读取，
    读取到的关键词集合 == 写入的关键词集合。
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        target_file = Path(tmp_dir) / 'target.md'
        _make_target_file(target_file)

        # 直接调用函数（不通过 subprocess）
        keyword_tag.write_tags_to_file(str(target_file), keywords)
        read_back = keyword_tag.read_tags_from_file(str(target_file))

        assert set(read_back) == set(keywords), (
            f'读取到的关键词集合 {set(read_back)} != 写入的关键词集合 {set(keywords)}'
        )


# ─────────────────────────────────────────────
# 属性 4：YAML 附录写入幂等性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 4: YAML 附录写入幂等性
@given(
    keywords=st.lists(_keyword_text, min_size=1, max_size=20),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property4_write_idempotent(keywords):
    """
    对于任意关键词列表，对同一文件连续调用 write_tags_to_file 两次，
    文件中有且仅有一个 <!-- spec-tags 块，内容与最后一次写入一致。
    """
    with tempfile.TemporaryDirectory() as tmp_dir:
        target_file = Path(tmp_dir) / 'target.md'
        _make_target_file(target_file)

        # 连续写入两次（相同关键词）
        keyword_tag.write_tags_to_file(str(target_file), keywords)
        keyword_tag.write_tags_to_file(str(target_file), keywords)

        content = target_file.read_text(encoding='utf-8')
        block_count = _count_spec_tags_blocks(content)

        assert block_count == 1, (
            f'文件中 spec-tags 块数量为 {block_count}，期望恰好 1 个'
        )

        # 读取内容应与写入一致
        read_back = keyword_tag.read_tags_from_file(str(target_file))
        assert set(read_back) == set(keywords), (
            f'两次写入后读取到的关键词集合 {set(read_back)} != 写入的关键词集合 {set(keywords)}'
        )


# ─────────────────────────────────────────────
# 属性 5：阶段2标记正确性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 5: 阶段2标记正确性
@given(
    keywords=st.lists(
        st.text(
            min_size=2,
            max_size=6,
            alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Lo')),
        ),
        min_size=1,
        max_size=5,
    ),
    n_relevant=st.integers(min_value=1, max_value=5),
    n_irrelevant=st.integers(min_value=1, max_value=5),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property5_phase2_marking_correctness(keywords, n_relevant, n_irrelevant):
    """
    对于任意关键词列表，phase2 执行后：
    - 副标题链接指向含关键词章节的行应有 ✅ 标记
    - 副标题链接指向不含关键词章节的行不应有 ✅ 标记
    """
    # 确保关键词不为空字符串
    keywords = [k for k in keywords if k.strip()]
    assume(len(keywords) >= 1)

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        overview = _build_overview_with_table(
            tmp_path, keywords, n_relevant, n_irrelevant
        )

        # 执行 phase2
        keyword_tag.phase2(str(overview))

        # 读取执行后的文件内容
        content = overview.read_text(encoding='utf-8')
        lines = content.split('\n')

        # 检查表格数据行
        for line in lines:
            if not keyword_tag.is_table_data_row(line):
                continue

            parts = line.split('|')
            if len(parts) < 3:
                continue

            url = keyword_tag.extract_link_from_cell(parts[2])
            if not url:
                continue

            # 判断链接指向的是相关文件还是无关文件
            fname = url.split('#')[0]
            is_relevant_file = fname.startswith('relevant_')
            has_check = '✅' in line

            if is_relevant_file:
                assert has_check, (
                    f'相关行缺少 ✅ 标记：{line!r}'
                )
            else:
                assert not has_check, (
                    f'无关行不应有 ✅ 标记：{line!r}'
                )


# ─────────────────────────────────────────────
# 属性 6：阶段2执行幂等性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 6: 阶段2执行幂等性
@given(
    keywords=st.lists(
        st.text(
            min_size=2,
            max_size=6,
            alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Lo')),
        ),
        min_size=1,
        max_size=5,
    ),
    n_relevant=st.integers(min_value=0, max_value=4),
    n_irrelevant=st.integers(min_value=0, max_value=4),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property6_phase2_idempotent(keywords, n_relevant, n_irrelevant):
    """
    对于任意目标文件，连续执行 phase2 两次，两次执行后的文件内容完全相同。
    """
    keywords = [k for k in keywords if k.strip()]
    assume(len(keywords) >= 1)
    assume(n_relevant + n_irrelevant >= 1)

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        overview = _build_overview_with_table(
            tmp_path, keywords, n_relevant, n_irrelevant
        )

        # 第一次执行
        keyword_tag.phase2(str(overview))
        content_after_first = overview.read_text(encoding='utf-8')

        # 第二次执行
        keyword_tag.phase2(str(overview))
        content_after_second = overview.read_text(encoding='utf-8')

        assert content_after_first == content_after_second, (
            '两次执行 phase2 后文件内容不同，幂等性验证失败'
        )


# ─────────────────────────────────────────────
# 属性 7：阶段2统计一致性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 7: 阶段2统计一致性
@given(
    n_rows=st.integers(min_value=0, max_value=20),
    keywords=st.lists(
        st.text(
            min_size=2,
            max_size=6,
            alphabet=st.characters(whitelist_categories=('Lu', 'Ll', 'Lo')),
        ),
        min_size=1,
        max_size=5,
    ),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property7_phase2_stats_consistency(n_rows, keywords):
    """
    对于任意目标文件，phase2 输出的「标记行数 + 跳过行数」
    等于文件中表格数据行的总数 R。
    """
    keywords = [k for k in keywords if k.strip()]
    assume(len(keywords) >= 1)

    # 构造 n_rows 行表格（一半相关，一半无关）
    n_relevant = n_rows // 2
    n_irrelevant = n_rows - n_relevant

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        overview = _build_overview_with_table(
            tmp_path, keywords, n_relevant, n_irrelevant
        )

        # 捕获 phase2 的 stdout 输出
        buf = io.StringIO()
        with redirect_stdout(buf):
            keyword_tag.phase2(str(overview))
        output = buf.getvalue()

        # 从输出中解析「标记行数」和「跳过行数」
        # 输出格式：完成：标记 N 行 ✅，跳过 M 行
        match = re.search(r'标记\s+(\d+)\s+行.*?跳过\s+(\d+)\s+行', output)
        assert match is not None, f'无法从输出中解析统计信息：{output!r}'

        marked = int(match.group(1))
        skipped = int(match.group(2))

        assert marked + skipped == n_rows, (
            f'标记行数({marked}) + 跳过行数({skipped}) = {marked + skipped} '
            f'!= 表格数据行总数 {n_rows}'
        )


# ─────────────────────────────────────────────
# 属性 8：扫描目录排除正确性
# ─────────────────────────────────────────────

# Feature: docs-tag-skill, Property 8: 扫描目录排除正确性
@given(
    unique_word=st.text(
        min_size=4,
        max_size=8,
        alphabet=st.characters(whitelist_categories=('Lu', 'Ll')),
    ),
    other_keywords=st.lists(_alpha_text, min_size=1, max_size=3),
)
@settings(max_examples=100, suppress_health_check=[HealthCheck.function_scoped_fixture])
def test_property8_scan_dir_exclusion(unique_word, other_keywords):
    """
    当目标文件所在子目录位于 --scan-dir 下时，
    该子目录中的文件内容不应出现在 1-scan 的候选词中。
    """
    # 确保 unique_word 足够独特（长度 >= 4，不在停用词中）
    assume(len(unique_word) >= 4)

    with tempfile.TemporaryDirectory() as tmp_dir:
        tmp_path = Path(tmp_dir)
        scan_dir = tmp_path / 'scan'
        scan_dir.mkdir()

        # 在 scan_dir 下创建其他文件（包含 other_keywords，用于触发扫描）
        other_md = scan_dir / 'other.md'
        _make_md_with_keywords(other_md, other_keywords)

        # 在 scan_dir/target_subdir/ 下创建目标文件（含 unique_word）
        target_subdir = scan_dir / 'target_subdir'
        target_subdir.mkdir()
        target_file = target_subdir / 'target.md'
        # 目标文件包含 unique_word 和 other_keywords（确保扫描时有匹配章节）
        target_file.write_text(
            f'# 目标章节\n\n{unique_word} ' + ' '.join(other_keywords) + '\n',
            encoding='utf-8',
        )

        # 调用 collect_candidates，以 target_file 为目标文件，scan_dir 为扫描目录
        candidates = keyword_tag.collect_candidates(
            seed_keywords=other_keywords,
            scan_dir=str(scan_dir),
            target_file=str(target_file),
            top_n=100,
        )

        candidate_terms = {term for term, _ in candidates}

        assert unique_word not in candidate_terms, (
            f'候选词中不应包含目标文件子目录中的词 {unique_word!r}，'
            f'但实际候选词为：{candidate_terms}'
        )
