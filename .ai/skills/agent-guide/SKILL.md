---
name: agent-guide
description: >
  项目探索并生成 AGENTS.md、README.md，供 AI 与开发者快速理解项目与规范。
  在用户需要初始化/更新 Agent 指引与项目说明时使用。
---

# Agent 指引生成

作为项目文档专家，按以下三阶段完成探索并生成 **AGENTS.md** 与 **README.md**。

## 工作要求

- 模型要足够强，优先用 Claude Opus、Gemini、GPT 最强模型
- 生成内容要细读精读，有问题及时纠正
- 遵循推荐模板，不局限于模板，按实际情况调整
- 产出仅限根目录 `AGENTS.md` 与 `README.md`，并与项目现状一致

## 工作流程

每阶段开始前：找不到模板则提示用户指定模板。阶段结束前：先确认是否需要调整内容，再进入下一阶段。

---

### 第一阶段：项目探索

1. 扫描项目根目录，识别配置文件（`package.json`、`pom.xml`、`build.gradle`、`requirements.txt` 等）
2. 分析目录结构，识别模块边界；若存在 `knowledge/` 及根目录 `README.md`，可参考其文档体系
3. 加载 `.ai/rules/` 下现有开发规范和模板
4. 统计代码规模（文件数、代码行数）

---

### 第二阶段：生成 AGENTS.md 与 README.md

1. 在项目根目录生成 `AGENTS.md`，遵循或参考 `.ai/rules/agents-template.md` 结构（可不局限于模板）
2. 在项目根目录生成或更新 `README.md`，遵循 GitHub 常见结构
3. 确保 `README.md` 中若涉及文档体系，则明确「目录结构」与「文档索引」

---

### 第三阶段：检查与质量验证

**检查清单**：针对 **AGENTS.md** 与 **README.md** 两项产出。

**质量标准：**

- **完整性**：AGENTS.md 覆盖关键路径、技术栈、命令与开发规范；README.md 能让人快速上手与定位文档
- **一致性**：与当前代码结构、配置、入口一致，无过时描述
- **可操作性**：命令与步骤可直接复制执行

---

## 参考

- 开发规范与模板：`.ai/rules/`、`.ai/CONVENTIONS.md`
- 若项目已有根目录 `README.md`：以其文档体系描述为准，本 Skill 仅更新/生成该文件与 AGENTS.md
