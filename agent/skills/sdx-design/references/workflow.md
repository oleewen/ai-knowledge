# sdx-design 工作流

门禁 [gates.md](gates.md)。**spec-asd** 与 **KNOWLEDGE_TYPE**：[knowledge-type-modes.md](../../sdx-architect/references/knowledge-type-modes.md)。

## 前置

- **PRD**（硬）；**ASD-* 和/或 `{DOC_DIR}/specs/spec-asd-*.md`**（缺则澄清或用户明示例外）
- IDEA-ID、{N}、`{DOC_DIR}`、`{DOC_DIR}/superpowers/specs/` 可写
- 仅要上游或 docs 主线时不强行套全流程

**分工**：ASD §1–§3；本技能 **DSD §1–§3**，实现级在 **§2**。映射：architect G1–G3；本技能 **Gd{n}**（DSD §1–§3）。

---

## 门禁状态机

```
[阶段一：参数确认] → （可 S/F 跳过）
[阶段二：逐门禁] Gd1→Gd2→Gd3（§1–§3）；每门禁：草案 → （可选）多方案 → 确认 → 收口
  → （可 S/F 跳过）
[Qclose-1] → C/S：PENDING → CONFIRMED
[阶段三] 骨架 → chunk §1–§3 → 终检
```

---

## 回跳影响面

用户在 **G{k}** 改结论后，后续门禁若为**强依赖**（同一 DD-n/API-n、服务/数据边界矛盾）→ 须重确认；**弱依赖**（大量引用术语/范围）→ 建议重确认；**无依赖** → 可保持。

*例*：改 Gd2（§2 API）边界 → Gd3（附录收口）常为弱依赖但仍建议快速复核术语一致。

---

## 待澄清项（Q-n）

**触发**：阶段二任一门禁出现歧义、矛盾或缺失。  
**规则**：每次一个 Q-n；选项写清语义勿用空洞「方案A/B」；结论写入对应 DSD 草案；选 **S** 须在 spec 标「Q-n 待澄清」及影响面。

格式示例：

```
Q-{n}：{问题}

背景：{为何问、影响哪项决策}

选项：1 … 2 … 3 其他（请说明）
请选择：C / M / S / F
```

---

## 阶段三（仅在 CONFIRMED 后）

不得绕过 HARD-GATE 单独跑本节（见 `gates.md`）。

### 步骤 0：架构输入（不落笔）

Architect 已产 **ASD-* 与/或 `spec-asd-*`**。实现级契约**只进 DSD §2**，与 PRD、分析等闭合。

- **有 ASD**：DSD §1 对齐 ASD/`asd-template` §1；**§2** 承载 API/DDL/时序等与 ASD §3 的对应展开（冲突以 ASD+PRD 为准）。
- **仅有 spec-asd**：§1 以 spec §1–2、`refs` 组织；§2 按 FR/UC 等落地并标 SSOT；与 PRD 冲突先收口上游。

### 步骤 1：详设（→ §2）

**输入**：ASD 与/或 spec-asd + PRD + 分析 + 按需 knowledge。  
**对齐 §2.1–§2.5**：应用架构、API-{NNN}、LOGIC、DDL/缓存、安全与可观测。  
**depth**：同 SKILL `--depth`。  
在此节内写明与 **FR-n / ASD §3 行 / spec-asd** 的追溯。

### 步骤 2：输出 DSD-*.md

1. 按 `dsd-template.md` 整合 §1–§3（仅有 spec-asd 时正文或元数据须可追溯其路径）。
2. 文末 `## 文档元数据`：含 `mvp_phase`、`parent`、必要时 `architecture_ref` 或 spec-asd 路径。
3. 对照 [quality-checklist.md](quality-checklist.md)。

**目录（应用全量，示意）**：

```
{DOC_DIR}/specs/spec-asd-...md          ← 概设（/sdx-architect）

{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/
├── ASD-...md    ← 可选（architect）
└── DSD-...md    ← 本技能（唯一详设正文）
```

（`MVP-Phase-* / specs/` **不是**本轮必建目录：仅当另有 **spec-asd**、`docs-push` 等与本包无关的资产时才可能存在。）

---

## 数据流（摘要）

```
/sdx-architect → ASD 与/或 {DOC_DIR}/specs/spec-asd-*.md
/sdx-design    → 读 spec-asd（若有）→ **仅 DSD-{IDEA-ID}-{N}.md**
```
