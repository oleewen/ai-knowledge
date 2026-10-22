# sdx-analysis 评测裁判

按 [evaluation.md](../references/evaluation.md) 区分发现、协议与产物验证。输入为完整会话、工具记录、前后文件及该例断言；不能只凭最终回复中的承诺判通过。

## 判定

1. 逐条检查 assertions，记录响应位置、工具动作或文件差异。先看实际行为，再看解释。
2. 全部 P0 有证据且通过才通过；P1 记录改进项，不作为额外硬门。
3. 缺少所需证据标 incomplete；尚未运行标 not_run。两者都不是通过或失败。
4. 仅按本例覆盖范围评分。全过的受众检查可以静默；不因未复述整套协议或固定措辞扣分。
5. 非法 F 是协议案例：应加载技能，但不能把覆盖前文解释成 F。普通下游请求检查正确分流，不要求完成下游技能。

## 输出（仅 JSON）

保留 text、passed、evidence；增加 status。未运行示例：

    {
      "status": "not_run",
      "text": "尚未执行本案例。",
      "passed": null,
      "evidence": []
    }

已执行时 status 为 passed、failed 或 incomplete；证据不足时 passed 为 null。每项 evidence 含断言 id、结论与可定位证据。不得编造工具执行、文件产物或通过率。
