# docs-archive 工作流

交付主线：**参数向导 → 澄清（确认书 = 意图澄清）→ 当前单元落盘 → 烤干 → 用户动作**。

契约：

- 写前澄清：[intent-clarify.md](../../../references/intent-clarify.md)（经确认书承载）
- 单元推进 / `C/M/G/S/F`：[unit-cycle-protocol.md](../../../references/unit-cycle-protocol.md)
- 写后烤干：[grilling-skill.md](../../../references/grilling-skill.md)

## 前置

- 路径：[knowledge-layout.md](../../../references/knowledge-layout.md)
- overview 路径（`system/knowledge/overview/` 或 `company/knowledge/overview/`，可选 `#锚点`）；目标由**表格行链接**解析
- 若环境未安装 `grilling` Skill，则按 grilling-skill fallback

## 参数向导（含探索）

先完成必要探索，再分步澄清；未明则问，**每次一维**；用户已说清则跳过。

1. 「来源 {符} 目标」简写 → 先解析两端（陷阱见 [core-concepts.md](core-concepts.md)、[gotchas.md](../gotchas.md)）
2. **读**来源（文件/目录/章标题/锚点）
3. **读**目标及同级体例（标题级、表、术语表）；标准路径下目标仅由 overview **行内副标题链接**定
4. 按需读 [gates.md](gates.md)、[links-and-index.md](links-and-index.md)

| 维度 | 内容 |
| ---- | ---- |
| 来源范围 | 单文件 / 目录 / 指定章；附件、脚注、历史版 |
| 目标形态 | 单文件节 / 多文件 / 新建+索引（overview 驱动时目标清单多已由当前轮探索得出） |
| 抽象层级 | 摘录 / 要点 / 可对外 |
| 术语风格 | 术语表、禁用词、语体 |
| 冲突策略 | 以来源 / 以目标 / 并列待裁 |
| 产出 | 仅 MD？是否更目录或 changelog |
| 来源清理 | 删已归档 / **仅索引壳**（推荐）/ 不动 |

参数/确认书未收口前，不进入落盘。

## 当前单元

单个目标章节 + 对应 overview 行回写。定义与确认书门禁见 [gates.md](gates.md)。

## 写后默认表

| 对象 | 默认烤干 | 强制升级 |
| --- | --- | --- |
| 单个归档单元（目标章 + overview 回写） | **必须** | 未确认决策落盘；跨单元依赖/批次前提变更；overview 行内链接/目标章/索引路径变更；冲突或来源清理策略变更 |

启发式只可升级为必须，不可把默认「必须」降为跳过。

## 技能步骤

### 1. 澄清（确认书）

确认书即写前意图澄清容器，须并入公共六项并标明「当前阶段：意图澄清」。公共六项在确认书中的落点：

| 公共六项 | 在确认书中的落点 |
| --- | --- |
| 本段/单元目标 | 会话主题 + 本轮归档要达成什么 |
| 范围 / 非范围 | 来源清单 + 不落盘清单 |
| 已知缺口 | 探索中未决项；无则写「无」 |
| 禁止臆测项 | 不得编造的路径、ID、冲突裁决、清理承诺 |
| 写后烤干预判 | 按上表；当前单元默认必须烤干 |
| 写入路径/容器 | 目标清单 + 映射表中的路径/节位 |

archive 特有字段见 [archive-template.md](../assets/archive-template.md)。收口协议见 intent-clarify；未获写前 `C` 不得落盘。

批次确认书收口后，各单元落盘前不再重复六项全清单；仅摘取本单元目标与写入路径。

### 2. 落盘

提取业务含义，去噪；多出处同一事实只留主述；句式与层级服从目标；最小 diff。  
来源不入正文（无 `(来源：…)` 等；追溯留在确认书/冲突清单）。  
回写 overview（按行）：本行归档并自检后删片段，或换「索引壳」占位，**保留行内副标题链接**。

顺序固定：先落目标章节 → 再回写 overview。目标失败则禁止回写 overview。

### 3. 烤干与用户动作

按写后默认表进入烤干；检查体例、断链/悬空、索引壳是否只留导航、冲突是否按确认书处理。动作字母见 unit-cycle-protocol。

## 收尾摘要

列：**改动的文件**、**每文件一句**、**待用户事**。写 `CHANGE-LOG.md` 则**新条插最前**。不自动 `git commit` / `push`（[links-and-index.md](links-and-index.md)）。

## 临时文件（可选）

映射表、冲突清单可放用户于当前确认书指定的路径；无固定文件名要求。
