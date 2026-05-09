# 蒸馏范围与变更发现

**唯一写目标**与表格体例：**[federation-spec.md](federation-spec.md)**。本节：如何发现变更、产物清单。

目标路径（复述一句）：

`system/architecture/overview/{APPNAME}-overview.md`（不存在则用 `NAME-overview.md` 模板，**文件名与 `# {NAME} 架构概览` 同步替换**。）

以下内容**仅来源**，不单列作蒸馏终稿：各视角长篇、`application-{name}/` knowledge、SDD 目录。  
`DISTILL-LOG`：全应用共用，见 [distill-log-spec.md](distill-log-spec.md)。

## 变更发现（可组合）

| 方式 | 说明 |
| ---- | ---- |
| Git diff | 自标签/提交/用户给区间，对 `system/application-{name}/` diff |
| 清单 | 用户给已改路径列表 |
| 全量快照 | 无基线时读应用 knowledge + SDD 全量作源 |

## 产物

| 产物 | 路径 | 内容 |
| ---- | ----- | ----- |
| overview | `…/overview/{APPNAME}-overview.md` | 五视角表；第三列 + A/U/D |
| 记录 | `system/changelogs/DISTILL-LOG.md` | 含 `app`；新条**最前**；作下轮锚点 |
