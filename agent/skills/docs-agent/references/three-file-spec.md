# 三文件分工

README、`AGENTS`、当前 **INDEX**：职责与去重。

## 矩阵

| 文件 | 读者 | 放 | 不放 |
| ---- | ---- | -- | ---- |
| **INDEX** | AI 检索 | 九章、路径精要、未索引声明 | 长教程、重复命令百科 |
| **README** | 人类、GitHub | H1、一句、Quick start、文档表、目录树 | Agent 角色长文 |
| **AGENTS** | AI | 角色、约束、流程、禁止、短路径 | 完整命令手册、§3 API 表副本 |

## 去重

1. 命令块 / 选项 / 大链接表 → **仅 README**；AGENTS：`详见 README.md` + 可选一条示例。
2. AGENTS「项目概述/技术栈」各 **≤3 行**；细节 → README + INDEX §1。
3. AGENTS「查阅顺序」一句：当前主 Index 相对路径 → `README.md` → 子索引或规范。
4. Skill 路径索引 → **仅 INDEX §9.3**；README / AGENTS 链 `agent/skills/README.md`，**不得复制 §9.3 Skill 长表**。

## 产出顺序

**先 README，后 AGENTS**（避免命令双写）。

## 规范

- README：骨架 [../assets/readme-skeleton.md](../assets/readme-skeleton.md)；30 秒可懂；路径可点；树与 INDEX §2 **一致**。
- AGENTS：骨架 [../assets/agents-skeleton.md](../assets/agents-skeleton.md)；首条参考 = 步骤 1 实测 Index 路径；§6 / 未读路径不写死为已核实。
