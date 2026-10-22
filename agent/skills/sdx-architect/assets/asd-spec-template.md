---
id: "spec-asd-{IDEA-ID}-{N}-{app-name}"
title: "{app-name} MVP-Phase-{N} 概设需求规约"
version: "1.0.0"
status: "draft"
created: "{YYYY-MM-DD}"
updated: "{YYYY-MM-DD}"
parent: "ASD-{IDEA-ID}-{N}"
refs:
  - "{PRD-PATH}"
  - "{ASD-PATH}"
scope:
  fr: ["FR-{n}"]
  uc: ["UC-{n}"]
  br: ["BR-{n}"]
  ex: ["EX-{n}"]
---

# {IDEA-ID} {app-name} MVP-Phase-{N} 概设需求规约

> 概设描述业务契约；实现详设由应用库 `DSD-*.md` 承载。保存到 `{DOC_DIR}/specs/spec-asd-{IDEA-ID}-{N}-{app-name}.md`，`id` 同文件名。

## 1. 需求规约范围

- 应用：{app-name}
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

- 接口签名：{协议级签名；不展开实现方法}
- **入参**：{业务输入摘要}
- **出参**：{业务输出摘要}
- **业务规则（BR）**
  - BR-001：{示例BR}
  - BR-002：{示例BR}
- **异常与拦截（EX）**

| EX 编号 | 异常描述 | message（对外提示） | suggestions（建议） |
| ------ | ---- | ---- | ---- |
| EX-001 | {示例EX} | {示例EX} message | {示例EX} suggestions |

## 6. 元数据

元数据只在文首 frontmatter 维护；`parent` 指向同链 ASD，`refs` 填已核实来源，`scope` 与正文 ID 一致。未涉及的条目使用空数组，不另造编号。
