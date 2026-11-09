import json
from pathlib import Path
import unittest

ROOT=Path(__file__).parent
PROJECT_ROOT=Path(__file__).resolve().parents[4]
class BehaviorEvalSpecTests(unittest.TestCase):
    def test_suite_has_ten_unique_scenarios_and_isolation_contract(self):
        data=json.loads((ROOT/'scenarios.json').read_text())
        self.assertEqual(len(data),10)
        ids=[x['id'] for x in data]
        self.assertEqual(len(ids),len(set(ids)))
        for case in data:
            self.assertTrue(case['prompt'])
            self.assertIn('marker',case)
            self.assertIn('required',case['marker'])
            self.assertTrue(case['skill'])
            self.assertIn('expected_status',case)
            self.assertTrue((PROJECT_ROOT/case['entry']).is_file(), case['entry'])

if __name__=='__main__': unittest.main()
