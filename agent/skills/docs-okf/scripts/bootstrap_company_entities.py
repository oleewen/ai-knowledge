#!/usr/bin/env python3
"""一次性创建 company/knowledge 示例实体 concept（OKF SSOT）。"""

from __future__ import annotations

from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO = SCRIPT_DIR.parents[1]
BUNDLE = REPO / "company"
TS = "2026-06-21T00:00:00Z"

ENTITIES: list[tuple[str, str]] = [
    (
        "knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md",
        """---
type: Business Domain
title: 示例业务域
description: 仅用于演示公司级 BD 数据结构。
tags: [business, BD]
timestamp: "%s"
full_id: BD-EXAMPLE
perspective: business
hierarchy: BD
parent_id: null
strategic_classification: core_domain
layer_scope: company
definition_scope: local
---
## 关系

- children:
  - [CAP-EXAMPLE](/knowledge/business/BD-EXAMPLE/CAP-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

business-domain-division.md（示例）
""",
    ),
    (
        "knowledge/business/BD-EXAMPLE/CAP-EXAMPLE.md",
        """---
type: Business Capability
title: 示例业务能力
description: 仅用于演示公司级单层 CAP；parent_id 指向所属 BD。
tags: [business, CAP]
timestamp: "%s"
full_id: CAP-EXAMPLE
perspective: business
hierarchy: CAP
parent_id: BD-EXAMPLE
layer_scope: company
---
## 关系

- parent: [BD-EXAMPLE](/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- definition_scope: local

## 依据与证据

business-capability.md（示例）
""",
    ),
    (
        "knowledge/product/PL-EXAMPLE/PL-EXAMPLE.md",
        """---
type: Product Line
title: 示例产品线
description: 仅用于演示公司级 PL 数据结构（一套解决方案集合）。
tags: [product, PL]
timestamp: "%s"
full_id: PL-EXAMPLE
perspective: product
hierarchy: PL
parent_id: null
layer_scope: company
---
## 关系

- children:
  - PD-EXAMPLE

## 跨视角

- (none)

## 详细说明

- target_users: [内部运营, 业务方]
- definition_scope: local

## 依据与证据

product-architecture.md（示例）
""",
    ),
    (
        "knowledge/product/PL-EXAMPLE/PD-EXAMPLE.md",
        """---
type: Product
title: 示例产品
description: 演示公司级 PD（单个解决方案）。
tags: [product, PD]
timestamp: "%s"
full_id: PD-EXAMPLE
perspective: product
hierarchy: PD
parent_id: PL-EXAMPLE
layer_scope: company
---
## 关系

- parent: PL-EXAMPLE

## 跨视角

- (none)

## 详细说明

- definition_scope: local

## 依据与证据

product-architecture.md（示例）
""",
    ),
    (
        "knowledge/application/SYS-EXAMPLE.md",
        """---
type: System
title: 示例系统
description: 仅用于演示公司级 SYS 数据结构。
tags: [application, SYS]
timestamp: "%s"
full_id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
parent_id: null
layer_scope: company
definition_scope: local
---
## 关系

- (none)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

application-overview.md（示例）
""",
    ),
    (
        "knowledge/data/MDG-EXAMPLE.md",
        """---
type: Master Data Domain
title: 示例主数据域
description: 仅用于演示公司级 MDG 数据结构。
tags: [data, MDG]
timestamp: "%s"
full_id: MDG-EXAMPLE
perspective: data
hierarchy: MDG
parent_id: null
governance_owner: 示例：数据治理委员会
layer_scope: company
definition_scope: local
---
## 关系

- (none)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

data-governance.md（示例）
""",
    ),
    (
        "knowledge/technical/TPL-EXAMPLE.md",
        """---
type: Technical Platform
title: 示例技术平台能力
description: 仅用于演示公司级 TPL 数据结构（示例）。
tags: [technical, TPL]
timestamp: "%s"
full_id: TPL-EXAMPLE
perspective: technical
hierarchy: TPL
parent_id: null
domain: 云基础设施
layer_scope: company
definition_scope: local
---
## 关系

- (none)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

technical-overview.md（示例）
""",
    ),
]


def main() -> None:
    written = 0
    for relpath, template in ENTITIES:
        out = BUNDLE / relpath
        out.parent.mkdir(parents=True, exist_ok=True)
        content = template % TS
        out.write_text(content, encoding="utf-8")
        print(f"wrote {out.relative_to(REPO)}")
        written += 1
    print(f"bootstrap_company_entities: {written} file(s)")


if __name__ == "__main__":
    main()
