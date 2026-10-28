"""BSD-L2 路径必须来自显式宿主或已核实落点，不能从子 ID 猜父名。"""
from pathlib import Path
import sys
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT / "agent/skills/docs-okf/scripts"))
import okf_lib
import okf_cross_layer as cross
from test_okf_cross_layer import configure


class SolutionBSDPathsTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.child = self.root / "system"
        self.parent = self.root / "solution"
        configure(self.child, self.root, "system")
        configure(self.parent, self.root, "solution")
        cross.write_parent(self.child, cross.Parent(
            "solution", "https://github.com/org/solution.git", str(self.parent),
            ".", parent_name="solution"))
        self.base = "https://github.com/org/solution/blob/main/"

    def write_entity(self, host):
        target = self.parent / "knowledge/business" / host / "BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md"
        target.parent.mkdir(parents=True)
        target.write_text("---\nid: BSD-PAYMENTS-L2\n---\n## 关系\n- parent: BSD-FINANCE\n")
        return target

    def test_new_entity_uses_differently_named_parent(self):
        self.assertEqual(okf_lib.entity_relpath(
            "business", "BSD-PAYMENTS-L2", path_parent="BSD-FINANCE", bundle="solution"),
            "knowledge/business/BSD-FINANCE/BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md")

    def test_new_entity_without_host_is_rejected(self):
        with self.assertRaises(ValueError):
            okf_lib.entity_relpath("business", "BSD-PAYMENTS-L2", bundle="solution")

    def test_new_entity_rejects_non_l1_host(self):
        for host in ("..", "APP-FINANCE", "BSD-FINANCE-L2", "BSD-FINANCE-L3"):
            with self.subTest(host=host), self.assertRaises(ValueError):
                okf_lib.entity_relpath("business", "BSD-PAYMENTS-L2", path_parent=host, bundle="solution")

    def test_existing_legacy_host_is_preserved_and_validated(self):
        target = self.write_entity("BSD-LEGACY-L1")
        expected = self.base + "knowledge/business/BSD-LEGACY-L1/BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md"
        self.assertEqual(cross.cross_layer_href(self.child, "BSD-PAYMENTS-L2"), expected)
        self.assertIsNone(cross.validate_http_href(self.child, expected))
        self.assertTrue(target.is_file())
        self.assertIsNotNone(cross.validate_http_href(
            self.child, expected.replace("BSD-LEGACY-L1", "BSD-PAYMENTS-L1")))

    def test_conflicting_explicit_host_does_not_override_existing_path(self):
        self.write_entity("BSD-LEGACY-L1")
        self.assertIsNone(cross.cross_layer_href(
            self.child, "BSD-PAYMENTS-L2", path_parent="BSD-FINANCE"))

    def test_missing_local_entity_does_not_guess_host(self):
        self.assertIsNone(cross.cross_layer_href(self.child, "BSD-PAYMENTS-L2"))

    def test_duplicate_id_is_a_conflict_even_with_explicit_host(self):
        self.write_entity("BSD-ONE")
        self.write_entity("BSD-TWO")
        for host in (None, "BSD-ONE"):
            with self.subTest(host=host), self.assertRaises(ValueError):
                cross.cross_layer_href(self.child, "BSD-PAYMENTS-L2", path_parent=host)
        error = cross.validate_http_href(self.child, self.base +
            "knowledge/business/BSD-ONE/BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md")
        self.assertIsNotNone(error)
        self.assertIn("BSD-ONE", error)
        self.assertIn("BSD-TWO", error)

    def test_explicit_host_cannot_relocate_existing_flat_entity(self):
        target = self.parent / "knowledge/business/BSD-PAYMENTS-L2.md"
        target.parent.mkdir(parents=True)
        target.write_text("---\nid: BSD-PAYMENTS-L2\n---\n## 关系\n- parent: BSD-FINANCE\n")
        self.assertIsNone(cross.cross_layer_href(
            self.child, "BSD-PAYMENTS-L2", path_parent="BSD-FINANCE"))

    def test_existing_noncanonical_file_does_not_generate_missing_nested_path(self):
        target = self.parent / "knowledge/business/BSD-FINANCE/BSD-PAYMENTS-L2.md"
        target.parent.mkdir(parents=True)
        target.write_text("---\nid: BSD-PAYMENTS-L2\n---\n## 关系\n- parent: BSD-FINANCE\n")
        self.assertIsNone(cross.cross_layer_href(self.child, "BSD-PAYMENTS-L2"))

    def test_offline_parent_requires_explicit_host(self):
        cross.write_parent(self.child, cross.Parent(
            "solution", "https://github.com/org/solution.git", str(self.root / "offline"),
            ".", parent_name="solution"))
        self.assertIsNone(cross.cross_layer_href(self.child, "BSD-PAYMENTS-L2"))
        self.assertEqual(cross.cross_layer_href(
            self.child, "BSD-PAYMENTS-L2", path_parent="BSD-FINANCE"),
            self.base + "knowledge/business/BSD-FINANCE/BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md")

    def test_offline_validation_rejects_missing_or_invalid_host_structure(self):
        cross.write_parent(self.child, cross.Parent(
            "solution", "https://github.com/org/solution.git", str(self.root / "offline"),
            ".", parent_name="solution"))
        for path in (
            "knowledge/business/BSD-PAYMENTS-L2.md",
            "knowledge/business/A/B/C/BSD-PAYMENTS-L2.md",
            "knowledge/business/BSD-FINANCE/OTHER/BSD-PAYMENTS-L2.md",
            "knowledge/business/../BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md",
        ):
            with self.subTest(path=path):
                self.assertIsNotNone(cross.validate_http_href(self.child, self.base + path))
        self.assertIsNone(cross.validate_http_href(self.child, self.base +
            "knowledge/business/BSD-FINANCE/BSD-PAYMENTS-L2/BSD-PAYMENTS-L2.md"))


if __name__ == "__main__":
    unittest.main()
