# docs-link 工作流

当前单元与授权见 [gates.md](gates.md)。脚本 `--help` 给出完整 CLI；以下说明影响执行决策的语义。

## 解析与预检

| 参数/状态 | 处理 |
| --- | --- |
| 源工作区 | cwd 必须为 company、solution 或 system 的 Git 根；核对 `.docsconfig` 与实际路径 |
| 本地 target | 首次 link 必须提供目标 Git 根；目标层级须恰好下一层，已有 `.docsconfig` 与 `knowledge-links.yaml` |
| remote URL | 只能使用源清单已登记的 child URL，通过该条 `path` 定位本地仓；不发起网络操作 |
| 名称 | `--app-name` 对三种目标层均有效；优先级为显式值、已有 `name`、目标目录名；转小写，允许 `a-z0-9._-` 且首位为字母或数字 |
| 重复 link | 更新原 identity，不追加；保留已有 label。改名须预览旧软链移除和新软链建立，其他 child 占用名称则停止 |
| 配置与清单 | 双边工作区边界、必填字段、唯一 parent、child identity/name 均在写入前检查 |
| 槽位冲突 | 普通文件/目录、父目录软链、指向其他目录的现有软链均停止，先核对归属 |

脚本接受 `--path` 作为弃用别名；重复目标、空值或 unlink 搭配 `--app-name/--rewrite-http` 会失败。脚本省略 `--dry-run` 即写入；对话授权由调用方负责。

## 预览与执行

1. 运行单目标 `--dry-run`，列出源/目标 links 路径、identity、name、槽位映射；开启 HTTP 改写时还须说明旧/新 parent 与文件范围。
2. 确认预览及授权覆盖当前参数，再去掉 `--dry-run`。参数变化后重做预览。
3. 读回验证：link 的源 child 与目标 parent 相互对应，槽位指向目标文档，改名后的旧槽位消失；unlink 的匹配 child/parent 与槽位消失。两种动作均须保留 meta 和无关条目；失联目标按下节报告。
4. 面向联邦维护者给出结果：模式、两侧清单、槽位、正文变化、未完成项。受众 A/B 见 [audience-and-language.md](../../../references/audience-and-language.md)。

## 换父、失联与失败

- **换父**：目标 parent 会替换为当前源。旧源清单不在本单元内，须列为待注销项；另一个源仓的清理需另立单元。不开启 `--rewrite-http` 时正文保持原样。
- **HTTP 改写**：只调用 `docs-okf/scripts/okf_parent.py`；先预览，再在授权内执行。仅处理目标 `knowledge` 下 Markdown 的旧前缀，越界软链会被拒绝；无旧 parent 时没有改写来源。不能宣称扫描过的文件都已修改。
- **失联 unlink**：目标路径、配置或清单缺失时，可按已登记 identity 处理源侧并移除槽位；明确标记“目标侧未更新”。目标配置存在但无效时停止，不假定其失联。
- **中途失败**：预检不等于跨文件事务。磁盘错误、权限变化或进程中断可能留下部分变更；停止并对照实际两侧清单、槽位和正文报告，不盲目重试或声称完成。

不自动迁移旧格式、不删除真实槽位目录。环境与兼容问题见 [gotchas.md](../gotchas.md)。
