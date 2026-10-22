"""Check that the shipped suite is consumable; this is not a skill behavior test."""

import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "scripts" / "run_evals.py"


class ShippedSuiteTests(unittest.TestCase):
    def test_default_suite_resolves_outside_repository(self):
        with tempfile.TemporaryDirectory() as directory:
            proc = subprocess.run(
                [sys.executable, "-B", str(RUNNER), "validate"],
                cwd=directory, capture_output=True, text=True, encoding="utf-8", timeout=10,
            )
        self.assertEqual(proc.returncode, 0, proc.stderr + proc.stdout)
        report = json.loads(proc.stdout)
        self.assertEqual(report["status"], "validated")
        self.assertGreater(report["cases"], 0)
        self.assertNotIn("passed", report)

    def test_metadata_template_cannot_be_scored_as_completed_results(self):
        proc = subprocess.run(
            [sys.executable, "-B", str(RUNNER), "score", "--results",
             str(ROOT / "evals" / "eval-metadata-template.json")],
            capture_output=True, text=True, encoding="utf-8", timeout=10,
        )
        self.assertEqual(proc.returncode, 2)
        self.assertEqual(json.loads(proc.stdout)["status"], "error")


if __name__ == "__main__":
    unittest.main()
