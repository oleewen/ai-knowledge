# sdx-analysis 评测失败分析（analyzer）

将失败样本转为可执行修复清单。

## 输入

失败样本（prompt、分类、响应、grader 证据）；[SKILL.md](../SKILL.md)；[references/gates.md](../references/gates.md)、[references/workflow.md](../references/workflow.md)、[references/anti-patterns.md](../references/anti-patterns.md)、[gotchas.md](../gotchas.md)。

## 输出（四段）

1. 失败模式归类
2. 根因与证据
3. 优先级修复
4. 回归建议

## 失败类型（可多选）

- **F1 路由**：should-trigger / should-not-trigger 误判
- **F2 边界**：SOLUTION、PRD、ASD、DSD、TDD 与 ANALYSIS 混淆
- **F3 协议回退**：退回会话 spec、`Qclose-1`、`PENDING/CONFIRMED`、写前 gate/hook
- **F4 当前段协议缺失**：缺参数向导、意图澄清、Section Cycle「澄清 → 生成 → 烤干」、`C/M/G/F`、单段停住
- **F5 语义越权**：语义性结论未确认就直接修订当前段或前文
- **F6 证据**：断言难以复核或样本覆盖不足
- **F7 意图澄清缺失**：跳过写前六项清单/写前 `C` 直接写正文

## 修复（P0/P1/P2）

- **P0**：误路由、协议回退、意图澄清/单段停住缺失、语义越权
- **P1**：边界不清、结构不全、与 SOLUTION 衔接弱
- **P2**：文案与样本覆盖

每条须含：目标、最小变更（文件/段）、预期影响、至少 1 个回归用例。

## 回归

1. 先跑 P0 样本，再跑全量
2. 成对验证：`/sdx-analysis` vs `/sdx-solution`、`/sdx-prd`、`/sdx-architect`、docs-*
3. 同模式两轮失败，优先考虑协议级重写而非堆补丁
