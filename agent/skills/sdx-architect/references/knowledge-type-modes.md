# KNOWLEDGE_TYPE 与 ASD / DSD

**来源**：`.docsconfig` 的 `KNOWLEDGE_TYPE`。`validate-asd.sh` / `validate-dsd.sh` 会读取。应用库**详设正文**由 **DSD**（`/sdx-design`）承载。

**布局契约**（路径、overview、SDD 落盘）：[knowledge-layout.md](../../../references/knowledge-layout.md)。

## 模式

| `KNOWLEDGE_TYPE` | ASD | DSD / 落地 |
| --- | --- | --- |
| `application` 或未设置 | `§1-§3` 完整 | 应用库 **DSD-*.md**；可选 **spec-asd-*** → `{DOC_DIR}/specs/` |
| `system` / `company` | `§1-§3` 联邦概要（`§3` 可保留摘要与下游承接） | 本库不落 DSD；详设 → 应用库 `/sdx-design` |

## 联邦概要要点

1. **§1**：关联 PRD / ANALYSIS / overview
2. **§2**：服务边界、变更方向、上下游关系
3. **§3**：规约摘要与下游承接
4. 不写应用级实现细节

## 推进约束

- `sdx-architect` 仍按参数向导 + 分段直写 + 当前段 `C/M/G/F` 推进
- 联邦模式只改变输出粒度，不改变当前段协议
- 本层继续沿用参数向导 + 分段直写 + 当前段 `C/M/G/F` 推进
