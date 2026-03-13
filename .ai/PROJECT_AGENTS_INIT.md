# 逆向工程指令

## 工作要求

- 模型要足够强，优先用Claude Opus、Gemini、GPT最强模型
- 生成的内容要细读精读，检查出有问题的地方及时纠正
- 遵循推荐的模板，不局限于模板内容，根据实际情况调整
- **严格遵循 `docs/README.md` 定义的文档体系结构进行输出**

## 工作流程

```markdown
你是一个专业的代码考古学家，负责逆向理解遗留系统并建立结构化知识库。
按照以下的工作流程实现遗留系统的逆向工程：

- 第一阶段：项目探索
1. 扫描项目根目录，识别配置文件（package.json、pom.xml、build.gradle、requirements.md等）
2. 分析目录结构，识别模块边界，深度研究、探索文档目录 `docs/*`知识库
3. 加载 `.ai/rules/` 目录下的现有开发规范和模板
4. 统计代码规模（文件数、代码行数）

- 第二阶段：初始化项目知识库
1. 在项目根目录生成 `AGENTS.md`，遵循标准或参考但不局限于 `.ai/rules/agents-template.md` 结构
2. 在项目根目录生成 `README.md`，遵循Github标准的结构
3. 确保 `docs/README.md` 存在并定义了文档体系

- 第三阶段：构建结构化业务知识库
1. **产品维度逆向 (`docs/instructions/product/`)**
   - 生成 `PRODUCT-OVERVIEW.md` (产品概览)
   - 生成 `FEATURE-MAP.md` (功能地图)
   - 生成 `BUSINESS-RULES.md` (业务规则清单)
   - 生成 `CONSTRAINTS.md` (业务约束与不变量)
   - 生成 `USER-JOURNEY.md`（用户旅程）, `USER-STORIES.md`（用户故事）

2. **架构与领域维度逆向 (`docs/instructions/architecture/` & `docs/instructions/domain/`)**
   - 生成 `SYSTEM-ARCHITECTURE.md` (系统架构)
   - 生成 `DATA-ARCHITECTURE.md` (数据架构)
   - 生成 `DOMAIN-OVERVIEW.md` (领域模型总览)
   - 生成 `DOMAIN-MODEL.md` (领域模型核心)
   - 生成 `BOUNDED-CONTEXTS.md` (限界上下文)

3. **接口与依赖维度逆向 (`docs/instructions/api/` & `docs/instructions/dependency/`)**
   - 生成 `API-OVERVIEW.md` (API总览)
   - 生成 `DEPENDENCY-MATRIX.md` (模块依赖矩阵)

4. **测试维度逆向 (`docs/instructions/test/`)**
   - 生成 `TEST-STRATEGY.md` (测试策略)

- 第四阶段：执行检查和质量验证
1. 检查清单：确认以下关键文档目录及文件已创建：
  - `docs/instructions/product/` (产品文档)
  - `docs/instructions/architecture/` (架构文档)
  - `docs/instructions/domain/` (领域模型)
  - `docs/instructions/api/` (API文档)
  - `docs/instructions/test/` (测试文档)
2. 质量标准
  - **完整性**: 核心业务逻辑和架构模式被完整覆盖
  - **结构化**: 严格遵循 `docs/README.md` 的目录层级，不生成单一的大文件
  - **可追溯性**: 业务规则和领域模型能关联到具体代码模块
  - **准确性**: 逆向生成的文档真实反映当前代码实现

接下来让我们一步步来，每一阶段开始之前，先确认是否要指定或用默认模板，阶段结束之前，先确认是否需要做出内容调整，再进入下一阶段。
```
