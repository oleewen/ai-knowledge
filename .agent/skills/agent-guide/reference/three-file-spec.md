# 三文件分工与产出规范

README.md、AGENTS.md、INDEX_GUIDE.md 三文件的职责划分、去重规则与产出格式要求。

---

## 职责矩阵

| 文件 | 读者 | 放什么 | 不放什么 |
|------|------|--------|----------|
| **当前 INDEX** | AI 检索 | 九章、路径精要、未索引声明 | 冗长教程、重复命令百科 |
| **README.md** | 人类、GitHub 首屏 | H1 + 一句话、Quick start、文档索引表、目录结构 | Agent 角色与禁止项长文 |
| **AGENTS.md** | AI | 角色、约束、工作流、禁止项、短关键路径 | 完整命令手册、§3 API 入口全表副本 |

---

## 去重硬规则

1. **命令块、选项说明、大链接表** → 只放在 README；AGENTS 用「详见 README.md」+ 可选一条最常用示例。
2. **项目概述/技术栈**（AGENTS）各 **≤3 行**；细节见 README 与 INDEX §1。
3. **查阅顺序**（AGENTS 一句话）：当前主 Index 相对路径 → `README.md` → 子域索引（如 `application/SYSTEM_INDEX.md`）或规范路径。

---

## 产出顺序

**先 README，后 AGENTS。**

避免 AGENTS 写满命令后再在 README 重复粘贴；AGENTS 内链指向 README 已定稿的小节。

---

## README.md 产出规范

按 [../assets/readme-skeleton.md](../assets/readme-skeleton.md) 骨架生成：

- 新读者约 30 秒内知道「是什么、下一步点哪」
- 相对路径可点、表格不空洞
- 与 INDEX §2 目录树**一致**，禁止第二套矛盾树

---

## AGENTS.md 产出规范

按 [../assets/agents-skeleton.md](../assets/agents-skeleton.md) 骨架生成：

- 骨架可裁剪，禁止与语义冲突
- 首条参考为步骤 1 确定的当前主 Index 实际落盘路径
- INDEX §6 或未读路径不得写成已核实结论
