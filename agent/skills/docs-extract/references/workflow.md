# docs-extract 工作流

[SKILL.md](../SKILL.md) 为主干；写入类门禁与例外见 [gates.md](gates.md)。

---

## 与 docs-distill 的关系（执行前必读）

`docs-extract` 是 `docs-distill` 的「**任意 `--sources`**」补充路径：两者共享同一写入目标（`XX-overview.md` 第三列）与 A/U/D 合并更新语义；**不**维护 `DISTILL-LOG` / 应用 `CHANGE-LOG` 蒸馏锚点链。

| 维度 | docs-distill | docs-extract |
|------|---------------|--------------|
| 知识来源 | 固定：`system/application-{name}/` | 用户指定：`--sources` 文件或目录 |
| 相关性过滤 | 来源已结构化，按联邦规则提炼 | **必须**：段落级关键词相关度（见 [extract-spec.md](extract-spec.md)） |
| 增量锚点 | 有（日志链） | **无**；靠 A/U/D 与本次命中集合追溯 |
| 本技能写入范围 | overview + DISTILL-LOG | **仅** overview 第三列 |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--sources` | 无（必填） | 一到多个路径，空格分隔；目录递归收集文本文件（隐藏项规则见 gotchas） |
| `--overview` | 无（必填） | 目标 `XX-overview.md` 路径 |
| `--dry-run` | `false` | 仅预览：命中段落摘要（归属章节 + 要点）、将写入的 A/U/D 变动列表 |

---

## 五阶段与硬门禁

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 校验 `--sources` / `--overview`；读 overview 关键词附录 | [extract-spec.md](extract-spec.md) |
| 2 | CLARIFY | 确认关键词覆盖与源规模；单次一问 | [extract-spec.md](extract-spec.md) |
| 3 | CONFIRM（HARD-GATE） | `dry-run` 展示命中与 A/U/D 列表；spec `CONFIRMED` 后解锁阶段 4 | [gates.md](gates.md) |
| 4 | EXECUTE | 4.1 段落筛选 → 4.2 读目标章节现有第三列 → 4.3 提炼写入（含 A/U/D） | [extract-spec.md](extract-spec.md) |
| 5 | CLOSE | 变更摘要；**不**自动 `git commit`；**不**由本技能写入 `DISTILL-LOG` / 应用 `CHANGE-LOG`（仓库级变更记录如需请另走 `docs-change` 等流程） | — |

**HARD-GATE**：阶段 3 未 `CONFIRMED` 前，禁止执行阶段 4。`dry-run` 属于阶段 3。

**阶段 4 原子约束**：

- **4.1 无命中**时禁止执行 4.2 / 4.3（无写入理由）。
- **4.3 失败**时须**整体回滚**，禁止部分落盘（避免 overview 不一致）。

---

## 命令示例

```bash
/docs-extract --sources docs/design.md --overview system/architecture/overview/billing-overview.md --dry-run
/docs-extract --sources docs/ --overview system/architecture/overview/billing-overview.md
/docs-extract --sources docs/design.md docs/adr/ --overview system/architecture/overview/billing-overview.md
```

---

## 核心约束（执行摘要）

- 关键词附录为筛选**唯一**依据；弱相关段落不写入。
- 禁止整段复制源文；第三列不写来源脚注。
- 只更新有命中段落的章节；无命中章节保持原样。
- 写入前先读目标章节现有第三列，再判断 A/U/D。
