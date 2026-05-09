# docs-build 设计原则

反模式 [anti-patterns.md](anti-patterns.md)；操作 [gotchas.md](../gotchas.md)。

1. **INDEX 先行** — 无地图不提取
2. **证据** — ID 可追溯已读片段
3. **顺序** — 技术→数据→业务→产品；后序只引用前序
4. **README 与 JSON 一致** — 阶段 3/4 不打架
5. **INDEX 四段同轮**
6. **闸门先于写盘** — Qclose-1、`CONFIRMED`
7. **可验证** — `validate-extraction.sh` + [quality-checklist.md](quality-checklist.md)
