---
type: Documentation
title: 应用知识库
---
# 应用知识库

五视角实体 SSOT；本层首次：**API / TBL / MW / CMP**。目录 [index.md](index.md) · 视角导航 INDEX-GUIDE 第四章 · 首次定义见 knowledge-governance。overview：[overview/README.md](overview/README.md)（extract / archive / tag；非 distill）。

| 文件 | 视角 | 概述 |
|------|------|------|
| [business/README.md](business/README.md) | 业务 | 无本层实体；引用上游定义 |
| [product/README.md](product/README.md) | 产品 | 无本层实体；引用上游定义 |
| [application/README.md](application/README.md) | 应用 | **API** 首次定义；SLN / SYS / APP / MS 引用上游 |
| [data/README.md](data/README.md) | 数据 | **TBL** 首次定义；MDG / DS / ENT 引用上游 |
| [technical/README.md](technical/README.md) | 技术 | **MW / CMP** 首次定义；TPL / TS 引用上游 |

## 上游引用

上游实体不建本层同 ID 文件，不重复字段语义；目录宿主可保留。已登记有效 `parent` 链、能定位首次定义层且统一工具可生成时，使用生成的 HTTP。无 `parent` 或工具无可用结果时保持纯 ID，不手写跨层路径或猜 URL；配置无效、目标层或实体不明时，先核实再写入。

关系特例仍按既有契约处理：系统侧 `SYS.implements_to`→SLN、`SYS.maps_to`→PD 固定纯 ID，不能推广为应用引用 SYS 的限制；指向下层的关系保持纯 ID。

链与字段见 [业务](../../agent/knowledge/business-meta.md#1-实体总表)、[产品](../../agent/knowledge/product-meta.md#1-实体总表)、[应用](../../agent/knowledge/application-meta.md#1-实体总表)、[数据](../../agent/knowledge/data-meta.md#1-实体总表)、[技术](../../agent/knowledge/technical-meta.md#1-实体总表)。
