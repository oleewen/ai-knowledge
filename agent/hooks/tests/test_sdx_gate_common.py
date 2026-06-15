import json
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1]))

from agent.hooks.sdx_gate_common import _has_confirmed_spec, run_gate


class GateCommonTests(unittest.TestCase):
    def test_has_confirmed_spec_avoids_substring_false_positive(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            specs_dir = repo / "application" / "superpowers" / "specs"
            specs_dir.mkdir(parents=True, exist_ok=True)
            spec = specs_dir / "S-1.md"
            spec.write_text(
                "<!-- sdx-prd-gate: CONFIRMED -->\n"
                "本次确认文件：PRD-2026-foo-v2.md\n",
                encoding="utf-8",
            )

            self.assertFalse(
                _has_confirmed_spec(
                    repo,
                    "<!-- sdx-prd-gate: CONFIRMED -->",
                    "PRD-2026-foo.md",
                    None,
                    None,
                )
            )

    def test_has_confirmed_spec_accepts_exact_basename(self) -> None:
        with tempfile.TemporaryDirectory() as tmp:
            repo = Path(tmp)
            specs_dir = repo / "application" / "superpowers" / "specs"
            specs_dir.mkdir(parents=True, exist_ok=True)
            spec = specs_dir / "S-2.md"
            spec.write_text(
                "<!-- sdx-prd-gate: CONFIRMED -->\n"
                "- PRD-2026-foo.md\n",
                encoding="utf-8",
            )

            self.assertTrue(
                _has_confirmed_spec(
                    repo,
                    "<!-- sdx-prd-gate: CONFIRMED -->",
                    "PRD-2026-foo.md",
                    None,
                    None,
                )
            )

    def test_run_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-abc.md"},
            "sessionId": "s1",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("prd", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_run_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-abc.md"},
            "sessionId": "s2",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "application" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "ok.md").write_text(
                    "<!-- sdx-prd-gate: CONFIRMED -->\nPRD-abc.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("prd", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    # ------------------------------------------------------------------
    # docs-distill / docs-extract / docs-archive gate 测试
    # ------------------------------------------------------------------

    def test_distill_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/billing-overview.md"},
            "sessionId": "s-distill-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("distill", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_distill_gate_deny_company_ea_overview_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "company/ea/overview/COMPANY-overview.md"},
            "sessionId": "s-distill-ea-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "company" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("distill", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_distill_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/billing-overview.md"},
            "sessionId": "s-distill-allow",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "system" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "distill-spec.md").write_text(
                    "<!-- docs-distill-gate: CONFIRMED -->\nbilling-overview.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("distill", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_distill_gate_no_bypass_via_env(self) -> None:
        """distill gate 无 bypass 环境变量，设置任意值均不应放行（仍走证据校验）。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/billing-overview.md"},
            "sessionId": "s-distill-bypass",
        }
        # 即使设置了类似 bypass 的环境变量，也不应放行（因为 bypass_env="" 被跳过）
        env = {"DOCS_DISTILL_ALLOW_WRITE": "1"}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("distill", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        # 无 confirmed spec，应 deny（不被环境变量绕过）
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_extract_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/payment-overview.md"},
            "sessionId": "s-extract-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("extract", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_extract_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/payment-overview.md"},
            "sessionId": "s-extract-allow",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "system" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "extract-spec.md").write_text(
                    "<!-- docs-extract-gate: CONFIRMED -->\npayment-overview.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("extract", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_archive_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/order-overview.md"},
            "sessionId": "s-archive-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("archive", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_archive_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "system/architecture/overview/order-overview.md"},
            "sessionId": "s-archive-allow",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "system" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "archive-spec.md").write_text(
                    "<!-- docs-archive-gate: CONFIRMED -->\norder-overview.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("archive", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_overview_outside_path_not_intercepted(self) -> None:
        """非 system/architecture/overview/ 或 company/ea/overview/ 路径的 overview 文件不被 distill/extract/archive gate 拦截。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "docs/some-overview.md"},
            "sessionId": "s-outside",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("distill", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        # 路径不在受管范围，应 allow
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    # ------------------------------------------------------------------
    # docs-build gate 测试
    # ------------------------------------------------------------------

    def test_build_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/knowledge/KNOWLEDGE_INDEX.md"},
            "sessionId": "s-build-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("build", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_build_gate_allow_with_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/knowledge/KNOWLEDGE_INDEX.md"},
            "sessionId": "s-build-allow",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "application" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "build-spec.md").write_text(
                    "<!-- docs-build-gate: CONFIRMED -->\nKNOWLEDGE_INDEX.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("build", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_build_gate_intercepts_json(self) -> None:
        """build gate 应拦截 knowledge/ 下的 .json 文件写入。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/knowledge/application/application_knowledge.json"},
            "sessionId": "s-build-json",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("build", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_build_gate_no_bypass_via_env(self) -> None:
        """build gate 无 bypass 环境变量，设置任意值均不应放行。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/knowledge/KNOWLEDGE_INDEX.md"},
            "sessionId": "s-build-bypass",
        }
        env = {"DOCS_BUILD_ALLOW_WRITE": "1"}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("build", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_indexing_gate_deny_without_confirmed_spec(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/INDEX_GUIDE.md"},
            "sessionId": "s-indexing-deny",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("indexing", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_indexing_gate_deny_confirmed_without_full_path(self) -> None:
        """仅有 CONFIRMED + basename 不足；须正文含仓库根相对路径。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/INDEX_GUIDE.md"},
            "sessionId": "s-indexing-deny-path",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "application" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "ix.md").write_text(
                    "<!-- docs-indexing-gate: CONFIRMED -->\n仅提及 INDEX_GUIDE.md 无目录前缀\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("indexing", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "deny"' in s for s in printed))

    def test_indexing_gate_allow_with_confirmed_spec_and_path(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/INDEX_GUIDE.md"},
            "sessionId": "s-indexing-allow",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "application" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "ix-spec.md").write_text(
                    "<!-- docs-indexing-gate: CONFIRMED -->\n"
                    "本轮写入：\n"
                    "- application/INDEX_GUIDE.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("indexing", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_indexing_gate_intercepts_indexing_log(self) -> None:
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/changelogs/INDEXING-LOG.md"},
            "sessionId": "s-indexing-log",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                specs_dir = repo / "application" / "superpowers" / "specs"
                specs_dir.mkdir(parents=True, exist_ok=True)
                (specs_dir / "ix2.md").write_text(
                    "<!-- docs-indexing-gate: CONFIRMED -->\n"
                    "application/changelogs/INDEXING-LOG.md\n",
                    encoding="utf-8",
                )
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("indexing", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_indexing_log_outside_changelogs_not_intercepted(self) -> None:
        """非 */changelogs/ 路径下的 INDEXING-LOG.md 不由 indexing gate 收集。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "docs/INDEXING-LOG.md"},
            "sessionId": "s-indexing-outside",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("indexing", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))

    def test_knowledge_outside_path_not_intercepted(self) -> None:
        """非 /knowledge/ 路径的文件不被 build gate 拦截。"""
        payload = {
            "toolName": "write_file",
            "args": {"path": "application/requirements/PRD-abc.md"},
            "sessionId": "s-build-outside",
        }
        env = {}

        with patch("agent.hooks.sdx_gate_common.is_session_active", return_value=True), patch(
            "agent.hooks.sdx_gate_common._repo_root"
        ) as mock_repo_root:
            with tempfile.TemporaryDirectory() as tmp:
                repo = Path(tmp)
                (repo / "application" / "superpowers" / "specs").mkdir(parents=True, exist_ok=True)
                mock_repo_root.return_value = repo
                with patch("builtins.print") as mock_print:
                    code = run_gate("build", stdin=json.dumps(payload), environ=env)

        self.assertEqual(code, 0)
        printed = [args[0] for args, _kwargs in mock_print.call_args_list if args]
        self.assertTrue(any('"permission": "allow"' in s for s in printed))


if __name__ == "__main__":
    unittest.main()
