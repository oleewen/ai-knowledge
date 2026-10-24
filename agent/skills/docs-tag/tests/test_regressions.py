"""执行边界与内容保留回归；所有写入仅发生在临时目录。"""

import json
import subprocess
import sys
from pathlib import Path

import pytest
import yaml

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'scripts'))
import keyword_tag

SCRIPT = Path(keyword_tag.__file__)


def run_cli(target, *args):
    return subprocess.run(
        [sys.executable, str(SCRIPT), '--file', str(target), *args],
        input='', capture_output=True, text=True, timeout=10,
    )


def test_scan_stdout_is_json_and_target_is_unchanged(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n', encoding='utf-8')
    (tmp_path / 'source.md').write_text('# Billing\n计费 Invoice\n', encoding='utf-8')
    before = target.read_bytes()
    result = run_cli(target, '--phase', '1-scan', '--keywords', '计费',
                     '--scan-dir', str(tmp_path))
    assert result.returncode == 0, result.stderr
    assert {'term': 'Invoice', 'count': 1} in json.loads(result.stdout)['candidates']
    assert target.read_bytes() == before


def test_installed_docs_layout_scans_its_own_knowledge(tmp_path):
    knowledge = tmp_path / 'project' / 'docs' / 'knowledge'
    target = knowledge / 'overview' / 'billing-overview.md'
    target.parent.mkdir(parents=True)
    target.write_text('# Overview\n', encoding='utf-8')
    (knowledge / 'source.md').write_text('# Billing\n计费 Invoice\n', encoding='utf-8')
    result = run_cli(target, '--phase', '1-scan', '--keywords', '计费')
    assert result.returncode == 0, result.stderr
    assert 'Invoice' in result.stdout


def test_unknown_layout_requires_scan_dir():
    with pytest.raises(ValueError, match='scan-dir'):
        keyword_tag.resolve_scan_dir(None, '/project/arbitrary.md')


def test_scan_excludes_only_target_subtree_and_target_file(tmp_path):
    target = tmp_path / 'overview' / 'target.md'
    target.parent.mkdir()
    target.write_text('# Target\n计费 TargetNoise\n', encoding='utf-8')
    other = tmp_path / 'business' / 'overview' / 'source.md'
    other.parent.mkdir(parents=True)
    other.write_text('# Source\n计费 Invoice\n', encoding='utf-8')
    matched = '\n'.join(keyword_tag.find_relevant_sections(['计费'], str(tmp_path), str(target)))
    assert 'Invoice' in matched
    assert 'TargetNoise' not in matched
    root_target = tmp_path / 'root.md'
    root_target.write_text('# Root\n计费 RootNoise\n', encoding='utf-8')
    matched = '\n'.join(keyword_tag.find_relevant_sections(['计费'], str(tmp_path), str(root_target)))
    assert 'RootNoise' not in matched
    assert 'Invoice' in matched


def test_unreadable_scan_document_fails_visibly(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n', encoding='utf-8')
    (tmp_path / 'broken.md').write_bytes(b'\xff')
    result = run_cli(target, '--phase', '1-scan', '--keywords', '计费',
                     '--scan-dir', str(tmp_path))
    assert result.returncode != 0
    assert 'broken.md' in result.stderr


@pytest.mark.parametrize('candidate_text', ['计费 Invoice', '无匹配'])
def test_all_stops_when_selection_is_cancelled_or_empty(tmp_path, monkeypatch, candidate_text):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n', encoding='utf-8')
    (tmp_path / 'source.md').write_text(candidate_text, encoding='utf-8')
    keyword_tag.write_tags_to_file(str(target), ['旧词'])
    before = target.read_bytes()
    monkeypatch.setattr(sys, 'argv', [str(SCRIPT), '--file', str(target), '--phase', 'all',
                                   '--keywords', '计费', '--scan-dir', str(tmp_path)])
    monkeypatch.setattr('builtins.input', lambda _: 'q')
    keyword_tag.main()
    assert target.read_bytes() == before


def test_phase2_preserves_other_columns_and_excerpt(tmp_path):
    (tmp_path / 'source.md').write_text('计费', encoding='utf-8')
    target = tmp_path / 'target.md'
    excerpt = ('## 架构摘录\n\n| 架构视角 | 主标题 | 副标题 |\n'
               '| --- | --- | --- |\n| 业务架构 | [主标题](source.md) | [副标题](source.md) |\n\n')
    target.write_text(excerpt + '## [业务架构](source.md)\n\n'
                      '| 主标题 | 副标题 | 知识 |\n| --- | --- | --- |\n'
                      '| 主✅ | [副](source.md) | 已验收 ✅ |\n', encoding='utf-8')
    keyword_tag.write_tags_to_file(str(target), ['计费'])
    keyword_tag.phase2(str(target))
    after = target.read_text(encoding='utf-8')
    assert after.startswith(excerpt)
    assert '| 主✅ | [副](source.md) ✅ | 已验收 ✅ |' in after


def test_phase3_preserves_notes_after_table(tmp_path):
    target = tmp_path / 'target.md'
    tail = '\n> 人工维护说明\n\n### 使用提示\n请保留这段。\n\n## 附录\n其他附录\n'
    target.write_text('## 架构摘录\n\n| 架构视角 | 主标题 | 副标题 |\n'
                      '| --- | --- | --- |\n| 旧 | 旧 | 旧 |\n' + tail, encoding='utf-8')
    keyword_tag.phase3(str(target))
    assert target.read_text(encoding='utf-8').endswith(tail)


def test_keyword_refresh_preserves_other_appendix_sections(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n\n## 附录\n\n### 备注\n保留备注\n\n'
                      '### 文档关键词\n\n```yaml\nkeywords:\n- 旧词\n```\n\n'
                      '### 来源\n保留来源\n', encoding='utf-8')
    keyword_tag.write_tags_to_file(str(target), ['新词'])
    once = target.read_bytes()
    keyword_tag.write_tags_to_file(str(target), ['新词'])
    assert target.read_bytes() == once
    text = target.read_text(encoding='utf-8')
    assert text.count('## 附录\n') == 1
    assert '保留备注' in text and '保留来源' in text and '旧词' not in text
    assert keyword_tag.read_tags_from_file(str(target)) == ['新词']


def test_legacy_tag_block_migrates_without_separator(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n<!-- spec-tags\nkeywords:\n  - 旧词\n-->\n', encoding='utf-8')
    keyword_tag.write_tags_to_file(str(target), ['新词'])
    assert '<!-- spec-tags' not in target.read_text(encoding='utf-8')
    assert keyword_tag.read_tags_from_file(str(target)) == ['新词']


def test_keyword_yaml_preserves_string_values(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n', encoding='utf-8')
    keywords = ['yes', 'null', '42', 'a: b', '#tag', '[Invoice]', 'quote"word']
    keyword_tag.write_tags_to_file(str(target), keywords)
    body = target.read_text(encoding='utf-8').split('```yaml\n')[1].split('```')[0]
    assert yaml.safe_load(body) == {'keywords': keywords}
    assert keyword_tag.read_tags_from_file(str(target)) == keywords


def test_blank_selection_rejected_without_mutation(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n', encoding='utf-8')
    before = target.read_bytes()
    result = run_cli(target, '--phase', '1-write', '--keywords', '计费', '--selected', ', ,')
    assert result.returncode != 0
    assert target.read_bytes() == before


@pytest.mark.parametrize('keywords', [['旧词'], []])
def test_keyword_block_allows_blank_lines_before_closing_fence(tmp_path, keywords):
    target = tmp_path / 'target.md'
    items = ''.join('- ' + word + '\n' for word in keywords)
    target.write_text('# Overview\n\n## 附录\n\n### 文档关键词\n\n'
                      '```yaml\nkeywords:\n' + items + '\n```\n', encoding='utf-8')
    assert keyword_tag.read_tags_from_file(str(target)) == keywords
    keyword_tag.write_tags_to_file(str(target), keywords)
    once = target.read_bytes()
    keyword_tag.write_tags_to_file(str(target), keywords)
    assert target.read_bytes() == once
    assert target.read_text(encoding='utf-8').count('### 文档关键词') == 1


def test_legacy_literal_starting_with_quote_remains_readable(tmp_path):
    target = tmp_path / 'target.md'
    target.write_text('# Overview\n\n## 附录\n\n### 文档关键词\n\n'
                      '```yaml\nkeywords:\n- "API"模式\n```\n', encoding='utf-8')
    assert keyword_tag.read_tags_from_file(str(target)) == ['"API"模式']


def test_html_anchor_before_heading_keeps_relevant_checkmark(tmp_path):
    (tmp_path / 'section.md').write_text(
        '<a id="billing"></a>\n\n## 计费\n计费正文\n### 子节\n明细\n## 其他\n其他正文\n',
        encoding='utf-8')
    target = tmp_path / 'overview.md'
    target.write_text('| 主标题 | 副标题 | 知识 |\n| --- | --- | --- |\n'
                      '| 业务 | [计费](section.md#billing) ✅ | 保留 |\n\n'
                      '## 附录\n### 文档关键词\n```yaml\nkeywords:\n- 计费\n```\n',
                      encoding='utf-8')
    result = run_cli(target, '--phase', '2')
    assert result.returncode == 0, result.stderr
    assert '[计费](section.md#billing) ✅' in target.read_text(encoding='utf-8')
    section = keyword_tag.get_section_content(str(tmp_path / 'section.md'), 'billing')
    assert '明细' in section and '其他正文' not in section


def test_yaml_single_quoted_keywords_decode_and_match(tmp_path):
    target = tmp_path / 'overview.md'
    target.write_text('| 主标题 | 副标题 | 知识 |\n| --- | --- | --- |\n'
                      '| 业务 | [计费](section.md) ✅ | 保留 |\n\n'
                      '## 附录\n### 文档关键词\n```yaml\nkeywords:\n'
                      "- '计费'\n- 'user''s' # 合法注释\n```\n", encoding='utf-8')
    (tmp_path / 'section.md').write_text('计费正文', encoding='utf-8')
    assert keyword_tag.read_tags_from_file(str(target)) == ['计费', "user's"]
    result = run_cli(target, '--phase', '2')
    assert result.returncode == 0, result.stderr
    assert '[计费](section.md) ✅' in target.read_text(encoding='utf-8')


def test_unclosed_single_quote_fails_before_mark_changes(tmp_path):
    target = tmp_path / 'overview.md'
    target.write_text('| 主标题 | 副标题 |\n| --- | --- |\n| 业务 | ✅ |\n\n'
                      "## 附录\n### 文档关键词\n```yaml\nkeywords:\n- '计费\n```\n",
                      encoding='utf-8')
    before = target.read_bytes()
    assert run_cli(target, '--phase', '2').returncode != 0
    assert target.read_bytes() == before


def test_excerpt_ignores_other_tables_in_perspective(tmp_path):
    target = tmp_path / 'overview.md'
    target.write_text('## 架构摘录\n| 架构视角 | 主标题 | 副标题 |\n| --- | --- | --- |\n\n'
                      '## [业务架构](business.md)\n| 主标题 | 副标题 | 知识 |\n'
                      '| --- | --- | --- |\n| 业务 | [计费](billing.md) ✅ | 事实 |\n\n'
                      '| 检查项 | 状态 | 备注 |\n| --- | --- | --- |\n'
                      '| 链接校验 | ✅ | 完成 |\n', encoding='utf-8')
    result = run_cli(target, '--phase', '3')
    assert result.returncode == 0, result.stderr
    excerpt = target.read_text(encoding='utf-8').split('## [业务架构]')[0]
    assert '[计费](billing.md)' in excerpt
    assert '链接校验' not in excerpt


def test_noninteractive_full_chain_preserves_generated_excerpt_on_retag(tmp_path):
    knowledge = tmp_path / 'docs' / 'knowledge'
    target = knowledge / 'overview' / 'billing-overview.md'
    target.parent.mkdir(parents=True)
    (knowledge / 'source.md').write_text('# 规则\n计费 Invoice\n', encoding='utf-8')
    target.write_text('## 架构摘录\n\n| 架构视角 | 主标题 | 副标题 |\n'
                      '| --- | --- | --- |\n| 旧 | 旧 | 旧 |\n\n> 保留说明\n\n'
                      '## [业务架构](../source.md)\n\n'
                      '| 主标题 | 副标题 | 知识 |\n| --- | --- | --- |\n'
                      '| [Billing](../source.md) | [规则](../source.md#规则) | 已复核 ✅ |\n',
                      encoding='utf-8')
    scan = run_cli(target, '--phase', '1-scan', '--keywords', '计费')
    assert scan.returncode == 0, scan.stderr
    assert {'term': 'Invoice', 'count': 1} in json.loads(scan.stdout)['candidates']
    write = run_cli(target, '--phase', '1-write', '--keywords', '计费', '--selected', 'Invoice')
    assert write.returncode == 0, write.stderr
    for phase in ('2', '3'):
        result = run_cli(target, '--phase', phase)
        assert result.returncode == 0, result.stderr
    after = target.read_text(encoding='utf-8')
    assert '| 业务架构 | [Billing](../source.md) | [规则](../source.md#规则) |' in after
    assert '| [Billing](../source.md) | [规则](../source.md#规则) ✅ | 已复核 ✅ |' in after
    assert '> 保留说明' in after
    assert keyword_tag.read_tags_from_file(str(target)) == ['计费', 'Invoice']
    retag = run_cli(target, '--phase', '2')
    assert retag.returncode == 0, retag.stderr
    assert target.read_text(encoding='utf-8') == after
