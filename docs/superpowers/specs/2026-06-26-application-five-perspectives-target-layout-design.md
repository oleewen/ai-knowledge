# Application Five Perspectives Target Layout Design

> 阶段：design
> 状态：DRAFT
> 范围对象：`/Users/only/workspaces/ai-knowledge/application/knowledge/`、`/Users/only/workspaces/ai-knowledge/application/DESIGN.md`
> 目标：把 `application/knowledge/` 下五大视角的实体组织关系升级为“目录结构表达层级语义”的目标态，并同步收敛元模型、示例实体、导航文件与索引路径。
> 设计时间：2026-06-26

---

## 0. 背景

- 当前 `application/knowledge/` 五大视角的目录语义不一致：
  - `business/` 仍在 `BSD-EXAMPLE/` 下扁平放置 `BC/AGG/AB`
  - `product/` 仍停留在旧链路 `PL -> PM -> FT -> UC`
  - `application/` 中 `APP` 与 `MS` 的关系写在正文里，但物理路径与 `parent_id` 仍未完全收口
  - `data/` 缺少 `MDG` 根层
  - `technical/` 缺少 `TSD` 根层
- 与之对比，仓库最近已在 `system/knowledge/business/` 与 `system/knowledge/product/` 中验证过“目录结构表达层级语义”的治理方式，证明这种形态更利于实体导航、父子关系对齐和后续演进。
- 本轮目标是在 `application/knowledge/` 范围内，把五视角示例树、元模型与导航一起收口到统一规则。

---

## 1. 目标与非目标

### 1.1 目标

- 统一五大视角的目录语义，让目录层级与实体层级一致。
- 为每个需要承载子实体的容器目录保留“同名主文件 + README.md + index.md”。
- 同步升级五个视角的 `*-meta.md`，使元模型与真实目录一致。
- 同步升级 `application/knowledge/index.md`、各视角 `README.md` 与 `index.md`、以及 `application/DESIGN.md`。
- 只在 `application/` 范围内完成示例实体、链接与索引路径调整。

### 1.2 非目标

- 不修改 `system/` 与 `company/` 下既有实体结构。
- 不新增业务运行时代码、脚本或自动化生成器。
- 不改变现有实体 ID 语义，仅调整路径、父子关系与元模型描述。
- 不扩展到 `chapters/` 正文重写，仅在必要时调整导航引用。

---

## 2. 设计范围

本轮设计覆盖以下对象：

- `application/knowledge/business/`
- `application/knowledge/product/`
- `application/knowledge/application/`
- `application/knowledge/data/`
- `application/knowledge/technical/`
- `application/knowledge/index.md`
- `application/DESIGN.md`

本轮设计不覆盖：

- `application/requirements/`
- `application/solutions/`
- `application/analysis/`
- `system/knowledge/`
- `company/knowledge/`

---

## 3. 目标态总览

五视角目标态如下：

- `business`
  - 根文件保留 `BD-{NAME}.md`
  - 目录从 `BSD-{NAME}/` 开始
  - `BSD -> BC -> AGG` 采用容器目录
  - `AB` 作为 `AGG` 下叶子文件
- `product`
  - 正式实体链固定为 `PL -> PM -> FT -> FR -> UC/BR`
  - `PL-{NAME}.md` 保留在产品根目录
  - `BP-{NAME}.md` 作为独立流程叙事文件，和 `PL-{NAME}.md` 同目录
  - 目录从 `PM-{NAME}/` 开始
  - `PM -> FT -> FR` 采用容器目录
  - `UC` 与 `BR` 为 `FR` 下单文件，文件内编号
- `application`
  - 根文件保留 `SYS-{NAME}.md`、`APP-{NAME}.md`
  - 目录从 `MS-{NAME}/` 开始
  - `MS` 为容器目录，`API` 为其下叶子文件
- `data`
  - 新增根文件 `MDG-{NAME}.md`
  - 目录从 `DS-{NAME}/` 开始
  - `ENT` 为 `DS` 下叶子文件
  - `TBL` 一类应用物理锚点文件保留在 `DS` 目录下
- `technical`
  - 新增根文件 `TSD-{NAME}.md`
  - 目录从 `MW-{NAME}/` 开始
  - `CMP` 为 `MW` 下叶子文件

---

## 4. 各视角层级契约

### 4.1 business

正式实体链：

```text
BD -> BSD -> BC -> AGG -> AB
```

父子规则：

- `BD.parent_id = null`
- `BD.children = [BSD-*]`
- `BSD.parent_id = BD-*`
- `BSD.children = [BC-*]`
- `BC.parent_id = BSD-*`
- `BC.children = [AGG-*]`
- `AGG.parent_id = BC-*`
- `AGG.children = [AB-*]`
- `AB.parent_id = AGG-*`

目录契约：

```text
application/knowledge/business/
├── BD-EXAMPLE.md
└── BSD-EXAMPLE/
    ├── BSD-EXAMPLE.md
    ├── README.md
    ├── index.md
    └── BC-EXAMPLE/
        ├── BC-EXAMPLE.md
        ├── README.md
        ├── index.md
        └── AGG-EXAMPLE/
            ├── AGG-EXAMPLE.md
            ├── README.md
            ├── index.md
            └── AB-EXAMPLE.md
```

### 4.2 product

正式实体链：

```text
PL -> PM -> FT -> FR -> UC
PL -> PM -> FT -> FR -> BR
```

流程叙事文件：

- `BP-{NAME}.md` 为独立文件
- `BP` 不进入正式实体链
- `BP` 与 `PL-{NAME}.md` 同目录
- `BP` 文件内分 `M`、`S`、`B` 三层，仅通过正文引用 `PL`、`PM`、`FT`

父子规则：

- `PL.parent_id = null`
- `PL.children = [PM-*]`
- `PM.parent_id = PL-*`
- `PM.children = [FT-*]`
- `FT.parent_id = PM-*`
- `FT.children = [FR-*]`
- `FR.parent_id = FT-*`
- `FR.children = [UC-* , BR-*]`
- `UC.parent_id = FR-*`
- `BR.parent_id = FR-*`

目录契约：

```text
application/knowledge/product/
├── BP-EXAMPLE.md
├── PL-EXAMPLE.md
└── PM-EXAMPLE/
    ├── PM-EXAMPLE.md
    ├── README.md
    ├── index.md
    └── FT-EXAMPLE/
        ├── FT-EXAMPLE.md
        ├── README.md
        ├── index.md
        └── FR-EXAMPLE/
            ├── FR-EXAMPLE.md
            ├── README.md
            ├── index.md
            ├── UC-EXAMPLE.md
            └── BR-EXAMPLE.md
```

文件内编号规则：

- 每个 `FR` 目录下只保留一个 `UC` 文件和一个 `BR` 文件
- 同一 `FR` 下多个具体用例写在 `UC-EXAMPLE.md` 正文内，以 `UC-001`、`UC-002` 分节
- 同一 `FR` 下多个具体规则写在 `BR-EXAMPLE.md` 正文内，以 `BR-001`、`BR-002` 分节
- `BP`、`UC`、`BR` 文件名均不带数字后缀

### 4.3 application

正式实体链：

```text
SYS -> APP -> MS -> API
```

父子规则：

- `SYS.parent_id = null`
- `SYS.children = [APP-*]`
- `APP.parent_id = SYS-*`
- `APP.children = [MS-*]`
- `MS.parent_id = APP-*`
- `MS.children = [API-*]`
- `API.parent_id = MS-*`

目录契约：

```text
application/knowledge/application/
├── SYS-EXAMPLE.md
├── APP-EXAMPLE.md
└── MS-EXAMPLE/
    ├── MS-EXAMPLE.md
    ├── README.md
    ├── index.md
    └── API-EXAMPLE-001.md
```

### 4.4 data

正式实体链：

```text
MDG -> DS -> ENT
```

父子规则：

- `MDG.parent_id = null`
- `DS.parent_id = MDG-*`
- `DS.children = [ENT-*]`
- `ENT.parent_id = DS-*`

目录契约：

```text
application/knowledge/data/
├── MDG-EXAMPLE.md
└── DS-EXAMPLE/
    ├── DS-EXAMPLE.md
    ├── ENT-EXAMPLE.md
    ├── TBL-EXAMPLE.md
    ├── README.md
    └── index.md
```

说明：

- `MDG` 为上游主数据域 reference 根
- `DS` 为目录锚点
- `TBL-*` 一类应用物理锚点文件不进入正式层级链，但保留在所属 `DS` 目录中

### 4.5 technical

正式实体链：

```text
TSD -> MW -> CMP
```

父子规则：

- `TSD.parent_id = null`
- `MW.parent_id = TSD-*`
- `MW.children = [CMP-*]`
- `CMP.parent_id = MW-*`

目录契约：

```text
application/knowledge/technical/
├── TSD-EXAMPLE.md
└── MW-EXAMPLE/
    ├── MW-EXAMPLE.md
    ├── CMP-EXAMPLE.md
    ├── README.md
    └── index.md
```

说明：

- `TSD` 为系统层技术域 reference 根
- `MW` 为目录锚点

---

## 5. 目标路径树与迁移清单

### 5.1 business

目标路径：

- `application/knowledge/business/BD-EXAMPLE.md`
- `application/knowledge/business/BSD-EXAMPLE/BSD-EXAMPLE.md`
- `application/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md`
- `application/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md`
- `application/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md`

迁移动作：

- 移动 `BC-EXAMPLE.md` 到 `BSD-EXAMPLE/BC-EXAMPLE/BC-EXAMPLE.md`
- 移动 `AGG-EXAMPLE.md` 到 `BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md`
- 移动 `AB-EXAMPLE.md` 到 `BSD-EXAMPLE/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md`
- 新增 `BC-EXAMPLE/README.md` 与 `BC-EXAMPLE/index.md`
- 新增 `AGG-EXAMPLE/README.md` 与 `AGG-EXAMPLE/index.md`
- 更新 `BSD-EXAMPLE/README.md` 与 `BSD-EXAMPLE/index.md`

### 5.2 product

目标路径：

- `application/knowledge/product/BP-EXAMPLE.md`
- `application/knowledge/product/PL-EXAMPLE.md`
- `application/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md`
- `application/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md`
- `application/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md`
- `application/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md`
- `application/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md`

迁移动作：

- 保留根 `PL-EXAMPLE.md`
- 新增根 `BP-EXAMPLE.md`
- 保留 `PM-EXAMPLE/PM-EXAMPLE.md`
- 移动 `PM-EXAMPLE/FT-EXAMPLE.md` 到 `PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md`
- 新增 `PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md`
- 移动并改造 `UC-EXAMPLE-001.md` 为 `PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md`
- 新增 `PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md`
- 新增 `FT-EXAMPLE/README.md` 与 `FT-EXAMPLE/index.md`
- 新增 `FR-EXAMPLE/README.md` 与 `FR-EXAMPLE/index.md`
- 更新 `PM-EXAMPLE/README.md` 与 `PM-EXAMPLE/index.md`

### 5.3 application

目标路径：

- `application/knowledge/application/SYS-EXAMPLE.md`
- `application/knowledge/application/APP-EXAMPLE.md`
- `application/knowledge/application/MS-EXAMPLE/MS-EXAMPLE.md`
- `application/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md`

迁移动作：

- 保留根 `SYS-EXAMPLE.md`
- 保留根 `APP-EXAMPLE.md`
- 保留 `MS-EXAMPLE/MS-EXAMPLE.md`
- 保留 `MS-EXAMPLE/API-EXAMPLE-001.md`
- 主要修正 `parent_id`、`children`、交叉引用与导航
- 更新 `MS-EXAMPLE/README.md` 与 `MS-EXAMPLE/index.md`

### 5.4 data

目标路径：

- `application/knowledge/data/MDG-EXAMPLE.md`
- `application/knowledge/data/DS-EXAMPLE/DS-EXAMPLE.md`
- `application/knowledge/data/DS-EXAMPLE/ENT-EXAMPLE.md`
- `application/knowledge/data/DS-EXAMPLE/TBL-EXAMPLE.md`

迁移动作：

- 新增根 `MDG-EXAMPLE.md`
- 移动 `DS-EXAMPLE.md` 到 `DS-EXAMPLE/DS-EXAMPLE.md`
- 移动 `ENT-EXAMPLE/ENT-EXAMPLE.md` 到 `DS-EXAMPLE/ENT-EXAMPLE.md`
- 保留 `DS-EXAMPLE/TBL-EXAMPLE.md`
- 更新 `DS-EXAMPLE/README.md` 与 `DS-EXAMPLE/index.md`
- 删除旧空壳 `ENT-EXAMPLE/` 目录

### 5.5 technical

目标路径：

- `application/knowledge/technical/TSD-EXAMPLE.md`
- `application/knowledge/technical/MW-EXAMPLE/MW-EXAMPLE.md`
- `application/knowledge/technical/MW-EXAMPLE/CMP-EXAMPLE.md`

迁移动作：

- 新增根 `TSD-EXAMPLE.md`
- 保留 `MW-EXAMPLE/MW-EXAMPLE.md`
- 保留 `MW-EXAMPLE/CMP-EXAMPLE.md`
- 更新 `MW-EXAMPLE/README.md` 与 `MW-EXAMPLE/index.md`

---

## 6. 元模型与导航联动

必须同步改动的正式契约文档：

- `application/knowledge/business/business-meta.md`
- `application/knowledge/product/product-meta.md`
- `application/knowledge/application/application-meta.md`
- `application/knowledge/data/data-meta.md`
- `application/knowledge/technical/technical-meta.md`
- `application/DESIGN.md`

必须同步改动的导航文件：

- `application/knowledge/index.md`
- 五个视角根 `README.md`
- 五个视角根 `index.md`
- 新增或更新的容器目录 `README.md`
- 新增或更新的容器目录 `index.md`

必须同步改动的实体正文：

- `parent`
- `children`
- 交叉视角引用路径
- 示例说明中的上游 SSOT 路径

---

## 7. 影响面

### 7.1 meta 契约

- `business-meta.md` 需改成 `BC/AGG` 容器目录路径示例。
- `product-meta.md` 需改成正式链 `PL -> PM -> FT -> FR -> UC/BR`，并新增 `BP` 作为独立叙事文件约定，不再把 `BP` 写成正式 hierarchy。
- `application-meta.md` 需改 `MS.parent_id` 与路径说明，明确目录从 `MS` 开始。
- `data-meta.md` 需增加 `MDG -> DS -> ENT`。
- `technical-meta.md` 需增加 `TSD -> MW -> CMP`。

### 7.2 示例实体

- 所有迁移后的实体文件都要同步修正 `parent_id`、`parent`、`children` 与交叉引用路径。
- `product/UC-EXAMPLE-001.md` 合并为 `UC-EXAMPLE.md` 后，原示例内容需保留到正文编号分节。
- `product/BP-EXAMPLE.md` 只承担流程叙事与引用，不进入正式实体引用链。

### 7.3 导航文件

- 五视角根 `README.md` 与 `index.md` 需同步目标树。
- 每个新增容器目录都要补 `README.md` 与 `index.md`。
- `application/knowledge/index.md` 证据链路径需整体切换到新路径。

### 7.4 全局文档

- `application/DESIGN.md` 需同步五视角层级、示例路径与目录说明。
- `application/index.md`、`application/README.md` 中若有旧路径引用，也要一并修正。

---

## 8. 验收标准

- 五视角目录树与本设计的目标态完全一致。
- 不残留旧空壳目录、旧示例文件名与旧路径引用。
- 每个正式实体的 `parent_id` 与其落盘目录一致。
- 每个容器主文件的 `children` 与其子实体文件一致。
- `BP` 不进入正式层级链，但正文中对 `PL`、`PM`、`FT` 的引用合法可跳转。
- `application/knowledge/index.md` 中五视角证据链全部可打开。
- 各视角 `README.md`、`index.md` 的阅读顺序与子目录表无断链。
- 最近修改文件不新增 markdownlint 或其他诊断错误。
- 旧路径扫描应清理以下典型历史路径：
  - `application/knowledge/product/PM-EXAMPLE/UC-EXAMPLE-001.md`
  - `application/knowledge/data/DS-EXAMPLE.md`
  - `application/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md`
- 文件移动优先使用 `git mv`，以保留历史。
- 本轮只修改 `application/` 范围，不连带调整 `system/` 与 `company/` 的实体内容。

---

## 9. 实施顺序建议

建议实施顺序如下：

1. 先修改五个 `*-meta.md` 与 `application/DESIGN.md`
2. 再完成实体迁移与正文互链修正
3. 再补齐或更新 `README.md` 与 `index.md`
4. 最后执行诊断检查与旧路径扫描

这样可以先固定正式契约，再做真实落盘，最后收口导航与质量校验，避免边迁移边失去路径基线。

---

## 10. 风险与约束

- 若只迁移实体而不改 `*-meta.md`，会造成元模型与真实目录冲突。
- 若只改 `*-meta.md` 而不改示例目录，会造成索引路径与阅读入口失真。
- `product/BP` 同时与 `PL` 同目录、又不进入正式实体链，必须在元模型和 README 中明确说明，避免后续误当成 hierarchy。
- `data/TBL-*` 属于应用物理锚点，不应被误写进 `MDG -> DS -> ENT` 正式链。
- `application/MS` 当前是本轮最容易遗漏的收口点，若不把 `parent_id` 与 `APP.service_ids` 同时修正，应用视角仍会自相矛盾。

---

## 11. 产出边界

本设计确认的是 `application/knowledge/` 五视角的正式目标态，不采用“只改契约、不落目录”的过渡方案。

一旦进入实现，应同时完成：

- 元模型契约升级
- 示例实体真实迁移
- 导航与索引修复
- 链接与诊断校验

不在本轮做的事：

- 扩展更多示例实体
- 改写 `system/` 与 `company/` 侧结构
- 设计新的自动化构建工具
