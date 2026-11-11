"""Real CLI regressions: invalid inputs must never become an empty successful report."""
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]
CLI = ROOT / 'agent/scripts/tools/validate-knowledge.sh'
BASH = shutil.which('bash')
if Path('/opt/homebrew/bin/bash').exists():
    BASH = '/opt/homebrew/bin/bash'


def entity(eid='VC-A', hierarchy='VC', perspective='business', layer='company', relations='', cross=''):
    types = {'VC': 'Value Chain', 'BD': 'Business Domain', 'CAP': 'Business Capability',
             'MS': 'Microservice', 'API': 'API Endpoint', 'APP': 'Application', 'SYS': 'System', 'TPL': 'Technical Platform', 'PD': 'Product'}
    return f'''---
type: {types[hierarchy]}
title: Example
description: Test entity
tags: [{perspective}, {hierarchy}]
timestamp: "2026-11-07T00:00:00+08:00"
id: {eid}
perspective: {perspective}
hierarchy: {hierarchy}
layer_scope: {layer}
---
<!-- markdownlint-disable-next-line MD025 -->
# Example

## 关系
{relations}
## 跨视角
{cross}
## 详细说明
Test.
## 依据与证据
待核实。
'''


class ValidationTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory(prefix='knowledge-validation-')
        self.addCleanup(self.tmp.cleanup)
        self.base = Path(self.tmp.name).resolve()
        self.repo = self.base / 'repo'
        self.doc = self.repo / 'custom/docs'
        self.doc.mkdir(parents=True)
        (self.base / 'agents').mkdir()
        (self.base / 'agents/configs').write_text(f'WORK_SPACE={self.base}\n')
        self.config()

    def config(self, layer='company'):
        (self.repo / '.docsconfig').write_text(f'AGENT_ROOT={self.base}\nAGENT_DIR=agents\nREPO_DIR=repo\nDOC_DIR=custom/docs\nKNOWLEDGE_TYPE={layer}\n')

    def put(self, name, text):
        path = self.doc / name
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(text)
        return path

    def run_cli(self, *args, cwd=None):
        self.assertTrue(CLI.is_file(), 'unified entrypoint is not implemented')
        p = subprocess.run([BASH, str(CLI), '--json', *args], cwd=cwd or self.repo,
                           text=True, capture_output=True, env={**os.environ, 'PYTHONDONTWRITEBYTECODE': '1'})
        try:
            data = json.loads(p.stdout)
        except json.JSONDecodeError:
            self.fail(f'not a JSON report: {p.stdout}\n{p.stderr}')
        self.assertEqual(p.returncode, int(any(x['status']=='FAIL' for x in data['checks'])), p.stderr)
        return data

    def has(self, report, domain, status, rule=None):
        return any(x['domain']==domain and x['status']==status and (rule is None or rule in x['rule']) for x in report['checks'])

    def valid(self):
        return self.put('knowledge/business/VC-A/VC-A.md', entity())

    def test_arbitrary_doc_dir_and_read_only_snapshot(self):
        path = self.valid()
        before = {str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()}
        data = self.run_cli(cwd=path.parent)
        self.assertEqual(data['context']['layer'], 'company')
        self.assertEqual(data['context']['bundle'], str(self.doc))
        self.assertTrue(self.has(data, 'structure', 'PASS'))
        self.assertTrue(self.has(data, 'facts', 'NOT_RUN'))
        self.assertNotEqual(data['status'], 'PASS')
        self.assertTrue(data['context']['rules']['files'])
        self.assertEqual(before, {str(p):p.read_bytes() for p in self.base.rglob('*') if p.is_file()})

    def test_missing_config_is_json_failure(self):
        self.assertTrue(self.has(self.run_cli(cwd=self.base), 'context', 'FAIL'))

    def test_meta_requires_both_parameters(self):
        self.config('meta'); self.valid()
        for args in [(), ('--layer','company'), ('--bundle','custom/docs')]:
            self.assertTrue(self.has(self.run_cli(*args), 'context', 'FAIL'))
        self.assertFalse(self.has(self.run_cli('--layer','company','--bundle','custom/docs'), 'context','FAIL'))

    def test_missing_or_wrong_type_and_id_are_not_skipped(self):
        for change in [('type: Value Chain\n',''), ('type: Value Chain','type: typo'), ('id: VC-A\n','')]:
            self.put('knowledge/business/VC-A/VC-A.md', entity().replace(*change))
            data=self.run_cli()
            self.assertTrue(self.has(data,'structure','FAIL'))
            self.assertTrue(self.has(data,'relations','NOT_RUN'))

    def test_navigation_and_governance_not_entities(self):
        self.valid()
        self.put('governance/profile.md','# Profile\n待迁移。\n')
        self.put('knowledge/business/README.md','# Navigation\n')
        self.assertFalse(self.has(self.run_cli(),'structure','FAIL'))

    def test_wrong_logical_layer_and_escape_fail(self):
        self.valid()
        self.assertTrue(self.has(self.run_cli('--layer','solution'),'context','FAIL'))
        self.assertTrue(self.has(self.run_cli('--bundle','../'),'context','FAIL'))
        self.assertTrue(self.has(self.run_cli('--file','../../outside.md'),'context','FAIL'))

    def test_local_scope_never_claims_global_uniqueness(self):
        path=self.valid()
        data=self.run_cli('--file',str(path))
        self.assertTrue(self.has(data,'identity','UNVERIFIED'))
        self.assertTrue(data['context']['selection']['partial'])

    def test_missing_file_selection_is_failure(self):
        self.valid()
        self.assertTrue(self.has(self.run_cli('--file',str(self.doc/'gone.md')),'context','FAIL'))

    def test_reference_links_and_anchor_failures(self):
        self.valid()
        self.put('index.md','# Index\n[broken][x]\n\n[x]: missing.md#absent\n')
        self.assertTrue(self.has(self.run_cli(),'references','FAIL'))
        self.put('index.md','# Index\n[bad](#absent)\n')
        self.assertTrue(self.has(self.run_cli(),'references','FAIL'))
        self.put('index.md','# Index\n[ok](#index)\n`[code](gone.md)`\n<!-- [comment](gone.md) -->\n')
        self.assertFalse(self.has(self.run_cli(),'references','FAIL'))

    def test_scoped_identity_does_not_false_duplicate(self):
        self.config('system')
        for app in ['APP-A','APP-B']:
            self.put(f'knowledge/application/SYS-A/{app}/MS-X/MS-X.md',entity('MS-X','MS','application','system', '- implements_to: '+app+'\n- implemented_by: API-X'))
        data=self.run_cli()
        self.assertTrue(self.has(data,'identity','UNVERIFIED'))
        self.assertFalse(self.has(data,'identity','FAIL'))

    def test_duplicate_identity_fails(self):
        self.valid()
        self.put('knowledge/business/VC-B/VC-A.md',entity())
        self.assertTrue(self.has(self.run_cli(),'identity','FAIL'))

    def test_illegal_relation_and_missing_reverse(self):
        self.valid()
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to: VC-A'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','reverse'))
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to: TPL-A'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','allowed'))

    def test_required_relation_missing(self):
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','required'))

    def test_local_missing_target_is_failure(self):
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to: VC-A'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','target'))

    def test_external_missing_source_is_unverified(self):
        self.config('system')
        self.put('knowledge/application/SYS-A/SYS-A.md',entity('SYS-A','SYS','application','system','- implements_to: SLN-A\n- implemented_by: APP-A'))
        data=self.run_cli()
        self.assertTrue(self.has(data,'relations','UNVERIFIED','target'))

    def test_meta_reference_whitelist(self):
        self.valid()
        (self.doc/'.agents').symlink_to(ROOT/'agent',target_is_directory=True)
        self.put('knowledge/business/README.md','# Business\n[meta](../../.agents/knowledge/business-meta.md)\n')
        self.assertFalse(self.has(self.run_cli(),'references','FAIL'))

    def test_numeric_title_is_not_a_string(self):
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('title: Example','title: 123').replace('# Example','# 123'))
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL'))

    def test_link_label_must_match_target_identity(self):
        self.valid()
        self.put('knowledge/business/VC-B/VC-B.md',entity('VC-B'))
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to: [VC-A](../../VC-B/VC-B.md)'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','link_identity'))

    def test_relation_id_in_code_example_is_ignored(self):
        self.valid()
        path=self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='```yaml\n- implements_to: VC-A\n```'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','required'))

    def test_two_composition_parents_fail(self):
        self.valid()
        self.put('knowledge/business/VC-B/VC-B.md',entity('VC-B'))
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to:\n  - VC-A\n  - VC-B'))
        self.assertTrue(self.has(self.run_cli(),'relations','FAIL','cardinality'))

    def test_bad_frontmatter_type_does_not_crash(self):
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('hierarchy: VC','hierarchy: [VC]'))
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL'))

    def test_legacy_okf_entry_runs_shared_checks(self):
        (self.doc/'agents').symlink_to(ROOT/'agent',target_is_directory=True)
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('type: Value Chain','type: typo'))
        result=subprocess.run([BASH,str(ROOT/'agent/skills/docs-okf/scripts/okf-validate.sh'),'--bundle','custom/docs'],cwd=self.repo,text=True,capture_output=True)
        self.assertNotEqual(result.returncode,0,result.stdout)
        self.assertIn('structure.profile',result.stdout+result.stderr)

    def test_null_tags_keeps_structured_failure(self):
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('tags: [business, VC]','tags: null'))
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL'))

    def test_qualified_identity_stays_atomic(self):
        self.config('system')
        self.put('knowledge/application/SYS-A/APP-A/APP-A.md',entity('APP-A','APP','application','system','- implements_to: SYS-A\n- implemented_by: APP-A/MS-X'))
        data=self.run_cli()
        self.assertTrue(self.has(data,'relations','UNVERIFIED'))
        self.assertFalse(self.has(data,'relations','FAIL','allowed'))

    def test_wrong_perspective_directory_cannot_hide_entity(self):
        self.put('knowledge/busines/VC-A/VC-A.md',entity())
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL'))

    def test_directory_host_must_match_declared_parent(self):
        self.valid()
        self.put('knowledge/business/VC-B/VC-B.md',entity('VC-B',relations='- implemented_by: CAP-A'))
        self.put('knowledge/business/VC-A/CAP/CAP-A.md',entity('CAP-A','CAP',relations='- implements_to: VC-B'))
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL','layout'))

    def parent_fixture(self):
        self.config('solution')
        upstream=self.base/'upstream'
        upstream.mkdir()
        (upstream/'.docsconfig').write_text(f'AGENT_ROOT={self.base}\nAGENT_DIR=agents\nREPO_DIR=upstream\nDOC_DIR=docs\nKNOWLEDGE_TYPE=company\n')
        (upstream/'docs').mkdir()
        self.put('knowledge-links.yaml','- type: parent\n  name: upstream\n  repository: https://github.com/test/upstream.git\n  path: ${WORK_SPACE}/upstream\n  dir: docs\n')
        self.put('knowledge/technical/TS-A.md',"""---
type: Technical Service
title: Service
description: Test
tags: [technical, TS]
timestamp: "2026-11-07T00:00:00+08:00"
id: TS-A
perspective: technical
hierarchy: TS
layer_scope: solution
---
<!-- markdownlint-disable-next-line MD025 -->
# Service
## 关系
- implements_to: TPL-A
- implemented_by: MW-A
## 跨视角
## 详细说明
Test
## 依据与证据
Pending
""")
        return upstream

    def test_mdg_without_ds_is_valid(self):
        self.config('solution')
        self.put('knowledge/data/MDG-VAS.md', """---
type: Master Data Domain
title: VAS
description: Test MDG
tags: [data, MDG]
timestamp: "2026-11-07T00:00:00+08:00"
id: MDG-VAS
perspective: data
hierarchy: MDG
layer_scope: solution
---
<!-- markdownlint-disable-next-line MD025 -->
# VAS
## 关系
## 跨视角
## 详细说明
Test.
## 依据与证据
待核实。
""")
        data = self.run_cli()
        self.assertFalse(any(x['rule'] == 'relations.required' and x['path'].endswith('MDG-VAS.md') for x in data['checks']))

    def test_ds_requires_mdg_without_mdg_reverse(self):
        self.config('system')
        self.put('knowledge/data/MDG-VAS.md', """---
type: Master Data Domain
title: VAS
description: Test MDG
tags: [data, MDG]
timestamp: "2026-11-07T00:00:00+08:00"
id: MDG-VAS
perspective: data
hierarchy: MDG
layer_scope: solution
---
<!-- markdownlint-disable-next-line MD025 -->
# VAS
## 关系
## 跨视角
## 详细说明
Test.
## 依据与证据
待核实。
""")
        self.put('knowledge/data/MDG-VAS/DS-VAS/DS-VAS.md', """---
type: Data Store
title: VAS DS
description: Test DS
tags: [data, DS]
timestamp: "2026-11-07T00:00:00+08:00"
id: DS-VAS
perspective: data
hierarchy: DS
layer_scope: system
---
<!-- markdownlint-disable-next-line MD025 -->
# VAS DS
## 关系
- implements_to: MDG-VAS
## 跨视角
## 详细说明
Test.
## 依据与证据
待核实。
""")
        data = self.run_cli()
        self.assertTrue(any(x['rule'] == 'relations.reverse' and x['status'] == 'NOT_APPLICABLE' and 'DS→MDG' in x['evidence'] for x in data['checks']))
        self.assertTrue(any(x['rule'] == 'relations.required' and x['status'] == 'FAIL' and 'implemented_by' in x['evidence'] for x in data['checks']))

    def test_ds_missing_mdg_is_fail(self):
        self.config('system')
        self.put('knowledge/data/MDG-VAS/DS-VAS/DS-VAS.md', """---
type: Data Store
title: VAS DS
description: Test DS
tags: [data, DS]
timestamp: "2026-11-07T00:00:00+08:00"
id: DS-VAS
perspective: data
hierarchy: DS
layer_scope: system
---
<!-- markdownlint-disable-next-line MD025 -->
# VAS DS
## 关系
## 跨视角
## 详细说明
Test.
## 依据与证据
待核实。
""")
        data = self.run_cli()
        self.assertTrue(any(x['rule'] == 'relations.required' and x['status'] == 'FAIL' and 'implements_to' in x['evidence'] for x in data['checks']))

    def test_readable_external_missing_entity_is_fail(self):
        self.parent_fixture()
        data=self.run_cli()
        self.assertTrue(any(x['rule']=='relations.target' and x['status']=='FAIL' and 'TPL-A' in x['evidence'] for x in data['checks']))

    def test_federation_inputs_are_in_snapshot(self):
        upstream=self.parent_fixture()
        data=self.run_cli()
        self.assertIn(str(self.doc/'knowledge-links.yaml'),data['context']['source_hashes'])
        self.assertIn(str(upstream/'.docsconfig'),data['context']['source_hashes'])
        self.assertIn('external_revisions',data['context'])

    def test_multiple_parents_is_context_failure(self):
        self.parent_fixture()
        p=self.doc/'knowledge-links.yaml'
        p.write_text(p.read_text()+p.read_text().replace('upstream','second'))
        self.assertTrue(self.has(self.run_cli(),'context','FAIL','federation'))

    def test_overview_template_not_an_entity(self):
        self.valid()
        self.put('knowledge/overview/NAME-overview.md','---\ntype: Knowledge Overview\ntitle: Overview\n---\n# Overview\n')
        self.assertFalse(self.has(self.run_cli(),'structure','FAIL'))

    def test_nonknowledge_repository_reference_allowed(self):
        self.valid()
        (self.repo/'README.md').write_text('# Root\n')
        self.put('README.md','# Docs\n[Root](../../README.md#root)\n')
        self.assertFalse(self.has(self.run_cli(),'references','FAIL'))

    def test_meta_refresh_requires_context_before_writing(self):
        self.config('meta'); self.valid()
        self.put('index.md','---\nokf_version: \"0.1\"\n---\n# Root\n')
        (self.doc/'agents').symlink_to(ROOT/'agent',target_is_directory=True)
        before={str(p):p.read_bytes() for p in self.doc.rglob('*.md')}
        result=subprocess.run([BASH,str(ROOT/'agent/skills/docs-okf/scripts/okf-indexing.sh'),'--bundle','custom/docs'],cwd=self.repo,text=True,capture_output=True)
        self.assertNotEqual(result.returncode,0)
        self.assertEqual(before,{str(p):p.read_bytes() for p in self.doc.rglob('*.md')})
        self.assertFalse((self.doc/'viz.html').exists())

    def test_calendar_timestamp_invalid(self):
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('2026-11-07','2026-99-99'))
        self.assertTrue(self.has(self.run_cli(),'structure','FAIL'))

    def test_bad_yaml_and_mapping_are_not_strings(self):
        for value in ['"unterminated','{k: v}','[one, two]','123','true','&anchor text']:
            self.put('knowledge/business/VC-A/VC-A.md',entity().replace('description: Test entity','description: '+value))
            self.assertTrue(self.has(self.run_cli(),'structure','FAIL'),value)

    def test_quoted_comment_and_inline_comment_are_valid(self):
        self.put('knowledge/business/VC-A/VC-A.md',entity().replace('description: Test entity','description: "contains # literally" # comment'))
        self.assertFalse(self.has(self.run_cli(),'structure','FAIL'))

    def test_unreadable_context_content_keeps_json(self):
        self.valid()
        for name in ['knowledge-links.yaml','governance/profile.md']:
            p=self.put(name,'temporary')
            p.write_bytes(b'\xff')
            data=self.run_cli()
            self.assertTrue(self.has(data,'context','UNVERIFIED') or self.has(data,'context','FAIL'))
            p.write_text('')

    def test_permission_denied_context_keeps_json(self):
        self.valid()
        for name in ['knowledge-links.yaml','governance/profile.md']:
            p=self.put(name,'temporary')
            p.chmod(0)
            try:
                if os.access(p,os.R_OK):
                    self.skipTest('privileged user bypasses file permissions')
                data=self.run_cli()
                self.assertTrue(any(c['status'] in ('FAIL','UNVERIFIED') for c in data['checks']))
            finally:
                p.chmod(0o600)
                p.write_text('')

    def test_shell_payload_in_config_never_executes(self):
        path=self.repo/'.docsconfig'
        path.write_text(path.read_text().replace('custom/docs', '$(touch /tmp/kv-never-execute)'))
        self.assertTrue(self.has(self.run_cli(),'context','FAIL'))
        self.assertFalse(Path('/tmp/kv-never-execute').exists())


if __name__=='__main__':
    unittest.main()
