# TODO-LIST

> 烤干未闭合代办（**仅元仓**仓根）。下游四层见 `{DOC_DIR}/TODO-LIST.md`。契约见 [grilling-skill.md § TODO-LIST](agent/references/grilling-skill.md#todo-list)。勾销即删；无代办时保留本空壳。变更溯源用 git；索引增量锚点 ∈ 目标 `INDEX-GUIDE.md` 内 `<!-- sdx-indexing:indexing_finished_ms=... -->`。
> **已烤条目内的表与路径 = 落地必遵**。未烤条目不得按本文件臆造切分。

## 开放代办

### 知识库治理契约的工具接入（2026-10-28）

本轮已修订规范；以下实现与行为验证尚未执行，不属于本轮文档修订的完成声明。

- [ ] **统一实体校验入口与分项结果**：按 [统一校验规范](agent/knowledge/knowledge-validation.md) 接入结构、关系、引用、显式逻辑层和待核实状态；覆盖错 type/缺 id、任意 DOC_DIR、必需断链及外库不可读场景。
- [ ] **接入 APP/MS/API 完整身份与消费关系**：按 [身份规范](agent/knowledge/naming-conventions.md#身份范围与限定引用) 更新共享解析、查重、路径生成、导航和可视化；验证跨 APP 的同名 MS/API、身份迁移、PD→SYS 单侧声明及反向派生；迁移真实实体前另行核实范围和授权。
- [ ] **实现消费定位、并发与联邦恢复**：按 [联邦契约](agent/knowledge/federation-config.md) 支持 dependency 条目、本机锁、操作记录、冲突检测和部分失败续办；注销须验证引用降级，Git 集成后复核双边一致性。
- [ ] **接入来源证据与升级兼容检查**：按 [证据登记](agent/knowledge/knowledge-evidence.md) 和 [升级流程](agent/skills/docs-upgrade/references/workflow.md) 验证来源变更定位、有效依赖解除、未提交来源可恢复性及真实实体规则迁移；不能用模板更新成功替代整体兼容通过。
- [ ] **同步行为评测与消费环境**：工具接入后更新受影响评测/测试，验证旧格式兼容与新增契约；按授权再安装 Agent 资源、升级消费库及刷新索引/可视化。本轮未改这些产物或发布版本。

### 系统 MVP 验收与退出条件（2026-10-28）

- [ ] **明确功能测试与里程碑退出的区别**（已实施并验证，待验收）。
  - 在 [FEATURE-EXAMPLE.md](system/features/FEATURE-EXAMPLE.md) §4.2 明确：证据不足或冲突提示测试通过，不豁免上游 ANALYSIS §6.1「高频状态无未决歧义」的退出条件。
  - 已同步 [viz.html](system/viz.html)；系统 bundle 校验 0 错误、2 条既有索引 frontmatter 警告，可视化 55 个概念与源内容一致。
