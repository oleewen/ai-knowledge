# `rewrite_agent_file` 定向替换与日志行为设计

日期：2026-04-08  
范围：`scripts/docs-init.sh`（仅 `rewrite_agent_file`）  
状态：已确认（待实现）

---

## 1. 背景与目标

当前 `rewrite_agent_file` 会执行两类替换：

- `.agent/ -> agent_slash`
- `system/ -> docs_slash`（不区分大小写）

本次目标是收敛为“最小、可观测、低风险”行为：

1. 非 dry-run：仅保留 `.agent/` 替换
2. 非 dry-run：不再执行 `system/` 替换；若命中则打印 `warn`
3. dry-run：不改文件，打印明细日志（行号 + 原文片段）

---

## 2. 变更边界

- 仅修改 `scripts/docs-init.sh` 中 `rewrite_agent_file`
- 不修改 `rewrite_doc_file`、`rewrite_agent_file`
- 不新增 CLI 参数，不变更 `--type` / `--mode` / `--scope` 语义
- 不调整调用链路与其他安装流程逻辑

---

## 3. 详细设计

### 3.1 非 dry-run 行为

`rewrite_agent_file` 在非 dry-run 分支中：

1. 执行 `.agent/ -> agent_slash`（保持大小写敏感）
2. 仅检测 `system/` 命中（不区分大小写），不执行替换
3. 当且仅当命中 `system/` 时打印 `warn`

### 3.2 dry-run 行为

`rewrite_agent_file` 在 dry-run 分支中：

1. 不落盘修改文件
2. `.agent/`：输出“将替换”明细日志（文件、行号、片段）
3. `system/`：输出“命中但禁用替换”的 `warn` 明细（文件、行号、片段）

### 3.3 日志口径

- `system/` 的 `warn` 触发规则：**仅命中时打印**
- 日志最小字段：文件路径、规则名、行号、原文片段
- 建议对原文片段做单行截断（例如 160 字符）防止刷屏

---

## 4. 验收标准

1. 非 dry-run，文件同时含 `.agent/` 与 `system/`  
   - `.agent/` 被替换  
   - `system/` 不变  
   - 输出 `warn`（含行号与片段）

2. 非 dry-run，文件仅含 `system/`（含大小写变体，如 `System/`）  
   - 文件内容不变  
   - 输出 `warn`

3. dry-run，文件同时含两类命中  
   - 文件无修改  
   - 输出 `.agent/` 将替换明细  
   - 输出 `system/` 命中禁用 `warn` 明细

4. 文件无匹配项  
   - 不输出多余 `warn`  
   - 无副作用

---

## 5. 风险与规避

- 风险：历史依赖 `system/ -> docs_slash` 的最小模板内容将不再被改写  
  规避：通过 `warn` 明确暴露命中点，便于人工确认

- 风险：日志过多影响可读性  
  规避：统一字段、限制片段长度、保持“仅命中打印”

---

## 6. 非目标

- 不恢复或新增 `system/` 替换开关
- 不改动其他替换函数语义
- 不扩展为全局日志配置系统

---

## 7. 结论

本设计以最小改动将 `rewrite_agent_file` 调整为“仅执行 `.agent/` 替换 + 对 `system/` 命中告警”，并在 dry-run 下提供可审计的明细日志，从而兼顾稳定性与可观测性。
