# sdx-design 工作流

[SKILL.md](../SKILL.md) 为主干；写入类门禁与例外见 [gates.md](gates.md)。

---

> **说明**：**ASD**（`/sdx-architect`）承载 **§1–§3**（§3 为需求规约摘要表，与 [dsd-template §3](../assets/dsd-template.md) 表头同构）。**需求规约 Markdown** 标准路径为 **`./specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（相对 `{DOC_DIR}`，与 dsd-template §3 表一致）；**由 `/sdx-design` 生成或扩写该文件时**，正文骨架以 **[dsd-spec-template.md](../assets/dsd-spec-template.md)** 为准；若该文件已由 `/sdx-architect` 创建，可先符合 [asd-spec-template §1–6](../../sdx-architect/assets/asd-spec-template.md)，详设阶段再按 `dsd-spec-template` 对齐实现级章节。路径段与元数据约定见 [asd-template §3 表](../../sdx-architect/assets/asd-template.md)。详设上游 **ASD 与该 Markdown 至少其一**（同 IDEA-ID / `{N}` 对齐）。**DSD**（`/sdx-design`）文档 **§1–§4**：**有 ASD 时** **§1** 与 ASD §1 / [asd-template §1](../../sdx-architect/assets/asd-template.md) 同源可追溯，**§3** 继承并扩写 **ASD §3**；**仅有需求规约 Markdown** 时 §1/§3 以该文件与元数据为 SSOT，表结构仍遵循 `dsd-template`。**详细设计从 §2 起编号**。门禁：**G1–G3**（ASD）、**G1–G4**（DSD §1–§4）。

本文件补充：**门禁状态机**（回跳影响面、Q-n 协议）与**阶段三内容生成算法**（步骤 0–3）。

---

## 门禁状态机

```
[阶段一：参数确认]
    ↓ 全部参数确认（或 S/F 跳过）
[阶段二：逐门禁交互]
    DSD 全量：G1 → G2 → G3 → G4（对应 §1–§4）
    每门禁：草案呈现 → （可选）多方案对比 → 确认点逐一确认 → 门禁收口
    ↓ 全部门禁收口（或 S/F 跳过）
[Qclose-1 总确认]
    ↓ C / S（PENDING → CONFIRMED）
[阶段三：文档生成]
    骨架 → chunk 1–4（§1–§4）→ dsd-spec-template 规约汇总稿 → 终检
```

---

## 回跳影响面评估

用户回跳到 **G{k}** 并修改结论后，评估后续门禁的依赖类型：

| 依赖类型 | 判断标准 | 处理方式 |
|---------|---------|---------|
| 强依赖 | 后续门禁与 **G{k}** 新结论显式矛盾，或引用同一实体（同一 DD-n/API-n、服务/数据边界） | 须重新确认 |
| 弱依赖 | 后续门禁大量引用 **G{k}** 的术语、范围或验收表述 | 建议重新确认 |
| 无依赖 | 后续门禁内容与 **G{k}** 无关联 | 保持已确认状态 |

**典型示例**：回跳 G2（§2 详设）变更 API 边界 → G3 规约表强依赖。向用户说明影响面后，由用户选择重审范围。

---

## 待澄清项（Q-n）协议

**触发**：阶段二任意门禁中出现歧义、矛盾或信息缺失时，立即标注 Q-n。

**格式**：

```
Q-{n}：{问题描述}

背景：{为什么需要澄清，影响哪个决策}

选项：
1. {具体含义描述}（推荐）
2. {具体含义描述}
3. 其他（请说明）

请选择：C / M / S / F
```

**规则**：

- 每次只提一个 Q-n，等用户回答后再提下一题
- 选项描述具体含义，不写「方案A/方案B」等抽象标签
- 澄清结论写入对应 **DSD** 草案条目，不单独设与交付物无关的「待澄清问题」章
- 用户选 S 时，在 spec 中标注「Q-{n} 待澄清」并说明影响范围

---

## 阶段三内容生成算法（步骤 0–3）

**仅在用户总确认（`CONFIRMED`）之后**用于填充 **DSD** 与规约汇总稿，不得绕过 HARD-GATE 单独执行（见 `gates.md`）。

### 步骤 0：架构输入（不在本技能落笔）

**`/sdx-architect`** 已产出 **`ASD-*.md`（§1–§3）** 与/或 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`**（可先为 asd-spec-template；详设落地稿对齐 **dsd-spec-template.md**），**至少其一**。

- **有 ASD**：DSD **§1** 与 ASD **§1 / [asd-template](../../sdx-architect/assets/asd-template.md)** 对齐；**§3** 在 **ASD §3** 已定稿行上扩写（若有 architect spec，接口/FR 细节可由其 §3–6 补全；冲突以已确认 ASD + PRD 为准）。
- **仅有 architect spec**：DSD **§1** 以 spec §1–2 与元数据 `refs` 为主组织，骨架对齐 `asd-template` §1；**§3** 以 spec FR/UC 等为表行基础并标注 SSOT；与 PRD 冲突时先收口上游。

---

### 步骤 1：详细设计（→ DSD §2）

**输入**：**ASD 与/或 architect spec**（至少其一）+ PRD + 分析 + 按需 knowledge

**与 DSD §2 对应**：

1. **§2.1** 应用架构（容器/MQ/异步…）
2. **§2.2** API-{NNN} 详设
3. **§2.3** 业务逻辑 / LOGIC-{NNN}
4. **§2.4** DDL、索引、缓存
5. **§2.5** 安全、可观测

**depth**：同 `SKILL.md` 所述 `--depth`。

---

### 步骤 2：规约汇总稿（→ `{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`）

从 **DSD §2**、**DSD §3 / ASD §3**（及 ASD 中仍有效的领域/边界描述）抽取实现级信息，在 **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`** 按 **[dsd-spec-template.md](../assets/dsd-spec-template.md)** 落盘，与 **DSD** 章节互可追溯（常与 §2 API/领域/数据小节对应）。

> **本技能不再约定** `specs/{service-name}/{api|domain|data|integration}/` 下的分文件 **YAML**；若工程另有 OpenAPI/契约仓，由仓库自身规范维护，**不作为** `sdx-design` 必交付物。

---

### 步骤 3：文档输出与终检（→ DSD-*.md）

1. 按 [../assets/dsd-template.md](../assets/dsd-template.md) 整合 **§1–§4**（**有 ASD 时 §1** 可复制 ASD §1；**仅有 architect spec 时** 在元数据或关联文档中显式引用该 spec 路径）。
2. 填充文末元数据（`## 文档元数据`）：
   - `id`、`title`、`version`、`status: draft`、`created`、`updated`、`parent`（常为 PRD）、`architecture_ref`（若有 ASD）、`mvp_phase`；无 ASD 时须在正文或元数据扩展字段中可追溯 **architect spec**（`specs/spec-{IDEA-ID}-{N}-{service-name}.md`）
3. 对照 [quality-checklist.md](quality-checklist.md) 逐项判定。

**输出目录（应用全量）**：

```
{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md   ← 规约汇总 Markdown（骨架：dsd-spec-template）

{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/
├── ASD-{IDEA-ID}-{N}.md        ← /sdx-architect（可选，与下项至少其一在 {DOC_DIR} 可追溯）
└── DSD-{IDEA-ID}-{N}.md        ← /sdx-design（本节）
```

`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md` 可在 **ASD §3** 表引用或由 `/sdx-architect` 初创；详设阶段由 `/sdx-design` 按 **dsd-spec-template.md** 生成或扩写，并须在 `{DOC_DIR}` 下可定位（若适用）。

---

## 步间数据流

```
/sdx-architect → ASD（§1、§2、§3）与/或 → {DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md（上游可选用 asd-spec-template）
/sdx-design → 同期可将该路径下规约汇总稿对齐 → dsd-spec-template.md
/sdx-design → DSD：**§1**（有 ASD 则对齐 ASD §1；仅有 spec 则以 spec 为 SSOT）+ **§2** 详细设计 → **§3**（有 ASD 则扩写 ASD §3；仅有 spec 则以 spec FR/UC 为基）→ **§4** 附录 → **`{DOC_DIR}/specs/spec-{IDEA-ID}-{N}-{service-name}.md`（dsd-spec-template）**
```
