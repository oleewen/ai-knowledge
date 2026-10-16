#!/usr/bin/env python3
"""一次性创建 system/knowledge 示例实体 concept（OKF SSOT）。"""

from __future__ import annotations

import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib

REPO = okf_lib.find_repo_root(Path(__file__).resolve())
BUNDLE = REPO / "system"
TS = "2026-06-21T00:00:00+08:00"

ENTITIES: list[tuple[str, str]] = [
    (
        "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BSD-EXAMPLE-L3.md",
        """---
type: Business Subdomain
title: 示例三级业务子域
description: BSD-L3；parent→解决方案 BSD-L2。
tags: [business, BSD]
timestamp: "%s"
id: BSD-EXAMPLE-L3
perspective: business
hierarchy: BSD
layer_scope: system
---
## 关系

- parent: BSD-EXAMPLE-L2
- implemented_by: [BC-EXAMPLE](BC-EXAMPLE/BC-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- level: 3
- BSD-L3；parent→解决方案 BSD-L2。

## 依据与证据

[../chapters/business-capability-map.md](../chapters/business-capability-map.md#三级子域)（示例）
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md",
        """---
type: Bounded Context
title: 示例限界上下文
description: 限界上下文。
tags: [business, BC]
timestamp: "%s"
id: BC-EXAMPLE
perspective: business
hierarchy: BC
layer_scope: system
---
## 关系

- implements_to: [BSD-EXAMPLE-L3](../BSD-EXAMPLE-L3.md)
- implemented_by: [AGG-EXAMPLE](AGG-EXAMPLE/AGG-EXAMPLE.md)
- supported_by: [APP-EXAMPLE](../../../application/SYS-EXAMPLE/APP-EXAMPLE/APP-EXAMPLE.md)

## 跨视角

- mapped_by: [PM-EXAMPLE](../../../product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md)

## 详细说明

- 限界上下文。

## 依据与证据

[../../chapters/business-capability-map.md](../../chapters/business-capability-map.md#限界上下文)（示例）
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md",
        """---
type: Aggregate
title: 示例聚合
description: 聚合根。
tags: [business, AGG]
timestamp: "%s"
id: AGG-EXAMPLE
perspective: business
hierarchy: AGG
layer_scope: system
---
## 关系

- implements_to: [BC-EXAMPLE](../BC-EXAMPLE.md)
- implemented_by: [AB-EXAMPLE](AB-EXAMPLE.md)

## 跨视角

- mapped_by:
  - [MS-EXAMPLE](../../../../application/SYS-EXAMPLE/APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md)
  - [ENT-EXAMPLE](../../../../data/MDG-EXAMPLE/DS-EXAMPLE/ENT-EXAMPLE.md)

## 详细说明

- 聚合根。

## 依据与证据

[../../../chapters/business-capability-map.md](../../../chapters/business-capability-map.md#聚合)（示例）
""",
    ),
    (
        "knowledge/business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md",
        """---
type: Ability
title: 示例能力
description: 领域能力。
tags: [business, AB]
timestamp: "%s"
id: AB-EXAMPLE
perspective: business
hierarchy: AB
layer_scope: system
---
## 关系

- implements_to: [AGG-EXAMPLE](AGG-EXAMPLE.md)

## 跨视角

- mapped_by: [UC-EXAMPLE](../../../../product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md)

## 详细说明

- 领域能力。

## 依据与证据

[../../../chapters/business-capability-map.md](../../../chapters/business-capability-map.md#领域能力)（示例）
""",
    ),

    (
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/PM-EXAMPLE.md",
        """---
type: Product Module
title: 示例产品模块
description: 产品模块。
tags: [product, PM]
timestamp: "%s"
id: PM-EXAMPLE
perspective: product
hierarchy: PM
layer_scope: system
---
## 关系

- implements_to: PD-EXAMPLE

## 跨视角

- maps_to: [BC-EXAMPLE](../../../business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md)

## 详细说明

- 产品模块。

## 依据与证据

[../../chapters/product-architecture.md](../../chapters/product-architecture.md#产品模块)（示例）
""",
    ),
    (
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FT-EXAMPLE.md",
        """---
type: Feature
title: 示例功能
description: 功能点。
tags: [product, FT]
timestamp: "%s"
id: FT-EXAMPLE
perspective: product
hierarchy: FT
layer_scope: system
---
## 关系

- implements_to: [PM-EXAMPLE](../PM-EXAMPLE.md)
- implemented_by: [FR-EXAMPLE](FR-EXAMPLE/FR-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 功能点。

## 依据与证据

[../../../chapters/product-feature.md](../../../chapters/product-feature.md#功能点)（示例）
""",
    ),
    (
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/FR-EXAMPLE.md",
        """---
type: Functional Requirement
title: 示例功能需求
description: 功能需求。
tags: [product, FR]
timestamp: "%s"
id: FR-EXAMPLE
perspective: product
hierarchy: FR
layer_scope: system
---
## 关系

- implements_to: [FT-EXAMPLE](../FT-EXAMPLE.md)
- implemented_by:
  - [UC-EXAMPLE](UC-EXAMPLE.md)
  - [BR-EXAMPLE](BR-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 功能需求。

## 依据与证据

[../../../../chapters/product-feature.md](../../../../chapters/product-feature.md#功能需求)（示例）
""",
    ),
    (
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/BR-EXAMPLE.md",
        """---
type: Business Rule
title: 示例规则
description: 业务规则。
tags: [product, BR]
timestamp: "%s"
id: BR-EXAMPLE
perspective: product
hierarchy: BR
layer_scope: system
---
## 关系

- implements_to: [FR-EXAMPLE](FR-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 业务规则。

## 依据与证据

[../../../../chapters/product-user-journeys.md](../../../../chapters/product-user-journeys.md#业务规则清单)（示例）
""",
    ),
    (
        "knowledge/product/PD-EXAMPLE/PM-EXAMPLE/FT-EXAMPLE/FR-EXAMPLE/UC-EXAMPLE.md",
        """---
type: Use Case
title: 示例用例
description: 用例。
tags: [product, UC]
timestamp: "%s"
id: UC-EXAMPLE
perspective: product
hierarchy: UC
layer_scope: system
---
## 关系

- implements_to: [FR-EXAMPLE](FR-EXAMPLE.md)

## 跨视角

- maps_to: [AB-EXAMPLE](../../../../../business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AB-EXAMPLE.md)

## 详细说明

- 用例。

## 依据与证据

[../../../../chapters/product-user-journeys.md](../../../../chapters/product-user-journeys.md#场景用例)（示例）
""",
    ),
    (
        "knowledge/application/SYS-EXAMPLE/SYS-EXAMPLE.md",
        """---
type: System
title: 示例系统
description: 系统（别名应用服务）；implements_to 解决方案 SLN；maps_to PD。
tags: [application, SYS]
timestamp: "%s"
id: SYS-EXAMPLE
perspective: application
hierarchy: SYS
layer_scope: system
---
## 关系

- implements_to: SLN-EXAMPLE
- implemented_by: [APP-EXAMPLE](APP-EXAMPLE/APP-EXAMPLE.md)

## 跨视角

- maps_to: PD-EXAMPLE

## 详细说明

- 系统（别名应用服务）；implements_to 解决方案 SLN（纯 ID）；maps_to PD。解决方案层不回写这条边。

## 依据与证据

[../chapters/application-overview.md](../chapters/application-overview.md)（示例）
""",
    ),
    (
        "knowledge/application/SYS-EXAMPLE/APP-EXAMPLE/APP-EXAMPLE.md",
        """---
type: Application
title: 示例应用
description: 应用，代码仓库与部署单元。
tags: [application, APP]
timestamp: "%s"
id: APP-EXAMPLE
perspective: application
hierarchy: APP
layer_scope: system
---
## 关系

- implements_to: [SYS-EXAMPLE](../SYS-EXAMPLE.md)
- implemented_by: [MS-EXAMPLE](MS-EXAMPLE/MS-EXAMPLE.md)
- supports_to: [BC-EXAMPLE](../../../business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/BC-EXAMPLE.md)

## 跨视角

- uses_to:
  - [DS-EXAMPLE](../../../data/MDG-EXAMPLE/DS-EXAMPLE/DS-EXAMPLE.md)

## 详细说明

- 应用，代码仓库与部署单元。

## 依据与证据

[../../chapters/application-architecture.md](../../chapters/application-architecture.md#应用)（示例）
""",
    ),
    (
        "knowledge/application/SYS-EXAMPLE/APP-EXAMPLE/MS-EXAMPLE/MS-EXAMPLE.md",
        """---
type: Microservice
title: 示例微服务
description: 微服务，入口能力簇。
tags: [application, MS]
timestamp: "%s"
id: MS-EXAMPLE
perspective: application
hierarchy: MS
layer_scope: system
---
## 关系

- implements_to: [APP-EXAMPLE](../APP-EXAMPLE.md)

## 跨视角

- maps_to: [AGG-EXAMPLE](../../../../business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md)

## 详细说明

- 微服务，入口能力簇。

## 依据与证据

[../../../chapters/application-architecture.md](../../../chapters/application-architecture.md#微服务)（示例）
""",
    ),
    (
        "knowledge/data/MDG-EXAMPLE/DS-EXAMPLE/DS-EXAMPLE.md",
        """---
type: Data Store
title: 示例数据源
description: 示例数据源。
tags: [data, DS]
timestamp: "%s"
id: DS-EXAMPLE
perspective: data
hierarchy: DS
layer_scope: system
---
## 关系

- implements_to: MDG-EXAMPLE

## 跨视角

- used_by: [APP-EXAMPLE](../../application/SYS-EXAMPLE/APP-EXAMPLE/APP-EXAMPLE.md)

## 详细说明

- 示例数据源。

## 依据与证据

[../chapters/data-model.md](../chapters/data-model.md#数据源)（示例）
""",
    ),
    (
        "knowledge/data/MDG-EXAMPLE/DS-EXAMPLE/ENT-EXAMPLE.md",
        """---
type: Entity
title: 示例实体
description: 数据实体，表或集合。
tags: [data, ENT]
timestamp: "%s"
id: ENT-EXAMPLE
perspective: data
hierarchy: ENT
layer_scope: system
---
## 关系

- implements_to: [DS-EXAMPLE](DS-EXAMPLE.md)

## 跨视角

- maps_to: [AGG-EXAMPLE](../../business/BSD-EXAMPLE-L2/BSD-EXAMPLE-L3/BC-EXAMPLE/AGG-EXAMPLE/AGG-EXAMPLE.md)

## 详细说明

- 数据实体，表或集合。

## 依据与证据

[../chapters/data-model.md](../chapters/data-model.md#数据实体)（示例）
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
