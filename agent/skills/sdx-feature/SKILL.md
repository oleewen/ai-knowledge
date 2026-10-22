---
name: sdx-feature
description: >
  基于已共识的 ANALYSIS 编写或修订六章 FEATURE 功能特性，细化 FR、MVP、依赖与风险。
  适用于系统或应用库中的功能拆分、MVP 规划及 FEATURE 分段评审；
  上游需求分析用 sdx-analysis，用户故事与详细验收规约用 sdx-prd。
---

# sdx-feature

将同库 `ANALYSIS-{IDEA-ID}.md` 细化为 `{DOC_DIR}/features/FEATURE-{IDEA-ID}.md`，供产品与业务方评审能力、交付价值和风险。

## 开始工作

1. 读 [workflow.md](references/workflow.md) 和 [gates.md](references/gates.md)，沿用用户已给的参数与授权，只澄清缺口。
2. 核实库类型、上游共识与本轮范围。仅在 `KNOWLEDGE_TYPE=system|application` 写 FEATURE；缺上游转 [sdx-analysis](../sdx-analysis/SKILL.md)，公司/解决方案分别转 `sdx-domains` / `sdx-solution`。
3. 按 [模板](assets/feature-template.md) 写当前段并烤干。默认逐段推进；§2 概览独立确认后才展开 FR，`F` 不自动绕过该停点。

上游 §6.1 里程碑不可用于拆能力时，先补齐证据，不自拟里程碑。功能、模块、里程碑与 MVP 的约束见 [core-concepts.md](references/core-concepts.md)。

## 按需读取

| 时机 | 资源 |
| --- | --- |
| 确定编号、深度，写 §2 或 §4 | [core-concepts.md](references/core-concepts.md) |
| 写作与证据取舍 | [design-principles.md](references/design-principles.md)、[受众与语言](references/audience-and-language.md) |
| 需要示意 | [节选样例](assets/samples/mini-feature-example.md)，不作为完整终稿复制 |
| 涉及技术决策 | [ADR 协议](../../references/sdx-adr-protocol.md)；FEATURE 的引用落 §6.2 |
| 写后与交付前 | [质量清单](references/quality-checklist.md)；仅通过的项勾选 |
| 排查失败 | [gotchas.md](gotchas.md)、[反模式](references/anti-patterns.md) |
| 维护或评测技能 | [evaluation.md](references/evaluation.md) |

## 校验

依赖 Bash 5+、Python 3；从技能安装位置运行 [validate-feature.sh](scripts/validate-feature.sh)：

```bash
bash agent/skills/sdx-feature/scripts/validate-feature.sh --file path/to/FEATURE-xxx.md
bash agent/skills/sdx-feature/scripts/validate-feature.sh --file path/to/FEATURE-xxx.md --strict
```

不传 `--file` 时按当前工程 `.docsconfig` 扫描 `features/`。默认保留内容告警，终检用 `--strict`；具体退出码与检查边界见 [workflow.md](references/workflow.md#结构校验)。脚本不判定业务语义、上游共识或用户授权。
