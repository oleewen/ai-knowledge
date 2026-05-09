# docs-tag — analyzer

样本 → P0/P1/P2 修复项。

## 输入

prompt、期望类、响应、grader 证据；`SKILL.md`、`gates.md`、`workflow.md`、`gotchas.md`。

## 输出

1. 模式  
2. 根因 + 证据  
3. 优先级修复  
4. 回归建议  

## 模式（多选）

- F1 路由误判  
- F2 与 extract/upgrade/indexing 混  
- F3 未复述参数就开写  
- F4 `--phase 1`/无 `1-scan`·`1-write`  
- F5 旧路径 `skills/docs-tag/`  
- F6 证据薄  

## 修复条

每条：目标 · 最小改动 · 影响 · ≥1 回归 eval。

## 回归

先 P0 再全 evals；`/docs-tag` vs extract vs upgrade；`cd agent/skills/docs-tag && python3 -m pytest tests/ -q`。
