# 脚本维护与验证

日常运行只需 [工作流](workflow.md)。修改代码或排查兼容性时再读本页。

## 代码职责

| 文件 | 职责 / 调用方 |
| --- | --- |
| [artifact_checks.py](../scripts/artifact_checks.py) | 写前路径检查、真实 OKF 块定位；复用 docs-build / docs-indexing 的正文解析，须保留相邻技能 |
| [resolve-okf-paths.sh](../scripts/resolve-okf-paths.sh) | 共享配置解析、bundle 覆盖与 viz 路径规则 |
| [okf-indexing.sh](../scripts/okf-indexing.sh)、[okf-validate.sh](../scripts/okf-validate.sh) | refresh 编排与 bundle 校验入口 |
| [inject_frontmatter.py](../scripts/inject_frontmatter.py)、[generate_index.py](../scripts/generate_index.py) | 治理元数据与目录索引 |
| [visualize.py](../scripts/visualize.py)、[validate_viz_index.py](../scripts/validate_viz_index.py) | 可视化生成与产物检查 |
| [validate_bundle.py](../scripts/validate_bundle.py)、[okf_lib.py](../scripts/okf_lib.py) | 概念校验及共享解析、遍历、类型规则 |
| [okf_cross_layer.py](../scripts/okf_cross_layer.py)、[okf_parent.py](../scripts/okf_parent.py) | parent 关系、跨层 HTTP；亦供 `docs-link` 使用 |
| [generate_knowledge_index.py](../scripts/generate_knowledge_index.py) | 转发到 `docs-build` 的兼容入口；保留历史 import 与 CLI，不参与 refresh |
| [bootstrap_system_entities.py](../scripts/bootstrap_system_entities.py)、[bootstrap_company_entities.py](../scripts/bootstrap_company_entities.py) | 一次性示例实体生成；硬编码层级、日期和样例，不能用于目标工程 refresh |
| [relocate_flat_tree.py](../scripts/relocate_flat_tree.py) | 历史 application 示例路径迁移，含移动与清理操作；不属于日常工作流 |

历史工具保留以兼容既有用途，不能因请求 refresh、校验或修复链接而自动执行。共享模块变更须检查 `docs-build` / `docs-link` 调用方。

## 验证

在元库根执行：

```bash
bash agent/skills/docs-okf/tests/run.sh
bash agent/scripts/tests/okf/run.sh
bash agent/scripts/tools/validate-link-reachable.sh
```

- 技能测试覆盖配置门禁、真实入口的 bundle 参数、输出位置、dry-run 不写与失败停止；使用临时工程。
- 共享 OKF 测试覆盖解析、跨层引用、frontmatter、索引、viz 与校验器。
- [行为样本](../evals/evals.json) 由 [grader](../agents/grader.md) 按实际工具轨迹和产物判断；描述命中或源码字符串匹配不能替代运行证据。

## 可视化浏览器回归

生成的 HTML 使用固定版本及 SRI 校验的 Cytoscape、marked、DOMPurify CDN 脚本。Markdown 经净化后显示；marked 或净化器缺失、不支持或失败时显示原始文本。图谱仍需要 Cytoscape 加载成功。

默认测试含 HTML 标题与 JSON 嵌入回归。验证浏览器交互时，按 [test_visualize_security.py](../tests/test_visualize_security.py) 的环境变量说明准备 Node.js/Playwright、Chrome 及固定版本 CDN 文件，再运行：

```bash
OKF_BROWSER_TESTS=1 python3 -B agent/skills/docs-okf/tests/test_visualize_security.py
```

浏览器用本地 CDN 原始字节响应请求并验证 SRI；覆盖元数据、Markdown 危险内容、内部导航及安全降级。不要用自写空桩替代净化库。
