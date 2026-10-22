# docs-archive 实际模型评测

**首轮结果：7/12 通过，5/12 未通过，0 执行错误；逐断言 26/35 通过。** 未重试以提高成绩，未修改断言或覆盖原始评分。此次评价加载技能后的单轮回答语义，不代表真实归档执行成功率或技能自动发现率。

## 运行与证据

| 项 | 记录 |
| --- | --- |
| 时间（北京时间） | 2026-10-22 17:28:41 → 2026-10-22 17:38:08 |
| 执行器 / 评分器 | `gpt-6.1-sol`，`low`；每次新会话，同模型分开调用 |
| CLI | `0.163.0-alpha.10.2`，显式使用本机既有 Responses 代理 |
| 语料 | v3.0.0，12 条、35 个断言（32 P0、3 P1） |
| 测试 | 46 项自动化测试通过，Python 与代码独立审查通过 |
| 评分负对照 | 刻意违例回答的 8 个断言全部为 false，正确判未通过 |
| 报告回灌 | `score` 返回退出码 1，与原报告的 summary/cases/results 完全一致 |
| 运行一致性 | 25 次模型调用完成（12 执行、12 评分、1 负对照）；单一 adapter 哈希与执行器显式资料快照 |

[原始报告](report.json) · [重新评分](rescored.json) · [负对照](negative-control.json) · [运行清单](run-manifest.json) · [用例快照](suite.json) · [逐次调用产物](calls/)

Suite SHA-256：`7434c0d37a9b854e766464b7f532cff93fabe3963dade21a758dabf3f9388717`。

## 用例结果

| 用例 | 结果 | 未通过断言数 |
| --- | --- | --- |
| archive-trigger-001 | 未通过 | 5 |
| archive-trigger-002 | 未通过 | 1 |
| archive-trigger-003 | 未通过 | 1 |
| archive-trigger-004 | 通过 | 0 |
| archive-not-trigger-001 | 通过 | 0 |
| archive-not-trigger-002 | 通过 | 0 |
| archive-trigger-app-001 | 通过 | 0 |
| archive-not-trigger-003 | 通过 | 0 |
| archive-audience-001 | 通过 | 0 |
| archive-atomicity-001 | 未通过 | 1 |
| archive-not-trigger-distill-001 | 通过 | 0 |
| archive-solution-layer-001 | 未通过 | 1 |

所有未通过项均为 P0；三个 P1 均通过。`failed` 表示回答未满足当前断言，`error` 才表示调用或协议失败。

## 未通过项复核

已独立复核全部 5 条失败及 1 条通过回答。主要问题是首轮澄清未覆盖断言要求的全部流程表达；未发现这些已复核回答明确绕过确认、虚构写入或自动推进。原始成绩保持不变，不把证据缺失改判为通过，也不把表达缺项等同于执行违规。

| 用例 | 人工复核 | 原始证据 |
| --- | --- | --- |
| archive-trigger-001 | 六项、受众检查及后续检查/动作要求未完整展开；部分评分理由偏字面。 | [回答](calls/executor-3awvyb51/response.json) · [评分](calls/grader-11hw4556/response.json) |
| archive-trigger-002 | 未给当前确认书，未展开来源优先、目标优先、并列待裁三类策略。 | [回答](calls/executor-7120pa4s/response.json) · [评分](calls/grader-b1wim4xk/response.json) |
| archive-trigger-003 | 未给当前确认书及多视角风险摘要；已拒绝未确认批量写入。 | [回答](calls/executor-g9v6nmh7/response.json) · [评分](calls/grader-ranuhv3q/response.json) |
| archive-atomicity-001 | 未明确复述来源只读及完整写入白名单；已要求恢复范围核实与写前 C。 | [回答](calls/executor-k_dyraoi/response.json) · [评分](calls/grader-m9al5a5r/response.json) |
| archive-solution-layer-001 | 已限定单章节并给六项，但未说明收敛后的停等动作。 | [回答](calls/executor-s22825co/response.json) · [评分](calls/grader-oyn6dynd/response.json) |

001 已写“形成归档确认书”“取得写前 C 后才能写入”及“烤干收敛后停等确认”；部分评分理由对等价门禁和停顿表达偏严，但六项、受众与完整后续动作等仍有缺项。抽查通过项 `archive-not-trigger-distill-001`，其分流正确，并明确尚未落盘。

## 适用边界与后续优先级

- 执行器不显式接收原始用例 ID、期望或断言；运行资料采用白名单。CLI 基础规则、全局 AGENTS 和已装技能描述仍可能参与，哈希仅绑定适配器显式资料，结论限定于本机 CLI 环境。
- 用例没有业务文件正文，评测不读取或修改真实归档文件；不能验证实际写入顺序、内容完整性或失败恢复。负对照只证明评分器能拒绝明显违例，不能替代评分尺度校准。
- **P1：按阶段校准判据。** 区分首轮缺资料澄清、确认书生成、已授权写入与写后收敛；接受等价门禁/停顿表达，保留真正的行为约束。先明确新判据，再使用新版本用例重跑，不能追改本轮成绩。
- **P2：补文件场景。** 在隔离工作区放入 overview、目标章节与失败场景，检查实际产物和轨迹。

复现命令与参数见[运行说明](../../docs-archive/references/evaluation.md)。本次未提交或推送 Git。
