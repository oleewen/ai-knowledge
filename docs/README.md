# 文档体系与目录规范

本文档定义了 AI SDD 项目的文档结构、命名规范及版本管理策略。

## 2.1 文档总体结构

```text
project-root/
├── docs/                                    # 文档根目录
│   ├── solutions/                           # 解决方案目录
│   │   ├── SOLUTION-{ID}-{title}.md         # 解决方案文档
│   │   └── archive/                         # 历史版本归档
│   │
│   ├── analysis/                            # 需求分析目录
│   │   ├── REQUIREMENT-{ID}-{title}.md      # 需求分析文档
│   │   └── archive/                         # 历史版本归档
│   │
│   ├── requirements/                        # 需求交付目录
│   │   └── REQUIREMENT-{ID}/                # 按需求编号组织
│   │       ├── README.md                    # 需求概述和MVP规划
│   │       ├── MVP-Phase-1/                 # MVP阶段1
│   │       │   ├── PRD-{ID}.md              # 产品需求文档
│   │       │   ├── ADD-{ID}.md              # 架构设计文档
│   │       │   ├── TDD-{ID}.md              # 测试设计文档
│   │       │   ├── SPEC-{ID}.md             # 开发规约文档
│   │       │   └── DEV-{ID}.md              # 开发交付记录
│   │       ├── MVP-Phase-2/                 # MVP阶段2
│   │       └── MVP-Phase-N/                 # MVP阶段N
│   │
│   ├── instructions/
│   │   ├── INDEX.md                         # 说明索引
│   │   ├── GLOSSARY.md                      # 统一术语表
│   │   ├── CHANGELOG.md                     # 文档变更日志
│   │   │
│   │   ├── product/                         # 产品文档
│   │   │   ├── PRODUCT-OVERVIEW.md          # 产品概览
│   │   │   ├── FEATURE-MAP.md               # 功能地图
│   │   │   ├── USER-JOURNEY.md              # 用户旅程地图
│   │   │   ├── USER-STORIES.md              # 用户故事
│   │   │   ├── BUSINESS-RULES.md            # 业务规则清单
│   │   │   ├── CONSTRAINTS.md               # 业务约束与不变量
│   │   │   └── USER-GUIDE.md                # 用户指南
│   │   │
│   │   ├── architecture/                    # 架构文档
│   │   │   ├── SYSTEM-ARCHITECTURE.md       # 系统架构
│   │   │   ├── DATA-ARCHITECTURE.md         # 数据架构
│   │   │   ├── DEPLOYMENT-ARCHITECTURE.md   # 部署架构
│   │   │   ├── INTEGRATION-MAP.md           # 集成关系图
│   │   │   └── DECISION-RECORDS/            # 架构决策记录
│   │   │       └── ADR-{NNN}-{title}.md
│   │   │
│   │   ├── domain/                          # 领域模型
│   │   │   ├── DOMAIN-OVERVIEW.md           # 领域模型总览
│   │   │   ├── BOUNDED-CONTEXTS.md          # 限界上下文
│   │   │   ├── DOMAIN-MODEL.md              # 领域模型
│   │   │   ├── DOMAIN-EVENTS.md             # 领域事件目录
│   │   │   └── CONTEXT-MAPPING.md           # 上下文映射关系
│   │   │
│   │   ├── api/                             # API文档
│   │   │   ├── API-OVERVIEW.md              # API总览
│   │   │   ├── API-CONVENTIONS.md           # API设计约定
│   │   │   └── services/
│   │   │       └── {service-name}/
│   │   │           ├── API-SPEC.md          # 服务API规约
│   │   │           └── SERVICE-CONTRACT.md  # 服务契约
│   │   │
│   │   ├── dependency/                      # 依赖与影响面
│   │   │   ├── DEPENDENCY-MATRIX.md         # 模块依赖矩阵
│   │   │   ├── IMPACT-ANALYSIS-GUIDE.md     # 影响面分析指南
│   │   │   └── CHANGE-RISK-MAP.md           # 变更风险地图
│   │   │
│   │   └── test/                            # 测试文档
│   │       ├── TEST-STRATEGY.md             # 测试策略
│   │       ├── TEST-COVERAGE.md             # 测试覆盖报告
│   │       └── TEST-SCENARIOS/              # 功能域测试场景
│   │           └── {domain-name}/
│   │               └── TEST-CASES.md
│   │
│   └── changelogs/                          # 变更记录
│       ├── CHANGELOG.md                     # 变更日志总览
│       └── changes/                         # 变更明细
│           └── CHANGE-{ID}-{date}.md        # 单次变更记录
│
├── specs/                                   # Spec 规约
│   ├── {service-name}/
│   │   ├── service.yaml                     # 服务元信息
│   │   ├── api/                             # API 规约
│   │   ├── domain/                          # 领域规约
│   │   ├── data/                            # 数据规约
│   │   └── integration/                     # 集成规约
│   └── ...
│
├── src/                                     # 源代码
│
├── .ai/                                     # AI Agent 配置
│   ├── agents.yaml                          # Agent 注册与配置
│   ├── workflows.yaml                       # 工作流定义
│   ├── prompts/                             # Prompt 模板库
│   │   ├── solutions/
│   │   ├── requirements/
│   │   ├── product/
│   │   ├── design/
│   │   ├── development/
│   │   └── archive/
│   └── context/                             # 上下文管理
│       ├── project-context.yaml             # 项目上下文
│       └── session/                         # 会话上下文
└── AGENTS.md
```

## 2.2 编码引用规范

**文档编码规范**：

| 文档类型 | 编号格式                      | 示例                               |
| -------- | ----------------------------- | ---------------------------------- |
| 解决方案 | SOLUTION-{YYYYMMDD}-{SEQ}     | SOLUTION-20250101-001              |
| 需求分析 | REQUIREMENT-{YYYYMMDD}-{SEQ}  | REQUIREMENT-20250101-001           |
| 产品需求 | PRD-{REQUIREMENT-ID}-MVP{N}   | PRD-REQUIREMENT-20250101001-MVP1    |
| 架构设计 | ADD-{REQUIREMENT-ID}-MVP{N}   | ADD-REQUIREMENT-20250101001-MVP1    |
| 技术设计 | TDD-{REQUIREMENT-ID}-MVP{N}   | TDD-REQUIREMENT-20250101001-MVP1    |
| 开发交付 | DEV-{REQUIREMENT-ID}-MVP{N}   | DEV-REQUIREMENT-20250101001-MVP1    |
| 变更记录 | CHANGE-{YYYYMMDD}-{SEQ}       | CHANGE-20250101-001                |

**文档引用规范**：

```yaml
reference_rules:
  cross_reference:
    - "使用相对路径引用同项目文档"
    - "使用文档ID引用（如 PRD-001、TDD-001）"
    - "引用时注明版本号"
  
  traceability:
    - "PRD 引用 需求来源"
    - "ADD 引用 PRD"
    - "TDD 引用 PRD 和 TDD"
    - "代码注释引用 TDD 中的设计章节"
    - "测试代码引用 TPD 中的测试用例编号"
    - "规约文件引用对应的设计文档"
```

## 2.3 文档版本管理

每份文档头部必须包含标准元数据块：

```yaml
---
id: "{文档编号}"
title: "{文档标题}"
version: "{主版本}.{次版本}.{修订号}"
status: "draft | review | approved | archived"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
author: "{作者/Agent}"
reviewers: ["{审阅者列表}"]
parent: "{父文档编号，如有}"
dependencies: ["{依赖文档编号列表}"]
tags: ["{标签列表}"]
---
```

## 2.4 质量门禁检查点

```text
┌─────────────────────────────────────────────────────────────────────┐
│                        质量门禁检查点                                 │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  需求分析 ──▶ [门禁1] ──▶ 方案设计 ──▶ [门禁2] ──▶ 需求开发 ──▶ [门禁3]  │
│                                                                     │
│  [门禁1] 需求质量门禁                                                 │
│  ├── 需求完整性检查                                                   │
│  ├── 需求一致性检查                                                   │
│  ├── 用户故事可验证性检查                                              │
│  └── MVP划分合理性检查                                                │
│                                                                     │
│  [门禁2] 设计质量门禁                                                 │
│  ├── 设计与需求的可追溯性                                              │
│  ├── 设计完整性检查                                                   │
│  ├── 架构一致性检查                                                   │
│  ├── 规约文件完整性检查                                               │
│  └── 测试计划覆盖度检查                                               │
│                                                                    │
│  [门禁3] 交付质量门禁                                                 │
│  ├── 代码质量检查（linter + 审查）                                     │
│  ├── 测试覆盖率检查                                                   │
│  ├── 测试通过率检查                                                   │
│  ├── 缺陷清零检查（P0/P1）                                            │
│  └── 文档同步检查                                                     │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```