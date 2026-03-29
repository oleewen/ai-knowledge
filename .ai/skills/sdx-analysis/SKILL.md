---
name: sdx-analysis
description: >
  需求分析：基于解决方案文档与知识库进行深度研究、需求细化、MVP 拆分与依赖/风险评估，输出需求分析文档。
  在用户执行 /sdx-analysis、编写需求分析文档、或进行方案→需求分析时使用。
  输出至 docs/analysis/ANALYSIS-{ID}.md，模板见 assets/analysis-template.md。
  主要面向产品经理与需求分析师；正文使用产品/需求分析通用表述，技术实现细节留给 sdx-design。
---

# 需求分析阶段（sdx-analysis）

在解决方案与事实材料基础上，将共识级方案细化为**可评审、可排期、可验收**的需求分析：划清范围、拆 MVP、标优先级与依赖，并识别风险。**主要读者为产品经理与需求分析师**（业务方参与范围与验收对齐）；研发以本阶段产出为输入编写 PRD/技术方案，故正文应以**场景、规则、验收与协作**表述为主，避免写成实现说明。

## 输入与输出

**输入**：解决方案文档（`docs/solutions/`）；为校准范围与事实可**按需**查阅 `knowledge/`、各 `requirements/.../specs/` 或 `knowledge/technical/`（**勿将工程细节原样写入需求分析正文**）。  
**输出**：`docs/analysis/ANALYSIS-{ID}.md`（结构遵循 [.ai/skills/sdx-analysis/assets/analysis-template.md](assets/analysis-template.md)）

| 类型 | 内容 |
|------|------|
| 硬输入 | 解决方案文档（`docs/solutions/SOLUTION-{ID}.md`） |
| 可选输入 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/`、AGENTS.md |
| 固定输出 | `docs/analysis/ANALYSIS-{ID}.md` |
| 不产出 | PRD、ADD、测试设计、代码（使用下游 sdx-prd / sdx-design / sdx-test） |

## 参数

| 参数 | 必需 | 默认值 | 说明 |
|------|------|--------|------|
| `--id` | 否 | `YYYYMMDD-SEQ` | 需求分析文档编号 |
| `--doc-root` | 否 | `docs` | 文档根目录 |
| `--depth` | 否 | `standard` | 分析深度（quick / standard / deep），影响步骤 1–2 粒度 |
| `--solution` | 否 | — | 上游解决方案编号，自动定位对应文件 |

## 适用场景

| 场景 | 使用本技能 |
|------|-----------|
| 已有解决方案，需要进行需求分析与 MVP 拆分 | 是 |
| 需将高层方案细化为可度量的功能与非功能诉求（仍以业务/产品可读的表述呈现） | 是 |
| 收到业务需求/工单，需先输出解决方案文档 | 否 → **sdx-solution** |
| 已有需求分析，需要编写 PRD | 否 → **sdx-prd** |
| 已有 PRD，需技术方案设计 | 否 → **sdx-design** |

## 核心概念（面向产品/需求分析语境）

- **深度研究**：从业务边界、核心规则、跨部门/跨系统协作、行业惯例等维度澄清「做什么、不做什么」；内部分析可对照知识库识别**现有能力缺口与历史约束**，写入文档时改为**对业务与协作的影响**表述，不罗列模块或栈名。
- **需求细化**：把方案目标拆成带优先级（P0–P3）的功能诉求与非功能诉求；用**输入信息—处理规则—产出与验收**描述功能，用**用户可感知的体验与承诺**（时效、可用场景、合规要求等）描述非功能，避免接口与存储细节。
- **MVP 拆分**：按独立业务价值、可独立交付、依赖尽量单向等原则划分阶段；每个 MVP 写清范围、清单与**可验证的验收要点**。
- **需求分析文档**：遵循 [.ai/skills/sdx-analysis/assets/analysis-template.md](assets/analysis-template.md) 的章节结构；语言规范见下文「文档语言约定」与共享规范引用。

## 文档语言约定（产品 / 需求分析师可读）

与 [.ai/skills/sdx-solution/reference/audience-language-spec.md](../sdx-solution/reference/audience-language-spec.md)**同一原则**：**谁能做什么、流程如何变、验收与对外承诺是什么**，而不是系统内部如何调用。

| 宜写入正文（产品/需求分析通用语） | 宜弱化或避免（留给下游技术设计） |
|----------------------------------|----------------------------------|
| 角色、场景、用户故事或主流程 | 类名、接口名、方法名 |
| 业务规则、异常与边界（业务话术） | 表名、字段名、消息队列/缓存等中间件名 |
| 验收标准、优先级、MVP 边界 | 具体技术栈、框架、部署形态 |
| 协作依赖（与哪个团队/环节对齐） | 服务模块名、协议类型（REST/gRPC 等） |

**需求工程常用词**（如用户故事、验收标准、MVP、非功能需求）**可以**使用，但释义须保持业务可读；非功能项用「高峰时段仍须流畅」「关键操作须可追责」等表述，避免裸指标堆砌且无业务语境。

Agent 为核对事实**可以**查阅工程材料；写入 `ANALYSIS-{ID}.md` 时**必须**将技术事实转写为需求/产品表述（转写示例见 [.ai/skills/sdx-solution/reference/audience-language-spec.md](../sdx-solution/reference/audience-language-spec.md)）。

## 工作流（五步）

按顺序执行，每步产出作为下一步输入；最终文档需通过质量门禁。详细算法与决策点见 [.ai/skills/sdx-analysis/reference/workflow-spec.md](reference/workflow-spec.md)。

### 步骤 1：深度研究与探索

从业务边界、核心概念与规则、跨团队/跨系统协作入手；对照现有材料澄清**已有能力与缺口**（内部分析可用工程线索，**写入文档时改为能力与流程表述**）；补充行业或对内惯例参考；边界场景用**业务后果**描述（如重复提交、数据不一致对用户或结算的影响），避免实现层术语主导段落。

### 步骤 2：需求细化与建模

功能需求：按场景细化，明确优先级 P0–P3，用**业务语言**写清规则与验收；非功能需求：从体验、时效、合规、容灾意识等角度写**可理解的期望**，不展开监控埋点与中间件选型；数据与状态需求用**业务对象生命周期、关键字段含义（业务名）**表述，不写物理表结构。

### 步骤 3：MVP 拆分与规划

按独立业务价值、可独立交付、依赖单向等原则拆分；为每个 MVP 定义范围、功能清单、**验收标准**与相对工作量/节奏；排序依据业务价值、依赖与风险（**风险用业务影响说明**）。

### 步骤 4：依赖分析与风险评估

梳理 MVP 之间以及对外部团队、第三方、合规节奏的依赖；识别进度与质量风险，给出**产品与协作侧**应对与跟进方式；避免以「联调某接口」代替「与某方在什么节点交付什么结果」。

### 步骤 5：文档输出与评审

将步骤 1–4 整合为需求分析文档，严格采用 [.ai/skills/sdx-analysis/assets/analysis-template.md](assets/analysis-template.md) 的章节与格式；**通读全文**，去除不必要的技术术语，确认业务与需求侧读者可独立理解；执行质量门禁自查。

质量门禁清单见 [.ai/skills/sdx-analysis/assets/quality-gate-checklist.md](assets/quality-gate-checklist.md)。

可使用辅助脚本验证文档结构（于**仓库根目录**执行）：

```bash
.ai/skills/sdx-analysis/scripts/validate-analysis.sh --doc-root docs
```

## 核心约束

| 约束 | 说明 |
|------|------|
| 模板驱动 | 输出严格遵循 analysis-template.md 八章结构 |
| 受众可读 | 正文以产品、需求分析通用语言为主；禁止将工程实现细节当正文主体；细则见上文「文档语言约定」与 [.ai/skills/sdx-solution/reference/audience-language-spec.md](../sdx-solution/reference/audience-language-spec.md) |
| 证据优先 | 须引用解决方案与 `knowledge/` 等事实校准，禁止臆测；写入文档时转为需求/业务表述 |
| 按需加载 | 仅在本轮需要时打开文件，禁止为完整性通读全仓 |
| 歧义标注 | 不确定项标为待澄清（如 Q-n），**逐一向用户提问确认**（每题 3–4 个选项 + 「其他」兜底），禁止自行假设；交互格式可参照 [.ai/skills/sdx-solution/reference/workflow-spec.md](../sdx-solution/reference/workflow-spec.md) |
| 范围清晰 | 仅产出需求分析文档，不涉及 PRD / ADD / 代码 |
| 可追溯 | 每个功能诉求可追溯到解决方案中的业务目标；每个 MVP 可追溯到功能清单 |

设计原则完整版与反模式清单见 [.ai/skills/sdx-analysis/reference/design-principles.md](reference/design-principles.md)。

## 依赖关系

| 类型 | 技能/组件 | 说明 |
|------|-----------|------|
| 上游（必需） | `sdx-solution` | 提供解决方案文档作为核心输入 |
| 上游（可选） | `knowledge-extract` | 提供 `knowledge/*/*_knowledge.json` 与 `knowledge/KNOWLEDGE_INDEX.md` 基线 |
| 下游 | `sdx-prd` | 基于需求分析转化为产品需求文档 |
| 下游 | `sdx-design` | 基于 PRD 进行技术方案设计 |
| 下游 | `sdx-test` | 基于 PRD 与 ADD 进行测试设计 |

## 参考

| 资源 | 路径 |
|------|------|
| 受众与文档语言规范（与解决方案阶段同原则，写入时需转写） | [.ai/skills/sdx-solution/reference/audience-language-spec.md](../sdx-solution/reference/audience-language-spec.md) |
| 设计原则与反模式 | [.ai/skills/sdx-analysis/reference/design-principles.md](reference/design-principles.md) |
| 五步工作流详细规范 | [.ai/skills/sdx-analysis/reference/workflow-spec.md](reference/workflow-spec.md) |
| 质量门禁验收清单 | [.ai/skills/sdx-analysis/assets/quality-gate-checklist.md](assets/quality-gate-checklist.md) |
| 需求分析文档模板 | [.ai/skills/sdx-analysis/assets/analysis-template.md](assets/analysis-template.md) |
| 文档结构校验脚本 | [.ai/skills/sdx-analysis/scripts/validate-analysis.sh](scripts/validate-analysis.sh) |
| 上游：解决方案 | `.ai/skills/sdx-solution/SKILL.md` |
| 下游：产品需求 | `.ai/skills/sdx-prd/SKILL.md` |
| 下游：技术设计 | `.ai/skills/sdx-design/SKILL.md` |
| 知识库 | `knowledge/`、`requirements/.../specs/`、`knowledge/technical/` |
