# docs-indexing 门禁

主干 [SKILL.md](../SKILL.md)；流程 [workflow.md](workflow.md)；节奏 [interaction-gate.md](interaction-gate.md)。

## CONVENTIONS

[CONVENTIONS §artifact-gates](../../../rules/CONVENTIONS.md#artifact-gates)：高风险 → `{DOC_DIR}/superpowers/specs/YYYY-MM-DD-<topic>-docs-indexing.md`，`PENDING`→`CONFIRMED`，Hooks 下 `sdx_gate_common.py --gate indexing`。

## 双层确认

1. **Qclose-1**：`mode`/`depth`/`output`/`since` — **C/M/S**（[workflow.md](workflow.md) 步骤 2）；摘要写入 spec 为佳  
2. **写入**：未 `CONFIRMED` 前禁止工具写受管 `INDEX_GUIDE`、`*/changelogs/INDEXING-LOG`

## 路径证据（多域同名）

多份 `INDEX_GUIDE`、`INDEXING-LOG` 并存时：spec **逐字含**本轮**仓库根相对路径**（如 `application/INDEX_GUIDE.md`），与工具 payload 一致。仅 `basename` 不足。

**会话 spec 目录**：`{DOC_DIR}/superpowers/specs/`，`{DOC_DIR}` 从 **`.docsconfig`** 读取，无效时默认 **`docs`**（见 [session-spec-path.md](../../../references/session-spec-path.md)）。无 `.docsconfig` 时可在同一 spec 中列出多条 INDEX 路径（如根 `INDEX_GUIDE.md` 与 `system/INDEX_GUIDE.md`）。

## 标记

文末 `<!-- docs-indexing-gate: PENDING -->` → 总确认后 `CONFIRMED`。无 env bypass。

## 钩子

[hooks.json](../../../hooks.json)：`python3 agent/hooks/sdx_gate_common.py --gate indexing`。[hooks/README.md](../../../hooks/README.md)。
