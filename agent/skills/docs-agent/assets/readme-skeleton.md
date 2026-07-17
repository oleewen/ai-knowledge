<!-- markdownlint-disable-file MD022 MD031 MD040 MD060 -->
# README.md 骨架

可按项目删减小节；**顺序尽量保留**。`{...}` 替换；`<!-- optional -->` 可省略。
分类：`README.md` 默认属于 **A 类：人类入口文档**，优先保留可见 `# H1`；是否保留 frontmatter `title` 需按仓库文档分类矩阵判断，勿为消除 `MD025` 自行删除被下游消费的字段。

```markdown
# {项目名}

{一句话}

<!-- optional badges -->

## 简介

{2–5 句；详链实际 INDEX-GUIDE（可点击）}

## 快速开始

### 环境
- ...

### 安装与启动
```shell
...
```

<!-- optional -->
## 核心业务 / 技术架构
...

## 项目结构

> 与 INDEX-GUIDE §2 一致，勿第二套矛盾树。

```
{root}/
├── ...
└── ...
```

## 文档导航

| 文档 | 用途 |
|------|------|
| `{实际 INDEX 路径}` | 九章索引指南 |
| `AGENTS.md` | Agent 契约 |

<!-- optional: 开发/贡献 -->

## 许可证
{许可证}
```
