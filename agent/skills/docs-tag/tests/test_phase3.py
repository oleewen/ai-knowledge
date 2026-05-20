#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""phase 3 架构摘录单测与集成"""

import os
import subprocess
import sys

import pytest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))

from keyword_tag import (
    EXCERPT_EMPTY_ROW,
    collect_excerpt_rows,
    is_perspective_section_boundary,
    parse_perspective_sections,
    phase3,
    replace_excerpt_table,
    row_has_check_in_subtitle,
)

SCRIPT_PATH = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'keyword_tag.py')

MINI_OVERVIEW = """\
# 测试概览

## 架构摘录

| 架构视角 | 主标题 | 副标题 |
| --- | --- | --- |
| _placeholder_ | | |

## [业务架构](../business/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [业务概述](../business/a.md) | [业务目标](../business/a.md#目标) ✅ | — |
| [业务概述](../business/a.md) | [业务范围](../business/a.md#范围) | — |

---

## [产品架构](../product/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [产品概述](../product/p.md) | [产品定位](../product/p.md#定位) ✅ | — |

## [应用架构](../application/README.md)

| 主标题 | 副标题 | 归档业务知识 |
| --- | --- | --- |
| [应用概述](../application/app.md) | [模块](../application/app.md#模块) ✅ | — |

## 附录

关键词占位
"""


class TestPerspectiveParsing:
    def test_节边界识别(self):
        assert is_perspective_section_boundary('## 附录\n')
        assert is_perspective_section_boundary('---\n')
        assert is_perspective_section_boundary('## [产品架构](x.md)\n')
        assert not is_perspective_section_boundary('| row |\n')

    def test_解析五视角节(self):
        lines = MINI_OVERVIEW.splitlines(keepends=True)
        sections, found = parse_perspective_sections(lines)
        assert '业务架构' in found
        assert '产品架构' in found
        assert '应用架构' in found
        assert len(sections['业务架构']) >= 2

    def test_副标题列含勾才入选(self):
        line = '| [A](a.md) | [B](b.md#x) ✅ | — |\n'
        assert row_has_check_in_subtitle(line)
        line2 = '| [A](a.md) | [B](b.md#x) | — |\n'
        assert not row_has_check_in_subtitle(line2)


class TestExcerptCollection:
    def test_按视角顺序合并(self):
        lines = MINI_OVERVIEW.splitlines(keepends=True)
        rows, counts = collect_excerpt_rows(lines)
        assert len(rows) == 3
        assert counts['业务架构'] == 1
        assert counts['产品架构'] == 1
        assert counts['应用架构'] == 1
        assert '业务架构' in rows[0]
        assert '产品架构' in rows[1]
        assert '应用架构' in rows[2]
        assert '✅' not in ''.join(rows)

    def test_空集占位行(self):
        content = """\
## 架构摘录

| 架构视角 | 主标题 | 副标题 |
| --- | --- | --- |
| old | x | y |

## [业务架构](../b/README.md)

| 主标题 | 副标题 | 第三列 |
| --- | --- | --- |
| [A](a.md) | [B](b.md) | — |

## 附录
"""
        lines = content.splitlines(keepends=True)
        rows, counts = collect_excerpt_rows(lines)
        assert rows == []
        assert sum(counts.values()) == 0
        new_lines = replace_excerpt_table(lines, rows)
        body = ''.join(new_lines)
        assert EXCERPT_EMPTY_ROW in body
        assert '| old |' not in body


class TestPhase3Integration:
    def test_phase3_写回摘录表(self, tmp_path):
        overview = tmp_path / 'overview.md'
        overview.write_text(MINI_OVERVIEW, encoding='utf-8')
        phase3(str(overview))
        text = overview.read_text(encoding='utf-8')
        assert '业务目标' in text
        assert '产品定位' in text
        assert '模块' in text
        assert '业务范围' not in text.split('## 架构摘录')[1].split('## [业务架构]')[0]
        assert EXCERPT_EMPTY_ROW not in text

    def test_phase3_幂等(self, tmp_path):
        overview = tmp_path / 'overview.md'
        overview.write_text(MINI_OVERVIEW, encoding='utf-8')
        phase3(str(overview))
        first = overview.read_text(encoding='utf-8')
        phase3(str(overview))
        second = overview.read_text(encoding='utf-8')
        assert first == second

    def test_phase3_无架构摘录节失败(self, tmp_path):
        overview = tmp_path / 'bad.md'
        overview.write_text('# 无摘录节\n', encoding='utf-8')
        with pytest.raises(SystemExit) as exc:
            phase3(str(overview))
        assert exc.value.code != 0

    def test_cli_phase3(self, tmp_path):
        overview = tmp_path / 'overview.md'
        overview.write_text(MINI_OVERVIEW, encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH, '--file', str(overview), '--phase', '3'],
            capture_output=True, text=True, encoding='utf-8',
        )
        assert result.returncode == 0, result.stderr
        assert '摘录 3 行' in result.stdout

    def test_cli_excerpt_别名(self, tmp_path):
        overview = tmp_path / 'overview.md'
        overview.write_text(MINI_OVERVIEW, encoding='utf-8')
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH, '--file', str(overview), '--phase', 'excerpt'],
            capture_output=True, text=True, encoding='utf-8',
        )
        assert result.returncode == 0, result.stderr
