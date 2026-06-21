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
        "knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md",
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

上游主定义：`company/ea/business/BD-EXAMPLE/`（公司层 OKF 落盘见后续波次）。

# Relations

- children:
  - [BSD-EXAMPLE](/knowledge/business/BD-EXAMPLE/BSD-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/business/BD-EXAMPLE/BSD-EXAMPLE.md",
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
# Relations

- parent: [BD-EXAMPLE](/knowledge/business/BD-EXAMPLE/BD-EXAMPLE.md)
- bounded_contexts:
  - [BC-EXAMPLE](/knowledge/business/BD-EXAMPLE/BC-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/business/BD-EXAMPLE/BC-EXAMPLE.md",
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
# Relations

- parent: [BSD-EXAMPLE](/knowledge/business/BD-EXAMPLE/BSD-EXAMPLE.md)
- aggregates:
  - [AGG-EXAMPLE](/knowledge/business/BD-EXAMPLE/AGG-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/business/BD-EXAMPLE/AGG-EXAMPLE.md",
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
# Relations

- parent: [BC-EXAMPLE](/knowledge/business/BD-EXAMPLE/BC-EXAMPLE.md)
- abilities:
  - [AB-EXAMPLE](/knowledge/business/BD-EXAMPLE/AB-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/business/BD-EXAMPLE/AB-EXAMPLE.md",
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
# Relations

- parent: [AGG-EXAMPLE](/knowledge/business/BD-EXAMPLE/AGG-EXAMPLE.md)

# Cross-perspective

- implemented_by_app_id: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE.md)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/PL-EXAMPLE.md",
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

上游主定义：`company/ea/product/PL-EXAMPLE/`（公司层 OKF 落盘见后续波次）。

# Relations

- children:
  - [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

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
# Relations

- parent: [PL-EXAMPLE](/knowledge/product/PM-EXAMPLE/PL-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/FT-EXAMPLE.md",
        """---
type: Feature
title: 示例功能
description: null
tags: [product, FT]
timestamp: "%s"
full_id: FT-EXAMPLE
perspective: product
hierarchy: FT
parent_id: PM-EXAMPLE
layer_scope: system
---
# Relations

- parent: [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/product/PM-EXAMPLE/UC-EXAMPLE-001.md",
        """---
type: Use Case
title: 示例用例
description: null
tags: [product, UC]
timestamp: "%s"
full_id: UC-EXAMPLE-001
perspective: product
hierarchy: UC
parent_id: FT-EXAMPLE
layer_scope: system
---
# Relations

- parent: [FT-EXAMPLE](/knowledge/product/PM-EXAMPLE/FT-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

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

上游主定义：`company/ea/application/SYS-EXAMPLE/`（公司层 OKF 落盘见后续波次）。

# Relations

- children:
  - [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/application/APP-EXAMPLE.md",
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
# Relations

- parent: [SYS-EXAMPLE](/knowledge/application/SYS-EXAMPLE.md)
- service_ids:
  - [MS-EXAMPLE](/knowledge/application/MS-EXAMPLE.md)

# Cross-perspective

- (none)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/application/MS-EXAMPLE.md",
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
# Relations

- parent: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE.md)

# Cross-perspective

- cross_references:
  - [BC-EXAMPLE](/knowledge/business/BD-EXAMPLE/BC-EXAMPLE.md)
  - [PM-EXAMPLE](/knowledge/product/PM-EXAMPLE/PM-EXAMPLE.md)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/data/DS-EXAMPLE.md",
        """---
type: Data Store
title: 示例数据源
description: 仅用于演示数据视角数据结构（示例）。
tags: [data, DS]
timestamp: "%s"
full_id: DS-EXAMPLE
perspective: data
hierarchy: DS
parent_id: null
config_key: example_config_key
layer_scope: system
---
# Relations

- (none)

# Cross-perspective

- owned_by_app_id: [APP-EXAMPLE](/knowledge/application/APP-EXAMPLE.md)

# Details

- (none)

# Evidence

示例数据
""",
    ),
    (
        "knowledge/data/ENT-EXAMPLE.md",
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
# Relations

- parent: [DS-EXAMPLE](/knowledge/data/DS-EXAMPLE.md)

# Cross-perspective

- maps_to_aggregate_id: [AGG-EXAMPLE](/knowledge/business/BD-EXAMPLE/AGG-EXAMPLE.md)

# Details

- (none)

# Evidence

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
