# 应用知识库 (Applications Knowledge Repository)

本目录存放各具体应用或微服务的**专属知识库与交付文档**，遵循系统级知识库的结构和规范，结合各自实际业务、产品和技术特性进行补充和细化。每个应用作为「联邦单元」自主维护知识及接口规范，并与系统总库协同更新。

## 快速导航

| 文档                                   | 说明                                              |
| -------------------------------------- | ------------------------------------------------- |
| **[知识索引](./INDEX.md)**                  | 应用内知识与交付全局导航，索引各核心文档               |

## 快速初始化

可参考主仓库的 sdx-init 工具，将基础文档模板、`.ai` 配置、专属 skills 结构一次性初始化到应用代码仓库内：

```bash
# step1: 按需指定应用仓库路径，初始化知识体系与AI配置
REPO_ROOT=/path/to/ai-sdd-knowledge /path/to/ai-sdd-knowledge/scripts/sdx-init.sh --dd=applications/your-app/docs/system --ad=applications/your-app/.ai --agents=cursor,trea
```

详见主库 [scripts/README.md](../../scripts/README.md)。

## 目录结构示例

```text
applications/
└── your-app/
    ├── README.md         # 简介（当前文件）
    ├── INDEX.md          # 本应用知识库全局入口
    └── ...               # 应用专属资料
```

## 设计与治理约定

- **联邦治理**：各应用自主管理本地知识、文档和命名规范，通过 `_meta.yaml`、`manifest.yaml` 与系统总库建立关联。
- **一致命名**：所有知识点、接口、实体须按全局唯一 ID 编排（格式如 `APP-XXX`、`MS-YYY`、`ENT-ZZZ`），支持跨仓库引用。
- **可扩展视图**：按需扩展业务/产品/技术/数据四视角内容，保持与主 knowledge 架构映射。
- **交付闭环**：分析、设计、需求规约、交付成果全流程归档，便于复用和追溯。

**提示**：以「用例」和「接口」驱动知识沉淀，遇到通用模型/标准尽量抽象到主知识库或反馈补充。

如需查看详细模板，请参考[系统知识库设计方案](../../system/DESIGN.md)及 [.ai/rules/design/design-template.md](../../.ai/rules/design/design-template.md)。
