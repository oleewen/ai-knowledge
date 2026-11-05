# docs-okf 工作流

先收口目标工程、`refresh` / `validate` / `viz` / `dry-run` 模式及可选 bundle。用户已明确的参数不重复询问；解析规则见 [path-resolution.md](path-resolution.md)。

验收遵守[统一校验规范](../../../knowledge/knowledge-validation.md)：明确逻辑层、文档根、范围完整性、规则与源快照、身份上下文，分别报告结构、确定性关系、必需引用及事实真实性。**工具尚未统一实现**，下列命令只证明各自实际覆盖项；缺口按该规范补核，不新增 CLI 参数或把脚本成功当作全量合规。

以下在目标工程根运行，`DOC_DIR`、`AGENT_DIR` 取已读取的配置值。运行时需要 Bash 5+ 与 Python 3。

## refresh / dry-run

写入前检查 bundle 是否包含 `governance/evidence/`、Profile 采用记录或操作记录等新治理元数据。旧生成器尚未按新容器分型；不能保证这些文件不被误收为实体图或台账时，停止受影响的 refresh/viz 生成，报告工具兼容缺口并保留原产物。仅不受该缺口影响的既有范围继续按原工作流执行，不凭人工校验通过绕过生成限制。

```bash
bash "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh"
# 指定 bundle 并预览；去掉 --dry-run 才执行
bash "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh" --bundle docs/archive --dry-run
```

refresh 按序调用；每步都使用解析后的 `BUNDLE`：

| 步骤 | 行为 |
| --- | --- |
| `artifact_checks.py` | 首写前检查输出路径与根 OKF 标记；文件软链、越出 bundle 的父路径、非普通输出或残缺/重复真实块均停止 |
| `inject_frontmatter.py` | 仅为匹配的治理文档补 frontmatter；跳过已有元数据、实体和保留名 |
| `generate_index.py --recursive` | 根 `index.md` 更新 `okf:begin/end` 块；无 frontmatter 的子目录索引重建，并保留阅读顺序与关联索引；已有 frontmatter 的子目录索引跳过；knowledge 根索引不生成库外导航，并清理旧生成器的上一级索引/说明链接 |
| `visualize.py` | 覆盖目标 bundle 内的 `viz.html` |
| `okf-validate.sh` | 执行现有 bundle 检查；错 type 判型、任意 DOC_DIR 的逻辑层、宿主内身份、关系语义及必需链接仍按统一规范补核 |
| `validate_viz_index.py` | 检查真实索引/导航标记，解析唯一 JSON 数据块；核对当前 bundle 的概念身份、内容和边，拒绝陈旧、缺失、多余、重复键或无效数据 |

`dry-run` 仍核对配置与目录，但只打印上述命令；它不证明产物校验通过。目录遍历跳过隐藏目录与目录软链，避免进入安装树或联邦槽位。

按[会话路径契约](../../../references/session-spec-path.md)，扫描排除整个 `.superpowers/`，并兼容排除历史 `superpowers/specs/`、`superpowers/plans/` 子树；起点位于排除目录内时也生效。该规则独立于 Git 忽略配置，不扩展到普通 `specs/`、`plans/`。各执行入口在扫描或写入前检查 bundle 的原始路径与真实路径，拒绝显式指定被排除目标（包括软链别名和下述纯工作稿容器）；refresh 在首写预检即停止。索引的显式 `--dir` 同样拒绝被排除目标。普通 bundle 目录软链仍可使用。

`superpowers` 若至少含一个真实 `specs/` 或 `plans/` 子目录，且直接子项全部为这两个目录，则视为纯工作稿容器，不生成空索引、不加入自动导航。有入口、其他文件/目录或软链时保留容器。含工作稿目录的容器已有 `index.md` 时原文保留，不判断人工或生成来源；已有 README 不变，无 index 时仍可生成过滤工作稿导航的索引。历史入口中的正文链接不在本流程自动清理。

根索引仅更新真实正文中的唯一 OKF 块，排除元数据与代码示例，保留块外字节及换行。写入入口不跟随文件软链；遇到旧产物冲突时报告具体路径，不自动删除或替换软链。校验器也要求当前 JSON 格式，旧版内联 JavaScript 产物需在获得刷新授权后重建。

## validate / viz

先在 Bash 5+ 会话中解析路径。`BUNDLE` 可预设为所选路径，空值使用配置默认：

```bash
source "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/resolve-okf-paths.sh"
resolve_okf_target "${BUNDLE:-}"
export DOCS_OKF_REPO_ABS="$repo_abs"
export PYTHONDONTWRITEBYTECODE=1
cd "$repo_abs"
```

`validate`：先执行现有 bundle 检查，成功后校验 index/viz；不生成或修复产物。非零时保留原始结果并按下节逐项判定；仅已证实的治理元数据格式误报可转人工补核，不能豁免其他错误。工具未覆盖的断言另补核，未补核标为未执行；后续工具因前序失败而未运行时如实报告。

```bash
"$BASH" "$OKF_SCRIPTS/okf-validate.sh" --bundle "$BUNDLE" &&
  python3 "$OKF_SCRIPTS/validate_viz_index.py" --bundle "$BUNDLE" --viz "$OKF_VIZ_OUT"
```

`okf-validate.sh` 单独调用只提供其现有 bundle 检查结果；不要据此宣称 viz 或完整合规通过。必需本地引用失败须阻断，不能沿用工具警告等级降为提示；补查工具与人工路径见[工具现状与补核](../../../knowledge/knowledge-validation.md#工具现状与补核)。

`viz`：只重建可视化，不隐式刷新索引或提取实体。

```bash
python3 "$OKF_SCRIPTS/visualize.py" --bundle "$BUNDLE" --out "$OKF_VIZ_OUT" --name "$OKF_VIZ_NAME"
```

## 失败与结果

- 任一步非零退出即停自动流水线，保留原始诊断与退出结果。refresh 已完成的写入不会自动回滚；报告失败阶段与已写产物，不盲目重复整条流水线。
- 旧校验器会拒绝无 frontmatter 的 EVID 等治理元数据。只有逐项确认是该分型误报后，才按[统一补核规则](../../../knowledge/knowledge-validation.md#工具现状与补核)人工检查并单列结论；脚本仍报告非零，其他错误不得一并豁免。生成兼容未解决时仍停止受影响生成。
- 缺失或无效配置按路径解析表分流；实体校验 ERROR 报具体文件与原因。
- 缺 `INDEX-GUIDE.md` 九章骨架交 `docs-indexing`；缺第四章 `docs-build:entity-index` 标记块交 `docs-build`。本技能不补造两者。
- 摘要说明 bundle、index/viz 是否写入、实际工具结果、人工补核及实体导航块状态；按统一规范区分通过、失败、待核实、不适用和未执行，dry-run 标「仅预览」。
- 外库不可读可报告「本地通过、跨库待核实」；相关删除、迁移、注销保持未闭合。模板/示例与业务实体分开报告；兼容证据缺失时不宣称升级完成。
