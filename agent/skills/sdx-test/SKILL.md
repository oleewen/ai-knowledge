---
name: sdx-test
description: >
  在 PRD/DSD 交付链中编写、修订或校验 TDD 测试设计文档，覆盖测试策略、用例、数据、环境、进出标准与回归。
  用于 /sdx-test、TDD-*.md 或将 PRD/DSD 转为测试方案。
  测试驱动开发、自动化测试编码、执行测试及编写执行报告不走本技能。
metadata:
  compatibility: Bash 5+；无参扫描依赖同一 agent 树的 scripts/lib/docsconfig.sh；显式 --file 可独立校验。
---

# sdx-test

**TDD 指测试设计文档**。将已共识需求与设计转为可评审用例；设计产物不代表执行结果。

正式正文：`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/TDD-{IDEA-ID}-{N}.md`。

## 先选任务

| 请求 | 执行入口 |
| --- | --- |
| 新建 TDD、修订章节或用例组 | [workflow.md](references/workflow.md)；写前读 [gates.md](references/gates.md) |
| 只校验已有 TDD | 直接运行下方命令；不启动写作向导，不修改文件 |
| PRD/ASD/DSD 正文、测试代码或执行结果 | 按用户要的产物分流，不以 TDD 代替 |

## 核心约束

- 按 [gates.md](references/gates.md) 对当前段执行「澄清 → 生成 → 烤干」与 `C/M/G/F`，无 `S`。
- PRD 必须可读；缺 DSD 时按 [输入与缺口](references/workflow.md#输入与缺口) 收窄范围，不编造接口或声称全覆盖。
- 保留 [模板](assets/tdd-template.md) 六章；用例就近追溯 US/FR/BR、API、异常设计或影响面。
- 系统库和应用库均可落 TDD；库类型、编号与 `depth` 见 [core-concepts.md](references/core-concepts.md)。

## 校验

以下示例从仓库根调用；在其他目录运行时使用脚本实际路径，`--file` 仍相对调用目录解析：

```bash
bash agent/skills/sdx-test/scripts/validate-test.sh --file path/to/TDD-xxx.md
bash agent/skills/sdx-test/scripts/validate-test.sh
```

`--file` 不依赖配置；无参读取 `.docsconfig` 并递归扫描 `{DOC_DIR}` 下的 `TDD-*.md`。退出码：`0` 至少一份且全部结构通过，`1` 结构错误，`2` 参数/配置/运行/读取错误，`3` 未校验任何文件。
结构通过不代表用例已执行或测试通过；内容与追溯须按 [质量清单](references/quality-checklist.md) 审核。

## 按需参考

| 时机 | 阅读 |
| --- | --- |
| 展开用例、决定覆盖与追溯 | [design-principles.md](references/design-principles.md) |
| 写后烤干、交付检查 | [quality-checklist.md](references/quality-checklist.md)、[audience-and-language.md](references/audience-and-language.md) |
| 出现流程误用或工具问题 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |
| 维护或评估本技能 | [evaluation.md](references/evaluation.md)、[evals.json](evals/evals.json)、[grader.md](agents/grader.md) |
