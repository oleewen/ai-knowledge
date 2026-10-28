# 从零起步构建知识库

> **定位**：落地操作指南；执行规则以各技能及共享协议为准。概念见 [README.md](README.md)；元模型见 [knowledge-governance](agent/knowledge/knowledge-governance.md)。

---

## 选型

**口诀**（与 [README 从零选型](README.md#从零选型) 同口径）：有应用仓 → bootstrap + build；有多应用 → 系统 link + Git 更新 + distill；有多系统 → 解决方案层再 hop；只有 legacy → extract → archive → build。

| 场景 | 适用 | 一句话 |
| --- | --- | --- |
| **A** | 单一应用，无联邦 | 应用仓 standalone，建 SSOT + 按需 SDD（含 `/sdx-analysis`） |
| **B** | 新交付（多应用）+ 上层业务知识库 | 先解决方案/系统需求与概设，再应用库详设 |
| **C** | 老系统（多应用）+ 上层业务知识库 | 先各应用 SSOT，再三跳 link/distill/archive |
| **D** | 仅有 Wiki/协作文档等 legacy | overview 缓冲区 → archive → build |

脚本参数与 mode 见 [agent/skills/docs-install/SKILL.md](agent/skills/docs-install/SKILL.md)；双轨自动化见 [bootstrap.sh](bootstrap.sh)。全新环境先安装 Agent 并配置 `WORK_SPACE`，再初始化知识库；已有 Agent 前置时可直接初始化。bootstrap 的 `--meta PATH` 可复用已有元库，未指定时将元库保留在 `WORK_SPACE/ai-knowledge`。

产物分工：[docs-indexing](agent/skills/docs-indexing/SKILL.md) 管九章 `INDEX-GUIDE.md` 与文内增量锚点；[docs-build](agent/skills/docs-build/SKILL.md) 管本层首次定义实体、视角 README 与 INDEX 第四章导航；目录 `index.md` 和 `viz.html` 按需由 [docs-okf](agent/skills/docs-okf/SKILL.md) 刷新。下文 `/docs` 为示例，实际路径以 `.docsconfig` 的 `DOC_DIR` 为准。

---

## 场景 A：独立应用系统

**目标**：单一应用仓建 SSOT，无需系统/解决方案/公司联邦。

```mermaid
flowchart LR
    S((开始))
    Z((结束))

    subgraph KB["知识库构建"]
        direction LR
        A["/agent-install → /docs-install<br/>应用知识库 · 独立模式"]
        B["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
        F["/docs-agent<br/>生成 AGENTS｜README"]
        C["/docs-build<br/>产出：本层实体与视角导航"]

        A --> B --> F --> C
    end

    subgraph RD["需求交付"]
        direction LR
        D["/sdx-*<br/>需求分析设计交付"]
    end

    subgraph CHG["变更闭环"]
        direction LR
        E["git log / git diff<br/>变更溯源"]
    end

    S --> A
    C --> D --> E --> Z
    E -.-> B
```

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 `/agent-install` 前置，再 `/docs-install`（`--mode=standalone`，`--type=application`） | 应用 `/docs` 骨架 + `.docsconfig` + Agent |
| 2 | `/docs-indexing`（完成 spec 与 gate 确认）+ `/docs-agent` | `INDEX-GUIDE.md`、`README.md`、`AGENTS.md` |
| 3 | `/docs-build` | 本层实体、视角 README、INDEX 第四章导航 |
| 4 | 需求交付按需：`/sdx-analysis` → `/sdx-feature` → `/sdx-prd` → `/sdx-architect` → `/sdx-design` → `/sdx-test` | `ANALYSIS` / `FEATURE` / `PRD` / `ASD` / `DSD` / `TDD` |
| 5 | `git log` / `git diff` + 定期 `/docs-indexing` | 变更可追溯 |

---

## 场景 B：新交付（多应用）+ 中央知识库

**目标**：公司 `domains/`、解决方案 `solutions/`、系统 `analysis/`→`features/`→`requirements/` 分层写；应用库承接详设。七章需求分析由 `/sdx-analysis` 写在系统/应用。

```mermaid
flowchart LR
    S((开始))

    subgraph SYS["上层业务知识库"]
        direction LR
        S0["bootstrap<br/>安装知识库"]
        S2["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
        S3["/docs-agent<br/>生成 AGENTS｜README"]
        S4["/docs-build<br/>产出：本层实体与视角导航"]
        S5["解决方案：/sdx-solution"]
        SC["公司：/sdx-domains"]
        S6["系统：/sdx-analysis → /sdx-feature"]
        S7["/sdx-prd<br/>产出：产品设计文档"]
        S8["/sdx-architect<br/>产出：概要设计文档"]
        S9["git log / git diff<br/>变更溯源"]
        S10["中央概设规约<br/>供应用只读引用"]

        S0 --> S2 --> S3 --> S4
        S4 --> SC
        S4 --> S5
        S4 --> S6 --> S7 --> S8 --> S9 -.-> S2
        S8 --> S10
    end

    subgraph APP["应用库接入"]
        direction LR
        A0["bootstrap<br/>安装应用知识库 · 多应用模式"]
        A1["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
        A2["/docs-agent<br/>生成 AGENTS｜README"]
        A3["/docs-build<br/>产出：本层实体与视角导航"]
        A4["/sdx-design<br/>产出：详细设计文档"]
        A5["/sdx-test<br/>产出：测试设计文档"]
        A6["git log / git diff<br/>变更溯源"]

        AL["/docs-link<br/>登记系统与应用"]
        AI["已确认的实现工作流"]
        A0 --> AL --> A1 --> A2 --> A4 --> A5 --> AI --> A3 --> A6
        A1 <-.-> A6
    end

    S --> S0
    S --> A0
    S10 --> A4
    A6 --> Z((结束))
```

### 阶段一：上层业务知识库 — 分层需求分析设计

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 Agent 前置，再 `/docs-install` 按层 `--type=company` / `solution` / `system` | `/docs` 骨架 + `.docsconfig` |
| 2 | `/docs-indexing` + `/docs-agent`，再 `/docs-build` | 九章地图、根入口、本层实体与视角导航 |
| 3 | 公司：`/sdx-domains`。解决方案：`/sdx-solution`。系统/应用：`/sdx-analysis` → `/sdx-feature` → `/sdx-prd` → `/sdx-architect` | `DOMAIN-*` / `SOLUTION` / `ANALYSIS` / `FEATURE` / `PRD` / `ASD` |

系统分析可从原始需求开始，不以 SOLUTION 为前置。公司、解决方案、系统在各自知识库执行上述分支。

### 阶段二：应用库 — 引用概设、详设与开发

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 Agent 前置，再 `/docs-install` 安装应用库，随后 `/docs-link`（系统→应用） | 应用 `/docs` + `application-slots` |
| 2 | `/docs-indexing` + `/docs-agent` 后，按 [只读消费契约](agent/skills/sdx-design/references/central-spec-source.md) 定位并确认中央 ASD/spec-asd | HTTP 来源链接与确认内容基线 |
| 3 | 规约详细设计链路：`/sdx-design` → `/sdx-test` | `DSD`、`TDD` |
| 4 | 使用当前工程已安装并确认的实现工作流 | 代码实现 + 规格归档 |
| 5 | `/docs-build`（按需） | 本层实体、视角 README、INDEX 第四章导航 |

应用库 **mode**：**standalone** = 单应用全量模板；**central** = 仅同步 `knowledge/` 等子集并 `docs-link` 建联（见 [agent/skills/docs-install/SKILL.md](agent/skills/docs-install/SKILL.md)）。

### 阶段三：变更溯源与索引

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | `git log` / `git diff` | 变更历史（仓内 commit） |
| 2 | `/docs-indexing`（增量，完成 gate 确认） | `INDEX-GUIDE.md` 与文内增量锚点对齐、可追溯 |

---

## 场景 C：老系统（多应用）+ 中央知识库

**目标**：先各应用落地 SSOT，再按 `application → system → solution → company` 上行聚合，再接分层 SDD。

```mermaid
flowchart LR
    S((开始))

    subgraph APP["应用知识库"]
        direction LR
        subgraph APP_KB["应用知识库构建"]
            direction LR
            A0["bootstrap<br/>安装应用知识库"]
            A1["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
            A2["/docs-agent<br/>生成 AGENTS｜README"]
            A3["/docs-build<br/>产出：本层实体与视角导航"]

            AX["按需准备 overview → extract<br/>核实后 archive"]
            A0 --> A1 --> A2 --> A3
            A2 -.-> AX -.-> A3
        end

        subgraph DSD["详细交付链路"]
            direction LR
            D0["/sdx-*<br/>产出：详细设计文档"]
        end

        subgraph APP_CHG["变更闭环"]
            direction LR
            D["git log / git diff<br/>变更溯源"]
        end

        D0 --> D
    end

    subgraph CENTRAL["中央知识库"]
        direction LR
        subgraph CEN_AGG["中央知识库构建"]
            direction LR
            C0["bootstrap<br/>安装系统/解决方案/公司库"]
            C1["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
            C2["/docs-agent<br/>生成 AGENTS｜README"]
            C3["/docs-link<br/>知识库建联"]
            C4["各仓 Git 更新<br/>docs-link --check 检查槽位"]
            C6["/docs-distill<br/>知识蒸馏"]
            C7["/docs-archive<br/>知识归档"]

            C0 --> C1 --> C2 --> C3 --> C4 --> C6 --> C7
        end

        subgraph CEN_SDX["需求分析设计"]
            direction LR
            S0["按知识层选择交付流程"]
            SC["公司：/sdx-domains"]
            SS["解决方案：/sdx-solution"]
            SY["系统：analysis → feature → prd → architect"]
            S1["系统 ASD/spec-asd<br/>供应用只读引用"]

            S0 --> SC
            S0 --> SS
            S0 --> SY --> S1
        end

        subgraph CEN_CHG["变更闭环"]
            direction LR
            H["git log / git diff<br/>变更溯源"]
        end

        C1 <-.-> H
        S1 --> H
        SC --> H
        SS --> H
    end

    S --> A0
    S --> C0
    A3 ---> C4
    A3 -.-> D0
    C7 --> S0
    S1 --> D0
    D -.-> A1
    H --> Z((结束))
    D --> Z
```

### 阶段一：现存应用构建知识库

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 Agent 前置，再为各应用 `/docs-install`（`--mode=standalone` 或 `central`） | 应用 `/docs` 骨架 + `.docsconfig` + Agent |
| 2 | `/docs-indexing`（完成 spec 与 gate 确认）+ `/docs-agent` | `INDEX-GUIDE.md`、`README.md`、`AGENTS.md` |
| 3 | 按需从 legacy 源 `/docs-extract`，核实后 `/docs-archive`；overview 前置见场景 D | overview 第三列 delta 与已归档章节 |
| 4 | `/docs-build` | 各应用本层实体、视角 README、INDEX 第四章导航 |
| 5 | `git log` / `git diff` | 各应用仓变更历史 |

### 阶段二：上层业务知识库 — 三跳登记、检查、蒸馏、归档

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 Agent 前置，再 `/docs-install` `--type=system` / `solution` / `company` | 各层 `/docs` + `.docsconfig` |
| 2 | `/docs-indexing` + `/docs-agent` | 各层索引入口 |
| 3 | `/docs-link`：系统←应用、解决方案←系统、公司←解决方案 | `knowledge-links.yaml` + 对应槽位 |
| 4 | 各下级仓按普通 Git 工作流更新；`/docs-link --check`，异常槽位用 `--repair --target <已登记路径或URL>` | 本地内容已核实、槽位可达 |
| 5 | 在系统、解决方案、公司目标仓逐跳 `/docs-distill`；按各仓实际 DOC_DIR、知识层与源名称执行，见 [工作流](agent/skills/docs-distill/references/workflow.md) | 各层 `{NAME}-overview.md` 第三列 |
| 6 | `/docs-archive`（核实后） | 落入该层 `knowledge/` 视角章节 |

### 阶段三：分层需求分析、概要设计

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 解决方案 `/sdx-solution`；系统/应用 `/sdx-analysis` → `/sdx-feature` → `/sdx-prd` → `/sdx-architect`；公司仅 `/sdx-domains` | `SOLUTION` / `ANALYSIS` / `FEATURE` / `PRD` / `ASD` / `DOMAIN-*` |

### 阶段四：应用库详设、开发与变更

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 按 [只读消费契约](agent/skills/sdx-design/references/central-spec-source.md) 确认各应用的中央规约来源 | HTTP 来源链接与确认内容基线 |
| 2 | 规约详细设计链路：`/sdx-design` → `/sdx-test` | `DSD`、`TDD` |
| 3 | 使用当前工程已安装并确认的实现工作流 | 代码实现 + 规格归档 |
| 4 | 各仓 Git 更新与溯源 + `/docs-link --check` + 三跳 `/docs-distill` | 联邦镜像与各层 overview 全量对齐 |
| 5 | `/docs-indexing`（增量，完成 gate 确认） | 各库 `INDEX-GUIDE.md` 与文内增量锚点更新 |

---

## 场景 D：从现存文档抽取结构化知识库

**目标**：仅有 Wiki / 协作文档等 legacy；overview 作缓冲区，再抽成 SSOT。

```mermaid
flowchart LR
    S((开始))
    subgraph LEGACY["知识库链路"]
        subgraph SRC["知识库构建"]
            direction LR
            A["bootstrap<br/>安装知识库"]
            B["/docs-indexing<br/>产出：INDEX-GUIDE.md"]
            G["/docs-agent<br/>生成 AGENTS｜README"]

            O["准备 overview<br/>核实关键词附录"]
            A --> B --> G --> O
        end

        subgraph EXTRACT["知识提纯"]
            direction LR
            C["/docs-extract<br/>知识提炼"]
            D["核实与烤干<br/>术语、边界及内容纠错"]
            E["/docs-archive<br/>知识归档"]
            F["/docs-build<br/>产出：本层实体与视角导航"]

            C --> D --> E --> F
        end

        subgraph DEP["变更闭环"]
            direction LR
            H["git log / git diff<br/>变更溯源"]

            F --> H
        end
    end
    S --> A
    O --> C
    H -.-> B
    H --> Z((结束))
```

### 阶段一：安装、盘点源、写入 overview

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 先满足 Agent 前置，再 `/docs-install` 按实际知识层初始化 | `/docs` 骨架 + `.docsconfig` + Agent |
| 2 | `/docs-indexing`（完成 spec 与 gate 确认）+ `/docs-agent` | `INDEX-GUIDE.md`、`README.md`、`AGENTS.md` |
| 3 | 复制该层 overview 模板为 `{NAME}-overview.md`，核实关键词附录；缺失时先 `/docs-tag` | overview 骨架与关键词附录 |
| 4 | `/docs-extract` 段落筛选提炼入第三列 | overview 第三列草稿 |

### 阶段二：核实归档与实体

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | 人工核实高优先级行（先术语与边界，再流程与接口） | 可归档条目 |
| 2 | `/docs-archive` | 知识落入该层 `knowledge/{perspective}/chapters/`（应用 / 系统 / 解决方案 / 公司） |
| 3 | `/docs-build` | 本层实体、视角 README、INDEX 第四章导航 |

> **原则**：overview → archive → entity，勿一步硬造 YAML。约定见 [knowledge-governance](agent/knowledge/knowledge-governance.md)、[knowledge-layout](agent/references/knowledge-layout.md)。

### 阶段三：变更溯源与按需需求交付

| 步骤 | 动作 | 产出 |
| --- | --- | --- |
| 1 | `git log` / `git diff` | 变更历史（仓内 commit） |
| 2 | `/docs-indexing`（增量，完成 gate 确认） | `INDEX-GUIDE.md` 与文内增量锚点对齐 |
| 3 | 按层交付：解决方案 `/sdx-solution`；系统/应用 `/sdx-analysis` → `/sdx-feature` → … → `/sdx-test`；公司 `/sdx-domains` | 对应阶段文档 |

---

## 相关文档

| 需求 | 文档 |
| --- | --- |
| 流程总览图 | [README.md — Agent 工作流](README.md#agent-工作流) |
| 元模型与实体层级 | [knowledge-governance.md](agent/knowledge/knowledge-governance.md) |
| 初始化脚本 | [bootstrap.sh](bootstrap.sh)、[agent/skills/README.md](agent/skills/README.md) |
| Skill 清单 | [agent/skills/README.md](agent/skills/README.md) |
