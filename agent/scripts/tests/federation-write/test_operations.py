import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

TOOLS = Path(__file__).resolve().parents[2] / 'tools'
sys.path.insert(0, str(TOOLS))


class OperationsFixture:
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.a = self.root / 'a'; self.b = self.root / 'b'
        self.a.mkdir(); self.b.mkdir()

    def engine(self):
        self.assertIsNotNone(importlib.util.find_spec('federation_write'), '缺少联邦写入引擎')
        from federation_write import operations
        return operations

    def plan(self):
        m = self.engine()
        p = m.Plan(self.a, [self.a, self.b], 'test')
        p.file(self.a / 'knowledge-links.yaml', 'one')
        p.file(self.b / 'knowledge-links.yaml', 'two')
        return m, p


class OperationsTests(OperationsFixture, unittest.TestCase):
    def test_preview_is_zero_write(self):
        m, p = self.plan()
        before = list(self.root.rglob('*'))
        p.execute(dry_run=True)
        self.assertEqual(before, list(self.root.rglob('*')))

    def test_atomic_steps_journal_and_permissions(self):
        m, p = self.plan()
        f = self.a / 'knowledge-links.yaml'
        f.write_text('old'); f.chmod(0o600)
        p = m.Plan(self.a, [self.a, self.b], 'test'); p.file(f, 'one')
        result = p.execute()
        self.assertEqual(f.read_text(), 'one')
        self.assertEqual(f.stat().st_mode & 0o777, 0o600)
        self.assertEqual(result['state'], 'complete')
        self.assertEqual(json.loads(Path(result['journal']).read_text())['state'], 'complete')

    def test_changed_baseline_writes_nothing(self):
        m, p = self.plan()
        (self.b/'knowledge-links.yaml').write_text('other')
        with self.assertRaisesRegex(ValueError, '指纹'):
            p.execute()
        self.assertFalse((self.a/'knowledge-links.yaml').exists())

    def test_partial_resume_and_external_edit_protection(self):
        m, p = self.plan()
        real = m.apply_step
        def fail_second(step):
            if step['path'].startswith(str(self.b)):
                raise OSError('disk failure')
            real(step)
        with patch.object(m, 'apply_step', fail_second):
            with self.assertRaises(OSError): p.execute()
        self.assertEqual((self.a/'knowledge-links.yaml').read_text(), 'one')
        with self.assertRaisesRegex(ValueError, '未完成'):
            m.Plan(self.b, [self.b], 'new').execute()
        (self.a/'knowledge-links.yaml').write_text('external')
        with self.assertRaisesRegex(ValueError, '指纹'):
            m.resume(p.journal)
        self.assertFalse((self.b/'knowledge-links.yaml').exists())
        (self.a/'knowledge-links.yaml').write_text('one')
        self.assertEqual(m.resume(p.journal)['state'], 'complete')
        self.assertEqual((self.b/'knowledge-links.yaml').read_text(), 'two')

    def test_crash_after_write_before_checkpoint_is_resumable(self):
        m, p = self.plan()
        real = m.apply_step
        def interrupted(step):
            real(step)
            raise OSError('after write')
        with patch.object(m, 'apply_step', interrupted):
            with self.assertRaises(OSError): p.execute()
        self.assertEqual(m.resume(p.journal)['state'], 'complete')

    def test_initial_journal_failure_prevents_data_write(self):
        m, p = self.plan()
        with patch.object(m, 'save_journal', side_effect=OSError('journal full')):
            with self.assertRaises(OSError): p.execute()
        self.assertFalse((self.a/'knowledge-links.yaml').exists())
        self.assertFalse((self.b/'knowledge-links.yaml').exists())

    def test_symlink_and_removal_resume(self):
        m = self.engine()
        link = self.a/'slot'; link.symlink_to('old')
        p = m.Plan(self.a, [self.a], 'repair'); p.symlink(link, str(self.b))
        p.execute(); self.assertEqual(os.readlink(link), str(self.b))
        p = m.Plan(self.a, [self.a], 'unlink'); p.symlink(link, None)
        p.execute(); self.assertFalse(link.is_symlink())

    def test_regular_slot_and_manifest_symlink_rejected(self):
        m = self.engine()
        f = self.a/'slot'; f.write_text('keep')
        p = m.Plan(self.a, [self.a], 'repair')
        with self.assertRaises(ValueError): p.symlink(f, str(self.b))
        link=self.a/'knowledge-links.yaml'; link.symlink_to(f)
        with self.assertRaises(ValueError): p.file(link, 'overwrite')
        self.assertEqual(f.read_text(), 'keep')

    def test_sorted_cross_process_locks(self):
        m = self.engine()
        with m.Locks([self.b, self.a]):
            code='from federation_write.operations import Locks; import sys\nwith Locks(sys.argv[1:]): pass'
            env={**os.environ,'PYTHONPATH':str(TOOLS),'PYTHONDONTWRITEBYTECODE':'1'}
            run=subprocess.run([sys.executable,'-B','-c',code,str(self.a),str(self.b)],env=env,capture_output=True,text=True)
            self.assertNotEqual(run.returncode,0)
            self.assertIn('锁冲突',run.stderr)
        with m.Locks([self.a,self.b]): pass

    def test_resume_refuses_modified_plan_or_outside_step(self):
        m, p = self.plan()
        with patch.object(m,'apply_step',side_effect=OSError('stop')):
            with self.assertRaises(OSError): p.execute()
        value=json.loads(p.journal.read_text()); value['steps'][0]['path']=str(self.root/'outside')
        p.journal.write_text(json.dumps(value))
        with self.assertRaises(ValueError): m.resume(p.journal)
        self.assertFalse((self.root/'outside').exists())

    def test_markdown_recipe_does_not_store_body(self):
        m = self.engine()
        f=self.a/'entity.md'; f.write_text('secret body [APP-A](https://host/a)')
        p=m.Plan(self.a,[self.a],'unlink')
        p.replace(f, {'[APP-A](https://host/a)':'APP-A'})
        result=p.execute()
        self.assertEqual(f.read_text(),'secret body APP-A')
        self.assertNotIn('secret body',Path(result['journal']).read_text())

if __name__ == '__main__': unittest.main()

class InstallGuardTests(OperationsFixture, unittest.TestCase):
    def test_install_guard_holds_lock_across_child_meta_write(self):
        m=self.engine()
        from federation_write import cli
        self.assertTrue(hasattr(cli,'guard_install'),'安装器缺少跨进程 guard')
        script='from federation_write.operations import Plan; import sys; from pathlib import Path; p=Plan(sys.argv[1],[sys.argv[1]],"meta-upsert"); p.file(Path(sys.argv[1])/"knowledge-links.yaml","meta"); p.execute()'
        env={**os.environ,'PYTHONPATH':str(TOOLS)}
        with patch.dict(os.environ,env):
            result=cli.guard_install(self.a,[sys.executable,'-B','-c',script,str(self.a)])
        self.assertEqual(result,0)
        self.assertEqual((self.a/'knowledge-links.yaml').read_text(),'meta')

    def test_install_guard_blocks_pending_before_child_runs(self):
        m,p=self.plan()
        from federation_write import cli
        self.assertTrue(hasattr(cli,'guard_install'),'安装器缺少跨进程 guard')
        with patch.object(m,'apply_step',side_effect=OSError('failed')):
            with self.assertRaises(OSError): p.execute()
        with self.assertRaisesRegex(ValueError,'未完成'):
            cli.guard_install(self.a,[sys.executable,'-c','raise SystemExit(99)'])

class JournalProtectionTests(OperationsFixture, unittest.TestCase):
    def test_external_journal_edit_is_preserved(self):
        m,p=self.plan(); real=m.apply_step
        def edit_journal(step):
            real(step)
            data=json.loads(p.journal.read_text()); data['operator_note']='keep this'
            p.journal.write_text(json.dumps(data))
        with patch.object(m,'apply_step',edit_journal):
            with self.assertRaisesRegex(ValueError,'日志|操作记录'): p.execute()
        self.assertEqual(json.loads(p.journal.read_text())['operator_note'],'keep this')
        self.assertFalse((self.b/'knowledge-links.yaml').exists())

    def test_forged_complete_state_cannot_bypass_pending(self):
        m,p=self.plan()
        with patch.object(m,'apply_step',side_effect=OSError('failed')):
            with self.assertRaises(OSError): p.execute()
        record=json.loads(p.journal.read_text()); record['state']='complete'
        p.journal.write_text(json.dumps(record))
        next_plan=m.Plan(self.b,[self.b],'other'); next_plan.file(self.b/'knowledge-links.yaml','overwrite')
        with self.assertRaisesRegex(ValueError,'未完成'): next_plan.execute()
        self.assertFalse((self.b/'knowledge-links.yaml').exists())

    def test_journal_ancestor_changed_after_planning_is_rejected(self):
        m,p=self.plan(); outside=self.root/'outside'; outside.mkdir()
        (self.a/'governance').symlink_to(outside,target_is_directory=True)
        with self.assertRaisesRegex(ValueError,'操作记录'): p.execute()
        self.assertFalse((self.a/'knowledge-links.yaml').exists())
        self.assertEqual(list(outside.iterdir()),[])

    def test_initial_journal_without_marker_still_blocks_ordinary_retry(self):
        m,p=self.plan()
        mark=m.Locks.mark
        def interrupted(locks,journal):
            mark(locks,journal)
            raise OSError('crash after registry')
        with patch.object(m.Locks,'mark',interrupted):
            with self.assertRaises(OSError): p.execute()
        for root in (self.a,self.b):
            new=m.Plan(root,[root],'retry'); new.file(root/'knowledge-links.yaml','new')
            with self.assertRaisesRegex(ValueError,'未完成'): new.execute()
        self.assertFalse((self.a/'knowledge-links.yaml').exists())

    def test_validation_checkpoint_failure_keeps_revalidation_state(self):
        m,p=self.plan(); source=self.b/'source.md'; source.write_text('before'); p.observe(source)
        p.record['validation']={'mode':'test'}
        with patch('federation_write.validation.validate_result',return_value={'complete':False}):
            with self.assertRaises(ValueError): p.execute()
        source.write_text('associated change')
        save=m.save_journal; calls=[]
        def fail_once(path,record):
            calls.append(True)
            if len(calls)==1: raise OSError('checkpoint failure')
            save(path,record)
        with patch('federation_write.validation.validate_result',return_value={'complete':True}):
            with patch.object(m,'save_journal',fail_once):
                with self.assertRaises(OSError): m.resume(p.journal)
            self.assertEqual(json.loads(p.journal.read_text())['state'],'pending_validation')
            self.assertEqual(m.resume(p.journal)['state'],'complete')

    def test_preview_detects_pending_without_creating_files(self):
        m,p=self.plan()
        with patch.object(m,'apply_step',side_effect=OSError('failed')):
            with self.assertRaises(OSError): p.execute()
        before=sorted(str(x) for x in self.root.rglob('*'))
        with self.assertRaisesRegex(ValueError,'未完成'):
            m.Plan(self.b,[self.b],'preview').execute(dry_run=True)
        self.assertEqual(before,sorted(str(x) for x in self.root.rglob('*')))
