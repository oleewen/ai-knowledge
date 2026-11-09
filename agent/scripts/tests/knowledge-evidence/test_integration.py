import copy
import unittest
from pathlib import Path
import test_evidence as fixture
from test_evidence import ManifestFixture

class IntegrationTests(ManifestFixture,unittest.TestCase):
    evidence=fixture.EvidenceTests.evidence
    payload=fixture.EvidenceTests.payload

    def test_release_word_in_conclusion_cannot_hide_active_source(self):
        e=self.evidence(); data=self.payload()
        data['conclusion']='其他来源已解除，本来源仍有效'; data['processing']='已结束'
        p=self.source/'governance/evidence/EVID-000001.md'; p.parent.mkdir(parents=True); p.write_text(e.render(data))
        self.assertTrue(e.blockers(self.source,[data['sources'][0]['identity']]))
        data['sources'][0]['dependency']='已解除'; data['sources'][0]['release_basis']='tester 独立复核已撤回该目标事实，结论见本记录'
        p.write_text(e.render(data))
        self.assertEqual(e.blockers(self.source,[data['sources'][0]['identity']]),[])

    def test_malformed_evidence_cannot_be_silently_skipped(self):
        e=self.evidence(); p=self.source/'governance/evidence/EVID-000001.md'; p.parent.mkdir(parents=True)
        p.write_text('来源 SYS-A 已解除')
        self.assertTrue(e.blockers(self.source,['SYS-A']))

    def test_unified_report_checks_evidence_without_claiming_unreviewed_facts(self):
        from knowledge_validation.core import validate
        e=self.evidence(); data=self.payload(); data.update(review_status='待核验',reviewer='尚未核验')
        p=self.source/'governance/evidence/EVID-000001.md'; p.parent.mkdir(parents=True); p.write_text(e.render(data))
        result=validate(self.source)
        self.assertTrue(any(c['domain']=='evidence' for c in result['checks']))
        self.assertFalse(any(c['domain']=='facts' and c['status']=='PASS' for c in result['checks']))

    def test_previous_cycles_are_not_valid_evidence_history(self):
        e=self.evidence(); data=self.payload(); p=self.source/'governance/evidence'; p.mkdir(parents=True)
        data['previous']='EVID-000002'; (p/'EVID-000001.md').write_text(e.render(data))
        data['id']='EVID-000002'; data['previous']='EVID-000001'; (p/'EVID-000002.md').write_text(e.render(data))
        self.assertTrue(e.scan(self.source)['issues'])
