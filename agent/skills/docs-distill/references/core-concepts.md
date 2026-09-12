# 核心概念

联邦与细节：[federation-spec.md](federation-spec.md)。

## 路径与标识

| 术语 | 含义 |
| ------ | ------ |
| `DOC_DIR` | 目标层：`system` 或 `company`（蒸馏目标；非 application） |
| `{NAME}` | system 边=应用名；company 边=系统名 |
| 源槽位 | `system/application-slots/application-{NAME}/` 或 `company/system-slots/system-{NAME}/` |
| `{NAME}-overview.md` | 目标层 `knowledge/overview/` 下产物 |

## 模式

- **仅全量**：整表扫描槽位源，按 federation-spec 写第三列 delta。
- **不写 DISTILL-LOG**：无增量锚点；勿再依赖历史 DISTILL-LOG 文件。

## 第三列语义

相对链接段落的 **delta** 缓冲区；细则 [federation-spec.md](federation-spec.md)。表行随目标层（系统库 vs 公司库）。
