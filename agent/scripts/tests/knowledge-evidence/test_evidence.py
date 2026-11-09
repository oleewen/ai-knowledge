import importlib
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

TOOLS=Path(__file__).resolve().parents[2]/'tools'
sys.path.insert(0,str(TOOLS))
sys.path.insert(0,str(Path(__file__).resolve().parents[1]/'federation-write'))
from fixtures import ManifestFixture

class EvidenceTests(ManifestFixture,unittest.TestCase):
    def evidence(self):
        return importlib.import_module('knowledge_validation.evidence')

    def payload(self):
        e=self.evidence()
        self.origin=self.source/'knowledge/fact.md'; self.origin.parent.mkdir(exist_ok=True)
        self.origin.write_bytes(b'raw source\r\n')
        self.destination=self.source/'knowledge/target.md'; self.destination.write_text('target')
        return {'id':'EVID-000001','target_identity':'consumer:docs/knowledge/target.md','target_path':'docs/knowledge/target.md',
          'target_sha256':e.file_hash(self.destination),'buffer':'无','previous':'无',
          'review_status':'已核验','reviewer':{'name':'tester','at':'2026-11-07T12:00:00+08:00'},
          'conclusion':'人工核验支持目标事实','processing':'已落盘','sources':[{
            'identity':'consumer:docs/knowledge/fact.md','repository':{'path':'${WORK_SPACE}/consumer','dir':'docs'},
            'path':'docs/knowledge/fact.md','sha256':e.file_hash(self.origin),'commit':'未验证',
            'captured_at':'2026-11-07T11:00:00+08:00','recoverability':'当前原件可读但无持久版本保证',
            'dependency':'有效','release_basis':'无'}]}

    def test_round_trip_and_raw_hash(self):
        e=self.evidence(); data=self.payload()
        self.assertEqual(e.parse(e.render(data),data['id']),data)
        result=e.audit(data,self.source)
        self.assertEqual(result['status'],'PASS',result)
        self.assertEqual(result['sources'][0]['recovery_status'],'UNVERIFIED')

    def test_duplicate_missing_and_invalid_states_rejected(self):
        e=self.evidence(); data=self.payload(); text=e.render(data)
        with self.assertRaises(ValueError): e.parse(text+'\n| 核验状态 | 已核验 |\n',data['id'])
        data['sources'][0]['dependency']='已解除'; data['sources'][0]['release_basis']='无'
        with self.assertRaises(ValueError): e.render(data)
        data['sources'][0]['release_basis']='复核人 tester 已撤回目标事实'
        data['reviewer']={'name':'','at':''}
        with self.assertRaises(ValueError): e.render(data)

    def test_source_change_targets_impact_without_overwriting_history(self):
        e=self.evidence(); data=self.payload(); old=data['sources'][0]['sha256']
        self.origin.write_text('changed')
        result=e.audit(data,self.source)
        self.assertEqual(result['status'],'INCOMPLETE')
        self.assertIn('source.changed',[c['rule'] for c in result['checks']])
        self.assertEqual(data['sources'][0]['sha256'],old)
        self.assertEqual(result['impacts'][0]['target_identity'],'consumer:docs/knowledge/target.md')

    def test_only_verified_explicit_git_commit_proves_recovery(self):
        e=self.evidence(); data=self.payload(); repo=self.source.parent
        subprocess.run(['git','init','-q',str(repo)],check=True)
        subprocess.run(['git','-C',str(repo),'add','docs/knowledge/fact.md'],check=True)
        subprocess.run(['git','-C',str(repo),'-c','user.name=test','-c','user.email=test@example.test','commit','-qm','fixture'],check=True)
        commit=subprocess.check_output(['git','-C',str(repo),'rev-parse','HEAD'],text=True).strip()
        data['sources'][0]['commit']=commit
        data['sources'][0]['recoverability']='已核验可从指定 Git 版本恢复'
        self.assertEqual(e.audit(data,self.source)['sources'][0]['recovery_status'],'PASS')
        data['sources'][0]['sha256']='0'*64
        self.assertEqual(e.audit(data,self.source)['status'],'FAIL')

    def test_paths_and_symlinks_cannot_escape(self):
        e=self.evidence(); data=self.payload()
        data['sources'][0]['path']='../outside'
        with self.assertRaises(ValueError): e.render(data)
        data['sources'][0]['path']='docs/knowledge/fact.md'
        self.origin.unlink(); self.origin.symlink_to(self.destination)
        self.assertEqual(e.audit(data,self.source)['status'],'INCOMPLETE')

    def test_ended_record_still_has_active_dependency(self):
        e=self.evidence(); data=self.payload(); data['processing']='已结束'
        self.assertEqual(e.dependencies(data),['consumer:docs/knowledge/fact.md'])
        data['sources'][0]['dependency']='解除待核实'
        self.assertEqual(e.dependencies(data),['consumer:docs/knowledge/fact.md'])

if __name__=='__main__': unittest.main()

class IdentityEvidenceTests(ManifestFixture,unittest.TestCase):
    evidence=EvidenceTests.evidence
    payload=EvidenceTests.payload

    def test_claimed_identity_must_match_actual_ssot(self):
        e=self.evidence(); data=self.payload()
        source=data['sources'][0]
        source.update(identity='SYS-B',repository={'path':'${WORK_SPACE}/provider','dir':'docs'},path='docs/knowledge/application/SYS-A/SYS-A.md',sha256=e.file_hash(self.target/'knowledge/application/SYS-A/SYS-A.md'))
        result=e.audit(data,self.source)
        self.assertEqual(result['status'],'FAIL')

    def test_nonexistent_anchor_is_failure(self):
        e=self.evidence(); data=self.payload(); data['sources'][0]['path']+='#missing'
        self.assertEqual(e.audit(data,self.source)['status'],'FAIL')
