---
type: Documentation
title: 业务架构
---
# 业务架构

[返回 · 解决方案知识库 — 架构文档](../README.md)

**本层 SSOT**：BSD(L2)（`parent`→公司 L1，`mapped_by`→BS）；BS（无 parent，`maps_to`→BSD(L2) 1:1）。BC 链 ∈ 系统。企业标准只引用公司 business。台账本页；字段 [business-meta.md](business-meta.md)。章节见 [chapters/](chapters/)。

## 章节

| 章节 | 文件 | 概述 |
|------|------|------|
| 业务概述 | [chapters/business-overview.md](chapters/business-overview.md) | 本方案纳入的 BSD(L2) 与 BS。公司背景、目标、范围、商业模式、价值链、组织角色只引用 |
| 业务域划分 | [chapters/business-domain-division.md](chapters/business-domain-division.md) | 二级子域与子域关系。L1 分类见公司层 business · business-domain-division |
| 业务术语 | [chapters/business-glossary.md](chapters/business-glossary.md) | 概念模型、业务术语与术语映射 |

## 实体

| 链序 | 层级 | ID | 名称 | 文件 |
|------|------|----|------|------|
| — | BSD(L2) | BSD-EXAMPLE-L2 | 示例二级子域 | [BSD-EXAMPLE-L2/BSD-EXAMPLE-L2.md](BSD-EXAMPLE-L2/BSD-EXAMPLE-L2.md) |
| — | BS | BS-EXAMPLE | 示例业务服务 | [BS/BS-EXAMPLE.md](BS/BS-EXAMPLE.md) |
