# docs-build 会话 spec

`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`。占位替换；总确认前 `PENDING`。

## 1. 范围

- `{DOC_DIR}`：
- 视角：`technical,data,business,product` 子集或全
- 主 Index Guide：已确认可用

## 2. 参数

- `--skip-existing` / `--confidence-threshold` / `--emit-report`

## 3. 将写入文件

- `*_knowledge.json`、`README`、`KNOWLEDGE_INDEX.md` …

## 4. 门禁进度（可选）

同 sdx 则锚本节；例 [sdx-solution 模板](../../sdx-solution/assets/solution-session-spec-template.md)。

## 5. Qclose-1

- 用户：**C / M / S**

---

`<!-- docs-build-gate: PENDING -->` → 总确认后 `CONFIRMED`；正文须含 `KNOWLEDGE_INDEX.md` 或目标 `*_knowledge.json` basename。
