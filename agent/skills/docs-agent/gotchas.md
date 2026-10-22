# docs-agent 易错点

## 写前

- 未完成六项澄清或未获写前 `C`，不得写入。
- 写前澄清不是 grilling；写后才进入烤干。
- `both` 不是双文件批写；一次只处理一个当前单元。

## Index 与探索

- 优先读取磁盘 Index；仓库路径优先于文档目录，命中即停。
- 四路径都无 Index 时停下，转 `/docs-indexing`，不猜结构。
- 以 Index 为地图做最小阅读，不通读全仓。

## 生成

- README 先于 AGENTS；目录树只来自 Index §2。
- AGENTS 不复制 Index §3、命令百科或 README 长段。
- `update` 合并，不全量抹除；不确定的职责或覆盖边界先停下。

## 验收

- 运行 `validate-guide.sh`；核对 AGENTS 首条 Index 链与实际路径一致。
- 受众、链接、重复度任一未通过，不宣称烤干收敛。
