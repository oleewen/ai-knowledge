# sdx-test 评测操作与数据

本目录提供样本和裁判约定，不表示已有自动执行器或外部解析保证。评测检验测试设计行为，不把写出 TDD 文档等同于运行测试。

## 运行与证据

1. 在隔离临时目录把 `setup` 说明落实为真实文件与历史；保存初始快照、具体路径和内容。fixtures 是准备要求，不是已存在文件。
2. 只向执行者提供请求、所需 skill 与原始材料；不提供 `expected_output`、断言或预期修复。没有后续用户确认时，在实际停点结束。
3. 保存完整回答、工具轨迹、前后 diff、命令输出和退出码；交 [grader](../agents/grader.md) 逐条评分。未准备、未运行或证据不足不得记通过。
4. 无 `setup` 的路由样本只评路由及误写；失败分析交 [analyzer](../agents/analyzer.md)。

## 样本字段

`evals/evals.json` 顶层保留 `skill_name`、`version`、`description`、`evals`。

| eval 字段 | 类型 | 含义 |
| --- | --- | --- |
| `id` | string | 稳定唯一 ID；改分类不改 ID |
| `category` | string | `should-trigger` 或 `should-not-trigger`，不得从 ID 推断 |
| `prompt` / `expected_output` | string | 执行请求 / 仅供裁判的期望 |
| `assertions` | array | 每项保留 `id`、`name`、`type`、`check`、`priority` |
| `scenario` | string，可选 | 场景或历史 ID 说明 |
| `setup` | object，可选 | `workspace: string`、`fixtures: string[]`、`history: string[]` |
| `resources` | string[]，可选 | 相对 skill 根的现有资源路径 |

断言类型保留 `must_include`（应观察到）和 `must_not_conflict`（不得发生），`check` 约束实际行为而非固定措辞；`priority` 为 `P0` 或 `P1`。新增字段可人工准备；忽略准备条件的旧读取器不能据此声称完成行为评测。

[eval-metadata-template.json](../evals/eval-metadata-template.json) 仅记录 `skill_name`、`eval_id`、`expected_category`、`run_status` 和 `artifacts`。`run_status` 为 `not-run | completed | blocked`；`artifacts` 为证据路径数组。不复制断言或评分规则。

裁判输出保留 `text: string`、`passed: boolean`、`evidence: string[]`；每条证据包含断言 ID、`pass | fail | not-run` 及位置或不足原因。运行完成不等于评分通过。

## 脚本回归

用 Bash 5+ 运行 [tests/run.sh](../tests/run.sh)。测试在临时目录验证参数、配置只读性、扫描范围、元数据同链、真实标题和退出码，完成后清理自建文件。它不执行模型行为评测或产品测试。

## 结构校验命令

[validate-test.sh](../scripts/validate-test.sh) 只校验 TDD 文本，不执行测试。`--file PATH` 按调用时的 cwd 解析，不依赖 `.docsconfig`；无参通过共享配置解析 `.docsconfig`，递归扫描 `{DOC_DIR}` 整棵树。

硬检模板的 10 个必需元数据字段、六主章，以及 §1.1–§1.3、§2.1–§2.4、§2.6、§5.1–§5.2。其余固定小节与用例内容由 [质量清单](quality-checklist.md) 人工核对；没有 DSD 或 §2.5 不会单独导致脚本失败。

| 退出码 | 含义 |
| --- | --- |
| `0` | 至少一份文件已检查，且全部结构检查通过 |
| `1` | TDD 结构检查失败 |
| `2` | 参数、配置、读取或运行错误 |
| `3` | 没有实际检查到文件 |

记录命令及退出码；空扫描不得报告通过。结构检查结果不能用作测试通过、实际覆盖率或 §5 执行标准达成的证据。
