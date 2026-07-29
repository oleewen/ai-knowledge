# 受众与语言（docs-agent）

> 公共维与烤干门禁：[audience-and-language.md](../../../references/audience-and-language.md)

## 主读者

按产物分流：**README** → 人类/GitHub；**AGENTS** → AI；**INDEX** → AI 检索。细则见 [three-file-spec.md](three-file-spec.md)。

## 宜写 / 宜弱化

| 宜写 | 宜弱化 |
| --- | --- |
| 与三文件矩阵一致的职责内容 | 把命令百科 thrice 写入 README/AGENTS/INDEX |
| 短路径、约束、查阅顺序（AGENTS） | 复制 INDEX §9.3 Skill 长表 |
| Quick start、文档表、目录树（README） | Agent 角色长文进 README |

## 反例

| 避免 | 推荐 |
| --- | --- |
| AGENTS 粘贴完整命令手册 | README 放命令；AGENTS 链过去 |
| README 写成长篇 Agent 契约 | 契约进 AGENTS |

## 特殊允许区

无。骨架见 `assets/readme-skeleton.md`、`assets/agents-skeleton.md`。
