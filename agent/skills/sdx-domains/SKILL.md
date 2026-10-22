---
name: sdx-domains
description: >
  创建或修订公司库的域架构总图 DOMAIN-MAP.md 与 DOMAIN-{BD-ID}.md，说明 BD/BSD-L1 如何支撑 VC。
  用于 /sdx-domains、公司域架构、company/domains 或价值链与业务域归属梳理。
  单个解决方案交付包用 sdx-solution；系统/应用需求分析用 sdx-analysis。
---

# sdx-domains

围绕已有知识实体写公司级归属与边界；实体定义仍以 `knowledge/` 为准。

## 开始执行

1. 读 [workflow.md](references/workflow.md) 与 [gates.md](references/gates.md)，从 `.docsconfig` 确定文档根；只处理 `KNOWLEDGE_TYPE=company`。
2. 确定总图映射块或单个分域章节，核实本段所需实体与关系；输入齐备时不重复询问。
3. 按共享协议执行写前澄清、生成、写后烤干；动作 `C/M/G/F`，无 `S`。未确认的归属与范围变化先停问。
4. 用 [质量清单](references/quality-checklist.md) 和校验脚本核验本轮产物；脚本通过不代表业务事实已核实。

## 产物边界

| 产物 | 路径与依据 |
| --- | --- |
| 总图 | `{DOC_DIR}/domains/DOMAIN-MAP.md`；[总图模板](assets/domain-map-template.md) |
| 单域 | `{DOC_DIR}/domains/DOMAIN-{BD-ID}.md`；[分域模板](assets/domain-template.md) |

`BD-ID` 使用已有实体 ID；保留已存在文档的文件名与 id。不得生成日期主题 ID、新建 knowledge 实体，或代写 SOLUTION/ANALYSIS/FEATURE/PRD。下层 PL 仅引用已核实的纯 ID。

## 按需读取

| 时机 | 文件 |
| --- | --- |
| 核对 ID、关系与历史命名 | [core-concepts.md](references/core-concepts.md) |
| 判断证据、缺口与受众 | [design-principles.md](references/design-principles.md)、[audience-and-language.md](references/audience-and-language.md) |
| 排查误用或执行问题 | [anti-patterns.md](references/anti-patterns.md)、[gotchas.md](gotchas.md) |
| 维护或评测技能 | [sdx-skill-skeleton.md](references/sdx-skill-skeleton.md)、[evaluation.md](references/evaluation.md) |

## 校验

在目标公司工程运行；`SKILL_DIR` 为本技能绝对目录，`DOC_DIR` 为已核实的配置值。依赖、参数与检查边界见 [workflow.md](references/workflow.md#校验脚本)。

```bash
bash "$SKILL_DIR/scripts/validate-domains.sh" --file "$DOC_DIR/domains/DOMAIN-MAP.md"
bash "$SKILL_DIR/scripts/validate-domains.sh"
```
