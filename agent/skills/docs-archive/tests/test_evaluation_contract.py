"""Validate grader calibration inputs, not the semantic correctness of a model."""

import json
from pathlib import Path
import sys
import unittest


ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))
from codex_adapter import prepare  # noqa: E402
from run_evals import fingerprint, read_json, score_case, validate_suite  # noqa: E402


class CalibrationContractTests(unittest.TestCase):
    def setUp(self):
        self.suite = read_json(ROOT / "evals" / "evals.json")
        self.cases = validate_suite(self.suite)
        self.calibration = read_json(ROOT / "evals" / "grader-calibration.json")

    def test_calibration_is_bound_to_suite_and_covers_every_assertion(self):
        self.assertEqual(self.calibration["suite_sha256"], fingerprint(self.suite))
        samples = self.calibration["samples"]
        self.assertTrue(samples)
        self.assertEqual(len({sample["id"] for sample in samples}), len(samples))
        for sample in samples:
            with self.subTest(sample=sample["id"]):
                case = self.cases[sample["case_id"]]
                expected = sample["expected_passed"]
                self.assertEqual(set(expected), {a["id"] for a in case["assertions"]})
                self.assertTrue(all(type(value) is bool for value in expected.values()))
                self.assertTrue(sample["rationale"].strip())
                result = {
                    "eval_id": case["id"], "response": sample["response"],
                    "judgments": [{"id": key, "passed": value,
                                   "evidence": sample["rationale"]}
                                  for key, value in expected.items()],
                }
                self.assertIn(score_case(case, result)["status"], {"passed", "failed"})

    def test_samples_use_real_grader_protocol_without_expected_answers(self):
        for sample in self.calibration["samples"]:
            with self.subTest(sample=sample["id"]):
                payload = {
                    "case": self.cases[sample["case_id"]], "response": sample["response"],
                    "grader_path": str(ROOT / "agents" / "grader.md"),
                }
                case_id, prompt, schema, _ = prepare("grader", payload)
                self.assertEqual(case_id, sample["case_id"])
                data = json.loads(prompt.split("\n")[-1])
                self.assertEqual(data, {"case": payload["case"], "response": sample["response"]})
                self.assertEqual(schema["properties"]["eval_id"]["enum"], [case_id])


if __name__ == "__main__":
    unittest.main()
