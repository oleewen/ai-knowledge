---
name: sdx-solution
description: >
  在解决方案知识库中创建或续写 SOLUTION-{IDEA-ID}.md，依据已有 knowledge 编写交付包切分叙事。
  用于 /sdx-solution、交付包方案及其范围、流程、主数据主权、技术例外的成文请求。
  不用于单独解释术语、通用方案咨询、系统/应用需求分析或公司域设计。
---

# sdx-solution

生成 `{DOC_DIR}/solutions/SOLUTION-{IDEA-ID}.md`：变更摘要及五段切分叙事，面向架构与产品评审。

## 适用边界

- 仅 `KNOWLEDGE_TYPE=solution`（别名 `sln`）。公司域设计用 `sdx-domains`，系统/应用需求分析用 `sdx-analysis`。
- 引用同库已有 knowledge，写取舍与边界；不生成实体定义、需求条目或实现方案。
- 创建新版本与续写当前草稿分别处理；前驱有后继时不另建分支。版本规则见 [core-concepts.md](references/core-concepts.md)。

## 执行

1. 读 [workflow.md](references/workflow.md)，确定文档根、创建/续写模式及当前段；只补问缺失参数。
2. 写前读 [gates.md](references/gates.md)，按共享契约澄清、生成、烤干。动作 `C/M/G/F`，无 `S`；默认一次一段。
3. 创建时用 [solution-template.md](assets/solution-template.md) 的元数据与六段骨架；续写保留已确认内容。
4. 写后按 [受众差额](references/audience-and-language.md) 评审；完成后运行校验。脚本通过不代表业务事实或用户确认已通过。

## 校验

在目标库内用 Bash 5+ 调用已安装的 [校验脚本](scripts/validate-solution.sh)，路径按实际安装位置解析：

```bash
bash /path/to/sdx-solution/scripts/validate-solution.sh --help
```

扫描范围、退出码与验收边界见 [workflow.md](references/workflow.md#校验与交付)。
