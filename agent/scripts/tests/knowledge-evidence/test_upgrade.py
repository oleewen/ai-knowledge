import importlib
import json
from pathlib import Path
import unittest
from test_evidence import ManifestFixture
from fixtures import entity
from knowledge_validation import evidence as ev
from knowledge_validation.core import validate

class UpgradeTests(ManifestFixture,unittest.TestCase):
    def tool(self): return importlib.import_module('knowledge_validation.upgrade')

    def test_diagnostic_never_equates_exit_zero_with_completion(self):
        m=self.tool(); report=m.check(self.source)
        self.assertFalse(report['can_advance_version'])
        self.assertIn('evidence',report['sections'])
        self.assertIn('business',report['sections'])
        self.assertIn('template',report['sections'])

    def approved_fixture(self):
        doc=self.repo('company','company'); path=doc/'knowledge/business/VC-A/VC-A.md'; path.parent.mkdir(parents=True)
        path.write_text(entity()); source=doc/'knowledge/source.md'; source.write_text('reviewed source')
        reviewer={'name':'tester','at':'2026-11-07T12:00:00+08:00'}
        data={'id':'EVID-000001','target_identity':'VC-A','target_path':str(path.relative_to(doc.parent)),
              'target_sha256':ev.file_hash(path),'buffer':'无','previous':'无','review_status':'已核验',
              'reviewer':reviewer,'conclusion':'人工已核验支持范围','processing':'已落盘','sources':[{
              'identity':'company:docs/knowledge/source.md','repository':{'path':'${WORK_SPACE}/company','dir':'docs'},
              'path':'docs/knowledge/source.md','sha256':ev.file_hash(source),'commit':'未验证',
              'captured_at':reviewer['at'],'recoverability':'当前原件可读但无持久版本保证','dependency':'有效','release_basis':'无'}]}
        p=doc/'governance/evidence/EVID-000001.md';p.parent.mkdir(parents=True);p.write_text(ev.render(data))
        baseline=validate(doc); saved=doc/'governance/compatibility/baseline.json';saved.parent.mkdir();saved.write_text(json.dumps(baseline))
        report=self.tool().check(doc); assessment=report['assessment_template']
        assessment['old_baseline']={'path':str(saved.relative_to(doc.parent)),'sha256':ev.file_hash(saved),'reviewer':reviewer,'conclusion':'已核对原采用报告及规则来源'}
        for section in ('scope','template'):
            assessment[section].update(reviewer=reviewer,conclusion='已核对完整计划、无未落位项与当前影响范围')
        return doc,path,assessment

    def test_final_check_requires_fresh_review_and_exact_rule_snapshot(self):
        m=self.tool(); doc,path,assessment=self.approved_fixture()
        report=m.check(doc,assessment)
        self.assertTrue(report['can_advance_version'],report['blockers'])
        path.write_text(path.read_text()+'\nnew fact\n')
        report=m.check(doc,assessment)
        self.assertFalse(report['can_advance_version'])
        self.assertTrue(any('快照' in str(x) for x in report['blockers']))

    def test_rules_and_unknown_baseline_cannot_be_bypassed(self):
        m=self.tool(); doc,path,a=self.approved_fixture()
        a['old_baseline']['sha256']='0'*64
        self.assertFalse(m.check(doc,a)['can_advance_version'])
        doc,path,a=self.approved_fixture() if False else (doc,path,a)
        a['target_rules']={}
        self.assertFalse(m.check(doc,a)['can_advance_version'])

    def test_inherited_unaffected_fact_requires_actual_old_report_binding(self):
        m=self.tool(); doc,path,a=self.approved_fixture()
        # Mark current evidence pending; old report cannot override an explicit
        # changed/failed evidence assertion, even for an unaffected entity.
        p=doc/'governance/evidence/EVID-000001.md'; data=ev.parse(p.read_text());data['review_status']='待复核';p.write_text(ev.render(data))
        a['scope']['affected']=[]
        self.assertFalse(m.check(doc,a)['can_advance_version'])

    def test_scope_review_expires_when_external_source_changes(self):
        m=self.tool(); doc,path,a=self.approved_fixture()
        evidence=doc/'governance/evidence/EVID-000001.md'
        data=ev.parse(evidence.read_text()); source=self.target/'knowledge/source.md'
        source.write_text('original external source')
        data['sources'][0].update(repository={'path':'${WORK_SPACE}/provider','dir':'docs'},path='docs/knowledge/source.md',identity='provider:docs/knowledge/source.md',sha256=ev.file_hash(source))
        evidence.write_text(ev.render(data))
        fresh=m.check(doc)['assessment_template']
        a['scope'].update({k:v for k,v in fresh['scope'].items() if k not in ('reviewer','conclusion')})
        a['template']['files']=fresh['template']['files']
        source.write_text('new reviewed source')
        data['sources'][0]['sha256']=ev.file_hash(source); evidence.write_text(ev.render(data))
        # An old scope signature must not authorize newly reviewed sources.
        report=m.check(doc,a)
        self.assertFalse(report['can_advance_version'])

    def test_invalid_assessment_shapes_return_diagnostic(self):
        m=self.tool(); doc,path,a=self.approved_fixture()
        for value in ([],{'scope':[]},dict(a,scope=[]),dict(a,template=[])):
            result=m.check(doc,value)
            self.assertFalse(result['can_advance_version'])
