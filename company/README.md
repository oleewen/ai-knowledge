# 公司知识库（顶层 `company/`）

本目录为 **公司知识库根** 语义：公司级架构与各 **`system-{name}/`** 系统镜像槽位（后续可通过 fetch 同步）。

## 子目录

| 路径 | 说明 |
|------|------|
| [`ea/`](ea/README.md) | 公司级企业架构（业务/产品/应用/数据/技术五视角，聚焦治理叙事） |
| [`solutions/`](solutions/README.md) | 公司级跨系统解决方案（明确哪个系统负责什么功能，作为 analysis 上游） |
| [`analysis/`](analysis/README.md) | 公司级跨系统需求分析（衔接 solutions，输出给各系统侧 requirements） |
| [`system-APPNAME/`](system-APPNAME/README.md) | 占位槽位；真实系统名替换 `APPNAME`，内容可由 fetch 填入 |
