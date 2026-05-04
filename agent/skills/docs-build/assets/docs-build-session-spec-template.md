# docs-build 会话 spec 骨架

路径：`docs/superpowers/specs/YYYY-MM-DD-<topic>-docs-build.md`

复制后替换占位；总确认前保留 `PENDING`。

---

## 1. 背景与范围

- `{DOC_DIR}`：`<路径或说明>`
- 本轮视角：`<technical,data,business,product 子集或全部>`
- 主 Index Guide：`<已确认可用>`

## 2. 参数

- `--skip-existing`：`<true|false>`
- `--confidence-threshold`：`<high|medium|low>`
- `--emit-report`：`<true|false>`

## 3. 将写入的文件清单

- `<列出各视角 *_knowledge.json / README.md / KNOWLEDGE_INDEX.md 等>`

## 4. 门禁进度（可选）

与 `sdx-*` 同构时锚到本文件内小节。示例见 [`sdx-solution` 会话模板](../../sdx-solution/assets/solution-session-spec-template.md)「门禁进度」。

## 5. Qclose-1 记录

- 用户选择：`<C / M / S>`

---

<!-- docs-build-gate: PENDING -->

（总确认后：`<!-- docs-build-gate: CONFIRMED -->`，且正文须含 `KNOWLEDGE_INDEX.md` 或目标 `*_knowledge.json` basename。）
