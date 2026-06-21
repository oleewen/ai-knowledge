# docs-extract 工作流

写入门禁见 [gates.md](gates.md)。

## 与 docs-distill

任意 `--sources` 补充路径；共享目标（overview 第三列）与 A/U/D；**无** `DISTILL-LOG` / 应用蒸馏锚点。

| 维度 | docs-distill | docs-extract |
|------|---------------|--------------|
| 源 | `system/application-{name}/` | 用户 `--sources` |
| 过滤 | 联邦规则 | **必须**段落级关键词（[extract-spec.md](extract-spec.md)） |
| 增量锚点 | 有 | **无** |
| 写入 | overview + DISTILL-LOG | **仅**第三列 |

## 参数

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--sources` | 必填 | 空格分隔；目录递归（隐藏项见 gotchas） |
| `--overview` | 必填 | 目标 `XX-overview.md` |
| `--dry-run` | `false` | 预览：命中摘要、A/U/D 列表 |

## 五阶段

| 阶段 | 名 | 摘要 | 详见 |
|------|-----|------|------|
| 1 | EXPLORE | 校验路径；读关键词附录 | extract-spec |
| 2 | CLARIFY | 关键词与源规模；单次一问 | extract-spec |
| 3 | CONFIRM | HARD-GATE；`dry-run`；spec `CONFIRMED` 后解锁 4 | gates |
| 4 | EXECUTE | 4.1 筛选 → 4.2 读第三列 → 4.3 写入 A/U/D | extract-spec |
| 5 | CLOSE | 摘要；**不**自动 commit；**不**写 `DISTILL-LOG` / 应用 `CHANGE-LOG` | — |

**HARD-GATE**：阶段 3 未 `CONFIRMED` → 禁止阶段 4；`dry-run` 属阶段 3。

**阶段 4 原子**：4.1 无命中 → 禁止 4.2/4.3；4.3 失败 → **整篇回滚**，禁止部分落盘。

## 命令示例

```bash
/docs-extract --sources docs/design.md --overview system/knowledge/overview/billing-overview.md --dry-run
/docs-extract --sources docs/ --overview system/knowledge/overview/billing-overview.md
/docs-extract --sources docs/design.md docs/adr/ --overview system/knowledge/overview/billing-overview.md
```

## 执行摘要

- 关键词附录为筛选**唯一**依据；弱相关不入。
- 禁止整段复制源文；第三列无来源脚注。
- 只更新有命中的章节；写入前先读现有第三列再定 A/U/D。
