---
name: docs-extract
description: >
  从用户指定的任意文件或目录中提炼业务知识，写入系统知识库指定的 XX-overview.md。
  当用户执行 /docs-extract，或提到「从文件提炼到 overview」「从这些文档抽取业务知识」
  「把这个目录的内容整理进系统库」「从 design.md 提炼知识写进 overview」
  「从源文件提取业务知识」「把这些文档的知识同步到 overview」
  「从指定文件提炼」「抽取业务知识到系统库」时必须触发本技能。
  支持 --sources --overview --dry-run。
  即使用户只是说「帮我从这几个文件提炼业务知识」或「把这个目录整理进 billing-overview」也应触发本技能。
---

# docs-extract：从任意文件提炼业务知识到 overview

> 从用户指定的任意文件或目录中，按段落级相关度筛选，提炼业务知识写入 `XX-overview.md` 第三列，形成合并更新（A/U/D）。

## 与 docs-distill 的关系

`docs-extract` 是 `docs-distill` 的「任意来源」补充路径，两者共享同一写入目标（`XX-overview.md`）和同一套写入规则（五视角 A/U/D 合并更新）。

| 维度 | docs-distill | docs-extract |
|------|-------------|-------------|
| 知识来源 | 固定：`system/application-{name}/` 知识库 | 用户指定：任意文件或目录 |
| 相关性过滤 | 不需要（来源本身已是结构化知识） | 必须：段落级关键词相关度筛选 |
| 增量锚点 | 有（ARCHIVE-LOG + CHANGE-LOG 日志链） | 无（轻量，靠 A/U/D 标识追溯） |
| 日志 | 三日志链路 | 仅 overview 内 A/U/D 变动标识 |

`docs-extract` **不替代** `docs-distill`——用于把知识库体系之外的原始文档纳入 overview。

## 快速定向

| 需要做什么 | 去读 |
|-----------|------|
| 了解参数契约、原子顺序 | 本文件（继续往下读） |
| 闸门触发条件、会话 spec 标记、交互节奏 | [reference/interaction-gate.md](reference/interaction-gate.md) |
| 关键词附录格式、段落筛选规则、提炼规范 | [reference/extract-spec.md](reference/extract-spec.md) |
| 常见陷阱与完整自查清单 | [gotchas.md](gotchas.md) |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--sources` | 无（必填） | 一到多个文件或目录路径，空格分隔；目录递归展开收集所有文本文件 |
| `--overview` | 无（必填） | 目标 `XX-overview.md` 的路径 |
| `--dry-run` | `false` | 仅预览不落盘，输出两层预览：命中段落摘要（不附源路径，仅展示归属章节 + 摘录要点）、将写入 overview 的变动摘要（A/U/D 条目列表） |

---

## 交互与确认闸门

写入前须完成**中间会话 spec + 用户总确认**（`PENDING` → `CONFIRMED`）。触发 HARD-GATE 时默认先 `--dry-run` 再落盘。完整触发条件表与推荐交互节奏见 [reference/interaction-gate.md](reference/interaction-gate.md)。

---

## 原子顺序（严格执行）

```
步骤 0  解析并校验参数
        - --sources 路径存在性检查；目录递归展开，收集所有文本文件
        - --overview 路径存在性检查；文件不存在则终止并提示用户先创建 overview

步骤 1  读取 overview「章节 → 文档关键词」附录节
        - 该节不存在或为空：终止并提示用户在 overview 中补充关键词附录
        - 附录格式见 [reference/extract-spec.md](reference/extract-spec.md)

步骤 2  扫描源文件，段落级相关度筛选
        - 按段落（空行分隔）切分每个源文件
        - 计算每个段落与各章节关键词的命中密度
        - 只保留命中密度超过阈值的段落，标注「归属章节」
        - 全部源文件均无命中段落：终止并提示用户检查关键词附录或源文件内容

步骤 3  读取 overview 五架构视角知识索引表，
        逐条读取副标题列文件链接对应章节的实际内容作为知识基准，读取该章节的「应填内容 + 产出建议」作为要求基准
        从源文件命中段落中，按要求基准提炼相应业务知识，跟知识基准对比，则：
        - 源文件提炼内容与知识基准内容无实质差异 → 跳过，不写入 overview 第三列
        - 源文件提炼内容有增量或差异 → 标 [U]，写入 overview 第三列
        - 目标章节为空 → 标 [A]，写入 overview 第三列
```

**关键约束**：步骤 2 无命中时禁止执行步骤 3；步骤 3 写入失败时不做部分落盘，整体回滚。

---

## 命令示例

```bash
/docs-extract --sources docs/design.md --overview system/architecture/overview/billing-overview.md --dry-run
/docs-extract --sources docs/ --overview system/architecture/overview/billing-overview.md
/docs-extract --sources docs/design.md docs/adr/ --overview system/architecture/overview/billing-overview.md
```

---

## 核心约束

- 提炼内容须与 overview 关键词强相关，弱相关段落不写入
- 禁止整段复制源文件内容；提炼为适合系统库的摘要表达
- 写入到 overview 第三列的知识正文不记录来源（不写 `(来源：...)`、出处、参见链接等）
- 只更新有命中段落的章节；无命中章节保持原内容不变
- 写入前先读目标章节现有内容，确认 A/U/D 判断准确
