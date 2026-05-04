---
name: docs-tag
description: >
  当用户执行 /docs-tag、需要为 Markdown 概览（如 *-overview.md）做关键词驱动的相关性标记、
  或说「扫描关键词」「给概览打标签」「表格行打 ✅」时，必须使用本技能。
  流程：扫描目录提取候选词 → 用户选择 → 写入 YAML 附录 → 按关键词标记表格行。
  若用户已明确要求仅 /docs-extract、仅 /docs-upgrade、仅 /docs-indexing 或仅改全文术语，则不要以本技能为主路径，应分流到对应技能。
---

# 关键词标记（docs-tag）

本技能以「调度器」方式工作：先完成参数门禁，再按阶段读取规范并调用 `keyword_tag.py`（`1-scan` / `1-write` / `2`，**禁止**在自动化流程中使用交互式 `--phase 1`）。

**主要读者**：维护架构概览表与关键词附录的工程师与 Agent。索引地图维护留给 **`docs-indexing`**；段落级业务提炼留给 **`docs-extract`**。

---

## 适用边界

- **本技能负责**：`--file` 目标 Markdown；`--phase` 为 `1`/`2`/`all` 或脚本子阶段 `1-scan`/`1-write`；候选词扫描与 YAML 附录 `<!-- spec-tags -->`；阶段 2 表格行 ✅ 标记。
- **本技能不负责**：生成或重写 `INDEX_GUIDE.md`；`docs-extract` 的 A/U/D 与 overview 第三列业务提炼；`docs-upgrade` 全库术语替换；不在本流程内调用其他技能的落盘逻辑。
- **边界分流**：用户只要从源文档提炼进 overview → `docs-extract`；只要批量替换措辞 → `docs-upgrade`；只要更新九章索引 → `docs-indexing`。

---

## 输入与前置检查

执行前最少确认：

- **`--file`** 存在且为预期概览路径。
- **`--phase`** 与 **`--keywords`**（当 phase 含阶段 1 时）已对齐；Skill 自动化路径**仅使用** `1-scan` + `1-write` + `2`，见 `gotchas.md` §7。
- 在仓库根执行脚本时，使用下文「脚本路径」中的相对路径。

---

## 执行路由（先读后写）

1. **参数门禁与复述**：先读 `references/gates.md`
2. **阶段命令与交互格式**：再读 `references/workflow.md`
3. **共现算法与停用词**：调参或理解候选词质量时读 `references/algorithm.md`
4. **执行层陷阱**：锚点、YAML 幂等、扫描排除、TTY 等读 `gotchas.md`

---

## 门禁要求（必须执行）

- 执行任何脚本前，完成 **步骤 1** 参数逐项确认，并 **一次性复述完整参数**（见 `references/gates.md`）。与 [agent/rules/CONVENTIONS.md](../../rules/CONVENTIONS.md) 低风险（现有参数确认）一致；**不加** `docs/superpowers/specs` 落盘 spec gate。

---

## 脚本路径（在 `{REPO_ROOT}` 下执行）

```bash
python3 agent/skills/docs-tag/scripts/keyword_tag.py ...
```

子阶段：`1-scan`、`1-write`、`2`；兼容用法见 `scripts/keyword_tag.py` 文件头注释。

---

## 评测与迭代（skill-creator 对齐）

- 评测样本：`evals/evals.json`
- 评测元模板：`evals/eval-metadata-template.json`
- 评分规则：`agents/grader.md`
- 失败分析：`agents/analyzer.md`

---

## 回归测试

```bash
cd agent/skills/docs-tag && python3 -m pytest tests/ -q
```
