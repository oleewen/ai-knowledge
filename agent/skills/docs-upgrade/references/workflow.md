# docs-upgrade 工作流

## 参数向导

按序收口；用户已明确时可跳过对应项：

1. 当前工程（含 `.docsconfig`；通常即 cwd 所属工程）
2. meta 源：默认读 `{DOC_ROOT}/knowledge-links.yaml` 的唯一 `type: meta`；可选 `--meta-path`
3. git ref（默认 `main`；仅 `--ref` CLI 可覆盖）
4. 模式：有有效 `@` → 文件强制对齐；无 `@` → 整树（默认先 dry-run）

参数未收口前，不进入执行。同一次单元不混两模式。

## 当前单元

**一次升级计划** = 一个当前单元（单个 `DOC_ROOT`）。

一次只推进一个工程；不并行多仓。

## 源解析

1. `validate_bootstrap_docsconfig`（或等价）读 `.docsconfig`
2. 缺 config → 硬停，提示 `/docs-install`
3. 读 links；缺唯一 `type: meta` 且无 `--meta-path` → 硬停，列修复选项（补 meta / `--meta-path` / 重跑 install upsert）
4. 展开 `path`；若为 git 仓 → `git fetch` 并对齐 ref；path 无效 → 用 `repository` 临时 clone 到工作目录
5. 结构源根 = `{meta_root}/{doc_dir}/`，其中 `doc_dir` 优先 meta 条，否则 `KNOWLEDGE_TYPE`

## 执行循环：整树

### 1 准备

- Bash 5+、Git
- 中央库可调用本技能 `scripts/docs-upgrade.sh`

### 2 dry-run 清单

```bash
bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh --dry-run [--meta-path PATH] [--ref REF]
```

脚本输出四桶 +「忽略遗留槽位」+「跳过软链」摘要（见 [merge-rules.md](merge-rules.md)）。展示后立即校核，停等 `C/M/S/F`。

### 3 实跑（用户 `C` 后）

1. **备份 + 新增骨架**（机械）：

   ```bash
   bash agent/skills/docs-upgrade/scripts/docs-upgrade.sh --apply-scaffold [--meta-path PATH] [--ref REF]
   ```

   将改路径 mirror 到 `{REPO_ROOT}/.docs-init/upgrade-{stamp}/`，再写入元库新增且本库缺失的允许文件。

2. **结构重填**（Agent）：对「结构重填」桶中每个 `.md`，以元库同路径（或 README 映射）为 H2/H3 骨架，填入本库同标题节正文；产出**未落位节清单**（本库有、元库无的节）。

3. **未落位**（一次一项）：按 [gates.md](gates.md) 逐项确认；仅已确认项写入。

失败则整单停，不静默改桶策略重试。

### 4 写后停顿

1. 校核：`DOC_ROOT` 仍在、links 未丢、备份目录存在（若有写入）
2. 受众维 **A/B**
3. 停下等待 `C/M/S/F`

未过 A/B → 不得宣称单元完成。

## 执行循环：文件强制对齐

### 1 解析 `@`

1. 收集 `@` 文件与目录；目录递归收**所有文件**
2. 校验：`DOC_ROOT` 内路径规范化为相对路径；软链 / 顶层遗留槽位名拒绝；`DOC_ROOT` 外路径拒绝；`*-slots` 根真文件允许
3. 去重；对每条判定动作（见 [merge-rules.md](merge-rules.md) §7）
4. fetch/解析 meta（与整树同源规则）

### 2 总览闸门

展示解析后 N 条及动作类型。停等总览 `C`（名单无误）/ `M` / `S`（取消整单）/ `F`（不扩到整树）。

总览未 `C` 前不得写任一文件。

### 3 逐文件（总览 `C` 后）

对名单中每条**可处理**项（拒绝项只报告）：

1. 展示该文件预览（将 scaffold / 强制重填摘要；`.md` 可含未落位预告）
2. 停等该文件 `C/M/S/F`：`C` 写盘；`S` 跳过本文件继续；`M` 只重开本文件；已写盘不回滚
3. `.md` 强制重填：契约同整树结构重填；未落位仍一次一项
4. 本缺元有：Agent 复制元库该相对路径到目标
5. 非 md 两边都有：不覆盖（总览已标跳过则本步可略）
6. **不**写 `{REPO_ROOT}/.docs-init/`（依赖 git）

### 4 写后停顿

全部预定项处理完（含 S）后：产物校核 → 整单一次 **A/B** → 停等 `C/M/S/F`。未过 A/B → 不得宣称单元完成。

## 禁止路径

- `docs-install.sh --scope=knowledge`（会备份清空 DOC_DIR）
- 静默删除本库独有文件
- 用元库覆盖 `knowledge-links.yaml`
- 文件模式与整树混在同一单元
- 文件模式把 `@` 指向 `DOC_ROOT` 外路径（非允许范围）
