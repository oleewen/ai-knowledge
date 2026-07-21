# Trigger eval harness note

## 2026-07-20 首轮

套件：`evals/evals.json`（should-trigger ×3 + should-not-trigger ×2）。

| 焦点 | eval id |
| --- | --- |
| 全流程 + ABC + SSOT 确认 | simplify-trigger-001 |
| 仅本文件快路径 | simplify-trigger-002 |
| 与 docs-upgrade 双目标分流 | simplify-trigger-003 |
| 勿抢 upgrade | simplify-not-trigger-001 |
| 勿抢 indexing | simplify-not-trigger-002 |

跑评测时以 P0 assertions 为准；见 [grader.md](../agents/grader.md)。

## 2026-07-21 真人试跑

目标：`company/solutions/SOLUTION-EXAMPLE.md`（写前 C → 改写 → 烤干 → 写后 C）。

共识回写原则/Skill：

- 模板硬结构：留七章与编号表，主砍散文
- 表密文档行数降幅可有限；烤干不以行数 KPI
- C4：允许刷新 `updated`；示例自查改外链须确认
