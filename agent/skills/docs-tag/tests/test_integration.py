#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
集成测试：docs-tag-skill 完整工作流链路验证
"""
import json
import os
import subprocess
import sys
from pathlib import Path

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'scripts'))
import keyword_tag

SCRIPT_PATH = os.path.join(os.path.dirname(__file__), '..', 'scripts', 'keyword_tag.py')

class TestIntegrationWorkflow:
    def test_完整链路_1scan_1write_phase2(self, tmp_path):
        """验证 1-scan → 1-write → phase 2 完整链路"""
        # 1. 创建扫描目录和文档
        scan_dir = tmp_path / 'scan'
        scan_dir.mkdir()
        (scan_dir / 'billing.md').write_text(
            '# 计费规则\n\n计费类型包括费用类型和结算模式。\n\n## 费用类型\n\n按次计费和按量计费。\n',
            encoding='utf-8'
        )
        
        # 2. 创建目标文件（含表格，链接指向 scan_dir 中的文件）
        target_dir = tmp_path / 'overview'
        target_dir.mkdir()
        target_file = target_dir / 'overview.md'
        target_file.write_text(
            '# 概览\n\n| 主标题 | 副标题 |\n| --- | --- |\n'
            '| 计费 | [计费规则](../scan/billing.md#计费规则) |\n'
            '| 其他 | [其他内容](../scan/billing.md#不存在章节) |\n',
            encoding='utf-8'
        )
        
        # 3. 执行 1-scan
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '1-scan',
             '--keywords', '计费',
             '--scan-dir', str(scan_dir),
             '--top-n', '10'],
            capture_output=True, text=True, encoding='utf-8'
        )
        assert result.returncode == 0, f'1-scan 失败：{result.stderr}'
        
        # 解析候选词 JSON
        json_line = next((l.strip() for l in result.stdout.split('\n') if l.strip().startswith('{')), None)
        assert json_line is not None
        data = json.loads(json_line)
        assert 'candidates' in data
        
        # 4. 执行 1-write（选择所有候选词）
        selected = ','.join(item['term'] for item in data['candidates'][:3]) or '费用类型'
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '1-write',
             '--keywords', '计费',
             '--selected', selected],
            capture_output=True, text=True, encoding='utf-8'
        )
        assert result.returncode == 0, f'1-write 失败：{result.stderr}'
        
        # 验证关键词附录已写入（新格式 ## 附录 / ```yaml，或旧格式 <!-- spec-tags）
        content = target_file.read_text(encoding='utf-8')
        assert '### 文档关键词' in content or '<!-- spec-tags' in content
        assert '计费' in content
        
        # 5. 执行 phase 2
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '2'],
            capture_output=True, text=True, encoding='utf-8'
        )
        assert result.returncode == 0, f'phase 2 失败：{result.stderr}'
        assert '标记' in result.stdout
        
        # 验证目标文件被修改（至少有一行被标记）
        final_content = target_file.read_text(encoding='utf-8')
        assert '✅' in final_content

    def test_phase2_向后兼容_已有YAML附录(self, tmp_path):
        """验证 --phase 2 在已有 YAML 附录的文件上可正常执行"""
        # 创建含 YAML 附录的目标文件
        target_file = tmp_path / 'target.md'
        target_file.write_text(
            '# 概览\n\n| 主标题 | 副标题 |\n| --- | --- |\n| 内容 | 无链接行 |\n'
            '\n---\n\n<!-- spec-tags\nkeywords:\n  - 计费\n-->\n',
            encoding='utf-8'
        )
        
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '2'],
            capture_output=True, text=True, encoding='utf-8'
        )
        assert result.returncode == 0, f'phase 2 失败：{result.stderr}'

    def test_1scan_非终端环境不挂起(self, tmp_path):
        """验证 1-scan 在非终端环境（subprocess）下不挂起"""
        scan_dir = tmp_path / 'scan'
        scan_dir.mkdir()
        (scan_dir / 'doc.md').write_text('# 测试\n\n计费内容\n', encoding='utf-8')
        
        target_file = tmp_path / 'target.md'
        target_file.write_text('# 目标\n', encoding='utf-8')
        
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '1-scan',
             '--keywords', '计费',
             '--scan-dir', str(scan_dir),
             '--top-n', '5'],
            capture_output=True, text=True, encoding='utf-8',
            timeout=10  # 10秒超时，确保不挂起
        )
        assert result.returncode == 0, f'1-scan 超时或失败：{result.stderr}'

    def test_1write_非终端环境不挂起(self, tmp_path):
        """验证 1-write 在非终端环境（subprocess）下不挂起"""
        target_file = tmp_path / 'target.md'
        target_file.write_text('# 目标\n', encoding='utf-8')
        
        result = subprocess.run(
            [sys.executable, SCRIPT_PATH,
             '--file', str(target_file),
             '--phase', '1-write',
             '--keywords', '计费',
             '--selected', '费用类型,结算模式'],
            capture_output=True, text=True, encoding='utf-8',
            timeout=10
        )
        assert result.returncode == 0, f'1-write 超时或失败：{result.stderr}'
