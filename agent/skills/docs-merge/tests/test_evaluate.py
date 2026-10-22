"""Behavior tests for the local, offline evaluation harness."""
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

SKILL = Path(__file__).resolve().parents[1]
SCRIPT = SKILL / 'scripts' / 'evaluate.py'


class HarnessTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory(prefix='docs-merge-test-')
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.fixtures = self.root / 'tests' / 'fixtures'
        self.fixtures.mkdir(parents=True)
        (self.fixtures / 'source.md').write_text('## Payment\n\nNew fact.\n', encoding='utf-8')
        (self.fixtures / 'target.md').write_text('# Guide\n\n## Payment\n\nOld fact.\n', encoding='utf-8')
        self.case = {
            'id': 'test', 'category': 'should-trigger', 'coverage': ['dry-run'],
            'prompt': '/docs-merge source.md target.md --dry-run',
            'expected_output': 'SECRET_EXPECTED_ONLY_FOR_REVIEW',
            'files': [
                {'fixture': 'source.md', 'path': 'source.md', 'role': 'source'},
                {'fixture': 'target.md', 'path': 'target.md', 'role': 'target'}],
            'absent_paths': ['missing.md'],
            'artifact_checks': [
                {'id': 'target-readonly', 'kind': 'unchanged', 'path': 'target.md'},
                {'id': 'missing-stays-missing', 'kind': 'absent', 'path': 'missing.md'}],
            'assertions': [{'id': 'ask-first', 'name': '确认', 'type': 'behavior',
                            'check': 'SECRET_ASSERTION_ONLY_FOR_REVIEW', 'priority': 'P0'}]}
        self.suite = self.root / 'evals' / 'evals.json'
        self.suite.parent.mkdir()
        self.save_suite()

    def save_suite(self):
        self.suite.write_text(json.dumps({'skill_name': 'docs-merge', 'evals': [self.case]}), encoding='utf-8')

    def cli(self, *args, expected=0):
        result = subprocess.run([sys.executable, str(SCRIPT), '--suite', str(self.suite), *args],
                                text=True, capture_output=True)
        self.assertEqual(result.returncode, expected, result.stdout + result.stderr)
        return json.loads(result.stdout)

    def prepare(self):
        destination = self.root / 'run'
        self.cli('prepare', '--case', 'test', '--output', str(destination))
        return destination

    def test_validate_and_prepare_copy_exact_bytes_without_answers(self):
        self.assertEqual(self.cli('validate')['cases'], 1)
        run = self.prepare()
        self.assertEqual((run / 'workspace/source.md').read_bytes(), (self.fixtures / 'source.md').read_bytes())
        request = (run / 'request.md').read_text()
        self.assertIn('/docs-merge source.md target.md --dry-run', request)
        self.assertNotIn('SECRET', request)
        self.assertNotIn('expected_output', request)
        self.assertTrue((run / 'manifest.json').is_file())

    def test_existing_destination_is_rejected_without_mutation(self):
        run = self.prepare()
        original = (run / 'manifest.json').read_bytes()
        self.cli('prepare', '--case', 'test', '--output', str(run), expected=2)
        self.assertEqual(original, (run / 'manifest.json').read_bytes())

    def test_unexecuted_case_is_not_a_pass(self):
        report = self.cli('verify', '--run', str(self.prepare()))
        self.assertEqual(report['status'], 'not_run')
        self.assertEqual(report['behavior']['status'], 'not_run')

    def test_artifact_pass_is_not_behavior_pass(self):
        report = self.cli('verify', '--run', str(self.prepare()), '--executed')
        self.assertEqual(report['artifacts']['status'], 'passed')
        self.assertEqual(report['behavior']['status'], 'not_run')
        self.assertEqual(report['status'], 'not_run')

    def test_source_edit_fails_even_without_custom_readonly_check(self):
        run = self.prepare()
        (run / 'workspace/source.md').write_text('modified', encoding='utf-8')
        report = self.cli('verify', '--run', str(run), '--executed', expected=1)
        self.assertEqual(report['artifacts']['status'], 'failed')

    def test_dry_run_target_edit_and_unexpected_creation_fail(self):
        run = self.prepare()
        (run / 'workspace/target.md').write_text('modified', encoding='utf-8')
        (run / 'workspace/missing.md').write_text('created', encoding='utf-8')
        report = self.cli('verify', '--run', str(run), '--executed', expected=1)
        self.assertGreaterEqual(report['artifacts']['summary']['failed'], 2)

    def test_actual_allowed_diff_can_pass_with_evidence(self):
        self.case['artifact_checks'] = [
            {'id': 'new-fact', 'kind': 'contains', 'path': 'target.md', 'text': 'New fact.'},
            {'id': 'old-fact', 'kind': 'contains', 'path': 'target.md', 'text': 'Old fact.'},
            {'id': 'once', 'kind': 'text_count', 'path': 'target.md', 'text': 'New fact.', 'count': 1}]
        self.save_suite()
        run = self.prepare()
        with (run / 'workspace/target.md').open('a', encoding='utf-8') as handle:
            handle.write('\nNew fact.\n')
        review = self.root / 'review.json'
        review.write_text(json.dumps({'eval_id': 'test', 'assertions': [
            {'id': 'ask-first', 'status': 'passed', 'evidence': 'Transcript turn 2 requests one decision.'}]}))
        report = self.cli('verify', '--run', str(run), '--executed', '--review', str(review))
        self.assertEqual(report['status'], 'passed')
        self.assertEqual(report['behavior']['summary']['passed'], 1)

    def test_missing_review_evidence_is_not_run(self):
        run = self.prepare()
        review = self.root / 'review.json'
        review.write_text(json.dumps({'eval_id': 'test', 'assertions': [{'id': 'ask-first', 'status': 'passed'}]}))
        report = self.cli('verify', '--run', str(run), '--executed', '--review', str(review))
        self.assertEqual(report['status'], 'not_run')

    def test_missing_target_fails_without_traceback(self):
        run = self.prepare()
        (run / 'workspace/target.md').unlink()
        report = self.cli('verify', '--run', str(run), '--executed', expected=1)
        self.assertEqual(report['status'], 'failed')

    def test_parent_and_absolute_fixture_paths_rejected(self):
        for value in ('../outside.md', '/etc/passwd', 'C:\\outside.md'):
            with self.subTest(path=value):
                self.case['files'][0]['fixture'] = value
                self.save_suite()
                self.cli('validate', expected=2)

    def test_workspace_path_escape_rejected_before_preparation(self):
        self.case['files'][0]['path'] = '../outside.md'
        self.save_suite()
        self.cli('prepare', '--case', 'test', '--output', str(self.root / 'bad'), expected=2)
        self.assertFalse((self.root / 'bad').exists())

    def test_symlink_fixture_and_workspace_escape_rejected(self):
        (self.fixtures / 'link.md').symlink_to(self.root / 'outside.md')
        (self.root / 'outside.md').write_text('outside')
        self.case['files'][0]['fixture'] = 'link.md'
        self.save_suite()
        self.cli('validate', expected=2)
        self.case['files'][0]['fixture'] = 'source.md'
        self.save_suite()
        run = self.prepare()
        (run / 'workspace/source.md').unlink()
        (run / 'workspace/source.md').symlink_to(self.root / 'outside.md')
        self.cli('verify', '--run', str(run), '--executed', expected=1)
        self.assertEqual((self.root / 'outside.md').read_text(), 'outside')

    def test_duplicate_case_id_and_missing_fixture_rejected(self):
        payload = {'skill_name': 'docs-merge', 'evals': [self.case, self.case]}
        self.suite.write_text(json.dumps(payload))
        self.cli('validate', expected=2)
        self.case['files'][0]['fixture'] = 'does-not-exist.md'
        self.save_suite()
        self.cli('validate', expected=2)

    def test_unexpected_file_is_an_artifact_failure(self):
        run = self.prepare()
        (run / 'workspace/unrelated.md').write_text('unexpected')
        report = self.cli('verify', '--run', str(run), '--executed', expected=1)
        self.assertEqual(report['status'], 'failed')

    def test_symlinked_output_parent_resolves_to_requested_new_directory(self):
        alias = self.root / 'alias'
        alias.symlink_to(self.root / 'parent', target_is_directory=True)
        (self.root / 'parent').mkdir()
        self.cli('prepare', '--case', 'test', '--output', str(alias / 'new-run'))
        self.assertTrue((self.root / 'parent/new-run/workspace/target.md').is_file())

    def test_fixture_root_symlink_is_rejected(self):
        external = self.root / 'external'
        self.fixtures.rename(external)
        self.fixtures.symlink_to(external, target_is_directory=True)
        self.cli('validate', expected=2)
        self.cli('prepare', '--case', 'test', '--output', str(self.root / 'bad'), expected=2)
        self.assertFalse((self.root / 'bad').exists())

    def test_fixture_parent_symlink_is_rejected(self):
        external = self.root / 'external-tests'
        self.fixtures.parent.rename(external)
        (self.root / 'tests').symlink_to(external, target_is_directory=True)
        self.cli('validate', expected=2)
        self.cli('prepare', '--case', 'test', '--output', str(self.root / 'bad'), expected=2)
        self.assertFalse((self.root / 'bad').exists())

    def test_nonobject_json_inputs_report_format_error(self):
        self.suite.write_text('[]')
        self.cli('validate', expected=2)
        self.save_suite()
        run = self.prepare()
        review = self.root / 'review.json'
        review.write_text('[]')
        self.cli('verify', '--run', str(run), '--executed', '--review', str(review), expected=2)

    def test_malformed_nested_objects_report_format_error(self):
        for field, value in [('files', ['not-a-file']), ('artifact_checks', ['not-a-check']),
                             ('assertions', ['not-an-assertion']), ('files', {})]:
            with self.subTest(field=field, value=value):
                original = self.case[field]
                self.case[field] = value
                self.save_suite()
                self.cli('validate', expected=2)
                self.case[field] = original

    def test_unknown_assertion_review_rejected(self):
        run = self.prepare()
        review = self.root / 'review.json'
        review.write_text(json.dumps({'eval_id': 'test', 'assertions': [{'id': 'unknown', 'status': 'passed', 'evidence': 'x'}]}))
        self.cli('verify', '--run', str(run), '--executed', '--review', str(review), expected=2)

    def set_workspace_paths(self, source, target, absent=None):
        self.case['files'][0]['path'] = source
        self.case['files'][1]['path'] = target
        self.case['absent_paths'] = absent or []
        self.case['artifact_checks'] = [
            {'id': 'target-readonly', 'kind': 'unchanged', 'path': target}]
        self.save_suite()

    def assert_layout_rejected_before_prepare(self):
        self.cli('validate', expected=2)
        destination = self.root / 'invalid-run'
        self.cli('prepare', '--case', 'test', '--output', str(destination), expected=2)
        self.assertFalse(destination.exists())

    def test_casefold_and_unicode_file_aliases_are_rejected(self):
        for source, target in [('Guide.md', 'guide.md'),
                               ('Straße.md', 'STRASSE.md'),
                               ('caf\u00e9.md', 'cafe\u0301.md')]:
            with self.subTest(source=source, target=target):
                self.set_workspace_paths(source, target)
                self.assert_layout_rejected_before_prepare()

    def test_file_and_descendant_collisions_are_rejected_in_both_orders(self):
        for source, target in [('docs', 'docs/target.md'),
                               ('docs/source.md', 'docs'),
                               ('Docs', 'docs/target.md')]:
            with self.subTest(source=source, target=target):
                self.set_workspace_paths(source, target)
                self.assert_layout_rejected_before_prepare()

    def test_shared_directory_aliases_are_rejected(self):
        for source, target in [('Docs/source.md', 'docs/target.md'),
                               ('caf\u00e9/source.md', 'cafe\u0301/target.md')]:
            with self.subTest(source=source, target=target):
                self.set_workspace_paths(source, target)
                self.assert_layout_rejected_before_prepare()

    def test_absent_paths_cannot_name_initial_files_or_directories(self):
        for absent in ['docs', 'DOCS', 'docs/guide.md', 'docs/GUIDE.md']:
            with self.subTest(absent=absent):
                self.set_workspace_paths('source.md', 'docs/guide.md', [absent])
                self.assert_layout_rejected_before_prepare()

    def test_nested_paths_and_sibling_prefix_names_remain_valid(self):
        for index, (source, target) in enumerate([
                ('docs/source.md', 'docs/nested/target.md'),
                ('docs', 'docs-extra/target.md'),
                ('docs/source.md', 'docs/source.md-backup')]):
            with self.subTest(source=source, target=target):
                self.set_workspace_paths(source, target, ['docs-missing', 'uncreated/nested.md'])
                self.assertEqual(self.cli('validate')['cases'], 1)
                destination = self.root / ('valid-run-%s' % index)
                self.cli('prepare', '--case', 'test', '--output', str(destination))
                self.assertEqual((destination / 'workspace' / source).read_bytes(),
                                 (self.fixtures / 'source.md').read_bytes())
                self.assertEqual((destination / 'workspace' / target).read_bytes(),
                                 (self.fixtures / 'target.md').read_bytes())
                report = self.cli('verify', '--run', str(destination), '--executed')
                self.assertEqual(report['artifacts']['status'], 'passed')

    def test_malformed_manifest_reports_format_error(self):
        run = self.prepare()
        path = run / 'manifest.json'
        original = json.loads(path.read_text())
        variants = [
            {'baseline': []},
            {'baseline': {'target.md': []}},
            {'artifact_checks': ['not-a-check']},
            {'case': []},
            {'case': {**original['case'], 'assertions': ['not-an-assertion']}},
        ]
        for variant in variants:
            with self.subTest(variant=variant):
                path.write_text(json.dumps({**original, **variant}))
                self.cli('verify', '--run', str(run), '--executed', expected=2)


if __name__ == '__main__':
    unittest.main()
