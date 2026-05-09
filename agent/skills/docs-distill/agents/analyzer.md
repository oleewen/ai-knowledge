# docs-distill 失败分析器

输入：失败样本 + `SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`。

## 输出

1. 模式归类  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改处、影响、≥1 回归样本）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** extract/archive/索引 混淆为完整 distill 写盘  
- **F3** 门禁：缺 CONFIRMED / 例外 / `DOCS_DISTILL_ALLOW_WRITE`  
- **F4** 缺：五阶段、双日志、4.3→4.4  
- **F5** 未确认自称写完  
- **F6** 证据不足  

## 回归

1. P0 后全 `evals`  
2. 成对：distill vs extract / archive / `sdx-*`  
3. 同模式连挂 2 轮 → 收紧规则而非只改话术  
