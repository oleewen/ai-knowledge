# docs-change 失败分析器（analyzer）

将失败样本转成可执行修复清单。

## 输入

失败样本（prompt、期望分类、响应、grader 证据）及 `SKILL.md`、`references/gates.md`、`workflow.md`、`anti-patterns.md`、`gotchas.md`。

## 输出

1. 失败模式归类  
2. 根因与证据  
3. **P0/P1/P2** 修复策略（目标、最小改动位置、影响、≥1 条回归用例）  
4. 回归评测建议  

## 模式（可多选）

- `F1` 路由误判  
- `F2` 边界混淆（docs-indexing / docs-build vs docs-change）  
- `F3` 基线遗漏（未读 `baseline_time_ms`、混用 baseline/cutoff）  
- `F4` 结构缺失（五步、三源、前插倒序）  
- `F5` 禁止产物（声称写 index 或改实体）  
- `F6` 证据不足  

## 回归

1. 先 P0 再全量  
2. 成对：`/docs-change` vs `/docs-indexing`、`/docs-build`  
3. 同模式连续 2 轮失败 → 考虑重写规则条文  
