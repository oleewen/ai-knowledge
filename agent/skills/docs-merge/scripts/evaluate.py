#!/usr/bin/env python3
"""Prepare isolated docs-merge evaluations and verify artifacts, without running a model."""
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import shutil
import sys
import unicodedata

SKILL_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_SUITE = SKILL_ROOT / 'evals' / 'evals.json'
STATUSES = ('passed', 'failed', 'not_run')
KINDS = ('unchanged', 'absent', 'contains', 'not_contains', 'text_count', 'equals_fixture')


def read_json(path):
    value = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(value, dict):
        raise ValueError('JSON 根必须是对象: %s' % path)
    return value


def dump_json(value, path=None):
    content = json.dumps(value, ensure_ascii=False, indent=2) + '\n'
    if path is None:
        print(content, end='')
    else:
        path.write_text(content, encoding='utf-8')


def relative(value):
    """Accept portable workspace-relative paths; reject traversal and platform aliases."""
    if not isinstance(value, str) or not value or '\\' in value or ':' in value:
        raise ValueError('路径必须是非空、可移植的相对路径: %r' % value)
    parts = value.split('/')
    if any(part in ('', '.', '..') for part in parts) or PurePosixPath(value).is_absolute():
        raise ValueError('路径不得越界: %r' % value)
    return value


def portable_parts(value):
    """Compare path components by Unicode NFC + casefold, independent of the host FS."""
    return tuple(unicodedata.normalize('NFC', part).casefold()
                 for part in relative(value).split('/'))


def validate_layout(paths, absent_paths):
    """Reject aliases and file/directory conflicts before prepare creates anything.

    Prefixes are whole components: docs and docs-old may coexist. Shared directory
    components must retain one spelling; an absent path cannot name a file or an
    implicit parent directory that preparation will create.
    """
    nodes = {}
    for path in sorted(paths):
        parts = path.split('/')
        key = portable_parts(path)
        for depth in range(1, len(parts) + 1):
            prefix = key[:depth]
            spelling = '/'.join(parts[:depth])
            kind = 'file' if depth == len(parts) else 'directory'
            previous = nodes.get(prefix)
            if previous is not None and (previous != (spelling, kind) or kind == 'file'):
                raise ValueError('工作区路径别名或文件/目录冲突: %s 与 %s' % (previous[0], spelling))
            nodes[prefix] = (spelling, kind)
    for path in absent_paths:
        if portable_parts(path) in nodes:
            raise ValueError('absent_paths 与将创建的文件或目录冲突: %s' % path)


def contained(root, value):
    relative(value)
    if root.is_symlink():
        raise ValueError('根目录不得为符号链接: %s' % root)
    candidate = root / value
    for parent in (candidate, *candidate.parents):
        if parent == root:
            break
        if parent.is_symlink():
            raise ValueError('不允许符号链接: %s' % candidate)
    try:
        candidate.resolve().relative_to(root.resolve())
    except ValueError as exc:
        raise ValueError('路径超出边界: %s' % candidate) from exc
    return candidate


def fixtures_root(suite_path):
    return contained(suite_path.parent.parent.resolve(), 'tests/fixtures')


def object_items(value, label):
    if not isinstance(value, list) or any(not isinstance(item, dict) for item in value):
        raise ValueError('%s 必须为对象数组' % label)
    return value


def sha256(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def require_text(value, label):
    if not isinstance(value, str) or not value.strip():
        raise ValueError('%s 必须是非空文本' % label)


def validate_suite(suite_path):
    suite = read_json(suite_path)
    if suite.get('skill_name') != 'docs-merge' or not isinstance(suite.get('evals'), list) or not suite['evals']:
        raise ValueError('评测集必须声明 docs-merge 和非空 evals')
    fixtures = fixtures_root(suite_path)
    seen = set()
    for case in suite['evals']:
        if not isinstance(case, dict) or not isinstance(case.get('id'), (str, int)):
            raise ValueError('每条用例需要字符串或整数 id')
        key = str(case['id'])
        if not key or key in seen:
            raise ValueError('重复或空用例 id: %s' % key)
        seen.add(key)
        if case.get('category') not in ('should-trigger', 'should-not-trigger'):
            raise ValueError('用例 %s 的 category 无效' % key)
        for field in ('prompt', 'expected_output'):
            require_text(case.get(field), field)
        if not isinstance(case.get('files'), list):
            raise ValueError('用例 %s 缺少 files 数组' % key)
        paths = set()
        for item in object_items(case['files'], 'files'):
            path = relative(item['path'])
            if path in paths or item.get('role') not in ('source', 'target', 'support'):
                raise ValueError('重复路径或无效 role: %s' % path)
            paths.add(path)
            fixture = contained(fixtures, item['fixture'])
            if not fixture.is_file():
                raise ValueError('fixture 不存在: %s' % fixture)
        if not isinstance(case.get('absent_paths', []), list):
            raise ValueError('absent_paths 必须为数组')
        validate_layout(paths, case.get('absent_paths', []))
        checks = case.get('artifact_checks')
        assertions = case.get('assertions')
        if not isinstance(checks, list) or not checks or not isinstance(assertions, list) or not assertions:
            raise ValueError('用例 %s 需要 artifact_checks 和 assertions' % key)
        ids = set()
        for check in object_items(checks, 'artifact_checks'):
            require_text(check.get('id'), 'artifact id')
            if check['id'] in ids or check.get('kind') not in KINDS:
                raise ValueError('重复断言或无效 artifact kind')
            ids.add(check['id'])
            path = relative(check['path'])
            if check['kind'] == 'unchanged' and path not in paths:
                raise ValueError('unchanged 必须引用初始文件')
            if check['kind'] in ('contains', 'not_contains', 'text_count'):
                require_text(check.get('text'), 'text')
            if check['kind'] == 'text_count' and (type(check.get('count')) is not int or check['count'] < 0):
                raise ValueError('count 必须为非负整数')
            if check['kind'] == 'equals_fixture' and not contained(fixtures, check['fixture']).is_file():
                raise ValueError('expected fixture 不存在')
        ids = set()
        for assertion in object_items(assertions, 'assertions'):
            require_text(assertion.get('id'), 'assertion id')
            require_text(assertion.get('check'), 'assertion check')
            if assertion['id'] in ids or assertion.get('priority') not in ('P0', 'P1', 'P2'):
                raise ValueError('重复断言或无效 priority')
            ids.add(assertion['id'])
    return suite


def prepare(suite_path, case_id, output):
    suite = validate_suite(suite_path)
    case = next((item for item in suite['evals'] if str(item['id']) == case_id), None)
    if case is None:
        raise ValueError('未知用例: %s' % case_id)
    output = output.absolute()
    if output.exists() or output.is_symlink():
        raise ValueError('准备目录必须尚不存在: %s' % output)
    output = output.parent.resolve() / output.name
    # A run directory must not pollute skill fixtures or replace another run.
    for protected in (SKILL_ROOT, fixtures_root(suite_path)):
        try:
            output.resolve().relative_to(protected.resolve())
        except ValueError:
            continue
        raise ValueError('评测目录必须在技能与评测资产目录之外')
    if not output.parent.is_dir():
        raise ValueError('准备目录的父目录必须是已存在的普通目录')
    fixtures = fixtures_root(suite_path)
    output.mkdir()
    workspace = output / 'workspace'
    workspace.mkdir()
    baseline = {}
    for item in object_items(case['files'], 'files'):
        source = contained(fixtures, item['fixture'])
        target = contained(workspace, item['path'])
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(source, target)
        baseline[item['path']] = {'sha256': sha256(target), 'role': item['role']}
    # Freeze exact expected bytes so later fixture edits cannot change this run's checks.
    checks = []
    for check in case['artifact_checks']:
        frozen = dict(check)
        if check['kind'] == 'equals_fixture':
            frozen['sha256'] = sha256(contained(fixtures, check['fixture']))
        checks.append(frozen)
    manifest = {'eval_id': case['id'], 'suite_sha256': sha256(suite_path),
                'case': case, 'baseline': baseline, 'artifact_checks': checks}
    dump_json(manifest, output / 'manifest.json')
    request = '# docs-merge 评测请求\n\n工作目录：`%s`\n\n%s\n' % (workspace, case['prompt'])
    if case.get('context'):
        request += '\n已有会话事实：\n%s\n' % case['context']
    request += '\n只操作本工作目录；需要用户决策时停下，不自行编造答复。\n'
    (output / 'request.md').write_text(request, encoding='utf-8')
    return {'status': 'not_run', 'eval_id': case['id'], 'workspace': str(workspace),
            'request': str(output / 'request.md'), 'manifest': str(output / 'manifest.json')}


def summarize(items):
    counts = {status: sum(item['status'] == status for item in items) for status in STATUSES}
    status = 'failed' if counts['failed'] else 'not_run' if counts['not_run'] or not items else 'passed'
    return {'status': status, 'summary': counts, 'checks': items}


def artifact_result(workspace, check, baseline, executed):
    result = {'id': check['id'], 'status': 'not_run', 'evidence': '尚未声明执行'}
    if not executed:
        return result
    try:
        path = contained(workspace, check['path'])
        kind = check['kind']
        if kind == 'absent':
            passed = not path.exists()
        elif not path.is_file():
            passed = False
        elif kind == 'unchanged':
            passed = sha256(path) == baseline[check['path']]['sha256']
        elif kind == 'equals_fixture':
            passed = sha256(path) == check['sha256']
        else:
            content = path.read_text(encoding='utf-8')
            count = content.count(check['text'])
            passed = count > 0 if kind == 'contains' else count == 0 if kind == 'not_contains' else count == check['count']
        result.update(status='passed' if passed else 'failed', evidence='%s: %s' % (kind, check['path']))
    except (OSError, ValueError, UnicodeError, KeyError) as exc:
        result.update(status='failed', evidence=str(exc))
    return result


def behavior_result(case, review, executed):
    supplied = {}
    if review is not None:
        if str(review.get('eval_id')) != str(case['id']):
            raise ValueError('review 的 eval_id 与运行不匹配')
        for item in object_items(review.get('assertions', []), 'review assertions'):
            require_text(item.get('id'), 'review assertion id')
            if item.get('id') in supplied or item.get('status') not in STATUSES:
                raise ValueError('review 存在重复 id 或无效 status')
            supplied[item['id']] = item
        known = {item['id'] for item in case['assertions']}
        if set(supplied) - known:
            raise ValueError('review 包含未知 assertion id')
    results = []
    for assertion in case['assertions']:
        item = supplied.get(assertion['id'], {})
        evidence = item.get('evidence', '')
        status = item.get('status', 'not_run') if executed and isinstance(evidence, str) and evidence.strip() else 'not_run'
        results.append({'id': assertion['id'], 'priority': assertion['priority'], 'status': status,
                        'evidence': evidence if status != 'not_run' else '缺少实际执行或逐项证据'})
    return summarize(results)


def verify(run, executed, review_path=None):
    if run.is_symlink() or not run.is_dir():
        raise ValueError('运行目录不存在或为符号链接')
    manifest = read_json(contained(run, 'manifest.json'))
    workspace = contained(run, 'workspace')
    if not workspace.is_dir():
        raise ValueError('workspace 不存在')
    baseline = manifest['baseline']
    if not isinstance(baseline, dict) or any(not isinstance(entry, dict) for entry in baseline.values()):
        raise ValueError('manifest baseline 必须是文件路径到快照对象的映射')
    case = manifest['case']
    if not isinstance(case, dict):
        raise ValueError('manifest case 必须是对象')
    object_items(case['assertions'], 'manifest assertions')
    checks = list(object_items(manifest['artifact_checks'], 'manifest artifact_checks'))
    # Source and support files are always protected, independently of case-specific checks.
    checks.extend({'id': 'readonly:' + path, 'kind': 'unchanged', 'path': path}
                  for path, entry in baseline.items() if entry['role'] != 'target')
    artifact_checks = [artifact_result(workspace, check, baseline, executed) for check in checks]
    inventory = {'id': 'workspace-inventory', 'status': 'not_run', 'evidence': '尚未声明执行'}
    if executed:
        actual = {str(path.relative_to(workspace)) for path in workspace.rglob('*')
                  if not path.is_dir() or path.is_symlink()}
        unexpected = sorted(actual - set(baseline))
        inventory.update(status='failed' if unexpected else 'passed',
                         evidence='未授权新增路径: %s' % unexpected if unexpected else '无新增文件')
    artifact_checks.append(inventory)
    artifacts = summarize(artifact_checks)
    review = read_json(review_path) if review_path else None
    behavior = behavior_result(case, review, executed)
    status = summarize([{'status': artifacts['status']}, {'status': behavior['status']}])['status']
    return {'eval_id': manifest['eval_id'], 'status': status, 'artifacts': artifacts, 'behavior': behavior,
            'note': '文件断言不证明逐项确认、语义落位或冲突决策；行为评分必须引用实际交互证据。'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--suite', type=Path, default=DEFAULT_SUITE, help='evals.json 路径（fixtures 位于技能 tests/fixtures）')
    subparsers = parser.add_subparsers(dest='command', required=True)
    subparsers.add_parser('validate', help='只读校验用例定义与原始 fixtures')
    prepare_parser = subparsers.add_parser('prepare', help='复制用例到全新隔离目录，不执行代理')
    prepare_parser.add_argument('--case', required=True, help='用例 id')
    prepare_parser.add_argument('--output', required=True, type=Path, help='尚不存在的运行目录')
    verify_parser = subparsers.add_parser('verify', help='验证一次运行的产物与独立行为评分')
    verify_parser.add_argument('--run', required=True, type=Path)
    verify_parser.add_argument('--executed', action='store_true', help='仅在实际运行该请求后指定')
    verify_parser.add_argument('--review', type=Path, help='含逐项证据的独立评分 JSON')
    args = parser.parse_args()
    try:
        if args.command == 'validate':
            suite = validate_suite(args.suite)
            result = {'status': 'passed', 'check': 'definitions_only', 'cases': len(suite['evals']),
                      'behavior': {'passed': 0, 'failed': 0, 'not_run': len(suite['evals'])}}
        elif args.command == 'prepare':
            result = prepare(args.suite, args.case, args.output)
        else:
            result = verify(args.run, args.executed, args.review)
        dump_json(result)
        return 1 if result['status'] == 'failed' else 0
    except (OSError, ValueError, UnicodeError, KeyError, TypeError) as exc:
        dump_json({'status': 'failed', 'error': str(exc)})
        return 2


if __name__ == '__main__':
    sys.exit(main())
