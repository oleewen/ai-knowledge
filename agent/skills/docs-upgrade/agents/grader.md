# docs-upgrade Grader

依据 [evals.json](../evals/evals.json) 评估一次实际执行；逐断言输出 `id`、`status`（pass / fail / not_run）和 `evidence`，再给用例状态。未运行或证据不足须注明原因。

## 判定

1. 按 `category` 判断应触发或应分流；只检查本场景适用的 assertions，不要求每次回答复述完整协议。
2. 以工具轨迹、预览清单和实际产物为证据。仅声称“已执行 / 已验证”不足以通过；未执行的步骤标明未验证。
3. 业务含义查 [SKILL.md](../SKILL.md) 的规则入口，不在 grader 另建协议。版本 / 源范围见 [workflow.md](../references/workflow.md)，内容分类见 [merge-rules.md](../references/merge-rules.md)，授权时机见 [gates.md](../references/gates.md)。
4. 任一适用断言失败则用例 fail；没有失败但证据不全则 not_run；全部适用断言有证据通过才为 pass。纯解释请求可以评价回答，操作请求不能仅因复述规则或口令而通过；受众 A/B 可静默完成。

## 快照与冲突评测

只给独立代理运行技能、当前请求和临时原始文件；不给预期、评分器或未来消息。快照例先真实执行 scaffold，保存交接目录，随后改变源 HEAD，再让代理完成已授权重填；检查目标来自保留快照且业务正文不丢。冲突例核对真实非零调用、项目字节不变和版本未推进。保存输入、逐轮响应、命令退出码及前后快照；测试目录仅作访问边界，不宣称操作系统沙箱。结构或脚本回归不替代模型行为，未抽样用例记 not_run。

## 指定目录行为评测

使用 [file-mode-directory.sh](../tests/fixtures/file-mode-directory.sh) 建立真实两侧目录；只在临时工作区评测。

- 预览轮：读取实际目录，核对两侧并集、每项动作与显式 `meta-only` scaffold；确认前目标文件应保持原字节。
- 执行轮：提供测试范围的 `C` 后，检查 scaffold 字节、元库标题结构与本库正文；确认本库独有及选区外文件、links、版本未被改动，且没有整树 apply 或 `.docs-init`。
- shell case 只验证 fixture；它的 PASS 不能代替 Agent 的预览与写盘行为结果。
