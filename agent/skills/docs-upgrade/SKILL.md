---
name: docs-upgrade
description: >
  定向改仓库内 Markdown、注释、配置文本；统一术语并沿引用链 + 关键词（同义/近义/中英）链式同步。
  触发：/docs-upgrade，或「改文档」「统一术语」「把 X 换成 Y」「对齐表述」「同步引用链」等（不必说命令名）。
  替换简写：`a - b`、`a > b`、`a 2 b` 均为 a→b。
  分流：用户只要 docs-archive、docs-change、docs-indexing、docs-build、仅 CHANGE-LOG / 仅 INDEX → 不以本技能为唯一主路径。
---

# docs-upgrade：定向升级与链式对齐

调度器：判定归属 → 读 `references/` → **范围确认** → 主改 → 关联检索 → 校验。

## 边界

| 负责 | 不负责（除非用户单列附加） |
| ---- | --------------------------- |
| MD/注释/配置中的文档性文本；引用链 + 关键词；**范围确认书**（`references/gates.md`） | **docs-change**（变更聚合）、**docs-indexing**（INDEX 重建）、**docs-archive**（overview 归档）、**docs-build**（实体/KNOWLEDGE_INDEX） |
| | 纯业务逻辑大范围重构、与文档无关代码改写 |

## IO

| 类型 | 内容 |
| ---- | ---- |
| 硬 | 路径、片段或替换指令 |
| 可选 | 简写、范围（如「只改本文件」） |
| 出 | 主文件；经确认的关联命中 |
| 不产 | CHANGE-LOG 聚合、全库 INDEX |

## 读序

1. `references/gates.md` + `assets/docs-upgrade-scope-ack-template.md`  
2. `references/workflow.md`  
3. 意图糊或步骤 3 前：`references/brainstorming-integration.md`  
4. 步骤 3：`references/related-doc-discovery.md`、`references/semantic-keyword-discovery.md`  
5. `references/core-concepts.md`、`references/design-principles.md`、`references/anti-patterns.md`  
6. 落盘：`references/quality-checklist.md`  
7. `gotchas.md`；索：`references/README.md`

## 门禁

**任何写入前**完成范围确认与用户 **C**/**S**（快路径见 `gates.md`）。**禁止**未确认批量多文件写入。

## 须用户拍板（勿编造）

业务规则、指标/日期/责任人、合规结论、架构决断；删段/保留兼容/结构取舍；多文件同名或多段语义可疑时是否「同一概念」。输出**编号选项**，选定后再改。

## 产出与评测

- 已改主文件与已确认关联；链校验见 `quality-checklist`。  
- `agents/openai.yaml` 仅展示元数据，**非**必读。

评测：`evals/evals.json`、`eval-metadata-template.json`、`agents/grader.md`、`agents/analyzer.md`。

## 工程化

本仓库**未**注册 `docs-upgrade` 专用 `preToolUse` 钩子；依赖确认书与执行纪律。

## 协作

| | |
| - | - |
| docs-change | 变更聚合与时间线 |
| docs-indexing | 重建 INDEX_GUIDE |
