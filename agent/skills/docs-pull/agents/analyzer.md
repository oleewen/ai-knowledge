# docs-pull 失败分析器

输入：失败样本 + `SKILL.md`、`gates`、`workflow`、`anti-patterns`、`gotchas`。

## 输出

1. 模式  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改动、≥1 回归题）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** pull vs distill/extract/archive  
- **F3** 虚构 spec gate / 钩子  
- **F4** 缺 HARD-GATE、pull-log、manifest 复述  
- **F5** 静默扫多 app  
- **F6** 证据不足  

## 回归

成对：**/docs-pull** vs **/docs-distill**、vs **/docs-extract**。
