#!/usr/bin/env python3
"""一次性创建 company/knowledge 示例实体 concept（OKF SSOT）。"""

from __future__ import annotations

import sys
from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
sys.path.insert(0, str(SCRIPT_DIR))
import okf_lib

REPO = okf_lib.find_repo_root(Path(__file__).resolve())
BUNDLE = REPO / "company"
TS = "2026-06-21T00:00:00+08:00"

ENTITIES: list[tuple[str, str]] = [
    (
        "knowledge/business/BD/BD-EXAMPLE/BD-EXAMPLE.md",
        """---
type: Business Domain
title: 示例业务域
description: 演示公司级 BD；支撑 VC，并下挂 BSD-L1。
tags: [business, BD]
timestamp: "%s"
id: BD-EXAMPLE
perspective: business
hierarchy: BD
layer_scope: company
---
## 关系

- children: [BSD-EXAMPLE](BSD-EXAMPLE.md)
- supports_to: [VC-EXAMPLE](../../VC-EXAMPLE/VC-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 演示公司级 BD；支撑 VC，并下挂 BSD-L1。

## 依据与证据

[business-domain-division.md](../../chapters/business-domain-division.md)（示例）
""",
    ),
    (
        "knowledge/business/BD/BD-EXAMPLE/BSD-EXAMPLE.md",
        """---
type: Business Subdomain
title: 示例一级业务子域
description: 公司层 BSD-L1；挂 BD；由 BL 一对一映射；maps_to CAP。
tags: [business, BSD]
timestamp: "%s"
id: BSD-EXAMPLE
perspective: business
hierarchy: BSD
layer_scope: company
---
## 关系

- parent: [BD-EXAMPLE](BD-EXAMPLE.md)
- maps_to: [CAP-EXAMPLE](../../VC-EXAMPLE/CAP/CAP-EXAMPLE.md)
- mapped_by: [BL-EXAMPLE](../../BL/BL-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- level: 1
- 公司层 BSD-L1；挂 BD；由 BL 一对一映射；maps_to CAP。

## 依据与证据

[business-domain-division.md](../../chapters/business-domain-division.md#业务子域)（示例）
""",
    ),
    (
        "knowledge/business/VC-EXAMPLE/VC-EXAMPLE.md",
        """---
type: Value Chain
title: 示例价值链
description: 演示公司级 VC；由 BD 支撑，并由 CAP 实现。
tags: [business, VC]
timestamp: "%s"
id: VC-EXAMPLE
perspective: business
hierarchy: VC
layer_scope: company
---
## 关系

- implemented_by: [CAP-EXAMPLE](CAP/CAP-EXAMPLE.md)
- supported_by: [BD-EXAMPLE](../BD/BD-EXAMPLE/BD-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 演示公司级 VC；由 BD 支撑，并由 CAP 实现。

## 依据与证据

[business-value-chain.md](../chapters/business-value-chain.md)（示例）
""",
    ),
    (
        "knowledge/business/VC-EXAMPLE/CAP/CAP-EXAMPLE.md",
        """---
type: Business Capability
title: 示例业务能力
description: 演示公司级 CAP；实现 VC；由 BSD-L1 一对一映射。
tags: [business, CAP]
timestamp: "%s"
id: CAP-EXAMPLE
perspective: business
hierarchy: CAP
layer_scope: company
---
## 关系

- implements_to: [VC-EXAMPLE](../VC-EXAMPLE.md)
- mapped_by: [BSD-EXAMPLE](../../BD/BD-EXAMPLE/BSD-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 演示公司级 CAP；实现 VC；由 BSD-L1 一对一映射。

## 依据与证据

[business-capability.md](../chapters/business-capability.md)（示例）
""",
    ),
    (
        "knowledge/business/BL/BL-EXAMPLE.md",
        """---
type: Business Line
title: 示例业务线
description: 演示公司级 BL；无 parent；与 BSD-L1 一对一映射。
tags: [business, BL]
timestamp: "%s"
id: BL-EXAMPLE
perspective: business
hierarchy: BL
layer_scope: company
---
## 关系

- maps_to: [BSD-EXAMPLE](../BD/BD-EXAMPLE/BSD-EXAMPLE.md)

## 跨视角

- (none)

## 详细说明

- 演示公司级 BL；无 parent；与 BSD-L1 一对一映射。

## 依据与证据

[../chapters/business-roles-and-organization.md](../chapters/business-roles-and-organization.md)（示例）
""",
    ),
    (
        "knowledge/technical/TPL/TPL-EXAMPLE.md",
        """---
type: Technical Platform
title: 示例技术平台能力
description: 演示公司级 TPL 结构。
tags: [technical, TPL]
timestamp: "%s"
id: TPL-EXAMPLE
perspective: technical
hierarchy: TPL
layer_scope: company
---
## 关系

- (none)

## 跨视角

- (none)

## 详细说明

- 演示公司级 TPL 结构。

## 依据与证据

[../chapters/technical-overview.md](../chapters/technical-overview.md)（示例）
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
