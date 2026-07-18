---
type: Documentation
title: application（mode=c · central）
---
# application（mode=c · central）

中央挂载建联：本树以 **knowledge** 与 **changelogs** 为主。共享入口见 [README.md](README.md)；安装差异见仓库根 [INDEX-GUIDE.md](../INDEX-GUIDE.md) §7.2。

## 维护主线

```text
agent/knowledge（治理 / 命名）
  ├──→ knowledge（五视角 + 实现级实体 SSOT）
  └──→ changelogs（变更 / 索引运维）
```

**落地顺序**：核 [knowledge-governance](../agent/knowledge/knowledge-governance.md) → 补 knowledge ID（[DESIGN.md](DESIGN.md)、[CONTRIBUTING.md](CONTRIBUTING.md)）→ changelogs 留痕。

上行：`docs-pull` 入系统槽位；**docs-distill 只写 system overview**，不回写本库 knowledge。

## 主线目录

| 主线 | 目录 | 内容 |
|------|------|------|
| 治理基线 | [agent/knowledge](../agent/knowledge/knowledge-governance.md) | 术语、原则、命名、ADR |
| 知识基线 | [knowledge](knowledge/README.md) | 五视角与实现级实体 |
| 变更留痕 | [changelogs](changelogs/README.md) | `CHANGE-LOG` / `INDEXING-LOG` |

机器元数据：[docs-meta.md](docs-meta.md)。
