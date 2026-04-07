# docs-archive 参考文档索引

渐进披露：执行技能时**先读上级目录 `SKILL.md`**，再按需打开下列文件。

| 文档 | 内容 | 何时打开 |
|------|------|----------|
| [archive-spec.md](archive-spec.md) | 系统侧系统知识库根目录（`application/`）全树范围、`--scope` 与扫描落点、变更发现方式、批次 `ARCHIVE-*.md` 格式 | 定归档范围、写批次文档 |
| [federation-spec.md](federation-spec.md) | 联邦层级、knowledge 提炼与 SDD 直接归档、**归档顺序**、各目录操作细则、质量自检 | 步骤 2 上行写入、多类型同批顺序 |
| [archive-log-spec.md](archive-log-spec.md) | `archive-log.yaml` 格式、增量逻辑、锚点更新时机 | 步骤 0 读锚点、步骤 3 更新锚点 |

上级目录 [gotchas.md](../gotchas.md)：锚点/ID/联邦边界等陷阱与完整自查清单。
