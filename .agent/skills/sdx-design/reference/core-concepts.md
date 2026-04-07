# 核心概念（sdx-design）

技术方案设计阶段的术语与产出口径，供步骤 1–4 对齐。算法、`--depth` 差异与角色分工见 [workflow-spec.md](workflow-spec.md)。

## IDEA-ID

**IDEA-ID** 的定义见 [../sdx-solution/reference/core-concepts.md#idea-id](../sdx-solution/reference/core-concepts.md#idea-id)。

本阶段路径示例：`system/requirements/REQUIREMENT-{IDEA-ID}/MVP-Phase-{N}/ADD-{IDEA-ID}.md`；规约摘录 `.../specs/spec-{IDEA-ID}-{service-name}.md`（`{service-name}` 为 ASCII slug，与 **IDEA-ID** 拼接为完整需求键）。

## 架构设计

系统与服务架构、调用关系、接口协议概要、领域模型（聚合/实体/值对象/领域事件）、数据架构（ER、分片、迁移）、发布与回滚方案；关键决策以 DD-n 记录，须可关联 PRD 的 US-n / FR-n。

## 详细设计

应用架构（集成与容器）、API 详设（签名、参数、错误码、幂等、容错）、核心类图与状态机、业务逻辑流程与伪代码、一致性策略、数据访问（DDL、索引、分页、缓存）、非功能（安全、可观测）。`quick` / `standard` / `deep` 下粒度见 workflow-spec。

## 规约生成

按服务在 `specs/{service-name}/` 下产出 YAML：`api/`、`domain/`、`data/`、`integration/`。规约须从 ADD 对应章节派生，头部标注可追溯的 `source`（ADD 条目）与 `requirement`（FR-n 等）。

## ADD 文档

架构设计说明书，严格遵循 [../assets/add-template.md](../assets/add-template.md) 的五章结构（设计概述→架构设计→详细设计→需求规约→附录）。受众与用语见 [audience-and-language.md](audience-and-language.md)。
