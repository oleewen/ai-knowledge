---
name: sdx-solution
description: >
  用于在解决方案知识库创建、续写或修订 SOLUTION-{IDEA-ID}.md，分析业务目标、产品职责边界与跨系统协作。
  适用于 /sdx-solution、解决方案分析、交付包切分、主数据主权、技术例外和方案级交付计划的成文请求。
  不用于单独解释术语、通用方案咨询、系统/应用需求分析或公司域设计。
---

# sdx-solution

生成 `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`：七章解决方案分析，面向业务负责人、产品与方案架构评审。

## 适用边界

- 仅 `KNOWLEDGE_TYPE=solution`（别名 `sln`）。公司域设计用 `sdx-domains`，系统/应用需求分析用 `sdx-analysis`。
- 原始业务材料可起步；按需核实知识与系统来源，区分事实、拟议能力与待核实事项。允许系统承接及方案级里程碑，不生成知识实体、系统需求清单或接口详设。
- 创建新版本与续写当前草稿分别处理；前驱有后继时不另建分支。版本规则见 [core-concepts.md](references/core-concepts.md)。

## 执行

1. 读 [workflow.md](references/workflow.md)，确定文档根、创建/续写模式及当前段；只补问缺失参数。
2. 写前读 [gates.md](references/gates.md)，按共享契约澄清、生成、烤干。动作 `C/M/G/F`，无 `S`；默认一次一段。
3. 创建时用 [solution-template.md](assets/solution-template.md) 的元数据与七章骨架；旧六段稿先确认内容映射再升级，续写保留已确认内容。
4. 写后按 [受众差额](references/audience-and-language.md) 评审；完成后运行校验。脚本通过不代表业务事实或用户确认已通过。

## 校验

在目标库内用 Bash 5+ 调用已安装的 [校验脚本](scripts/validate-solution.sh)，路径按实际安装位置解析：

```bash
bash /path/to/sdx-solution/scripts/validate-solution.sh --help
```

扫描范围、退出码与验收边界见 [workflow.md](references/workflow.md#校验与交付)。

仅维护或评估技能时读取 [评测说明](references/evaluation.md)。
