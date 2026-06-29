#!/usr/bin/env python3
"""一次性创建 system/knowledge 示例实体 concept（OKF SSOT）。"""

from __future__ import annotations

from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
REPO = SCRIPT_DIR.parents[1]
BUNDLE = REPO / "system"
TS = "2026-06-21T00:00:00Z"

ENTITIES: list[tuple[str, str]] = [
    (
        "knowledge/business/BD-EXAMPLE.md",
        """---
type: Business Domain
title: 示例业务域
description: 仅用于演示业务视角数据结构（示例）。
tags: [business, BD]
timestamp: "%s"
full_id: BD-EXAMPLE
perspective: business
hierarchy: BD
parent_id: null
strategic_classification: supporting_domain
definition_scope: reference
ssot_layer: company
layer_scope: system
---
# SSOT

上游主定义：`company/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md`（公司层 OKF SSOT）。

## 关系

- children:
  - [BSD-EXAMPLE](/knowledge/business/BSD-EXAMPLE/BSD-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE/BSD-EXAMPLE.md",
        """---
type: Business Subdomain
title: 示例业务子域
description: 仅用于演示业务视角数据结构（示例）。
tags: [business, BSD]
timestamp: "%s"
full_id: BSD-EXAMPLE
perspective: business
hierarchy: BSD
parent_id: BD-EXAMPLE
layer_scope: system
---
## 关系

- parent: [BD-EXAMPLE](/knowledge/business/BD-EXAMPLE.md)
- bounded_contexts:
  - [BC-EXAMPLE](/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md",
        """---
type: Bounded Context
title: 示例限界上下文
description: null
tags: [business, BC]
timestamp: "%s"
full_id: BC-EXAMPLE
perspective: business
hierarchy: BC
parent_id: BSD-EXAMPLE
layer_scope: system
---
## 关系

- parent: [BSD-EXAMPLE](/knowledge/business/BSD-EXAMPLE/BSD-EXAMPLE.md)
- aggregates:
  - [AGG-EXAMPLE](/knowledge/business/BSD-EXAMPLE/AGG-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE/AGG-EXAMPLE.md",
        """---
type: Aggregate
title: 示例聚合
description: null
tags: [business, AGG]
timestamp: "%s"
full_id: AGG-EXAMPLE
perspective: business
hierarchy: AGG
parent_id: BC-EXAMPLE
layer_scope: system
---
## 关系

- parent: [BC-EXAMPLE](/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md)
- abilities:
  - [AB-EXAMPLE](/knowledge/business/BSD-EXAMPLE/AB-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE/AB-EXAMPLE.md",
        """---
type: Ability
title: 示例业务能力
description: null
tags: [business, AB]
timestamp: "%s"
full_id: AB-EXAMPLE
perspective: business
hierarchy: AB
parent_id: AGG-EXAMPLE
layer_scope: system
---
## 关系

- parent: [AGG-EXAMPLE](/knowledge/business/BSD-EXAMPLE/AGG-EXAMPLE.md)

## 跨视角

- implemented_by_app_id: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/product/PL-EXAMPLE.md",
        """---
type: Product Line
title: 示例产品线
description: null
tags: [product, PL]
timestamp: "%s"
full_id: PL-EXAMPLE
perspective: product
hierarchy: PL
parent_id: null
definition_scope: reference
ssot_layer: company
layer_scope: system
---
# SSOT

上游主定义：`company/knowledge/product/PL-EXAMPLE.md`（公司层 OKF SSOT）。

## 关系

- children:
  - [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md",
        """---
type: Product Module
title: 示例产品模块
description: null
tags: [product, PM]
timestamp: "%s"
full_id: PM-EXAMPLE
perspective: product
hierarchy: PM
parent_id: PL-EXAMPLE
layer_scope: system
---
## 关系

- parent: [PL-EXAMPLE](/knowledge/product/PL-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md",
        """---
type: Feature
title: 示例功能
description: 仅用于演示产品视角数据结构（示例）。
tags: [product, FT]
timestamp: "%s"
full_id: FT-EXAMPLE
perspective: product
hierarchy: FT
parent_id: PM-EXAMPLE
layer_scope: system
---
## 关系

- parent: [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)
- children:
  - [FR-EXAMPLE](/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md)

## 跨视角

- invokes_api_ids: [API-EXAMPLE-001](/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md)
- realizes_use_case_ids: [UC-EXAMPLE](/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md)

## 详细说明

- acceptance_criteria: 示例验收标准A; 示例验收标准B

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md",
        """---
type: Use Case
title: 示例用例
description: 仅用于演示产品视角数据结构（示例）。
tags: [product, UC]
timestamp: "%s"
full_id: UC-EXAMPLE
perspective: product
hierarchy: UC
parent_id: FR-EXAMPLE
layer_scope: system
---
## 关系

- parent: [FR-EXAMPLE](/knowledge/product/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md)

## 跨视角

- map_to_api_id: [API-EXAMPLE-001](/knowledge/application/MS-EXAMPLE/API-EXAMPLE-001.md)

## 详细说明

### UC-001

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/application/SYS-EXAMPLE.md",
        """---
type: System
title: 示例系统边界
description: null
tags: [application, SYS]
timestamp: "%s"
full_id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
parent_id: null
definition_scope: reference
ssot_layer: company
layer_scope: system
---
# SSOT

上游主定义：`company/knowledge/application/SYS-EXAMPLE.md`（公司层 OKF SSOT）。

## 关系

- children:
  - [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md",
        """---
type: Application
title: 示例应用
description: null
tags: [application, APP]
timestamp: "%s"
full_id: APP-EXAMPLE
perspective: application
hierarchy: APP
parent_id: SYS-EXAMPLE
startup_class: ExampleApp
maven_module: example-module
repo_url: "git@example.com:org/example.git"
layer_scope: system
---
## 关系

- parent: [SYS-EXAMPLE](/knowledge/application/SYS-EXAMPLE.md)
- service_ids:
  - [MS-EXAMPLE](/knowledge/application/APP-EXAMPLE/MS-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/application/APP-EXAMPLE/MS-EXAMPLE.md",
        """---
type: Microservice
title: 示例微服务
description: null
tags: [application, MS]
timestamp: "%s"
full_id: MS-EXAMPLE
perspective: application
hierarchy: MS
parent_id: APP-EXAMPLE
layer_scope: system
---
## 关系

- parent: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md)

## 跨视角

- cross_references:
  - [BC-EXAMPLE](/knowledge/business/BSD-EXAMPLE/BC-EXAMPLE.md)
  - [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/data/DS-EXAMPLE/DS-EXAMPLE.md",
        """---
type: Data Store
title: 示例数据源
description: 仅用于演示数据视角数据结构（示例）。
tags: [data, DS]
timestamp: "%s"
full_id: DS-EXAMPLE
perspective: data
hierarchy: DS
parent_id: MDG-EXAMPLE
config_key: example_config_key
layer_scope: system
---
## 关系

- parent: [MDG-EXAMPLE](/knowledge/data/MDG-EXAMPLE.md)

## 跨视角

- owned_by_app_id: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE/APP-EXAMPLE.md)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
    (
        "knowledge/data/DS-EXAMPLE/ENT-EXAMPLE.md",
        """---
type: Entity
title: 示例实体
description: null
tags: [data, ENT]
timestamp: "%s"
full_id: ENT-EXAMPLE
perspective: data
hierarchy: ENT
parent_id: DS-EXAMPLE
layer_scope: system
---
## 关系

- parent: [DS-EXAMPLE](/knowledge/data/DS-EXAMPLE/DS-EXAMPLE.md)

## 跨视角

- maps_to_aggregate_id: [AGG-EXAMPLE](/knowledge/business/BSD-EXAMPLE/AGG-EXAMPLE.md)

## 详细说明

- (none)

## 依据与证据

示例数据
""",
    ),
]


def main() -> None:
    for relpath, template in ENTITIES:
        path = BUNDLE / relpath
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(template % TS, encoding="utf-8")
        print(f"written: system/{relpath}")


if __name__ == "__main__":
    main()
