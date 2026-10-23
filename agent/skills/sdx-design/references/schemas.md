# sdx-design 评测数据

本文件定义本目录的评测约定，不表示已有自动执行器或外部解析保证。运行方法与证据要求如下。

## 样本与准备

`evals/evals.json` 顶层保留 `skill_name`、`version`、`description`、`evals`。

| eval 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | string | 稳定唯一 ID；分类变更不改 ID |
| `category` | string | `should-trigger` 或 `should-not-trigger`；以字段值为准，不从 ID 推断 |
| `prompt` / `expected_output` | string | 给执行者的请求 / 仅给裁判的期望 |
| `assertions` | array | 每项保留 `id`、`name`、`type`、`check`、`priority` |
| `scenario` | string，可选 | 场景标识或历史 ID 说明 |
| `setup` | object，可选 | `workspace`（环境说明）、`fixtures`（原始材料说明数组）、`history`（前序已确认事实数组） |
| `resources` | string[]，可选 | 相对 skill 根的现有资源路径；按需加载 |

断言 `type` 保留 `must_include`（应观察到）和 `must_not_conflict`（不得发生），但 `check` 检查行为，不限制固定措辞。`priority` 为 `P0` 或 `P1`。旧字段含义不变；新增字段可由人工准备，不能因旧读取器忽略它们而声称行为评测已完成。

1. 在隔离临时目录准备 `setup` 的真实文件与历史；保存初始快照。fixtures 是准备要求，不是已存在文件。
2. 给执行者请求、所需 skill 及原始材料；不给 `expected_output`、断言或预期修复。冻结本次材料，记录实际路径与内容。
3. 收集完整回答、工具调用、文件 diff、命令输出与退出码；按 [grader](../agents/grader.md) 评分。无 `setup` 的路由样本只评路由及有无误写。
4. 准备不充分、命令未跑或证据缺失记未运行/未验证，不记通过。失败分析用 [analyzer](../agents/analyzer.md)。

## 单次记录

[eval-metadata-template.json](../evals/eval-metadata-template.json) 只记录 `skill_name`、`eval_id`、`expected_category`、`run_status`、`artifacts`。`run_status` 为 `not-run | completed | blocked`；`artifacts` 为证据路径数组。断言与评分规则仅引用样本集和 grader，不再复制。

裁判输出保留 `text: string`、`passed: boolean`、`evidence: string[]`；每条 evidence 包含断言 ID、`pass | fail | not-run` 和证据位置或不足原因。执行完成不等于评分通过。

## 脚本回归

使用 Bash 5+ 运行 [tests/run.sh](../tests/run.sh)。测试在临时目录验证 CLI、配置只读性、元数据同链、HTTP URL query/fragment 不干扰文件身份、真实标题和退出码；完成后清理自建临时文件。它不执行上述模型行为评测。

## DSD 校验命令

[validate-dsd.sh](../scripts/validate-dsd.sh) 检查 DSD 文本，不验证本 JSON，也不替代语义评审。`--file PATH` 按当前工作目录解析路径，不依赖 `.docsconfig`；无参通过共享配置逻辑解析 `.docsconfig`，扫描 `{DOC_DIR}/requirements`。

| 退出码 | 含义 |
| --- | --- |
| `0` | 至少一份文件已检查且脚本检查通过 |
| `1` | DSD 内容检查失败 |
| `2` | 参数、路径或运行错误 |
| `3` | 没有实际检查到文件 |

报告保留命令及退出码；不得将空扫描或结构通过表述为整份详设已验收。
