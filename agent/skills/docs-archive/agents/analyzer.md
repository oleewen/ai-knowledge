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
- **F3** 缺当前确认书或当前单元  
- **F4** 缺步骤、回写、冲突清单或动作停顿  
- **F5** 语义变更未确认即宣称已写目标  
- **F6** 证据不足  

## 回归

1. P0 后全量 `evals/evals.json`  
2. 成对：archive vs extract / build / upgrade  
3. 同模式连挂 2 轮 → 收紧规则或 `gates.md`
4. 修复优先补确认书收口、回写顺序、断链处理与动作停顿
