# TODO-LIST

> 烤干未闭合代办（**仅元仓**仓根）。下游四层见 `{DOC_DIR}/TODO-LIST.md`。契约见 [grilling-skill.md § TODO-LIST](agent/references/grilling-skill.md#todo-list)。勾销即删；无代办时保留本空壳。变更溯源用 git；索引增量锚点 ∈ 目标 `INDEX-GUIDE.md` 内 `<!-- sdx-indexing:indexing_finished_ms=... -->`。
> **已烤条目内的表与路径 = 落地必遵**。未烤条目不得按本文件臆造切分。

## 开放代办

### 统一 superpowers 内容落点（2026-10-29）

- [ ] **验收统一会话材料落点**（已实施并验证，待验收）。
  - 工程根 `.superpowers/{specs,plans,sdd}/`；本工程 2 份规格、7 份计划已迁移，无重名；历史路径文字同步，历史哈希、时间和测试结果保留。
  - 目录外禁止引用新旧会话目录中的任何具体文件；内部互引、目录模式和占位说明允许。必要结论应进入正式知识后再移除会话稿引用；本次未发现需提取的知识库引用。
  - Git 全局忽略 `.superpowers/` 已生效；路径契约、导航、引用隔离及 OKF/正文扫描已同步。引用隔离、OKF、正文链接隔离测试和 bootstrap 回归通过；原两条库外绝对路径已随 sdx-solution 改造修正，Agent 与根/四层正文链接检查通过。

### 清理 @refresh-codex 内容（2026-10-29）

- [ ] **验收退役内容清理**（2026-10-30 已实施，待验收）：按确认删除 8 份命中的历史证据文件；清理旧计划与规格中的相关任务描述，同步存留记录的失效证据引用。当前工作树检索仅保留本待办标题；未改生产代码、测试或 Git 历史。

### 知识库治理契约的工具接入（2026-10-28）

以下按条目状态推进；工具安装、消费库升级与真实实体迁移另行授权。

- [ ] **隔离行为评测已完成，真实消费环境待授权**：已更新受影响评测并验证旧格式兼容与新增契约；真实安装 Agent 资源、升级消费库及刷新索引/可视化尚未执行。
  - 已新增 [10 组隔离行为场景](agent/scripts/tests/behavior-evals/README.md)，覆盖四层安装、旧格式、消费范围、恢复、证据生命周期、升级门禁和重装保护；采用临时 HOME、元库副本、工作区与独立评分。
  - 2026-11-07 首次尝试全部 10 组超时，均为 `not_run`；2026-11-09 修正隔离执行与评分环境后重跑，[10 组均通过](agent/scripts/tests/behavior-evals/results-2026-11-09.json)，每个结果均核验现存 `score.json=passed`。该结果仅覆盖临时夹具，不替代真实消费库安装、升级、索引/可视化刷新；两处模板数据问题与 docs-indexing 缓存污染保持独立待办。

### 统一校验发现的后续问题（2026-11-07）

- [ ] **核实并修订两处知识库数据问题**：解决方案 [BSD-EXAMPLE-L2](solution/knowledge/business/BS/BSD-EXAMPLE/BSD-EXAMPLE-L2/BSD-EXAMPLE-L2.md) 的目录宿主已与正文 parent 对齐并补 `level`，定向校验无结构 `FAIL`；应用 [knowledge/index.md](application/knowledge/index.md) 引用知识目录外的 INDEX-GUIDE 仍待修订。全部修订后重跑统一校验。
- [ ] **处理 docs-indexing 安装测试的既有缓存污染**：测试复制了 2026-10-25 已有的 Python 缓存，导致安装树无缓存断言失败；隔离无缓存副本 43 项通过。核实夹具隔离方式后修复并重跑，删除既有缓存另需确认。

### 系统 MVP 验收与退出条件（2026-10-28）

- [ ] **明确功能测试与里程碑退出的区别**（已实施并验证，待验收）。
  - 在 [FEATURE-EXAMPLE.md](system/features/FEATURE-EXAMPLE.md) §4.2 明确：证据不足或冲突提示测试通过，不豁免上游 ANALYSIS §6.1「高频状态无未决歧义」的退出条件。
  - 已同步 [viz.html](system/viz.html)；系统 bundle 校验 0 错误、2 条既有索引 frontmatter 警告，可视化 55 个概念与源内容一致。
