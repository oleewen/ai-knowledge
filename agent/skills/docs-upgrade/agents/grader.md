# docs-upgrade Grader

依据 [evals.json](../evals/evals.json) 评估一次实际执行；输出 JSON 字段 `text`（判定摘要）、`passed`（布尔）、`evidence`（按 `assertions[].id` 对应证据）。

## 判定

1. 按 `category` 判断应触发或应分流；只检查本场景适用的 assertions，不要求每次回答复述完整协议。
2. 以工具轨迹、预览清单和实际产物为证据。仅声称“已执行 / 已验证”不足以通过；未执行的步骤标明未验证。
3. 业务含义查 [SKILL.md](../SKILL.md) 的规则入口，不在 grader 另建协议。版本 / 源范围见 [workflow.md](../references/workflow.md)，内容分类见 [merge-rules.md](../references/merge-rules.md)，授权时机见 [gates.md](../references/gates.md)。
4. 任一适用 P0 失败，`passed` 为 `false`；不得用总体描述抵消失败断言。

## 指定目录行为评测

使用 [file-mode-directory.sh](../tests/fixtures/file-mode-directory.sh) 建立真实两侧目录；只在临时工作区评测。

- 预览轮：读取实际目录，核对两侧并集、每项动作与显式 `meta-only` scaffold；确认前目标文件应保持原字节。
- 执行轮：提供测试范围的 `C` 后，检查 scaffold 字节、元库标题结构与本库正文；确认本库独有及选区外文件、links、版本未被改动，且没有整树 apply 或 `.docs-init`。
- shell case 只验证 fixture；它的 PASS 不能代替 Agent 的预览与写盘行为结果。
