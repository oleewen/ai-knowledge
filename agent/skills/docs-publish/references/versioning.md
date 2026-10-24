# 版本规则

`docs-publish` 只维护四层 `DESIGN.md` 的发布版本。脚本通过共享库
[`agent/scripts/lib/version.sh`](../../../scripts/lib/version.sh) 解析和比较版本；不要在技能正文或其他技能中复制解析实现。

## 版本计算

目标格式为 `YYYY.MMdd.patch`。

| 当前状态 | 新版本 |
| --- | --- |
| 四层都是旧格式 `YY.MM.DD`，归一化日期不晚于当天 | 当天 `YYYY.MMdd.0` |
| 当前版本日期等于当天 | 当天日期 + 当前最大 patch + 1 |
| 当前版本日期早于当天 | 当天 `YYYY.MMdd.0` |
| 新旧格式归一化后日期晚于当天 | 停止，核实版本或系统日期；不降低版本 |

四层 `DESIGN.md` 的 `version` 必须存在；解析后必须完全一致。缺失、格式非法或层间不一致时，发布停止。

## 发布标记

正式提交 subject 固定为：

```text
docs-publish: version YYYY.MMdd.patch
```

`/docs-upgrade` 用该 subject 识别模板发布边界，因此不要手工改 subject，也不要用普通提交替代发布提交。
