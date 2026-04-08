# 设计：doc-root 脚本重构（get-doc-root + source-repo-doc-root）

**日期**: 2026-04-08  
**状态**: 已定稿（实现前规格）

---

## 1. 背景与目标

- 将 `.agent/scripts/sdx-doc-root.sh` 重命名为 **`get-doc-root.sh`**，作为知识库根目录（仓库内「文档树首段」）推断的单一实现源。
- 将 `.agent/scripts/sdx-validate-bootstrap.sh` 重命名为 **`source-repo-doc-root.sh`**：负责定位并 source `get-doc-root.sh`，并在同一次初始化中导出 **`DOC_ROOT`** 与 **`REPO_ROOT`**（**不**再单独提供 `get-repo-root.sh`）。
- 推断顺序固定为：**`--doc-root`（CLI 传入的 override）> `.doc-root` 文件 > 目录探测 > 默认 `docs`**。
- 对外主变量名由 `REPO_DOC_ROOT` 统一改为 **`DOC_ROOT`**（绝对路径）。

---

## 2. 非目标

- 不在本变更中扩展「校验知识库目录结构」的逻辑；`source-repo-doc-root.sh` 仍仅为加载与变量导出，**不做**存在性/NFR 式目录强校验（与旧 bootstrap 行为一致）。
- 不提供对已删除文件名 `.sdx-doc-root` 的兼容读取（见 §4）。

---

## 3. 文件与职责

| 文件 | 职责 |
|------|------|
| **`get-doc-root.sh`** | 实现首段解析、`.doc-root` 读取、目录探测与默认值；提供 **`load_doc_root <override> <probe_base>`**（名称可在实现中微调，但语义固定）：解析成功后 **`export DOC_ROOT`** 为规范化绝对路径。可保留与现有 `sdx_resolve_repo_doc_root` 等价的**仅打印路径**的薄封装，仅供极少数不需要 export 的调用方；主路径以 export `DOC_ROOT` 为准。 |
| **`source-repo-doc-root.sh`** | （1）按与旧 `sdx-validate-bootstrap.sh` 相同策略定位 `get-doc-root.sh` 并 **`source`**；（2）若缺失则提供与现有一致的极简兜底（保证存在可调用的 `load_doc_root` 或等价行为）；（3）暴露供各 skill `validate-*.sh` 使用的入口（例如重命名后的 **`load_repo_doc_root_library`**，替代 `sdx_validate_load_doc_root`）；（4）在调用方执行 **`load_doc_root`** 之后，由**本文件**提供 **`export REPO_ROOT`** 的约定： **`REPO_ROOT="$(dirname "$DOC_ROOT")"`**（路径规范化），即合并原计划的独立 `get-repo-root.sh` 行为，**不**新增 `get-repo-root.sh`。 |

**锚点文件**：自任意路径向上查找「仓库根」时，以存在 **`.agent/scripts/get-doc-root.sh`** 为准（替代原 `sdx-doc-root.sh`）。

---

## 4. 推断顺序与输入输出

**顺序（严格）：**

1. **CLI override**：`--doc-root` 对应的首段（语义与现 `sdx_normalize_doc_root_segment` 一致：规范化后取单段）。
2. **`.doc-root` 文件**：在 **git 根**（若可得）与 **probe_base** 下查找 **`.doc-root`**（首行非注释、单行），内容为首段名。
3. **目录探测**：沿用现有 `sdx_probe_doc_root_segment` 的判定规则（`docs/`、`application/`、`system/`、`company/`、`*/knowledge/` 等）。
4. **默认**：`docs`。

**不再作为推断输入：** 环境变量 `REPO_DOC_ROOT`、`SDX_DOC_ROOT`（避免与输出变量名 `DOC_ROOT` 混淆及隐式覆盖）。**不再读取** `.sdx-doc-root`；迁移方式为人工将文件改名为 `.doc-root`。

**输出：**

- **`DOC_ROOT`**：`probe_base` 规范化后的绝对路径 + `/` + 首段，即知识库根目录的绝对路径。
- **`REPO_ROOT`**：由 `source-repo-doc-root.sh` 在 `DOC_ROOT` 已设定后导出为 **`dirname(DOC_ROOT)`**（与「doc 根为仓库根下单一首段」约定一致）。

---

## 5. 调用约定（各 validate / 工具脚本）

- **典型流程**：`source` **`source-repo-doc-root.sh`** → 调用库加载入口（传入 `SCRIPT_DIR` 等与现 bootstrap 一致）→ 调用 **`load_doc_root "$DOC_ROOT_ARG" "$PROBE_BASE"`**（`PROBE_BASE` 一般为 `git rev-parse --show-toplevel` 或约定的仓库根）→ 由 **`source-repo-doc-root.sh` 文档或辅助函数** 完成 **`REPO_ROOT` 的 export**（见 §3，避免调用方重复实现 `dirname`）。
- **`validate-agent-md-links.sh`** 等直接 source `get-doc-root.sh` 的脚本：改为使用 **`DOC_ROOT`** 环境变量名；若需 `REPO_ROOT`，应在 `load_doc_root` 后使用与 `source-repo-doc-root.sh` 相同的 **`REPO_ROOT` 推导**（可 source 同一套小函数，避免复制粘贴），以保持单一事实来源。

---

## 6. 影响面（实现阶段执行）

- 全仓库替换路径与符号引用：`sdx-doc-root.sh` → `get-doc-root.sh`，`sdx-validate-bootstrap.sh` → `source-repo-doc-root.sh`。
- 所有使用 `REPO_DOC_ROOT` 的 shell/Python：改为 **`DOC_ROOT`**（含 `validate-agent-md-links.sh` 内嵌 Python 读取的环境变量名）。
- 文档：`scripts/README.md`、`.agent/README.md`、各 skill 内注释、既有 superpowers 规格中提及旧文件名处，同步更新。
- **破坏性**：`.sdx-doc-root` 必须重命名为 `.doc-root`；依赖环境变量推断 doc 根的用法需改为显式 `--doc-root` 或 `.doc-root` 文件。

---

## 7. 自检（规格质量）

- [x] 无占位 TBD；边界（无单独 `get-repo-root.sh`、变量名 `DOC_ROOT`）已写明。
- [x] `DOC_ROOT` 与 `REPO_ROOT` 导出职责：`get-doc-root.sh` 负责 `DOC_ROOT`；`REPO_ROOT` 在 **`source-repo-doc-root.sh`** 合并导出，与需求一致。

---

## 8. 实现后验证建议

- 在仓库根与各 skill 下执行现有 `validate-*.sh`，确认 `DOC_ROOT` / `REPO_ROOT` 打印与链接校验行为与重构前一致（除变量重命名与 `.doc-root` 文件名外）。
