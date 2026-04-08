# docs-init `rewrite_agent_file` system 跳过替换设计

日期：2026-04-08  
范围：`scripts/docs-init.sh`  
状态：已评审（待实现）

---

## 1. 背景与目标

当前 `rewrite_agent_file()` 会同时执行两类替换：

- `.agent/ -> agent_slash`
- `system/ -> docs_slash`（不区分大小写）

本次目标是仅调整 Agent 树替换策略：

- 保持 `.agent/ -> agent_slash` 正常执行
- `system/`（不区分大小写）不再替换
- 每命中一次 `system/` 都打印一条 `warn` 日志

---

## 2. 用户确认结论

已确认的需求选项：

1. 跳过方式：匹配级跳过（仅跳过 `system/` 的替换，`.agent/` 继续替换）
2. 日志级别：`warn`
3. 日志频率：每个匹配打印一次（不按文件聚合）

---

## 3. 方案对比与选型

### 3.1 方案 A（采用）

两阶段处理：

1. 第一阶段仅替换 `.agent/`
2. 第二阶段仅扫描 `system/` 并逐匹配输出日志，不做替换

优点：改动小、可读性高、与现有脚本结构一致。  
缺点：每文件增加一次扫描开销（可接受）。

### 3.2 备选方案（未采用）

- 单次 Perl 同时替换和日志：可行，但可读性差、转义复杂，维护成本高。

---

## 4. 详细设计

### 4.1 修改点

仅修改 `scripts/docs-init.sh` 的 `rewrite_agent_file()`，其余函数不变。

### 4.2 行为定义

- 输入前置：保持现有 `[[ -f "$file" ]] && is_text_file "$file"` 校验不变。
- Perl 依赖：保持现有 `have_perl || return 0` 不变。
- 内容替换：
  - 保留：`s{\.agent/}{$ENV{SDX_AGENT_SLASH}}g`
  - 删除：`s{system/}{$ENV{SDX_DOCS_SLASH}}gi`
- 日志输出：
  - 对文件内容中每个 `system/`（`gi`）匹配输出一条 `warn`
  - 日志建议格式：`警告: rewrite_agent_file 跳过 system/ 替换: <file>`
- 后处理：继续调用 `rewrite_docs_prefix_to_doc_dir "$file" "$docs_slash"`，保持调用链兼容。

---

## 5. 验收标准

1. 文件包含 `.agent/` 与 `SYSTEM/`：
   - `.agent/` 被替换
   - `SYSTEM/` 保持不变
   - 日志输出命中次数与 `SYSTEM/`/`system/` 总匹配数一致
2. 文件仅包含 `.agent/`：
   - 正常替换
   - 无新增 `system/` 跳过日志
3. 文件不含任何匹配项：
   - 无内容改写副作用
   - 无新增日志

---

## 6. 风险与规避

- 风险：逐匹配日志在高密度文件中会较多。  
  规避：这是已确认行为，不在本次设计内引入开关。

- 风险：后续维护误把 `system/` 替换加回。  
  规避：在函数注释中明确“Agent 树不替换 `system/`，仅记录日志”。

---

## 7. 非目标

- 不变更 `rewrite_doc_file()` / `rewrite_doc_file_minimal()` 的替换逻辑
- 不新增 CLI 参数、环境变量或兼容开关
- 不调整 `install_agent_skills()` / `install_agent_rules()` 调用时序

---

## 8. 结论

采用“两阶段（替换 + 扫描日志）”的最小改动方案，可以准确满足本次需求：在 Agent 树中继续处理 `.agent/`，并对 `system/` 执行“仅告警不替换”。
