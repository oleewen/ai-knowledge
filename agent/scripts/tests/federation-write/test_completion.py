import json
import os
from pathlib import Path
import sys
import unittest
from entry_fixture import EntrypointFixture
from federation_write.operations import Plan

class CompletionTests(EntrypointFixture, unittest.TestCase):
    def test_unregister_http_needs_opt_in_and_verified_identity(self):
        # Link solution -> system, where SYS points upward to a solution SLN.
        from fixtures import entity
        p=self.source/'knowledge/application/SLN-A/SLN-A.md'; p.parent.mkdir(parents=True)
        p.write_text(entity('SLN-A','SYS','application','solution').replace('System','Solution').replace('hierarchy: SYS','hierarchy: SLN').replace('application, SYS','application, SLN'))
        r=self.run_link('--link','--target',str(self.target.parent))
        self.assertEqual(r.returncode,0,r.stderr)
        body=self.target/'knowledge/application/SYS-A/SYS-A.md'
        url='https://github.com/test/consumer/blob/main/docs/knowledge/application/SLN-A/SLN-A.md'
        body.write_text(body.read_text()+f'\n上游 [SLN-A]({url})\n')
        r=self.run_link('--unlink','--target',str(self.target.parent))
        self.assertNotEqual(r.returncode,0)
        self.assertIn('--downgrade-http',r.stderr)
        r=self.run_link('--unlink','--target',str(self.target.parent),'--downgrade-http')
        self.assertEqual(r.returncode,0,r.stderr)
        self.assertNotIn(url,body.read_text())
        self.assertIn('上游 SLN-A',body.read_text())

    def test_git_recheck_finds_broken_reverse_registration(self):
        r=self.run_link('--link','--target',str(self.target.parent)); self.assertEqual(r.returncode,0,r.stderr)
        records=[json.loads(p.read_text()) for p in (self.source/'governance/operations').glob('*.yaml')]
        record=next(r for r in records if r['action']=='link')
        (self.target/'knowledge-links.yaml').write_text('links: []\n')
        r=self.run_link('--operation-check',record['id'])
        self.assertNotEqual(r.returncode,0)
        self.assertIn('双边',r.stdout+r.stderr)

    def test_governance_symlink_cannot_redirect_journal(self):
        outside=self.base/'outside'; outside.mkdir()
        (self.source/'governance').symlink_to(outside,target_is_directory=True)
        with self.assertRaisesRegex(ValueError,'操作记录|越界'):
            Plan(self.source,[self.source],'test').execute()
        self.assertEqual(list(outside.iterdir()),[])

    def test_unlink_blocks_live_consumer_and_evidence(self):
        from fixtures import entity
        r=self.run_link('--link','--target',str(self.target.parent)); self.assertEqual(r.returncode,0,r.stderr)
        pd=self.source/'knowledge/product/PD-A.md'; pd.parent.mkdir(parents=True)
        pd.write_text(entity('PD-A','PD','product','solution','- implements_to: PL-A','- uses_to: SYS-A'))
        before=(self.source/'knowledge-links.yaml').read_bytes()
        r=self.run_link('--unlink','--target',str(self.target.parent))
        self.assertNotEqual(r.returncode,0)
        self.assertIn('有效',r.stderr)
        self.assertEqual((self.source/'knowledge-links.yaml').read_bytes(),before)

    def test_reparent_old_owner_cleanup_then_resume(self):
        import subprocess
        from entry_fixture import ENTRY
        first=self.run_link('--link','--target',str(self.target.parent))
        self.assertEqual(first.returncode,0,first.stderr)
        new=self.repo('new-parent','solution')
        subprocess.run(['git','init','-q',str(new.parent)],check=True)
        subprocess.run(['git','-C',str(new.parent),'remote','add','origin','https://github.com/test/new.git'],check=True)
        def from_new(*args):
            return subprocess.run(['/opt/homebrew/bin/bash',str(ENTRY),*args],cwd=new.parent,text=True,capture_output=True)
        moved=from_new('--link','--target',str(self.target.parent))
        self.assertNotEqual(moved.returncode,0)
        record=json.loads(next((new/'governance/operations').glob('*.yaml')).read_text())
        self.assertEqual(record['state'],'pending_validation')
        cleaned=self.run_link('--unlink','--target',str(self.target.parent))
        self.assertEqual(cleaned.returncode,0,cleaned.stderr)
        finished=from_new('--resume',record['id'])
        self.assertEqual(finished.returncode,0,finished.stderr)
        self.assertEqual(json.loads(next((new/'governance/operations').glob('*.yaml')).read_text())['state'],'complete')

    def test_selected_repair_ignores_unrelated_invalid_child(self):
        m=self.module()
        r=self.run_link('--link','--target',str(self.target.parent)); self.assertEqual(r.returncode,0,r.stderr)
        f=self.source/'knowledge-links.yaml'; entries=m.read(f)
        entries.append({'type':'child','repository':'https://example.com/offline.git','path':'${WORK_SPACE}/../../escape','dir':'docs','name':'offline','label':'offline'})
        f.write_text(m.render(entries))
        slot=self.source/'system-slots/system-provider'; slot.unlink()
        repaired=self.run_link('--repair','--target',str(self.target.parent))
        self.assertEqual(repaired.returncode,0,repaired.stderr)
        self.assertEqual(slot.resolve(),self.target)

    def test_selected_repair_ignores_unrelated_missing_fields(self):
        m=self.module()
        r=self.run_link('--link','--target',str(self.target.parent)); self.assertEqual(r.returncode,0,r.stderr)
        f=self.source/'knowledge-links.yaml'; original=f.read_text()
        slot=self.source/'system-slots/system-provider'
        for missing in ('dir','path'):
            with self.subTest(missing=missing):
                e={'type':'child','repository':'https://example.com/offline.git','path':'${WORK_SPACE}/offline','dir':'docs','name':'offline','label':'offline'}
                del e[missing]
                f.write_text(original+m.render([e]).split('links:\n',1)[1])
                slot.unlink()
                repaired=self.run_link('--repair','--target',str(self.target.parent))
                self.assertEqual(repaired.returncode,0,repaired.stderr)
                self.assertEqual(slot.resolve(),self.target)
