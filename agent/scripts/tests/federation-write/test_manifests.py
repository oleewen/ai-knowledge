from fixtures import ManifestFixture, entity
import unittest

class ManifestTests(ManifestFixture, unittest.TestCase):
    def test_incremental_ids_preserve_other_entries(self):
        m=self.module()
        original={'type':'meta','repository':'https://github.com/test/meta.git','path':'${WORK_SPACE}/meta','dir':'solution'}
        (self.source/'knowledge-links.yaml').write_text(m.render([original]))
        self.add(['SYS-A']).execute(); self.add(['SYS-B']).execute()
        entries=m.read(self.source/'knowledge-links.yaml')
        self.assertEqual(entries[0],original)
        self.assertEqual(entries[1]['entity_ids'],['SYS-A','SYS-B'])
        self.assertFalse((self.target/'governance').exists())

    def test_remove_explicit_ids_and_clear(self):
        m=self.module(); self.add(['SYS-A','SYS-B']).execute()
        p=m.dependency_plan(self.source,self.target,None,['SYS-A'],remove=True); p.execute()
        self.assertEqual(m.read(self.source/'knowledge-links.yaml')[0]['entity_ids'],['SYS-B'])
        with self.assertRaises(ValueError): m.dependency_plan(self.source,self.target,None,[],remove=True)
        m.dependency_plan(self.source,self.target,None,[],remove=True,clear=True).execute()
        self.assertEqual(m.read(self.source/'knowledge-links.yaml'),[])

    def test_used_id_blocks_removal(self):
        m=self.module(); self.add(['SYS-A']).execute()
        p=self.source/'knowledge/product/PD-A.md'; p.parent.mkdir(parents=True)
        p.write_text(entity('PD-A','PD','product','solution','- implements_to: PL-A','- uses_to: SYS-A'))
        before=(self.source/'knowledge-links.yaml').read_bytes()
        with self.assertRaisesRegex(ValueError,'有效|引用'):
            m.dependency_plan(self.source,self.target,None,['SYS-A'],remove=True)
        self.assertEqual((self.source/'knowledge-links.yaml').read_bytes(),before)

    def test_missing_target_wrong_layer_and_duplicate_ids_rejected(self):
        m=self.module()
        for ids in (['SYS-MISSING'],['SYS-A','SYS-A'],['APP-A/MS-MISSING']):
            with self.assertRaises(ValueError): self.add(ids)
        with self.assertRaises(ValueError):
            m.dependency_plan(self.source,self.base/'offline',None,['SYS-A'])

    def test_meta_upsert_preserves_dependency(self):
        m=self.module(); self.add(['SYS-A']).execute()
        m.meta_plan(self.source,'https://github.com/test/meta.git','${WORK_SPACE}/meta','solution').execute()
        entries=m.read(self.source/'knowledge-links.yaml')
        self.assertEqual(entries[0]['entity_ids'],['SYS-A'])
        self.assertEqual(entries[1]['type'],'meta')

    def test_strict_writer_rejects_structure_and_unknown_fields(self):
        m=self.module()
        for text in ('links: []\nlinks: []\n','links: []\n - type: meta\n','links:\n  - type: meta\n    unexpected: value\n'):
            p=self.source/'knowledge-links.yaml'; p.write_text(text)
            with self.assertRaises(ValueError): m.read(p)

if __name__=='__main__': unittest.main()

class ReferenceRaceTests(ManifestFixture, unittest.TestCase):
    def test_new_evidence_after_preview_blocks_removal(self):
        m=self.module(); self.add(['SYS-A']).execute()
        plan=m.dependency_plan(self.source,self.target,None,['SYS-A'],remove=True)
        e=self.source/'governance/evidence/EVID-000001.md'; e.parent.mkdir(parents=True)
        e.write_text('来源 SYS-A\n| 事实依赖 | 有效 |\n')
        with self.assertRaisesRegex(ValueError,'指纹|有效'): plan.execute()
        self.assertEqual(m.read(self.source/'knowledge-links.yaml')[0]['entity_ids'],['SYS-A'])

    def test_same_identity_cannot_be_registered_to_second_ssot(self):
        m=self.module(); self.add(['SYS-A']).execute()
        other=self.repo('other','system'); self.put(other,'SYS-A')
        before=(self.source/'knowledge-links.yaml').read_bytes()
        with self.assertRaisesRegex(ValueError,'身份|映射'):
            m.dependency_plan(self.source,other,'https://github.com/test/other.git',['SYS-A'])
        self.assertEqual((self.source/'knowledge-links.yaml').read_bytes(),before)
