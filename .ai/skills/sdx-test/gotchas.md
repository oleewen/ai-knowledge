# sdx-test 常见陷阱（Gotchas）

执行 `sdx-test` Skill 时高频踩坑点，供 Agent 与人类参考。工作流算法见 [reference/workflow-spec.md](reference/workflow-spec.md)。

---

## 1. 输入与前置条件

### 1.1 无 PRD 直接写 TDD

**陷阱**：仅有口头需求或 ADD 片段就开写测试设计。  
**后果**：用例无法追溯到 US-n / FR-n，评审与验收无锚点。  
**正确做法**：以 `PRD-{YYMMDD}-{主题slug}.md` 为硬输入；缺失则终止并提示先执行 `sdx-prd`。

### 1.2 无 ADD 仍按「完整接口覆盖」编造路径

**陷阱**：ADD 不存在时，仍假设大量 API 路径与错误码。  
**后果**：与真实设计不一致，开发与测试双返工。  
**正确做法**：无 ADD 时在 TDD 概述中显式标注「缺少 ADD 基线」，接口类用例收缩为 PRD 已声明边界；待 ADD 补齐后再扩展 TC-API-*。

### 1.3 `--doc-root` 与仓库实际布局不一致

**陷阱**：校验脚本在错误根目录下查找 `TDD-*.md`，误判「未产出」。  
**后果**：CI 或本地校验失效。  
**正确做法**：本仓库默认产出在 `system/requirements/...`；执行 [scripts/validate-test.sh](scripts/validate-test.sh) 时传入 `--doc-root system`（旧布局用 `docs`）。

---

## 2. 用例与追溯

### 2.1 臆测用例、无 US/API/BR 锚点

**陷阱**：表格填满 TC 编号，但「关联故事」或 API 列为空或泛写。  
**后果**：不可追溯，违反质量门禁。  
**正确做法**：每个 TC 至少关联 US-n、或 ADD 中 API 规约、或 BR-n；做不到则标为待澄清项。

### 2.2 仅 happy path，忽略异常与边界

**陷阱**：§2.4、§2.5 留空且未标「不适用」。  
**后果**：上线后缺陷集中出现在异常与并发场景。  
**正确做法**：按 `workflow-spec` 中 depth 要求覆盖；若无 NFR 或未要求性能/安全测试，§2.5 显式写「不适用」及原因。

### 2.3 回归范围与 ADD 影响面脱节

**陷阱**：§2.6 只写「全量回归」或泛泛列举模块。  
**后果**：要么浪费工时，要么漏测间接影响。  
**正确做法**：回归用例与 ADD 影响面分析对齐，标注直接影响 / 间接影响与优先级（P0 核心链优先）。

---

## 3. 范围与产出物

### 3.1 在 TDD 中写自动化脚本或可执行测试代码

**陷阱**：把本阶段当成「写 Playwright/JUnit」。  
**后果**：混淆设计阶段与实现阶段；模板章节被代码挤占。  
**正确做法**：仅产出 `TDD-*.md`；自动化实现留在开发流程与代码仓。

### 3.2 跳过或重排模板章节

**陷阱**：合并 §3–§4 或省略 §6 变更历史。  
**后果**：`validate-test.sh` 与门禁失败，下游无法快速定位章节。  
**正确做法**：严格遵循 [assets/tdd-template.md](assets/tdd-template.md)；无内容章节保留标题并写「不适用」或「待补充」。

### 3.3 忽略 `--depth`

**陷阱**：`quick` 仍展开性能、安全与大套异常矩阵。  
**后果**：小迭代成本过高；`deep` 又过薄。  
**正确做法**：depth 对步骤 2 的影响以 [reference/workflow-spec.md](reference/workflow-spec.md) 为准。

---

## 4. 阅读策略

### 4.1 为「完整性」通读 knowledge 或全仓

**陷阱**：步骤 1 起递归打开大量与本轮 MVP 无关的文档。  
**后果**：上下文膨胀、幻觉风险上升。  
**正确做法**：按 `design-principles` 的按需加载；仅读当前 PRD/MVP、对应 ADD 与必要规约。

---

## 5. 质量门禁与脚本

### 5.1 未执行清单勾选即宣称「完成」

**陷阱**：跳过 [reference/quality-checklist.md](reference/quality-checklist.md)。  
**后果**：frontmatter、子章节或追溯字段遗漏。  
**正确做法**：步骤 5 必须逐项自查；必要时运行 `validate-test.sh`。
