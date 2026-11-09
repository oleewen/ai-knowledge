import json
import os
from pathlib import Path
import subprocess
import sys
import unittest
from fixtures import ManifestFixture

ROOT=Path(__file__).resolve().parents[4]
ENTRY=ROOT/'agent/skills/docs-link/scripts/docs-link.sh'

class EntrypointFixture(ManifestFixture):
    def setUp(self):
        super().setUp()
        (self.base/'agents/scripts').symlink_to(ROOT/'agent/scripts', target_is_directory=True)
        for doc, name in ((self.source,'consumer'),(self.target,'provider')):
            subprocess.run(['git','init','-q',str(doc.parent)],check=True)
            subprocess.run(['git','-C',str(doc.parent),'remote','add','origin',f'https://github.com/test/{name}.git'],check=True)

    def run_link(self,*args):
        env={**os.environ,'PYTHONDONTWRITEBYTECODE':'1'}
        return subprocess.run(['/opt/homebrew/bin/bash',str(ENTRY),*args],cwd=self.source.parent,env=env,text=True,capture_output=True)
