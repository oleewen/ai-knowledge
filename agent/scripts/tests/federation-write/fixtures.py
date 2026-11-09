import importlib.util
import os
from pathlib import Path
import sys
import tempfile
import unittest

HERE=Path(__file__).resolve()
sys.path.insert(0,str(HERE.parents[1]/'knowledge-validation'))
sys.path.insert(0,str(HERE.parents[2]/'tools'))
from test_validation import entity
os.environ['KNOWLEDGE_VALIDATION_BASH']='/opt/homebrew/bin/bash'


class ManifestFixture:
    def setUp(self):
        self.temp=tempfile.TemporaryDirectory(); self.addCleanup(self.temp.cleanup)
        self.base=Path(self.temp.name).resolve()
        (self.base/'agents').mkdir(); (self.base/'agents/configs').write_text(f'WORK_SPACE={self.base}\n')
        self.source=self.repo('consumer','solution'); self.target=self.repo('provider','system')
        self.put(self.target,'SYS-A'); self.put(self.target,'SYS-B')

    def module(self):
        self.assertIsNotNone(importlib.util.find_spec('federation_write.manifests'),'缺少共享登记计划器')
        from federation_write import manifests
        return manifests

    def repo(self,name,layer):
        r=self.base/name; (r/'docs').mkdir(parents=True)
        (r/'.docsconfig').write_text(f'AGENT_ROOT={self.base}\nAGENT_DIR=agents\nREPO_DIR={name}\nDOC_DIR=docs\nKNOWLEDGE_TYPE={layer}\n')
        (r/'docs/knowledge-links.yaml').write_text('links: []\n')
        return r/'docs'

    def put(self,doc,eid):
        p=doc/f'knowledge/application/{eid}/{eid}.md'; p.parent.mkdir(parents=True)
        p.write_text(entity(eid,'SYS','application','system','- implements_to: SLN-A'))

    def add(self,ids):
        return self.module().dependency_plan(self.source,self.target,'https://github.com/test/provider.git',ids)
