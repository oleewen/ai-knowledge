# docs-build 工作流

[SKILL.md](../SKILL.md) 为主干；门禁与 Qclose-1 见 [gates.md](gates.md)。

---

## 术语

**应用知识库**指 `.docsconfig` 中 `DOC_DIR` 对应目录，下文记 `{DOC_DIR}/`。

---

## 输入与输出

| 类型 | 内容 |
|------|------|
| 硬输入 | 主 Index Guide（不可用则终止并提示先 `/docs-indexing`） |
| 可选输入 | README.md、AGENTS.md、PRD、源代码 |
| 固定输出 | `{DOC_DIR}/knowledge/{perspective}/{perspective}_knowledge.json`；各视角 `README.md`；`{DOC_DIR}/knowledge/KNOWLEDGE_INDEX.md` |
| 可选输出 | `{DOC_DIR}/knowledge/{perspective}/extraction_report.md`（仅 `--emit-report`） |
| 不产出 | 锚点文档、CHANGELOG、目录树 |

---

## 参数

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--perspectives` | `technical,data,business,product` | 逗号分隔 |
| `--skip-existing` | `true` | 跳过已处理实体；变更涉及文件仍强制重提 |
| `--confidence-threshold` | `medium` | high / medium / low |
| `--emit-report` | `false` | 生成提取报告 |

---

## 预检策略（何时暂停）

默认采用默认参数，不逐项追问。仅在以下情况暂停（**一次只问一个点**）：用户显式改参数或视角子集；`DOC_DIR` 歧义；校验失败需选处理方式；`extraction-rules.md` 未覆盖的边界。

---

## 四阶段与 HARD-GATE

| 阶段 | 名称 | 摘要 | 详见 |
|------|------|------|------|
| 1 | 初始化 | 验证主 Index Guide、输出目录可写、加载内置配置；**完成后触发 Qclose-1** | [builtin-config.md](builtin-config.md) |
| — | **HARD-GATE** | 见 [gates.md](gates.md)；`CONFIRMED` 后解锁阶段 2 | [interaction-gate.md](interaction-gate.md) |
| 2 | 提取 | 按固定顺序执行四视角；后续只读前序 ID，不改前序文件 | [extraction-rules.md](extraction-rules.md) |
| 3 | README 填充 | 先读既有版式，再映射 JSON 刷新数据行 | [readme-fill-spec.md](readme-fill-spec.md) |
| 4 | 归并 | 四 JSON → 验证 → 更新 `KNOWLEDGE_INDEX.md`；跑验证脚本 | [consolidation-spec.md](consolidation-spec.md) |

### 阶段 2 视角顺序

| 顺序 | 视角 | 层级 | 主要输入源 |
|------|------|------|-----------|
| 1 | 技术 | SYS / APP / MS / API | 主 INDEX、源码、接口定义 |
| 2 | 数据 | DS / ENT | 主 INDEX、数据源、实体、MyBatis XML |
| 3 | 业务 | BD / BSD / BC / AGG / AB | 主 INDEX、包 FQCN、技术 MS-* |
| 4 | 产品 | PL / PM / FT / UC | 主 INDEX、README、PRD、技术+业务 ID |

API 须覆盖四类入口：**Dubbo、HTTP、MQ Consumer、Job**，每条 `api_type`。

### 阶段 4 验证命令

```bash
agent/skills/docs-build/scripts/validate-extraction.sh
```

（从仓库根执行，路径以实际为准。）

---

## 核心约束（执行摘要）

| 约束 | 说明 |
|------|------|
| 证据优先 | 每实体 ID 有可验证证据来源 |
| 零幻觉 | 只从已读文件提取，禁止编造 |
| 前缀唯一 | 层级+ID、层级+别名全局唯一 |
| 视角对称 | `KNOWLEDGE_INDEX.md` §1～§4 同轮；README 与 JSON 同源 |
| 幂等可重试 | 支持中断续跑；失败视角可标记 |
| API 四类 | Dubbo / HTTP / MQ Consumer / Job，`api_type` 必填 |
| 边界清晰 | 不生成锚点文档或 CHANGELOG |

完整内置规则见 [builtin-config.md](builtin-config.md)。

---

## 命令示例

```bash
/docs-build
/docs-build --perspectives technical,data
/docs-build --skip-existing false
/docs-build --confidence-threshold high --emit-report
```
