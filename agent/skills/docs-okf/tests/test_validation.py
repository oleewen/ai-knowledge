"""校验器须检查保留名索引，即使索引没有 concept frontmatter。"""
from __future__ import annotations

import contextlib
import io
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "scripts"))
from validate_bundle import Validator


class IndexValidationTests(unittest.TestCase):
    def test_root_and_plain_directory_index_links_are_checked_once(self):
        with tempfile.TemporaryDirectory(prefix="okf-index-validation-") as temp:
            bundle = Path(temp)
            (bundle / "knowledge").mkdir()
            (bundle / "index.md").write_text(
                '---\nokf_version: "0.1"\n---\n# Root\n'
                '[missing](missing-root.md)\n[valid](knowledge/index.md#section)\n',
                encoding="utf-8",
            )
            (bundle / "knowledge/index.md").write_text(
                '# Section\n[missing](missing-child.md)\n'
                '[parent](../index.md#root)\n[anchor](#section)\n', encoding="utf-8"
            )
            validator = Validator(bundle)
            errors = io.StringIO()
            with contextlib.redirect_stdout(io.StringIO()), contextlib.redirect_stderr(errors):
                result = validator.run()
            self.assertEqual(result, 0, errors.getvalue())  # 断链维持原有 WARN 契约。
            self.assertEqual(validator.warnings, 2, errors.getvalue())
            self.assertIn("missing-root.md", errors.getvalue())
            self.assertIn("missing-child.md", errors.getvalue())


if __name__ == "__main__":
    unittest.main()
