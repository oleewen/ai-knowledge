# docs-upgrade 失败分析器

输入：失败样本 + `SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`。

## 输出

1. 模式  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改处、≥1 回归题）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** archive/change/indexing 混淆  
- **F3** 缺确认、C/S、未确认多写  
- **F4** 缺 主→链→词  
- **F5** 越权承诺 CHANGE-LOG / INDEX  
- **F6** 证据不足  

## 回归

成对：upgrade vs archive、change、indexing；同模式连挂 2 轮 → 收紧规则。
