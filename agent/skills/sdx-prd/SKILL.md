---
name: sdx-prd
description: >
  基于已共识 FEATURE 的当前 MVP 编写、修订或评审十一章 PRD 产品需求。
  用于系统或应用库的用户故事、用例、业务流程与验收细化；
  功能拆分用 sdx-feature，架构与实现设计用 sdx-architect / sdx-design。
---

# sdx-prd

将 `FEATURE-{IDEA-ID}.md` 的目标 `MVP-Phase-{N}` 细化为 `PRD-{IDEA-ID}-{N}.md`，供产品与业务方确认流程、故事和验收。

## 开始工作

1. 读 [workflow.md](references/workflow.md) 与 [gates.md](references/gates.md)，区分新建、修订和只读评审；沿用已给参数与授权，只澄清缺口。
2. 写作前核实目标系统或应用库、FEATURE 与 MVP；缺直接上游时转 [sdx-feature](../sdx-feature/SKILL.md)，ANALYSIS 只作背景。只读评审可先检查能核实的部分，并列明缺失依据。
3. 按 [十一章模板](assets/prd-template.md) 处理当前段。写作默认走「澄清 → 生成 → 烤干」和 `C/M/G/F`（无 `S`）；局部修订保留其他段，只读评审仅报告证据与建议。

## 按需读取

| 时机 | 资源 |
| --- | --- |
| 确定 IDEA-ID、阶段、深度与追溯关系 | [core-concepts.md](references/core-concepts.md) |
| 写作取舍、业务表达 | [design-principles.md](references/design-principles.md)、[受众与语言](references/audience-and-language.md) |
| 需要追溯和验收示意 | [节选样例](assets/samples/mini-prd-example.md)，不作完整终稿 |
| 写后及交付前 | [quality-checklist.md](references/quality-checklist.md) |
| 排查操作失败或边界误用 | [gotchas.md](gotchas.md)、[反模式](references/anti-patterns.md) |
| 维护或评测技能 | [evaluation.md](references/evaluation.md) |

## 校验

依赖 Bash 5+、Python 3.8+（标准库）。从技能安装位置运行 [validate-prd.sh](scripts/validate-prd.sh)：

```bash
bash agent/skills/sdx-prd/scripts/validate-prd.sh --file path/to/PRD-xxx.md
bash agent/skills/sdx-prd/scripts/validate-prd.sh --help
```

不传 `--file` 时按当前工程 `.docsconfig` 扫描 `requirements/`。退出码、检查范围与限制见 [workflow.md](references/workflow.md#结构校验)。脚本不判定业务语义、上游共识或用户授权；无目标不代表通过。
