# 参数与基线

先采用用户给定值；仅对缺失或冲突项提问。可以一次汇总参数，用户选定后复述最终值；同一组明确参数无需反复确认。

## 1. 参数

| 参数 | 规则 |
| --- | --- |
| `mode` | `full` 全量；`incremental` 增量。CLI 兼容 `f` / `i` |
| `depth` | `1` 拓扑、`2` 结构、`3` 精读；含义见 [scan-spec.md](scan-spec.md) |
| `output` | 文件名固定为 `INDEX-GUIDE.md`；相对路径从仓库根解析 |
| `since` | incremental 的正整数 epoch 毫秒；显式值优先，否则读目标指南锚点 |

Agent 优先采用 `.docsconfig` 的 `DOC_DIR`；合法仓内相对子路径按 [docsconfig.sh](../../../scripts/lib/docsconfig.sh) 的通用配置校验判断。缺失或无效时建议 `docs`，经用户收口后作为输出根。输出默认为该根下的 `INDEX-GUIDE.md`；不按现存目录静默切换到 `doc/` 或仓库根。

脚本依赖共享 `docsconfig.sh` 的完整配置，解析失败会停止。该依赖不等于 Agent 可以自动补写配置。`--output` 只覆盖输出位置，脚本仍扫描配置解析出的 `DOC_DIR`；目录不存在时不创建空扫描根。

参数未给出时可推荐 `full + depth 2`；首次只看目录可选 `full + depth 1`。已有有效基线时可选 `incremental + depth 2`。深度 3 的成本与范围须说明，不能自行降级。

## 2. 增量基线

基线来源及格式以 [indexing-log-spec.md](indexing-log-spec.md) 为准。缺失或无效时，请用户选择：

1. 改用 full，并保留已选深度与目标路径。
2. 补充有效 since，继续 incremental。
3. 中止。

### 2.0 对人展示时间锚（Agent 输出）

`since`、`since_ms`、`indexing_finished_ms` 对人展示均使用 Asia/Shanghai：`yyyy-MM-dd HH:mm:ss +08（epoch_ms）`。CLI 和 HTML 注释仍存纯数字。全量可写“全量（无 since）”。

```bash
python3 - 1714108800000 <<'TIME'
from datetime import datetime, timedelta, timezone
import sys
ms = int(sys.argv[1])
wall = datetime.fromtimestamp(ms / 1000, timezone(timedelta(hours=8)))
print(wall.strftime('%Y-%m-%d %H:%M:%S +08') + f'（{ms}）')
TIME
```

## 3. 收口示例

“本轮：`mode=full`、`depth=2`、扫描 `docs/`、输出 `docs/INDEX-GUIDE.md`、无 since；先只读预览。”

进入实际写入时，再按 [gates.md](gates.md) 完成当前单元六项清单；不把参数复述当作隐含写入授权。
