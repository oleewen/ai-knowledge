# sdx-design 工作流规范（详细设计 **DSD**）

> **说明**：**ASD**（`/sdx-architect`）承载 **§1–§3**（§3 为需求规约摘要表，与 [dsd-template §3](../assets/dsd-template.md) 表头同构）。**DSD**（`/sdx-design`）为独立技能，文档 **§1–§4**：**§1** 与 [asd-template §1](../../sdx-architect/assets/asd-template.md) 对齐且与 ASD 同源/可追溯；**§3** 继承并扩写 **ASD §3**；**详细设计从 §2 起编号**。门禁：**Ga1–Ga3**（ASD）、**Gd1–Gd4**（DSD §1–§4）。

[SKILL.md](../SKILL.md) 为主干。本文件补充：**门禁状态机**（回跳影响面、Q-n 协议）与**阶段三内容生成算法**（步骤 0–3）。

---

## 门禁状态机

```
[阶段一：参数确认]
    ↓ 全部参数确认（或 S/F 跳过）
[阶段二：逐门禁交互]
    DSD 全量：Gd1 → Gd2 → Gd3 → Gd4（对应 §1–§4）
    每门禁：草案呈现 → （可选）多方案对比 → 确认点逐一确认 → 门禁收口
    ↓ 全部门禁收口（或 S/F 跳过）
[Qclose-1 总确认]
    ↓ C / S（PENDING → CONFIRMED）
[阶段三：文档生成]
    骨架 → chunk 1–4（§1–§4）→ 规约 YAML → 终检
```

---

## 回跳影响面评估

用户回跳到 **Gd{k}** 并修改结论后，评估后续门禁的依赖类型：

| 依赖类型 | 判断标准 | 处理方式 |
|---------|---------|---------|
| 强依赖 | 后续门禁与 **Gd{k}** 新结论显式矛盾，或引用同一实体（同一 DD-n/API-n、服务/数据边界） | 须重新确认 |
| 弱依赖 | 后续门禁大量引用 **Gd{k}** 的术语、范围或验收表述 | 建议重新确认 |
| 无依赖 | 后续门禁内容与 **Gd{k}** 无关联 | 保持已确认状态 |

**典型示例**：回跳 Gd2（§2 详设）变更 API 边界 → Gd3 规约表强依赖。向用户说明影响面后，由用户选择重审范围。

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

**仅在用户总确认（`CONFIRMED`）之后**用于填充 **DSD** 与规约，不得绕过 HARD-GATE 单独执行。

### 步骤 0：架构（不在本技能落笔）

**ASD** **`/sdx-architect`** 已产出 **`ASD-*.md`（§1–§3）**。「设计概述」在 DSD **§1** 必须与 ASD **§1 / [asd-template](../../sdx-architect/assets/asd-template.md)** 对齐；**§3 需求规约**表须在 **ASD §3** 已定稿行上扩写。

---

### 步骤 1：详细设计（→ DSD §2）

**输入**：**ASD** + PRD + 分析 + 按需 knowledge

**与 DSD §2 对应**：

1. **§2.1** 应用架构（容器/MQ/异步…）
2. **§2.2** API-{NNN} 详设
3. **§2.3** 业务逻辑 / LOGIC-{NNN}
4. **§2.4** DDL、索引、缓存
5. **§2.5** 安全、可观测

**depth**：同 SKILL `--depth`。

---

### 步骤 2：规约生成（→ specs/）

从 **DSD §2**、**DSD §3 / ASD §3** 规划路径（及 ASD 中仍有效的领域/边界描述，若规约条目引用）抽取，写入：

```
specs/{service-name}/
├── api/         ← §2.2
├── domain/      ← 与 ASD§2/DSD§2 设计边界一致条目
├── data/        ← §2.4
└── integration/ ← 架构集成类（常与 ASD§2 / §2.1 对应）
```

`source` 示例：`DSD §2.2 API-001`。

---

### 步骤 3：文档输出与终检（→ DSD-*.md）

1. 按 [../assets/dsd-template.md](../assets/dsd-template.md) 整合 **§1–§4**（**§1** 可复制 ASD §1）。
2. 填充文末元数据（`## 文档元数据`）：
   - `id`、`title`、`version`、`status: draft`、`created`、`updated`、`parent`（常为 PRD）、`architecture_ref`（ASD）、`mvp_phase`
3. 对照 [quality-checklist.md](quality-checklist.md) 逐项判定。

**输出目录（应用全量）**：

```
{DOC_DIR}/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/
├── ASD-{IDEA-ID}-{N}.md        ← /sdx-architect
├── DSD-{IDEA-ID}-{N}.md        ← /sdx-design（本节）
└── specs/{service-name}/{type}/*.yaml
```

---

## 步间数据流

```
/sdx-architect → ASD（§1、§2、§3）
/sdx-design → DSD：**§1**（与 ASD §1）+ **§2** 详细设计 → **§3** 需求规约（扩写 ASD §3）→ **§4** 附录 → **specs/**
```
