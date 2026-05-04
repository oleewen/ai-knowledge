# docs-extract 核心概念

[SKILL.md](../SKILL.md) 为主干；关键词与段落算法见 [extract-spec.md](extract-spec.md)。

---

## 标识与路径

| 术语 | 含义 |
|------|------|
| `--sources` | 一个或多个文件或目录；目录递归展开（规则见 gotchas） |
| `--overview` | 目标 `system/architecture/overview/XX-overview.md` |
| `## 文档关键词` | overview 末尾附录表；**筛选唯一依据** |
| A / U / D | 第三列新增 / 变更 / 删除标识（见 extract-spec） |

---

## 语义区分

- **无 distill 锚点**：不读取、不写入 `DISTILL-LOG`；不替代 `docs-distill` 上行主路径。
- **段落命中**：仅 `--sources` 内文本参与匹配；**不得**把 `--overview` 自身当源扫描（见 gotchas）。
