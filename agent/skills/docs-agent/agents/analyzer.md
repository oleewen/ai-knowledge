# docs-agent 失败分析器

输入：失败样本（prompt、分类、响应、grader evidence）+ `SKILL.md`、`gates`、`workflow`、`intent-clarify`、`execution-spec`、`gotchas`。

## 输出

1. 失败模式归类  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改处、预期影响、≥1 回归用例）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** 与 docs-indexing / docs-build / sdx-solution / docs-upgrade 混淆  
- **F3** 协议执行：缺参数向导、跳过写前意图澄清、未按当前单元停顿、未做烤干  
- **F4** 结构：顺序/三文件校验/缺失  
- **F5** INDEX 幻觉  
- **F6** 证据不足  

## 回归

1. P0 后跑全 `evals/evals.json`  
2. 成对：`/docs-agent` vs indexing、sdx-solution  
3. 同模式连挂 2 轮 → 收紧 `description` 或 `gates.md`
