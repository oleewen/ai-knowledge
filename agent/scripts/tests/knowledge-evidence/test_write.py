import copy
import importlib
import json
from pathlib import Path
import subprocess
import sys
import unittest
from unittest.mock import patch
import test_evidence as fixture
from test_evidence import ManifestFixture, TOOLS

class WriteTests(ManifestFixture,unittest.TestCase):
    evidence=fixture.EvidenceTests.evidence
    payload=fixture.EvidenceTests.payload

    def writer(self): return importlib.import_module('knowledge_validation.evidence_write')

    def test_create_preview_and_update_preserve_versions(self):
        m=self.writer(); data=self.payload()
        before=list(self.source.rglob('*'))
        plan=m.create_plan(self.source,data); plan.execute(dry_run=True)
        self.assertEqual(before,list(self.source.rglob('*')))
        plan.execute(); path=self.source/'governance/evidence/EVID-000001.md'
        original=self.evidence().parse(path.read_text())
        m.update_plan(self.source,data['id'],{'review_status':'待复核','conclusion':'来源待重新核实'}).execute()
        now=self.evidence().parse(path.read_text())
        self.assertEqual(now['sources'],original['sources'])
        with self.assertRaises(ValueError): m.update_plan(self.source,data['id'],{'target_sha256':'0'*64})

    def test_pending_target_finalization_requires_actual_hash(self):
        m=self.writer(); data=self.payload(); data.update(target_sha256='尚无',review_status='待核验',reviewer='尚未核验',processing='待落盘')
        m.create_plan(self.source,data).execute()
        with self.assertRaises(ValueError): m.update_plan(self.source,data['id'],{'target_sha256':'0'*64,'processing':'已落盘'})
        changes={'target_sha256':self.evidence().file_hash(self.destination),'processing':'已落盘','review_status':'已核验','reviewer':{'name':'reviewer','at':'2026-11-07T12:00:00+08:00'},'conclusion':'已读取目标与原始来源，支持本次范围'}
        m.update_plan(self.source,data['id'],changes).execute()

    def test_create_race_and_source_edit_before_write_stop(self):
        m=self.writer(); data=self.payload(); one=m.create_plan(self.source,data); two=m.create_plan(self.source,data)
        one.execute()
        with self.assertRaises(ValueError): two.execute()
        newer=copy.deepcopy(data); newer['id']='EVID-000002'
        plan=m.create_plan(self.source,newer); self.origin.write_text('changed')
        with self.assertRaisesRegex(ValueError,'指纹'): plan.execute()
        self.assertFalse((self.source/'governance/evidence/EVID-000002.md').exists())

    def test_refresh_only_marks_affected_records_and_is_resumable(self):
        m=self.writer(); data=self.payload(); m.create_plan(self.source,data).execute()
        self.origin.write_text('new source version')
        plan=m.refresh_plan(self.source)
        from federation_write import operations
        with patch.object(operations,'apply_step',side_effect=OSError('disk')):
            with self.assertRaises(OSError): plan.execute()
        operations.resume(plan.journal)
        current=self.evidence().parse((self.source/'governance/evidence/EVID-000001.md').read_text())
        self.assertEqual(current['review_status'],'待复核')
        self.assertEqual(current['sources'][0]['sha256'],data['sources'][0]['sha256'])
        self.assertEqual(self.destination.read_text(),'target')

    def test_cli_check_incomplete_is_explicit_nonzero(self):
        self.writer(); data=self.payload()
        path=self.source/'governance/evidence/EVID-000001.md'; path.parent.mkdir(parents=True)
        path.write_text(self.evidence().render(data)); self.origin.write_text('changed')
        result=subprocess.run([sys.executable,'-B',str(TOOLS/'knowledge-evidence.py'),'check','--doc',str(self.source)],text=True,capture_output=True)
        self.assertNotEqual(result.returncode,0)
        self.assertEqual(json.loads(result.stdout)['status'],'INCOMPLETE')

    def test_verified_commit_cannot_be_replaced_or_erased(self):
        m=self.writer(); data=self.payload(); repo=self.source.parent
        subprocess.run(['git','init','-q',str(repo)],check=True)
        subprocess.run(['git','-C',str(repo),'add','.'],check=True)
        subprocess.run(['git','-C',str(repo),'-c','user.name=test','-c','user.email=test@example.test','commit','-qm','fixture'],check=True)
        data['sources'][0]['commit']=subprocess.check_output(['git','-C',str(repo),'rev-parse','HEAD'],text=True).strip()
        m.create_plan(self.source,data).execute()
        with self.assertRaises(ValueError):
            m.update_plan(self.source,data['id'],{'sources':[{'index':1,'commit':'未验证','recoverability':'待核实'}]})

    def test_inline_review_rechecks_bytes_without_persisting_body(self):
        m=self.writer(); data=self.payload(); text='private inline original'
        data.update(review_status='待核验',reviewer='尚未核验')
        source=data['sources'][0]; source.update(repository='不适用',path='message:thread/turn1',identity='message:thread/turn1',inline_text=text)
        source.pop('sha256'); source['recoverability']='待核实'
        m.create_plan(self.source,data).execute()
        changes={'review_status':'已核验','reviewer':{'name':'reviewer','at':'2026-11-07T12:00:00+08:00'},'conclusion':'已重读原文并核验支持范围'}
        with self.assertRaises(ValueError): m.update_plan(self.source,data['id'],changes)
        changes['sources']=[{'index':1,'inline_text':text}]
        m.update_plan(self.source,data['id'],changes).execute()
        path=self.source/'governance/evidence/EVID-000001.md'
        self.assertNotIn(text,path.read_text())
        self.assertEqual(m.check(self.source)['status'],'PASS')
        self.assertEqual(m.check(self.source)['records'][0]['audit']['sources'][0]['recovery_status'],'UNVERIFIED')

    def test_create_resume_after_file_write_before_checkpoint(self):
        m=self.writer(); plan=m.create_plan(self.source,self.payload())
        from federation_write import operations
        original=operations.apply_step
        def interrupted(step):
            original(step)
            raise OSError('interrupted after replace')
        with patch.object(operations,'apply_step',side_effect=interrupted):
            with self.assertRaises(OSError): plan.execute()
        result=operations.resume(plan.journal)
        self.assertEqual(result['state'],'complete')

    def test_previous_target_mismatch_rejected_before_writing(self):
        m=self.writer(); data=self.payload(); m.create_plan(self.source,data).execute()
        data.update(id='EVID-000002',previous='EVID-000001',target_identity='other-chapter')
        with self.assertRaisesRegex(ValueError,'目标身份'):
            m.create_plan(self.source,data)
        self.assertFalse((self.source/'governance/evidence/EVID-000002.md').exists())
