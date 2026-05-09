# docs-extract 核心概念

段落算法见 [extract-spec.md](extract-spec.md)。

## 标识与路径

| 术语 | 含义 |
|------|------|
| `--sources` | 文件或目录；目录递归（gotchas） |
| `--overview` | 目标 `system/architecture/overview/XX-overview.md` |
| `## 文档关键词` | overview 附录；**筛选唯一依据** |
| A / U / D | 第三列新增 / 变更 / 删除（extract-spec） |

## 语义

- **无 distill 锚点**：不读不写 `DISTILL-LOG`；不替代 distill 上行主路径。
- **命中范围**：仅 `--sources`；**勿**扫 `--overview` 自身（gotchas）。
