#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""keyword_tag 单测"""

import subprocess
import sys
import os

# 将 scripts/ 目录加入 Python 路径
sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

import pytest
from keyword_tag import (
    split_sections,
    extract_terms,
    get_section_content,
    resolve_link,
    is_table_data_row,
    extract_link_from_cell,
    add_check_mark,
    strip_check_mark,
)

SCRIPT_PATH = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'keyword_tag.py')


# ─────────────────────────────────────────────
# split_sections
# ─────────────────────────────────────────────

class TestSplitSections:
    def test_空字符串返回单个空节(self):
        # split_sections('') 的实际行为：返回一个 ('', '') 的节，而非空列表
        result = split_sections('')
        assert len(result) == 1
        heading, body = result[0]
        assert heading == ''
        assert body == ''

    def test_只有标题无正文(self):
        content = '# 标题一'
        result = split_sections(content)
        assert len(result) == 1
        heading, body = result[0]
        assert heading == '标题一'
        assert body == ''

    def test_多级标题嵌套(self):
        content = '# 一级标题\n一级正文\n## 二级标题\n二级正文'
        result = split_sections(content)
        assert len(result) == 2
        assert result[0][0] == '一级标题'
        assert '一级正文' in result[0][1]
        assert result[1][0] == '二级标题'
        assert '二级正文' in result[1][1]

    def test_无标题纯正文(self):
        content = '这是一段没有标题的正文内容'
        result = split_sections(content)
        assert len(result) == 1
        heading, body = result[0]
        assert heading == ''
        assert '这是一段没有标题的正文内容' in body


# ─────────────────────────────────────────────
# extract_terms
# ─────────────────────────────────────────────

class TestExtractTerms:
    def test_纯中文_2字边界(self):
        terms = extract_terms('计费')
        assert '计费' in terms

    def test_纯中文_8字边界(self):
        terms = extract_terms('费用类型定义规则')  # 8字
        assert '费用类型定义规则' in terms

    def test_纯英文_驼峰词(self):
        terms = extract_terms('PolicyType')
        assert 'PolicyType' in terms

    def test_纯英文_全大写缩写(self):
        terms = extract_terms('API')
        assert 'API' in terms

    def test_混合文本(self):
        terms = extract_terms('计费PolicyType费用')
        assert '计费' in terms
        assert 'PolicyType' in terms
        assert '费用' in terms

    def test_特殊字符不被提取(self):
        terms = extract_terms('!@#$%^&*()')
        assert terms == []

    def test_1字中文不被提取(self):
        terms = extract_terms('费')
        assert '费' not in terms

    def test_9字中文不被提取_超出8字上限(self):
        terms = extract_terms('费用类型定义规则集')  # 9字
        assert '费用类型定义规则集' not in terms


# ─────────────────────────────────────────────
# get_section_content
# ─────────────────────────────────────────────

class TestGetSectionContent:
    def test_文件不存在返回空字符串(self):
        result = get_section_content('/不存在的路径/文件.md', '')
        assert result == ''

    def test_无锚点返回全文(self, tmp_path):
        f = tmp_path / 'doc.md'
        f.write_text('# 标题\n正文内容', encoding='utf-8')
        result = get_section_content(str(f), '')
        assert '标题' in result
        assert '正文内容' in result

    def test_markdown锚点匹配_github规则删除全角括号(self, tmp_path):
        # GitHub 规则：全角括号删除，空格转 -
        f = tmp_path / 'doc.md'
        f.write_text('# 计费（规则）\n计费正文内容\n# 其他章节\n其他内容', encoding='utf-8')
        # 全角括号被删除后锚点为 "计费规则"
        result = get_section_content(str(f), '计费规则')
        assert '计费正文内容' in result
        assert '其他内容' not in result

    def test_html锚点匹配(self, tmp_path):
        f = tmp_path / 'doc.md'
        f.write_text(
            '<a id="billing-section"></a>\n计费章节内容\n# 其他\n其他内容',
            encoding='utf-8'
        )
        result = get_section_content(str(f), 'billing-section')
        assert '计费章节内容' in result
        assert '其他内容' not in result

    def test_锚点不存在返回空字符串(self, tmp_path):
        f = tmp_path / 'doc.md'
        f.write_text('# 存在的章节\n内容', encoding='utf-8')
        result = get_section_content(str(f), '不存在的锚点')
        assert result == ''


# ─────────────────────────────────────────────
# resolve_link
# ─────────────────────────────────────────────

class TestResolveLink:
    def test_带锚点的相对路径(self):
        abs_path, anchor = resolve_link('subdir/doc.md#section', '/base/dir')
        assert anchor == 'section'
        assert abs_path.endswith(os.path.join('subdir', 'doc.md'))

    def test_无锚点的相对路径(self):
        abs_path, anchor = resolve_link('subdir/doc.md', '/base/dir')
        assert anchor == ''
        assert abs_path.endswith(os.path.join('subdir', 'doc.md'))

    def test_上级目录路径(self):
        abs_path, anchor = resolve_link('../other/doc.md#anchor', '/base/dir')
        assert anchor == 'anchor'
        # 路径应解析到上级目录
        assert 'other' in abs_path
        assert 'doc.md' in abs_path


# ─────────────────────────────────────────────
# is_table_data_row
# ─────────────────────────────────────────────

class TestIsTableDataRow:
    def test_表头行返回False(self):
        assert is_table_data_row('| 主标题 | 副标题 | 说明 |') is False

    def test_分隔行返回False(self):
        assert is_table_data_row('| --- | --- | --- |') is False

    def test_数据行返回True(self):
        assert is_table_data_row('| 内容 | [链接](url) | 说明 |') is True

    def test_非表格行返回False(self):
        assert is_table_data_row('这是普通文本行') is False


# ─────────────────────────────────────────────
# extract_link_from_cell
# ─────────────────────────────────────────────

class TestExtractLinkFromCell:
    def test_含markdown链接的单元格(self):
        result = extract_link_from_cell(' [文档标题](docs/file.md#section) ')
        assert result == 'docs/file.md#section'

    def test_不含链接的单元格返回None(self):
        result = extract_link_from_cell(' 普通文本内容 ')
        assert result is None

    def test_含多个链接返回第一个(self):
        result = extract_link_from_cell(' [第一](url1) [第二](url2) ')
        assert result == 'url1'


# ─────────────────────────────────────────────
# add_check_mark / strip_check_mark
# ─────────────────────────────────────────────

class TestCheckMark:
    def test_无标记行_add_check_mark追加标记(self):
        line = '| 主标题 | [副标题](doc.md) | 说明 |'
        result = add_check_mark(line)
        assert '✅' in result

    def test_已有标记行_strip_check_mark移除标记(self):
        line = '| 主标题 | [副标题](doc.md) ✅ | 说明 |'
        result = strip_check_mark(line)
        assert '✅' not in result

    def test_strip后再add结果幂等_只有一个标记(self):
        line = '| 主标题 | [副标题](doc.md) ✅ | 说明 |'
        stripped = strip_check_mark(line)
        added = add_check_mark(stripped)
        assert added.count('✅') == 1


# ─────────────────────────────────────────────
# 错误处理路径（subprocess 调用脚本验证退出码）
# ─────────────────────────────────────────────

class TestErrorHandling:
    def test_file不存在_非零退出(self, tmp_path):
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(tmp_path / '不存在.md'),
             '--phase', '2'],
            capture_output=True
        )
        assert result.returncode != 0

    def test_phase_1scan_缺keywords_非零退出(self, tmp_path):
        f = tmp_path / 'test.md'
        f.write_text('# 测试', encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(f),
             '--phase', '1-scan'],
            capture_output=True
        )
        assert result.returncode != 0

    def test_phase_1write_缺selected_非零退出(self, tmp_path):
        f = tmp_path / 'test.md'
        f.write_text('# 测试', encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(f),
             '--phase', '1-write',
             '--keywords', '计费'],
            capture_output=True
        )
        assert result.returncode != 0

    def test_top_n为0_非零退出(self, tmp_path):
        f = tmp_path / 'test.md'
        f.write_text('# 测试', encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(f),
             '--phase', '1-scan',
             '--keywords', '计费',
             '--top-n', '0'],
            capture_output=True
        )
        assert result.returncode != 0

    def test_scan_dir不存在_非零退出(self, tmp_path):
        f = tmp_path / 'test.md'
        f.write_text('# 测试', encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(f),
             '--phase', '1-scan',
             '--keywords', '计费',
             '--scan-dir', str(tmp_path / '不存在目录')],
            capture_output=True
        )
        assert result.returncode != 0
