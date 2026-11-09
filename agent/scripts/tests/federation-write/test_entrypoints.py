from entry_fixture import EntrypointFixture
import unittest
import json
import subprocess

class EntrypointTests(EntrypointFixture, unittest.TestCase):
    def test_dependency_cli_preview_add_remove(self):
        before=(self.source/'knowledge-links.yaml').read_bytes()
        p=self.run_link('--dependency-add','--target',str(self.target.parent),'--entity-id','SYS-A','--dry-run')
        self.assertEqual(p.returncode,0,p.stderr)
        self.assertEqual((self.source/'knowledge-links.yaml').read_bytes(),before)
        self.assertFalse((self.source/'governance').exists())
        p=self.run_link('--dependency-add','--target',str(self.target.parent),'--entity-id','SYS-A')
        self.assertEqual(p.returncode,0,p.stderr)
        self.assertEqual(self.module().read(self.source/'knowledge-links.yaml')[0]['entity_ids'],['SYS-A'])
        p=self.run_link('--dependency-remove','--target',str(self.target.parent),'--entity-id','SYS-A')
        self.assertEqual(p.returncode,0,p.stderr)

    def test_legacy_link_writes_journal_and_preserves_dependency(self):
        self.add(['SYS-A']).execute()
        other=self.repo('other','system')
        subprocess.run(['git','init','-q',str(other.parent)],check=True)
        subprocess.run(['git','-C',str(other.parent),'remote','add','origin','https://github.com/test/other.git'],check=True)
        p=self.run_link('--link','--target',str(other.parent))
        self.assertEqual(p.returncode,0,p.stderr)
        entries=self.module().read(self.source/'knowledge-links.yaml')
        self.assertTrue(any(e['type']=='dependency' and e['entity_ids']==['SYS-A'] for e in entries))
        records=[json.loads(p.read_text()) for p in (self.source/'governance/operations').glob('*.yaml')]
        self.assertTrue(any(r['action']=='link' and r['state']=='complete' for r in records))
        self.assertTrue((self.source/'system-slots/system-other').is_symlink())

    def test_legacy_check_accepts_dependency_and_stays_readonly(self):
        self.add(['SYS-A']).execute()
        before=(self.source/'knowledge-links.yaml').read_bytes()
        p=self.run_link('--check')
        self.assertEqual(p.returncode,0,p.stderr)
        self.assertEqual((self.source/'knowledge-links.yaml').read_bytes(),before)

    def test_local_meta_origin_survives_legacy_link(self):
        self.module().meta_plan(self.source,str(self.base/'meta'),'${WORK_SPACE}/meta','solution').execute()
        result=self.run_link('--link','--target',str(self.target.parent))
        self.assertEqual(result.returncode,0,result.stderr)
        meta=next(e for e in self.module().read(self.source/'knowledge-links.yaml') if e['type']=='meta')
        self.assertEqual(meta['repository'],str(self.base/'meta'))

    def test_operation_check_cannot_pass_unfinished_writes(self):
        from federation_write.operations import Plan
        from unittest.mock import patch
        p=Plan(self.source,[self.source],'test')
        p.file(self.source/'pending.txt','planned')
        with patch('federation_write.operations.apply_step',side_effect=OSError('stop')):
            with self.assertRaises(OSError): p.execute()
        result=self.run_link('--operation-check',p.record['id'])
        self.assertNotEqual(result.returncode,0)
        self.assertIn('未完成',result.stdout+result.stderr)

if __name__=='__main__': unittest.main()
