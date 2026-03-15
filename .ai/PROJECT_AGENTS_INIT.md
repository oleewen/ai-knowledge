# 逆向工程指令

## 工作要求

- 模型要足够强，优先用Claude Opus、Gemini、GPT最强模型
- 生成的内容要细读精读，检查出有问题的地方及时纠正
- 遵循推荐的模板，不局限于模板内容，根据实际情况调整
- **严格遵循根目录 `README.md` 定义的文档体系结构进行输出**

## 工作流程

```markdown
你是一个专业的代码考古学家，负责逆向理解遗留系统并建立结构化知识库。
按照以下的工作流程实现遗留系统的逆向工程：

- 第一阶段：项目探索
1. 扫描项目根目录，识别配置文件（package.json、pom.xml、build.gradle、requirements.md等）
2. 分析目录结构，识别模块边界，深度研究、探索知识库 `knowledge/` 及根目录 `README.md` 定义的文档体系
3. 加载 `.ai/rules/` 目录下的现有开发规范和模板
4. 统计代码规模（文件数、代码行数）

- 第二阶段：初始化项目知识库
1. 在项目根目录生成 `AGENTS.md`，遵循标准或参考但不局限于 `.ai/rules/agents-template.md` 结构
2. 在项目根目录生成 `README.md`，遵循Github标准的结构
3. 确保根目录 `README.md` 存在并定义了文档体系（参见其中「目录结构」与「文档索引」）

- 第三阶段：构建结构化业务知识库（与根目录 `README.md` 中 knowledge/ 结构一致）
1. **宪法层逆向 (`knowledge/constitution/`)**
   - 架构决策写入 `knowledge/constitution/adr/`
   - 命名与规范参考 `knowledge/constitution/standards/`、`principles/`

2. **业务维度逆向 (`knowledge/business/`)**
   - 业务域/子域/限界上下文/聚合写入 `knowledge/business/` 对应层级（BD → BSD → BC → AGG）

3. **产品维度逆向 (`knowledge/product/`)**
   - 产品线/模块/功能点/用例按层级组织（PL → PM → FT → UC）
   - 示例：`PL-ECOMMERCE/PRODUCT-OVERVIEW.md`、`PM-xxx/FEATURE-MAP.md`、`BUSINESS-RULES.md`、`USER-STORIES.md`

4. **技术维度逆向 (`knowledge/technical/`)**
   - 系统/应用/微服务写入 `knowledge/technical/`（如 `SYS-xxx/APPLICATION-ARCHITECTURE.md`、`INTEGRATION-MAP.md`）

5. **数据维度逆向 (`knowledge/data/`)**
   - 数据存储与数据实体写入 `knowledge/data/`（DS → ENT），可含 `DATA-ARCHITECTURE.md` 等

6. **测试与规约**
   - 测试策略与计划写入需求交付产物 `requirements/`（TDD）、或 `specs/`、或 `knowledge/technical/` 下应用说明

- 第四阶段：执行检查和质量验证
1. 检查清单：确认以下关键目录及产出与根目录 `README.md` 一致：
  - `knowledge/constitution/`（宪法层：ADR、原则、规范）
  - `knowledge/business/`（业务视角）
  - `knowledge/product/`（产品视角）
  - `knowledge/technical/`（技术视角）
  - `knowledge/data/`（数据视角）
2. 质量标准
  - **完整性**: 核心业务逻辑和架构模式被完整覆盖
  - **结构化**: 严格遵循根目录 `README.md` 的目录层级（knowledge 为四视角+宪法层），不生成单一的大文件
  - **可追溯性**: 业务规则和领域模型能关联到具体代码模块
  - **准确性**: 逆向生成的文档真实反映当前代码实现

接下来让我们一步步来，每一阶段开始之前，找不到模板则提示指定模板，阶段结束之前，先确认是否需要做出内容调整，再进入下一阶段。
```
