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
- **F3** 缺意图澄清、写前 C、未确认多写  
- **F4** 缺澄清→生成→烤干或落盘后跳过烤干  
- **F5** 越权承诺 CHANGE-LOG / INDEX  
- **F6** 证据不足  

## 回归

成对：upgrade vs archive、change、indexing；同模式连挂 2 轮 → 收紧 `gates.md` 或 workflow。
