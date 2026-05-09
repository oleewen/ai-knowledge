# docs-archive 失败分析器

输入：失败样本 + `SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`。

## 输出

1. 模式归类  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改处、影响、≥1 回归用例）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** 与 extract / distill / upgrade / build 混淆  
- **F3** 门禁：HARD-GATE、确认书、PENDING/CONFIRMED、明示例外  
- **F4** 缺步骤 0～6、回写、冲突清单  
- **F5** 未确认即宣称已写目标  
- **F6** 证据不足  

## 回归

1. P0 后全量 `evals/evals.json`  
2. 成对：archive vs extract / build / upgrade  
3. 同模式连挂 2 轮 → 收紧规则或 `gates.md`
