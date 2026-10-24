# docs-agent 工作流

主线：参数收口 → Index 解析 → 当前单元澄清 → 生成 → 烤干 → 校验。

## 参数

| 参数 | 值 | 说明 |
| --- | --- | --- |
| `output` | `readme` / `agents` / `both` | 目标入口；默认 `both` |
| `mode` | `create` / `update` | 初始化或合并；默认 `update` |
| 写入策略 | `merge` / `overwrite` | 与 `mode` 不一致时先停下确认 |
| 当前单元 | `README.md` / `AGENTS.md` | 默认 README；`output=agents` 时从 AGENTS 开始 |

用户已明确参数时不重复询问。未收口前不写入。

## 1. 解析 Index

按 [execution-spec.md](execution-spec.md) 查找并记录落盘 `INDEX-GUIDE.md` 的相对路径。仓库根优先，其次文档目录。缺失时停止并提示 `/docs-indexing`。

## 2. 最小阅读

以 Index 为地图，仅打开当前入口需要的 §1、§2、§7 及明确点名的路径。README 的目录树只取 Index §2；AGENTS 不复制 Index §3 接口表。

## 3. 处理当前单元

1. 输出公共六项澄清、写入策略和 Index 锚点，标明“当前阶段：意图澄清”。
2. 获写前 `C` 后，按对应模板生成；`update` 合并有效正文和命令。
3. 标明“当前阶段：烤干”，按 [quality-standards.md](quality-standards.md) 与受众矩阵检查。
4. 从当前已加载技能目录运行校验脚本，`--root` 指目标工程，`--output` 指当前文件；报告链接与 Index 结果。两文件均完成后才用 `both` 检查重复度。
5. 当前单元收敛后等待 `C/M/G/S/F`；只有用户推进才开始下一单元。

## 4. 产物分工

- README 面向人类：一句定位、Quick start、项目结构、导航和必要命令。
- AGENTS 面向 AI：角色、约束、查阅顺序和短链；命令事实源留在 README。
- INDEX 面向检索：九章地图与路径精要；不在本技能内改写。

## 5. 校验

```bash
bash "$SKILL_DIR/scripts/validate-guide.sh" --root <repo> --output readme
```

脚本默认报告警告并以错误数作为退出码；需要把警告也视为失败时加 `--strict`。

`SKILL_DIR` 为当前已加载技能的绝对目录；`--output` 可为 readme/agents/both，默认 both 兼容已有调用。单文件校验不要求另一文件存在，不检查其旧问题。
