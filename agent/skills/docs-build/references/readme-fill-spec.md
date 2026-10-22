# README 台账同步

实体就绪后、导航归并前，更新 `{DOC_DIR}/knowledge/{视角}/README.md`。README 是 A 类人类入口：保留既有标题、表头与有效说明；正文事实留在实体文件。

## 数据与链接

- 每行取自本层实际 `{ID}.md`：`hierarchy`、`id`、`title` 与实体文件位置；不用 JSON 中间样例或外层 ID 填充台账。
- 按层级分组，沿用现有栏目。无本层实体时注明「本层无首次定义实体」；预期有实体但证据不足时注明待补充及原因。
- 实体链接相对当前 README。链接限制同 [knowledge-governance.md](../../../knowledge/knowledge-governance.md)：知识内互引；五种 meta 可按治理例外引用；不新增或保留指向层根 INDEX、SDD、其他 Agent 文档的违规链接。
- 不以 README 导航为由新增上层 reference 实体。保持实体、台账与当前授权范围内的引用一致。

## 现有表头映射

以下用于识别既有模板，不强制将所有 README 改成统一表头。

| 视角 | 表头 | 取值 |
| --- | --- | --- |
| 应用 | 类型、名称、ID (INDEX-GUIDE)、路径 / 说明 | hierarchy 中文名、title、id、实体链接 |
| 数据 | 链序、层级、类型、名称、锚点目录 / 文件 | MDG/DS/ENT/TBL 链序、hierarchy、中文类型、title、实体链接 |
| 业务 | 链序、层级、ID、名称、文件/目录 | 所属链序、hierarchy、id、title、实体链接 |
| 产品 | 链序、层级、类型、名称、锚点目录 | 产品链或流程链序、hierarchy、中文类型、title、实体链接 |
| 技术 | 链序、层级、ID、名称、文件/目录 | TPL/TS/MW/CMP 链序、hierarchy、id、title、实体链接 |

链序来源为各视角 meta 的实体总表，见 [extraction-rules.md](extraction-rules.md)。业务能力链与域模型链分组；BL/BS 不进链。产品链与 BP/BSP 流程链分组。仅展示当前层实体，不为补齐链序复制其他层文件。

## 验收

README 中每个实体链接可解析且对应实际 ID；本轮实体都有台账行；人工维护的有效静态段保留。frontmatter `title` 与 H1 遵 [document-guidelines.md](../../../rules/document/document-guidelines.md)，不为消 MD025 擅删契约字段。
