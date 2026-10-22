# sdx-analysis 操作提示

| 情况 | 处理 |
| --- | --- |
| 用户已给 ID、深度、当前段授权 | 直接沿用；只问剩余缺口，不重复向导 |
| 同名 ANALYSIS 已存在 | 先读再局部编辑；不得重新套骨架覆盖 |
| 无知识库或材料很短 | 只补影响当前段的背景，注明证据盲区；不编造基线 |
| 模板缺失、配置层级不符或路径不可写 | 说明具体阻碍；不改全局配置或改投其他层级 |
| 默认校验退出 0 但有警告 | 仍是待审稿；全篇收尾用 --strict 并逐条检查 |
| 从子目录调用脚本 | --file 相对调用目录；脚本路径使用实际安装位置 |
| 系统 bash 太旧 | 选已有 Bash 5+ 运行；不以此次任务名义安装或改默认 shell |

流程见 [workflow](references/workflow.md)，语义决策见 [gates](references/gates.md)，终检见 [quality-checklist](references/quality-checklist.md)。
