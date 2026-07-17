# docs-distill 失败分析器

输入：失败样本 + `SKILL.md`、`gates`、`workflow`、`intent-clarify`、`anti-patterns`、`gotchas`。

## 输出

1. 模式归类  
2. 根因 + 证据  
3. **P0/P1/P2** 修复（目标、最小改处、影响、≥1 回归样本）  
4. 回归建议  

## 模式（可多选）

- **F1** 路由误判  
- **F2** extract/archive/索引 混淆为完整 distill 写盘  
- **F3** 缺参数向导、跳过写前意图澄清或当前单元  
- **F4** 缺双日志顺序、overview -> `DISTILL-LOG` 原子性  
- **F5** 语义变更未确认或未停下等待 `C/M/G/S/F`  
- **F6** 证据不足  

## 回归

1. P0 后全 `evals`  
2. 成对：distill vs extract / archive / `sdx-*`  
3. 同模式连挂 2 轮 → 收紧规则而非只改话术  
4. 修复优先补参数向导、当前单元、日志原子性与动作停顿
