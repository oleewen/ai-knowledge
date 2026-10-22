---
name: sdx-analysis
description: >
  创建或修订系统、应用知识库的七章需求分析 ANALYSIS-{IDEA-ID}.md。
  用于把业务材料整理成目标、范围、影响、风险和里程碑，或续写、评审已有 ANALYSIS。
  FEATURE、PRD、ASD、DSD、TDD 和解决方案层 SOLUTION 交由对应技能。
metadata:
  compatibility: Bash 5+；校验脚本仅做结构与内容检查。
---

# sdx-analysis

把业务材料写成业务与产品可评审的需求分析，产物为 `{DOC_DIR}/analysis/ANALYSIS-{IDEA-ID}.md`。仅支持 `KNOWLEDGE_TYPE=system|application`；公司域架构用 `sdx-domains`，解决方案用 `sdx-solution`，MVP/FR 拆分用 `sdx-feature`。用户已指定其他交付阶段时，直接走对应技能。

## 执行

1. 先读 [workflow.md](references/workflow.md) 与 [gates.md](references/gates.md)，核对材料、配置和已有文件；沿用已给参数与当前段授权，只问缺口。
2. 按 [analysis-template.md](assets/analysis-template.md) 处理当前章或子章。默认一次一段，写前澄清、写后烤干，再等待 `C/M/G/F`；`F` 的批确认与前文保护见 gates。
3. 收尾对照 [quality-checklist.md](references/quality-checklist.md) 并运行校验。脚本结果不能代替业务共识或写后确认。

## 按需读取

| 时机 | 资源 |
| --- | --- |
| 确定 ID、深度、编号或下游衔接 | [core-concepts.md](references/core-concepts.md) |
| 生成与审阅业务正文 | [design-principles.md](references/design-principles.md)、[audience-and-language.md](references/audience-and-language.md) |
| 遇到输入不足、续写或校验问题 | [gotchas.md](gotchas.md)；误用辨别见 [anti-patterns.md](references/anti-patterns.md) |
| 出现持久技术决策 | gates 中的 ADR 绑定与其共享协议 |

## 校验

在目标工程运行，脚本从 `.docsconfig` 解析文档根。以下路径是元库位置；安装后使用实际技能路径。参数与退出码见 [workflow.md](references/workflow.md#校验)。

```bash
bash agent/skills/sdx-analysis/scripts/validate-analysis.sh --file docs/analysis/ANALYSIS-example.md
bash agent/skills/sdx-analysis/scripts/validate-analysis.sh --strict
```

维护本技能时才读 [评测说明](references/evaluation.md)；技能结构参考 [sdx-skill-skeleton.md](references/sdx-skill-skeleton.md)。
