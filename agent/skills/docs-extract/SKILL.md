---
name: docs-extract
description: >
  从用户指定的任意文件或目录中，按段落级关键词相关度筛选，提炼业务知识写入指定 XX-overview.md 第三列（A/U/D 合并更新）。
  只要用户意图涉及以下任一场景，就应立即触发本技能，不要等用户说出命令名：
  「从文件提炼到 overview」「从这些文档抽取业务知识」「把这个目录的内容整理进系统库」
  「从 design.md 提炼知识写进 overview」「从源文件提取业务知识」「把这些文档的知识同步到 overview」
  「从指定文件提炼」「抽取业务知识到系统库」「把这个文件的内容写进 overview」
  「从文档里提取业务规则」「把设计文档整理进知识库」。
  即使用户只说「帮我从这几个文件提炼业务知识」或「把这个目录整理进 billing-overview」也应触发。
  支持 --sources --overview --dry-run。
  用户执行 /docs-extract 时必须触发。
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

| 需要做什么 | 去读 | 何时打开 |
|-----------|------|---------|
| 参数契约、原子顺序、工作流 | 本文件（继续往下读） | 每次执行前 |
| 闸门触发条件、会话 spec 标记、交互节奏 | [reference/interaction-gate.md](reference/interaction-gate.md) | 任意写入前；首次写入 / 命中异常多 / 大量 U 更新时 |
| 关键词附录格式、段落筛选规则、提炼规范 | [reference/extract-spec.md](reference/extract-spec.md) | 阶段 1 读关键词、阶段 4 提炼写入时 |
| 常见陷阱与完整自查清单 | [gotchas.md](gotchas.md) | 遇到异常命中或执行完毕自查时 |

---

## 参数契约

| 参数 | 默认 | 说明 |
|-----|------|------|
| `--sources` | 无（必填） | 一到多个文件或目录路径，空格分隔；目录递归展开收集所有文本文件 |
| `--overview` | 无（必填） | 目标 `XX-overview.md` 的路径 |
| `--dry-run` | `false` | 仅预览不落盘，输出两层预览：命中段落摘要（归属章节 + 摘录要点）、将写入 overview 的变动摘要（A/U/D 条目列表） |

---

## 交互与确认闸门

写入前须完成**中间会话 spec + 用户总确认**（`PENDING` → `CONFIRMED`）。这个节奏的目的是让用户在落盘前看到命中段落和变动范围，避免关键词过宽导致大量误写入。触发 HARD-GATE 时默认先 `--dry-run` 再落盘。完整触发条件表与推荐交互节奏见 [reference/interaction-gate.md](reference/interaction-gate.md)。

HARD-GATE 固定在**阶段 3 与阶段 4 之间**。

**门禁标记**：会话 spec 中使用 `<!-- docs-extract-gate: PENDING -->`，用户总确认后改为 `<!-- docs-extract-gate: CONFIRMED -->`，且正文须出现目标文件名（basename）。本 gate **无 bypass 环境变量**，须完整走确认流程；唯一例外是用户在同一对话中明示跳过。

---

## 工作流（五阶段）

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | EXPLORE | 校验 --sources / --overview 路径；读取 overview 关键词附录 | [extract-spec.md](reference/extract-spec.md) |
| 2 | CLARIFY | 确认关键词覆盖范围是否准确；评估源文件规模；单次一问 | [extract-spec.md](reference/extract-spec.md) |
| 3 | CONFIRM（HARD-GATE）| dry-run 展示命中段落摘要与 A/U/D 变动列表；会话 spec 标记 CONFIRMED 后解锁阶段 4 | [interaction-gate.md](reference/interaction-gate.md) |
| 4 | EXECUTE | 4.1 段落级相关度筛选 → 4.2 读目标章节现有内容 → 4.3 提炼写入第三列（含 A/U/D 标识） | [extract-spec.md](reference/extract-spec.md) |
| 5 | CLOSE | 变更摘要；CHANGE-LOG 倒序插入（最新在前）；不自动 git commit | — |

> **HARD-GATE**：阶段 3 会话 spec 标记 CONFIRMED 前，禁止执行阶段 4（写入 overview 第三列）。dry-run 属于阶段 3，不单独占阶段。

**阶段 4 原子约束**：步骤 4.1 无命中时禁止执行 4.2/4.3；步骤 4.3 写入失败时整体回滚，不做部分落盘——部分落盘会让 overview 处于不一致状态，比完全不写更难修复。

---

## 命令示例

```bash
/docs-extract --sources docs/design.md --overview system/architecture/overview/billing-overview.md --dry-run
/docs-extract --sources docs/ --overview system/architecture/overview/billing-overview.md
/docs-extract --sources docs/design.md docs/adr/ --overview system/architecture/overview/billing-overview.md
```

---

## 核心约束

- 提炼内容须与 overview 关键词强相关，弱相关段落不写入——关键词附录是唯一筛选依据
- 禁止整段复制源文件内容；提炼为适合系统库的摘要表达
- 写入到 overview 第三列的知识正文不记录来源（不写 `(来源：...)`、出处、参见链接等）
- 只更新有命中段落的章节；无命中章节保持原内容不变，不覆盖
- 写入前先读目标章节现有内容，确认 A/U/D 判断准确

---

## 工程化支持

仓库 [agent/hooks.json](../../hooks.json) 注册了 `preToolUse` 钩子（`Write` / `StrReplace`），脚本见 [agent/hooks/sdx_gate_common.py](../../hooks/sdx_gate_common.py)（`python3 agent/hooks/sdx_gate_common.py --gate extract`）；需启用 Hooks 方生效。

钩子证据校验逻辑：检查 `docs/superpowers/specs/` 下是否存在包含 `<!-- docs-extract-gate: CONFIRMED -->` 且引用目标文件名的 spec 文件；未通过则拒绝写入。**本 gate 无 bypass 环境变量。**
