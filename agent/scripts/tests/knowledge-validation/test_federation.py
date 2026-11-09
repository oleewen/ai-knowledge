"""Read-only federation traversal and consumer coverage regressions."""
import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import unittest

from test_identity import ROOT, record
from test_validation import entity

os.environ['KNOWLEDGE_VALIDATION_BASH']='/opt/homebrew/bin/bash'


class FederationTests(unittest.TestCase):
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.base=Path(self.temp.name).resolve()
        (self.base/'agents').mkdir()
        (self.base/'agents/configs').write_text(f'WORK_SPACE={self.base}\n')
        self.solution=self.repo('consumer','solution')
        self.system=self.repo('provider','system')
        self.put(self.system,'SYS-A','SYS','application','system','- implements_to: SLN-A\n- implemented_by: APP-A')
        self.put(self.solution,'PD-A','PD','product','solution','- implements_to: PL-A', '- uses_to: SYS-A')

    def repo(self,name,layer):
        root=self.base/name; (root/'docs').mkdir(parents=True)
        (root/'.docsconfig').write_text(f'AGENT_ROOT={self.base}\nAGENT_DIR=agents\nREPO_DIR={name}\nDOC_DIR=docs\nKNOWLEDGE_TYPE={layer}\n')
        return root/'docs'

    def put(self,root,eid,hierarchy,perspective,layer,relations='',cross=''):
        p=root/'knowledge'/perspective/(eid+'.md'); p.parent.mkdir(parents=True,exist_ok=True)
        p.write_text(entity(eid,hierarchy,perspective,layer,relations,cross)); return p

    def link(self,kind,name,layer=None,ids=None):
        s=f'  - type: {kind}\n    repository: https://github.com/test/{name}.git\n    path: ${{WORK_SPACE}}/{name}\n    dir: docs\n    name: {name}\n'
        if layer: s+=f'    target_layer: {layer}\n'
        if ids: s+='    entity_ids: ['+', '.join(ids)+']\n'
        return s

    def world(self,root=None,consumers=()):
        self.assertIsNotNone(importlib.util.find_spec('knowledge_validation.federation'),'federation reader missing')
        from knowledge_validation.federation import World
        from knowledge_validation.context import Snapshot
        return World(root or self.solution, 'solution' if root is None else 'system', consumers, Snapshot())

    def test_dependency_and_single_sided_consumption(self):
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['SYS-A']))
        before={str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()}
        world=self.world()
        edges=world.consumption()
        self.assertEqual([(e['source'],e['target'],e['status']) for e in edges],[('PD-A','SYS-A','PASS')])
        self.assertEqual(before,{str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()})

    def test_child_recursion_and_revisit_do_not_duplicate_consumers(self):
        company=self.repo('company','company')
        (company/'knowledge-links.yaml').write_text('links:\n'+self.link('child','consumer'))
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','company')+self.link('child','provider'))
        world=self.world(self.system,[company,self.solution])
        self.assertEqual(len(world.consumption()),1)
        self.assertEqual(len([c for c in world.coverage if c['root']==str(self.solution) and c['status']=='PASS']),1)

    def test_duplicate_dependency_mapping_blocks_even_when_one_offline(self):
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['SYS-A'])+self.link('dependency','offline','system',['SYS-A']))
        world=self.world()
        self.assertTrue(any(i['status']=='FAIL' and '重复' in i['evidence'] for i in world.issues))
        self.assertNotEqual(world.consumption()[0]['status'],'PASS')

    def test_offline_and_wrong_layer_are_explicit(self):
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','offline','system',['SYS-A']))
        world=self.world()
        self.assertEqual(world.consumption()[0]['status'],'UNVERIFIED')
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','company',['SYS-A']))
        self.assertTrue(any(i['status']=='FAIL' for i in self.world().issues))

    def test_dependency_parser_rejects_bad_lists_and_path_escape(self):
        for ids in ('[]','[SYS-A, SYS-A]','SYS-A','[42]'):
            (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system')+f'    entity_ids: {ids}\n')
            self.assertTrue(any(i['status']=='FAIL' for i in self.world().issues),ids)
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','../escape','system',['SYS-A']))
        self.assertTrue(any(i['status']=='FAIL' for i in self.world().issues))

    def test_each_registration_layer_checked_before_dedup(self):
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['SYS-A'])+self.link('dependency','provider','application',['API-001']))
        self.assertTrue(any(i['status']=='FAIL' for i in self.world().issues))

    def test_explicit_offline_dependency_never_falls_back_to_consumer_roots(self):
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','offline','system',['SYS-A']))
        self.assertEqual(self.world(consumers=[self.system]).consumption()[0]['status'],'UNVERIFIED')

    def test_cross_layer_index_keeps_homonyms_and_full_identity(self):
        import okf_cross_layer
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        self.put(self.system,'APP-B','APP','application','system','- implements_to: SYS-A')
        for app in ('APP-A','APP-B'):
            path=self.system/'knowledge/application'/app/'MS-Q/MS-Q.md'
            path.parent.mkdir(parents=True)
            path.write_text(entity('MS-Q','MS','application','system','- implements_to: '+app))
        index=okf_cross_layer._index_concepts(self.system)
        self.assertIn('APP-A/MS-Q',index)
        self.assertIn('APP-B/MS-Q',index)
        self.assertNotIn('MS-Q',index)

    def test_visualization_contains_consumption_and_coverage(self):
        import visualize
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['SYS-A']))
        data=visualize.build_bundle_data(self.solution,'Test')
        self.assertTrue(any(e.get('relation')=='uses_to' and e.get('derived') for e in data['edges']))
        self.assertIn('coverage',data)
        self.assertTrue(any(c.get('fullIdentity')=='SYS-A' for c in data['concepts'].values()))

    def test_consumer_upgrade_does_not_reregister_dependency(self):
        company=self.repo('company','company')
        self.repo('other','system')
        (self.system/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','consumer'))
        (company/'knowledge-links.yaml').write_text('links:\n'+self.link('child','consumer'))
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','other','system',['SYS-B']))
        world=self.world(self.system,[company])
        self.assertFalse(any('重复' in i['evidence'] for i in world.issues))

    def test_navigation_displays_qualified_identity(self):
        import generate_index
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        path=self.system/'knowledge/application/SYS-A/APP-A/MS-Q/MS-Q.md'
        path.parent.mkdir(parents=True)
        path.write_text(entity('MS-Q','MS','application','system','- implements_to: APP-A'))
        generate_index.write_index(path.parent,self.system)
        self.assertIn('APP-A/MS-Q',(path.parent/'index.md').read_text())

    def test_unified_cli_consumption_and_migration_are_single_json_read_only(self):
        import json, subprocess
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        self.put(self.system,'APP-B','APP','application','system','- implements_to: SYS-A')
        self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['SYS-A']))
        before={str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()}
        proc=subprocess.run(['/opt/homebrew/bin/bash',str(ROOT/'agent/scripts/tools/validate-knowledge.sh'),
                             '--json','--consumer-root',str(self.solution),
                             '--move-identity','APP-A/MS-Q','--to-owner','APP-B'],cwd=self.system,text=True,capture_output=True)
        data=json.loads(proc.stdout)
        self.assertEqual(data['context']['consumption'][0]['status'],'PASS')
        self.assertEqual(data['context']['migration']['changes'][0]['to_identity'],'APP-B/MS-Q')
        self.assertEqual(proc.returncode,int(data['summary']['FAIL']>0))
        self.assertEqual(before,{str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()})

    def test_verified_legacy_api_and_homonyms_in_new_layout(self):
        from knowledge_validation.core import validate
        app=self.repo('application','application')
        (app/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','provider'))
        for name in ('APP-A','APP-B'):
            self.put(self.system,name,'APP','application','system','- implements_to: SYS-A')
            p=self.system/'knowledge/application/SYS-A'/name/'MS-Q/MS-Q.md'
            p.parent.mkdir(parents=True)
            p.write_text(entity('MS-Q','MS','application','system','- implements_to: '+name))
            p=app/'knowledge/application'/name/'MS-Q/API-001/API-001.md'
            p.parent.mkdir(parents=True)
            p.write_text(entity('API-001','API','application','application','- implements_to: '+name+'/MS-Q'))
        data=validate(app)
        self.assertFalse(any(x['status']=='FAIL' and x['domain'] in ('identity','structure') for x in data['checks']),data['checks'])
        self.assertEqual(len([r for r in data['context']['identities'] if r['full_id'] and r['full_id'].endswith('/API-001')]),2)
        path=app/'knowledge/application/APP-A/MS-Q/API-001/API-001.md'
        legacy=app/'knowledge/application/MS-Q/API-001.md';legacy.parent.mkdir(parents=True)
        path.rename(legacy)
        data=validate(app)
        self.assertFalse(any(x['status']=='FAIL' and x['rule']=='structure.layout' for x in data['checks']))

    def test_http_label_identity_cannot_point_at_other_app_service(self):
        from knowledge_validation.core import validate
        app=self.repo('application','application')
        (app/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','provider'))
        for name in ('APP-A','APP-B'):
            self.put(self.system,name,'APP','application','system','- implements_to: SYS-A')
            p=self.system/'knowledge/application/SYS-A'/name/'MS-Q/MS-Q.md'
            p.parent.mkdir(parents=True)
            p.write_text(entity('MS-Q','MS','application','system','- implements_to: '+name))
        p=app/'knowledge/application/APP-A/MS-Q/API-001/API-001.md';p.parent.mkdir(parents=True)
        href='https://github.com/test/provider/blob/main/docs/knowledge/application/SYS-A/APP-B/MS-Q/MS-Q.md'
        p.write_text(entity('API-001','API','application','application','- implements_to: [APP-A/MS-Q]('+href+')'))
        data=validate(app)
        self.assertTrue(any(x['rule']=='relations.link_identity' and x['status']=='FAIL' for x in data['checks']))

    def test_verified_flat_ms_is_read_compatible(self):
        from knowledge_validation.core import validate
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        path=self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        data=validate(self.system)
        self.assertFalse(any(x['status']=='FAIL' and x['rule']=='structure.layout' and x['object']==str(path) for x in data['checks']))

    def test_migration_includes_dependency_identity_registration(self):
        from knowledge_validation.migration import preview
        for name in ('APP-A','APP-B'):
            self.put(self.system,name,'APP','application','system','- implements_to: SYS-A')
        self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        (self.solution/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','provider','system',['APP-A/MS-Q']))
        result=preview(self.world(),'APP-A/MS-Q','APP-B')
        self.assertTrue(any(x['path'].endswith('knowledge-links.yaml') and x['identity']=='APP-A/MS-Q' for x in result['references']))

    def test_graph_invalid_source_cannot_emit_verified_semantic_edge(self):
        import visualize
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        path=self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        path.write_text(path.read_text().replace('timestamp: "2026-11-07T00:00:00+08:00"','timestamp: broken'))
        data=visualize.build_bundle_data(self.system,'Test')
        self.assertFalse(any(e.get('relation') and e.get('status')=='PASS' and e['source'].endswith('MS-Q') for e in data['edges']))

    def test_identity_owner_cannot_bypass_explicit_offline_dependency(self):
        other=self.repo('other','system')
        self.put(other,'APP-A','APP','application','system','- implements_to: SYS-A')
        self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        (self.system/'knowledge-links.yaml').write_text('links:\n'+self.link('dependency','offline','system',['APP-A']))
        world=self.world(self.system,[other])
        row=next(r for r in world.records if r['id']=='MS-Q')
        self.assertEqual(row['identity_status'],'UNVERIFIED')
        self.assertIsNone(row.get('full_id'))

    def test_ambiguous_scoped_identity_blocks_navigation_writes(self):
        import generate_index
        app=self.repo('application','application')
        (app/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','provider'))
        for name in ('APP-A','APP-B'):
            self.put(self.system,name,'APP','application','system','- implements_to: SYS-A')
            path=self.system/'knowledge/application'/name/'MS-Q/MS-Q.md';path.parent.mkdir(parents=True)
            path.write_text(entity('MS-Q','MS','application','system','- implements_to: '+name))
        api=self.put(app,'API-001','API','application','application','- implements_to: MS-Q')
        with self.assertRaises(ValueError): generate_index.write_index(api.parent,app)
        self.assertFalse((api.parent/'index.md').exists())

    def test_snapshot_change_downgrades_derived_payloads(self):
        from knowledge_validation.core import Report
        report=Report()
        path=self.system/'source.txt';path.write_text('before');report.snapshot.read(path)
        report.context={'identities':[{'status':'PASS'}],'consumption':[{'status':'PASS'}]}
        report.add('identity','PASS',path,'test','read')
        path.write_text('after')
        data=report.finish()
        self.assertEqual(data['context']['identities'][0]['status'],'UNVERIFIED')
        self.assertEqual(data['context']['consumption'][0]['status'],'UNVERIFIED')

    def test_migration_finds_descriptive_markdown_path_references(self):
        from knowledge_validation.migration import preview
        for name in ('APP-A','APP-B'):
            self.put(self.system,name,'APP','application','system','- implements_to: SYS-A')
        path=self.put(self.system,'MS-Q','MS','application','system','- implements_to: APP-A')
        note=self.system/'notes.md'
        note.write_text('[服务正文](/knowledge/application/MS-Q.md)')
        world=self.world(self.system)
        result=preview(world,'APP-A/MS-Q','APP-B')
        self.assertTrue(any(r['path']==str(note) and r.get('target_path')==str(path) for r in result['references']))

    def test_app_http_generation_refuses_duplicate_global_identity(self):
        import okf_cross_layer
        app=self.repo('application','application')
        (app/'knowledge-links.yaml').write_text('links:\n'+self.link('parent','provider'))
        self.put(self.system,'APP-A','APP','application','system','- implements_to: SYS-A')
        p=self.system/'knowledge/application/other/APP-A.md';p.parent.mkdir(parents=True)
        p.write_text(entity('APP-A','APP','application','system','- implements_to: SYS-B'))
        with self.assertRaises(ValueError):
            okf_cross_layer.cross_layer_href(app,'APP-A',path_parent='SYS-A')

if __name__=='__main__': unittest.main()
