"""Scoped identities must never collapse homonyms or guess ownership from directories."""
import importlib.util
from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT/'agent/scripts/tools'))
sys.path.insert(0, str(ROOT/'agent/skills/docs-okf/scripts'))
import okf_lib


def record(eid, owner=None, path=None, root=Path('/test')):
    return {'id':eid, 'meta':{'id':eid,'hierarchy':eid.split('-')[0]},
            'path':root/(path or eid+'.md'), 'root':root,
            'edges': [('implements_to',owner,'关系')] if owner else [],
            'valid':True, 'selected':True, 'body':'', 'declarations':set()}


class IdentityTests(unittest.TestCase):
    def catalog(self, rows):
        self.assertIsNotNone(importlib.util.find_spec('knowledge_validation.identity'), 'shared identity resolver missing')
        from knowledge_validation.identity import Catalog
        return Catalog(rows)

    def test_homonyms_resolve_by_verified_owner(self):
        rows=[record('APP-A'),record('APP-B'),record('MS-Q','APP-A','a/ms.md'),record('MS-Q','APP-B','b/ms.md'),
              record('API-001','APP-A/MS-Q','a/api.md'),record('API-001','APP-B/MS-Q','b/api.md')]
        cat=self.catalog(rows)
        self.assertEqual(cat.resolve('APP-A/MS-Q/API-001')[0]['path'],Path('/test/a/api.md'))
        self.assertEqual(cat.resolve('APP-B/MS-Q/API-001')[0]['path'],Path('/test/b/api.md'))
        self.assertEqual(cat.resolve('MS-Q')[1],'UNVERIFIED')
        self.assertEqual(cat.resolve('API-001')[1],'UNVERIFIED')

    def test_bare_id_only_when_unique_and_owner_read(self):
        cat=self.catalog([record('APP-A'),record('MS-Q','APP-A')])
        self.assertEqual(cat.resolve('MS-Q')[0]['full_id'],'APP-A/MS-Q')
        cat=self.catalog([record('API-001','APP-A/MS-MISSING')])
        self.assertEqual(cat.resolve('APP-A/MS-MISSING/API-001')[1],'UNVERIFIED')

    def test_duplicate_full_identity_is_not_overwritten(self):
        cat=self.catalog([record('APP-A'),record('MS-Q','APP-A','one.md'),record('MS-Q','APP-A','two.md')])
        self.assertEqual(cat.resolve('APP-A/MS-Q')[1],'UNVERIFIED')
        self.assertEqual(len(cat.duplicates()['APP-A/MS-Q']),2)

    def test_multiple_or_wrong_owner_fails(self):
        bad=record('MS-Q','APP-A'); bad['edges'].append(('implements_to','APP-B','关系'))
        rows=[record('APP-A'),record('APP-B'),bad,record('API-001','APP-A')]
        self.catalog(rows)
        self.assertEqual(bad['identity_status'],'FAIL')
        self.assertEqual(rows[-1]['identity_status'],'FAIL')

    def test_new_api_layout_includes_app(self):
        self.assertEqual(okf_lib.entity_relpath('application','API-001',path_parent='APP-A/MS-Q',bundle='application'),
                         'knowledge/application/APP-A/MS-Q/API-001/API-001.md')
        with self.assertRaises(ValueError):
            okf_lib.entity_relpath('application','API-001',path_parent='MS-Q',bundle='application')

    def test_migration_preview_changes_descendants_without_mutating_records(self):
        self.assertIsNotNone(importlib.util.find_spec('knowledge_validation.migration'), 'migration preview missing')
        from knowledge_validation.migration import preview
        from types import SimpleNamespace
        rows=[record('APP-A'),record('APP-B'),record('MS-Q','APP-A'),record('API-001','APP-A/MS-Q')]
        cat=self.catalog(rows)
        world=SimpleNamespace(catalog=cat, records=rows, coverage=[], issues=[], readable=set(), snapshot=None)
        result=preview(world,'APP-A/MS-Q','APP-B')
        self.assertEqual([(x['from_identity'],x['to_identity']) for x in result['changes']],
                         [('APP-A/MS-Q','APP-B/MS-Q'),('APP-A/MS-Q/API-001','APP-B/MS-Q/API-001')])
        self.assertFalse(result['executable'])
        self.assertEqual(rows[2]['full_id'],'APP-A/MS-Q')

    def test_migration_collision_and_unknown_owner_block(self):
        self.assertIsNotNone(importlib.util.find_spec('knowledge_validation.migration'), 'migration preview missing')
        from knowledge_validation.migration import preview
        from types import SimpleNamespace
        rows=[record('APP-A'),record('APP-B'),record('MS-Q','APP-A','one.md'),record('MS-Q','APP-B','two.md')]
        cat=self.catalog(rows)
        world=SimpleNamespace(catalog=cat, records=rows, coverage=[], issues=[], readable=set(), snapshot=None)
        self.assertTrue(preview(world,'APP-A/MS-Q','APP-B')['blockers'])
        self.assertTrue(preview(world,'APP-A/MS-Q','APP-UNKNOWN')['blockers'])


if __name__=='__main__': unittest.main()
