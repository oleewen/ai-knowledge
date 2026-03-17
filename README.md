# 软件系统知识文档库 (ai-sdd-docs)

本仓库是企业级软件系统的**全局知识底座**，采用「单一事实源」与「联邦治理」理念管理架构与知识体系。

## 快速初始化 (sdx-init)

在任意目录下执行以下命令，可从本仓库初始化 SDD 开发环境（文档模板、知识库结构、`.ai` 配置与 Agent 的 skills/命令）：

```bash
# 方式一：从 Git 拉取并初始化当前目录（需先设置 GIT_REPO_URL 为实际仓库地址）
curl -sL "https://raw.githubusercontent.com/oleewen/ai-sdd-docs/main/scripts/sdx-init-bootstrap.sh" | bash -s -- [选项]

# 方式二：已克隆本仓库时，在目标目录执行
cd /path/to/your-project
REPO_ROOT=/path/to/ai-sdd-docs /path/to/ai-sdd-docs/scripts/sdx-init.sh [选项]
```

**默认初始化**

- ① 将仓库内 **system** 目录下文件拷贝到当前目录的 `docs/system/`（可改），默认仅拷贝 **knowledge** 及根目录同级文件，`--ds=full` 可拷贝完整文档；**applications** 拷贝到 `docs/applications/`（与 docs/system 同级）；
- ② 将 `.ai` 拷贝到当前目录的 `.ai/`（默认不包含 `rules/solution`、`rules/analysis`）；
- ③ 按 `--agents` 为 Cursor、Trea 等 Agent 生成或拷贝配置（`.cursor`、`.trea` 等）。详见 [scripts/README.md](scripts/README.md)。

## 功能简介

**系统知识库** 已统一放在 **[system](system/)** 目录下，包含：

- [system/README.md](system/README.md) — 知识库说明与快速导航  
- [system/INDEX.md](system/INDEX.md) — 全局索引（业务知识、解决方案、需求分析、需求交付、需求规约入口）  
- [system/DESIGN.md](system/DESIGN.md) — 设计摘录与约定  

**应用知识库** 已统一放在 **[applications](applications/)** 目录下，包含：

- [applications/README.md](applications/README.md) — 应用知识库说明与初始化方式  
- [applications/INDEX.md](applications/INDEX.md) — 应用知识结构、方案与需求、治理信息导航  

## 目录结构

```text
ai-sdd-docs/
├── README.md           # 本文件：总览、快速初始化、功能简介与文档索引
├── AGENTS.md           # AI Agents 开发指南（角色、关键路径、规范、命令）
├── system/             # 系统知识库
│   ├── README.md, INDEX.md, DESIGN.md, CONTRIBUTING.md
│   ├── knowledge/      # 四视角 + 宪法层（constitution, business, product, technical, data）
│   ├── solutions/      # 解决方案（SOLUTION-{ID}.md）
│   ├── analysis/       # 需求分析（REQUIREMENT-{ID}.md）
│   ├── requirements/   # 需求交付（REQUIREMENT-{ID}/MVP-Phase-*/）
│   ├── specs/          # 需求规约
│   └── changelogs/     # 变更日志
├── applications/       # 应用知识库（README、INDEX 及各应用子目录）
├── scripts/            # sdx-init 等脚本，详见 scripts/README.md
├── .ai/                # AI 规范与技能（CONVENTIONS.md、rules/、skills/）
├── .cursor/            # Cursor 配置与 Slash 命令（README、skills/）
└── .trea/             # Trea Agent 配置
```

## 文档索引

| 用途           | 文档 |
|----------------|------|
| 全局文档入口   | [system/INDEX.md](system/INDEX.md) |
| 设计依据与约定 | [system/DESIGN.md](system/DESIGN.md)、[.ai/CONVENTIONS.md](.ai/CONVENTIONS.md) |
| 贡献与新增约定 | [system/CONTRIBUTING.md](system/CONTRIBUTING.md) |
| 初始化与选项   | [scripts/README.md](scripts/README.md) |
| Cursor 命令表  | [.cursor/README.md](.cursor/README.md) |
| AI 开发指南    | [AGENTS.md](AGENTS.md) |