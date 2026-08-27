---
type: Architecture Chapter
tags: [architecture, chapter]
title: 数据流转
---
# 数据流转

[返回 · 数据架构](../README.md)

本系统数据流动、加工与一致性保障。

> **数据流转 SSOT**：公司级数据框架见 公司层 data 视角章节。

## 数据流图

画主要 DFD；区分批/实时并与业务流程对齐。

## ETL 流程

写抽取/转换/加载职责、调度与质量校验嵌入点。

## 实时数据流

写 CDC、Topic、顺序语义与 Schema 演进约定。

## 数据同步

写系统间同步模式、幂等与冲突解决。

## 数据一致性

写强一致/最终一致/Saga 选用场景与对账规则。
