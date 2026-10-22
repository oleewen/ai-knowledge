---
name: sdx-design
description: >
  基于 PRD 与 ASD/spec-asd 编写、修订或校验 DSD 详细设计说明书。
  用于 /sdx-design、DSD 当前段及其中的 API、DDL、业务逻辑、错误码、幂等与时序设计。
  普通接口编码、SQL 修改，以及 PRD、ASD、TDD 或知识归档请求不走本技能。
metadata:
  compatibility: Bash 5+；无参扫描依赖同一 agent 树的 scripts/lib/docsconfig.sh；显式 --file 可独立校验。
---

# sdx-design

将已共识需求与架构展开为可实现、可追溯的 DSD。正式正文为
`{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/DSD-{IDEA-ID}-{N}.md`。

## 先选任务

| 请求 | 执行入口 |
| --- | --- |
| 新建 DSD、修改章节或单个设计块 | [workflow.md](references/workflow.md)；写前读 [gates.md](references/gates.md) |
| 只校验已有 DSD | 直接运行下方命令；不启动写作向导，不修改文件 |
| 需求、架构、测试设计或实现代码 | 按用户要的产物分流；不以 DSD 代替 |

## 核心约束

- 当前段可以是章节，或一个 API、DDL/TBL、LOGIC、错误码组、幂等/事务/时序/安全块。写作按「澄清 → 生成 → 烤干」与 `C/M/G/F` 推进，无 `S`；具体绑定见 [gates.md](references/gates.md)。
- 读取同一 `IDEA-ID`、MVP 的 PRD 与 ASD 或 spec-asd；缺口处理见 [workflow.md](references/workflow.md#输入与缺口)。不编造上游，也不在 DSD 中暗改架构。
- 保留 [模板](assets/dsd-template.md) §1–§3；全部实现级契约与追溯放在 §2，不建第二份详设正文。
- DSD 默认落应用库；先核对 [层级约束](references/knowledge-type-modes.md)，不因当前目录可写就新建阶段目录。

## 校验

以下示例从仓库根调用；在其他目录运行时，使用脚本的实际路径，`--file` 仍相对调用目录解析：

```bash
bash agent/skills/sdx-design/scripts/validate-dsd.sh --file path/to/DSD-xxx.md
bash agent/skills/sdx-design/scripts/validate-dsd.sh
```

`--file` 相对调用目录解析，无参按 `.docsconfig` 扫描。退出码：`0` 已校验且通过，`1` 结构错误，`2` 参数/配置/读取错误，`3` 未校验任何文件。
脚本只检查结构；语义、授权和引用真实性仍须按 [质量清单](references/quality-checklist.md) 审核。

## 按需参考

| 时机 | 阅读 |
| --- | --- |
| 展开当前段、决定追溯与编号 | [design-principles.md](references/design-principles.md) |
| 写后烤干、交付检查 | [quality-checklist.md](references/quality-checklist.md)、[audience-and-language.md](references/audience-and-language.md) |
| 出现误路由、流程或工具问题 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |
| 维护或评估本技能 | [schemas.md](references/schemas.md)、[evals.json](evals/evals.json)、[grader.md](agents/grader.md) |
