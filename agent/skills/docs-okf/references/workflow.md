# docs-okf 工作流

先收口目标工程、`refresh` / `validate` / `viz` / `dry-run` 模式及可选 bundle。用户已明确的参数不重复询问；解析规则见 [path-resolution.md](path-resolution.md)。

以下在目标工程根运行，`DOC_DIR`、`AGENT_DIR` 取已读取的配置值。运行时需要 Bash 5+ 与 Python 3。

## refresh / dry-run

```bash
bash "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh"
# 指定 bundle 并预览；去掉 --dry-run 才执行
bash "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/okf-indexing.sh" --bundle docs/archive --dry-run
```

refresh 按序调用；每步都使用解析后的 `BUNDLE`：

| 步骤 | 行为 |
| --- | --- |
| `inject_frontmatter.py` | 仅为匹配的治理文档补 frontmatter；跳过已有元数据、实体和保留名 |
| `generate_index.py --recursive` | 根 `index.md` 更新 `okf:begin/end` 块；无 frontmatter 的子目录索引重建，并保留阅读顺序与关联索引；已有 frontmatter 的子目录索引跳过；knowledge 根索引不生成库外导航，并清理旧生成器的上一级索引/说明链接 |
| `visualize.py` | 覆盖目标 bundle 内的 `viz.html` |
| `okf-validate.sh` | 校验概念 frontmatter、ID、章节、链接与 index 条目 |
| `validate_viz_index.py` | 检查目录索引、viz 与 `INDEX-GUIDE.md` 第四章实体导航块 |

`dry-run` 仍核对配置与目录，但只打印上述命令；它不证明产物校验通过。目录遍历跳过隐藏目录与目录软链，避免进入安装树或联邦槽位。

## validate / viz

先在 Bash 5+ 会话中解析路径。`BUNDLE` 可预设为所选路径，空值使用配置默认：

```bash
source "${DOC_DIR}/${AGENT_DIR}/skills/docs-okf/scripts/resolve-okf-paths.sh"
resolve_okf_target "${BUNDLE:-}"
export DOCS_OKF_REPO_ABS="$repo_abs"
export PYTHONDONTWRITEBYTECODE=1
cd "$repo_abs"
```

`validate`：先校验 bundle，成功后校验 index/viz；不生成或修复产物。

```bash
"$BASH" "$OKF_SCRIPTS/okf-validate.sh" --bundle "$BUNDLE" &&
  python3 "$OKF_SCRIPTS/validate_viz_index.py" --bundle "$BUNDLE" --viz "$OKF_VIZ_OUT"
```

`okf-validate.sh` 单独调用只校验 bundle；不要据此宣称 viz 校验通过。

`viz`：只重建可视化，不隐式刷新索引或提取实体。

```bash
python3 "$OKF_SCRIPTS/visualize.py" --bundle "$BUNDLE" --out "$OKF_VIZ_OUT" --name "$OKF_VIZ_NAME"
```

## 失败与结果

- 任一步非零退出即停。refresh 已完成的写入不会自动回滚；报告失败阶段与已写产物，不盲目重复整条流水线。
- 缺失或无效配置按路径解析表分流；实体校验 ERROR 报具体文件与原因。
- 缺 `INDEX-GUIDE.md` 九章骨架交 `docs-indexing`；缺第四章 `docs-build:entity-index` 标记块交 `docs-build`。本技能不补造两者。
- 摘要说明 bundle、index/viz 是否写入、bundle 校验与产物校验各自结果、实体导航块状态；未检查标「未检查」，dry-run 标「仅预览」。
