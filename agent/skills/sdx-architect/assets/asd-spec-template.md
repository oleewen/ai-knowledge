# {IDEA-ID} {APP-NAME} MVP-Phase-{n} 概设需求规约示例

> **spec-asd-*.md**：概设（本模板）。**spec-dsd-*.md**：详设，路径仅 `requirements/.../MVP-Phase-{N}/specs/`。落 **`{DOC_DIR}/specs/spec-asd-{IDEA-ID}-{MVP-PHASE}-{app-name}.md`**，`id` 同文件名。

## 1. 需求规约范围

- 应用：{APP-NAME}
- 能力：能力示例
- 覆盖：FR/UC/BR/EX（按需列出）
- SSOT：PRD/ASD 路径（按需列出）

## 2. 业务术语概念

- 示例概念：{示例概念}
- 示例字段：{示例字段}
- 示例口径：{示例口径}

## 3. 需求条目（FR）

- FR-001：{示例FR}
- FR-002：{示例FR}

## 4. 用例条目（UC）

- UC-001：{示例UC}
- UC-002：{示例UC}

## 5. 接口定义

### 示例接口

- 接口签名：{示例签名}
- **入参**：{示例入参}
- **出参**：{示例出参}
- **业务规则（BR）**
  - BR-001：{示例BR}
  - BR-002：{示例BR}
- **异常与拦截（EX）**

| EX 编号 | 异常描述 | message（对外提示） | suggestions（建议） |
| ------ | ---- | ---- | ---- |
| EX-001 | {示例EX} | {示例EX} message | {示例EX} suggestions |

## 6. 元数据

```yaml
id: "spec-asd-{IDEA-ID}-{MVP-PHASE}-{APP-NAME}"
title: "{app-name} MVP-Phase-{n} 需求规约"
version: "1.0.0"
status: "draft"
created: "YYYY-MM-DD"
updated: "YYYY-MM-DD"
parent: "{ASD-ID}"
refs:
  - "{PRD-PATH}"
  - "{ASD-PATH}"
scope:
  fr: ["FR-{n}"]
  uc: ["UC-{n}"]
  br: ["BR-{n}"]
  ex: ["EX-{n}"]
```
