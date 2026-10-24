# docs-merge 评测

用 [evals.json](../evals/evals.json) 检验实际决策与文件结果，数量以套件为准。保留原有 1–9、`merge-audience-001` 编号；原始 Markdown 在 [tests/fixtures/](../tests/fixtures/)。夹具含故意错误的链接与结构，只供隔离评测。

## 覆盖

| 行为 | 用例 ID |
| --- | --- |
| 预览、清点、单元停顿、正式授权 | 1、4、8、9、13 |
| 内联、缺参、路径拼写、目标缺失或格式不符 | 2、5、17–19、24、25、28 |
| 同名 H3、完整父路径、新建节、父子块切分 | 10、20、21、30 |
| 围栏、frontmatter、引用示例、未闭合结构 | 11、23 |
| 重复正文无变更、空源 | 12、25 |
| 采纳/跳过、修改后再采纳、冲突决议后正式确认 | 3、14、15、31 |
| 旧计划失效、保留他人编辑 | 16 |
| knowledge 引用与写后质检 | 6、`merge-audience-001` |
| 链接迁移、表格/代码、无关内容保留 | 13、22 |
| extract / simplify / revise 分流 | 7、26、27 |
| 源内指令不构成授权 | 29 |
| 暂停后恢复预览，不升级为正式写入 | 32 |

## 运行

以下命令从仓库根执行，仅依赖 Python 3 标准库：

```bash
python3 agent/skills/docs-merge/scripts/evaluate.py validate
python3 -m unittest discover -s agent/skills/docs-merge/tests -v
python3 agent/skills/docs-merge/scripts/evaluate.py prepare --case 13 --output /tmp/docs-merge-case13
```

`prepare` 要求输出目录尚不存在，生成：

- `workspace/`：原始材料副本。执行代理仅在这里操作。
- `request.md`：用户请求及已经发生的会话事实，不含预期答案。
- `manifest.json`：评测员私有的用例、原始 SHA-256 与断言；不要提供给执行代理。

给独立执行代理技能路径、`request.md` 和工作目录。不要给它 `expected_output`、`assertions`、评分模板或先前结论。记录真实对话、工具调用与文件结果；遇待确认项时，由评测员按用例的 `driver_turns` 逐轮提供答复，不能让执行代理自行模拟用户。条件尚未发生时，不提前发送答复；未覆盖的问题记为待决，不猜答案。多轮用例在每次答复前检查目标快照，证实没有边确认边写。

执行结束后，由独立评测员按 [grader.md](../agents/grader.md) 对每条行为断言评分，可复制 [评分结构](../evals/eval-metadata-template.json)，替换为当前用例 ID 与断言。随后执行：

```bash
python3 agent/skills/docs-merge/scripts/evaluate.py verify --run /tmp/docs-merge-case13 --executed --review /tmp/docs-merge-case13-review.json
```

`--executed` 只用于确实运行过的请求。首次执行仍在等待必要用户答复时，应继续用例或将未覆盖断言记为 `not_run`。同一用例重跑时使用全新目录，避免旧产物污染。

## 判分

| 检查层 | 能证明什么 | 不能证明什么 |
| --- | --- | --- |
| `validate` | 用例结构、ID、fixtures 路径有效；路径无大小写/Unicode 别名、文件/目录冲突或初始存在性矛盾 | 代理能完成合入 |
| 工具单测 | 隔离、路径边界、快照检测、失败退出、三态计分 | 技能行为正确 |
| `verify` 的 artifacts | 源/support 未改、目标具体内容、无额外文件；dry-run 字节未变 | 落位语义、授权有效、每轮只问一项 |
| 独立 review | 真实交互及 diff 支持各行为断言 | 尚未执行的后续阶段 |

每条评分使用 `passed` / `failed` / `not_run`，必须给具体证据。缺少执行声明、断言评分或证据均为 `not_run`；文件检查通过不会把行为自动判过。任一已检查项失败，整条失败；仍有未检查项且无失败，整条为 `not_run`。汇总须分别报告定义数、工具测试数、实际行为通过/失败/未跑数。

工具不执行模型、不调用外部服务、不自动合并。退出码：`0` 为校验完成（可能仍含 `not_run`，须读 JSON），`1` 为产物或行为失败，`2` 为输入/路径/评分格式错误。`--help` 可查看各命令参数。
