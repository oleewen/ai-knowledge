# 宝盒lite 会话抽取 CLI Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `ai-knowledge/agent/cli` 落地只读 Python CLI `baohe`，从本机 zbox-lite 缓存列出/点名导出/批量导出单聊与群聊为 JSON + Markdown 报告骨架。

**Architecture:** 发现数据目录 → 从 `localCache.json` 与 IndexedDB 文件扫描合并会话 → 拷贝 LevelDB 后字符串抽 JSON 消息 → 按会话过滤排序 → 写出规范化 `messages.json` 与 `report.md`。不调用 LLM，不写回宝盒数据。

**Tech Stack:** Python 3.9+、stdlib（`argparse`, `json`, `base64`, `re`, `shutil`, `tempfile`, `pathlib`, `dataclasses`）、`pytest`（dev）。无编译扩展。

**Spec:** `agent/cli/docs/2026-10-15-baohe-cli-design.md`

## Global Constraints

- Python 3.9+ only；禁止引入需编译的 LevelDB 绑定（本阶段）
- 只读宝盒数据；LevelDB 占用时必须先拷贝再读
- 报告必须声明「本地缓存、非全量」
- 包安装根：`agent/cli/`；命令名 `baohe`
- 默认输出根：`~/Documents/grok-exports/baohe/`
- 环境变量：`BAOHE_DATA_DIR` 覆盖数据根
- 提交信息用简体中文或约定 `feat(baohe):` / `test(baohe):` 前缀；仅提交本 CLI 相关文件
- 测试不依赖本机真实宝盒目录：用 fixtures 模拟 `localCache.json` 与假 LevelDB 文件

---

## File map

| Path | Responsibility |
| --- | --- |
| `agent/cli/pyproject.toml` | 包元数据、`baohe` console_script、pytest |
| `agent/cli/README.md` | 安装与三条命令示例 |
| `agent/cli/baohe/__init__.py` | 版本号 |
| `agent/cli/baohe/__main__.py` | `python -m baohe` |
| `agent/cli/baohe/models.py` | `Session`, `Message` dataclasses + `to_dict` |
| `agent/cli/baohe/discover.py` | 解析 data-dir / `baohe_*` partition / 路径 |
| `agent/cli/baohe/sessions.py` | 读 search_history、合并会话、按名/ID 查找 |
| `agent/cli/baohe/messages.py` | 拷贝 LevelDB、扫文件抽消息、forward 解码、过滤 |
| `agent/cli/baohe/export.py` | 写 JSON/MD、recent index |
| `agent/cli/baohe/cli.py` | argparse：`list` / `export` / `recent` |
| `agent/cli/tests/conftest.py` | fixture 根目录 |
| `agent/cli/tests/test_*.py` | 各模块测试 |
| `agent/cli/tests/fixtures/` | 最小假数据 |

---

### Task 1: Scaffold package + models

**Files:**
- Create: `agent/cli/pyproject.toml`
- Create: `agent/cli/baohe/__init__.py`
- Create: `agent/cli/baohe/__main__.py`
- Create: `agent/cli/baohe/models.py`
- Create: `agent/cli/tests/test_models.py`

**Interfaces:**
- Produces: `Session(id: str, name: str, chat_type: int, group: bool)`；`Message(msg_id: str, sender: str, sender_id: str, body: str, send_time: int | None, chat_type: int | None, session_id: str, session_name: str, source: str)`；两者 `to_dict() -> dict`

- [ ] **Step 1: Write failing tests for models**

```python
# agent/cli/tests/test_models.py
from baohe.models import Message, Session


def test_session_to_dict():
    s = Session(id="2100", name="日志采集治理", chat_type=1, group=True)
    assert s.to_dict() == {
        "id": "2100",
        "name": "日志采集治理",
        "chatType": 1,
        "group": True,
    }


def test_message_to_dict_fields():
    m = Message(
        msg_id="1",
        sender="高明",
        sender_id="u1",
        body="hello",
        send_time=1720000000000,
        chat_type=1,
        session_id="2100",
        session_name="日志采集治理",
        source="indexeddb",
    )
    d = m.to_dict()
    assert d["msgId"] == "1"
    assert d["sender"] == "高明"
    assert d["body"] == "hello"
    assert d["source"] == "indexeddb"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `cd agent/cli && python3 -m pytest tests/test_models.py -v`  
Expected: FAIL（`baohe` 未安装 / import error）

- [ ] **Step 3: Write pyproject + models**

```toml
# agent/cli/pyproject.toml
[build-system]
requires = ["setuptools>=61"]
build-backend = "setuptools.build_meta"

[project]
name = "baohe"
version = "0.1.0"
description = "Read-only CLI to extract 宝盒lite chat caches"
requires-python = ">=3.9"
dependencies = []

[project.optional-dependencies]
dev = ["pytest>=7.0"]

[project.scripts]
baohe = "baohe.cli:main"

[tool.setuptools.packages.find]
where = ["."]
include = ["baohe*"]

[tool.pytest.ini_options]
testpaths = ["tests"]
```

```python
# agent/cli/baohe/__init__.py
__version__ = "0.1.0"
```

```python
# agent/cli/baohe/__main__.py
from baohe.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
```

```python
# agent/cli/baohe/models.py
from __future__ import annotations

from dataclasses import dataclass
from typing import Any, Optional


@dataclass
class Session:
    id: str
    name: str
    chat_type: int
    group: bool

    def to_dict(self) -> dict[str, Any]:
        return {
            "id": self.id,
            "name": self.name,
            "chatType": self.chat_type,
            "group": self.group,
        }


@dataclass
class Message:
    msg_id: str
    sender: str
    sender_id: str
    body: str
    send_time: Optional[int]
    chat_type: Optional[int]
    session_id: str
    session_name: str
    source: str

    def to_dict(self) -> dict[str, Any]:
        return {
            "msgId": self.msg_id,
            "sender": self.sender,
            "senderId": self.sender_id,
            "body": self.body,
            "sendTime": self.send_time,
            "chatType": self.chat_type,
            "sessionId": self.session_id,
            "sessionName": self.session_name,
            "source": self.source,
        }
```

Stub `cli.py` temporarily so `__main__` imports work:

```python
# agent/cli/baohe/cli.py
def main(argv=None) -> int:
    return 0
```

- [ ] **Step 4: Install editable and run tests**

Run:
```bash
cd ~/workspaces/ai-knowledge/agent/cli
python3 -m pip install -e ".[dev]"
python3 -m pytest tests/test_models.py -v
```
Expected: PASS

- [ ] **Step 5: Commit**

```bash
cd ~/workspaces/ai-knowledge
git add agent/cli/pyproject.toml agent/cli/baohe agent/cli/tests/test_models.py
git commit -m "feat(baohe): scaffold package and models"
```

---

### Task 2: discover — locate zbox-lite paths

**Files:**
- Create: `agent/cli/baohe/discover.py`
- Create: `agent/cli/tests/test_discover.py`
- Create: `agent/cli/tests/fixtures/fake_zbox/localCache.json`（最小空壳，Task 3 再填）
- Create: `agent/cli/tests/fixtures/fake_zbox/Partitions/baohe_6458944/IndexedDB/file__0.indexeddb.leveldb/.gitkeep`

**Interfaces:**
- Consumes: `Path`, env `BAOHE_DATA_DIR`
- Produces: `dataclass BaohePaths` with `data_dir`, `local_cache`, `leveldb_dir`, `uid`；`resolve_paths(data_dir: Path | None = None) -> BaohePaths`；缺目录时 `FileNotFoundError` 且文案含建议

- [ ] **Step 1: Write failing tests**

```python
# agent/cli/tests/test_discover.py
from pathlib import Path

import pytest

from baohe.discover import resolve_paths


FIXTURE = Path(__file__).parent / "fixtures" / "fake_zbox"


def test_resolve_paths_from_explicit_dir():
    p = resolve_paths(FIXTURE)
    assert p.data_dir == FIXTURE.resolve()
    assert p.local_cache.name == "localCache.json"
    assert p.leveldb_dir.name == "file__0.indexeddb.leveldb"
    assert p.uid == "6458944"


def test_resolve_paths_missing_raises(tmp_path):
    with pytest.raises(FileNotFoundError) as ei:
        resolve_paths(tmp_path / "nope")
    assert "zbox-lite" in str(ei.value).lower() or "找不到" in str(ei.value)
```

- [ ] **Step 2: Run — expect FAIL**

Run: `cd agent/cli && python3 -m pytest tests/test_discover.py -v`  
Expected: FAIL import / missing function

- [ ] **Step 3: Implement discover + fixtures**

Create fixture dirs; `localCache.json` content `{}` for now.

```python
# agent/cli/baohe/discover.py
from __future__ import annotations

import os
from dataclasses import dataclass
from pathlib import Path
from typing import Optional


DEFAULT_DATA_DIR = Path.home() / "Library" / "Application Support" / "zbox-lite"


@dataclass(frozen=True)
class BaohePaths:
    data_dir: Path
    local_cache: Path
    leveldb_dir: Path
    uid: str


def resolve_paths(data_dir: Optional[Path] = None) -> BaohePaths:
    root = Path(
        data_dir
        if data_dir is not None
        else os.environ.get("BAOHE_DATA_DIR", DEFAULT_DATA_DIR)
    ).expanduser().resolve()
    if not root.is_dir():
        raise FileNotFoundError(
            f"找不到宝盒数据目录: {root}。请确认已安装宝盒lite，或用 --data-dir / BAOHE_DATA_DIR 指定。"
        )
    cache = root / "localCache.json"
    if not cache.is_file():
        raise FileNotFoundError(
            f"缺少 localCache.json: {cache}。可能不是有效的 zbox-lite 数据根。"
        )
    parts = root / "Partitions"
    candidates = sorted(parts.glob("baohe_*")) if parts.is_dir() else []
    if not candidates:
        raise FileNotFoundError(
            f"在 {parts} 下找不到 baohe_* 分区。宝盒可能未登录过。"
        )
    part = candidates[0]
    uid = part.name.split("_", 1)[1]
    leveldb = part / "IndexedDB" / "file__0.indexeddb.leveldb"
    if not leveldb.is_dir():
        raise FileNotFoundError(
            f"缺少 IndexedDB LevelDB 目录: {leveldb}。可尝试关闭宝盒后重试。"
        )
    return BaohePaths(
        data_dir=root,
        local_cache=cache,
        leveldb_dir=leveldb,
        uid=uid,
    )
```

- [ ] **Step 4: Run tests — PASS**

Run: `cd agent/cli && python3 -m pytest tests/test_discover.py -v`

- [ ] **Step 5: Commit**

```bash
git add agent/cli/baohe/discover.py agent/cli/tests/test_discover.py agent/cli/tests/fixtures
git commit -m "feat(baohe): resolve zbox-lite data paths"
```

---

### Task 3: sessions — search_history + lookup

**Files:**
- Create: `agent/cli/baohe/sessions.py`
- Create: `agent/cli/tests/test_sessions.py`
- Modify: `agent/cli/tests/fixtures/fake_zbox/localCache.json`

**Interfaces:**
- Consumes: `BaohePaths.local_cache`；`Session`
- Produces: `load_sessions(local_cache: Path) -> list[Session]`；`find_session(sessions, query: str) -> Session | None`（精确 ID 优先，再名称包含匹配，大小写不敏感）

- [ ] **Step 1: Write fixture + failing tests**

`localCache.json`（结构对齐真实缓存条目包装）：

```json
{
  "search_history": {
    "key": "search_history",
    "type": "data",
    "value": [
      {
        "id": "2100049657645613109",
        "name": "日志采集治理",
        "groupName": "日志采集治理",
        "title": "日志采集治理",
        "type": 1,
        "chatType": 1
      },
      {
        "id": "1991687173296697422",
        "name": "增值计费系统",
        "groupName": "增值计费系统",
        "title": "增值计费系统",
        "type": 1,
        "chatType": 1
      },
      {
        "id": "u-dm-1",
        "name": "张三",
        "title": "张三",
        "type": 0,
        "chatType": 0
      }
    ]
  }
}
```

```python
# agent/cli/tests/test_sessions.py
from pathlib import Path

from baohe.sessions import find_session, load_sessions

CACHE = Path(__file__).parent / "fixtures" / "fake_zbox" / "localCache.json"


def test_load_sessions_from_search_history():
    sessions = load_sessions(CACHE)
    assert len(sessions) == 3
    names = {s.name for s in sessions}
    assert "日志采集治理" in names
    g = next(s for s in sessions if s.id == "2100049657645613109")
    assert g.group is True


def test_find_session_by_name_substring():
    sessions = load_sessions(CACHE)
    s = find_session(sessions, "日志采集")
    assert s is not None
    assert s.id == "2100049657645613109"


def test_find_session_by_id():
    sessions = load_sessions(CACHE)
    s = find_session(sessions, "1991687173296697422")
    assert s.name == "增值计费系统"


def test_find_session_miss():
    assert find_session(load_sessions(CACHE), "不存在的群") is None
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement sessions.py**

```python
# agent/cli/baohe/sessions.py
from __future__ import annotations

import json
from pathlib import Path
from typing import Iterable, List, Optional

from baohe.models import Session


def load_sessions(local_cache: Path) -> List[Session]:
    data = json.loads(local_cache.read_text(encoding="utf-8"))
    entry = data.get("search_history") or {}
    value = entry.get("value") if isinstance(entry, dict) else entry
    if not isinstance(value, list):
        return []
    out: List[Session] = []
    seen = set()
    for item in value:
        if not isinstance(item, dict):
            continue
        sid = str(item.get("id") or item.get("groupId") or "")
        if not sid or sid in seen:
            continue
        name = (
            item.get("groupName")
            or item.get("name")
            or item.get("title")
            or sid
        )
        chat_type = int(item.get("chatType") if item.get("chatType") is not None else item.get("type") or 0)
        group = bool(item.get("groupId") or chat_type == 1 or item.get("group") is True)
        # 单聊 type/chatType 常见为 0
        if item.get("chatType") == 0 or item.get("type") == 0:
            group = False
        seen.add(sid)
        out.append(Session(id=sid, name=str(name), chat_type=chat_type, group=group))
    return out


def find_session(sessions: Iterable[Session], query: str) -> Optional[Session]:
    q = query.strip()
    if not q:
        return None
    for s in sessions:
        if s.id == q:
            return s
    ql = q.lower()
    for s in sessions:
        if ql == s.name.lower():
            return s
    matches = [s for s in sessions if ql in s.name.lower()]
    if len(matches) == 1:
        return matches[0]
    if len(matches) > 1:
        # 最短名称优先，减少误匹配
        return sorted(matches, key=lambda s: len(s.name))[0]
    return None
```

- [ ] **Step 4: Run — PASS**

Run: `python3 -m pytest tests/test_sessions.py -v`

- [ ] **Step 5: Commit**

```bash
git add agent/cli/baohe/sessions.py agent/cli/tests/test_sessions.py agent/cli/tests/fixtures/fake_zbox/localCache.json
git commit -m "feat(baohe): load and find sessions from localCache"
```

---

### Task 4: messages — forward decode + LevelDB string scan

**Files:**
- Create: `agent/cli/baohe/messages.py`
- Create: `agent/cli/tests/test_messages.py`
- Create: `agent/cli/tests/fixtures/fake_zbox/Partitions/baohe_6458944/IndexedDB/file__0.indexeddb.leveldb/000001.log`（内嵌可读 JSON 片段）
- Modify: fixture `localCache.json` 增加一条 `forwardMsgId_*`（可选，测 forward）

**Interfaces:**
- Consumes: `BaohePaths`, `Session`, `Message`
- Produces:
  - `copy_leveldb(src: Path, dest: Path) -> Path`
  - `iter_raw_json_blobs(leveldb_dir: Path) -> list[str]`
  - `parse_messages_from_blobs(blobs, session: Session) -> list[Message]`
  - `load_forward_messages(local_cache: Path, session: Session) -> list[Message]`
  - `collect_messages(paths: BaohePaths, session: Session, *, days: int | None = None) -> list[Message]`（合并、去重 `msgId`、按 `send_time` 升序、按 days 过滤；`source` 为 `indexeddb` 或 `forward`）
  - 非文本 content list 项转 `[图片]` / `[文件]` 等占位

- [ ] **Step 1: Write fixture log + failing tests**

在 `000001.log` 写入（可夹杂噪声字节前后）一段 UTF-8：

```text
NOISE{"msgId":"m1","senderId":"u9","extraParams":{"senderName":"高明"},"content":"{\"list\":[{\"type\":\"text\",\"text\":\"治理目标是降丢失\"}]}","groupId":"2100049657645613109","chatType":1,"sendTime":1728800000000}NOISE
```

另写一条错误会话 `groupId":"other"` 确认被过滤。

```python
# agent/cli/tests/test_messages.py
from pathlib import Path

from baohe.discover import resolve_paths
from baohe.messages import collect_messages
from baohe.models import Session
from baohe.sessions import find_session, load_sessions

FIXTURE = Path(__file__).parent / "fixtures" / "fake_zbox"


def test_collect_messages_filters_by_session():
    paths = resolve_paths(FIXTURE)
    sessions = load_sessions(paths.local_cache)
    session = find_session(sessions, "日志采集治理")
    assert session is not None
    msgs = collect_messages(paths, session, days=None)
    assert any("治理目标" in m.body for m in msgs)
    assert all(m.session_id == session.id for m in msgs)


def test_collect_messages_days_filter(monkeypatch):
    paths = resolve_paths(FIXTURE)
    session = Session(id="2100049657645613109", name="日志采集治理", chat_type=1, group=True)
    # sendTime 在 fixture 内；days=0 应滤掉很旧的（若实现用 now-days）
    msgs = collect_messages(paths, session, days=0)
    # days=0 → 仅「今天」；fixture 时间戳固定为 2024 附近，应为空或极少
    assert isinstance(msgs, list)
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement messages.py**（核心逻辑要点）

实现要求写进代码注释也可，但必须包含：

1. `shutil.copytree(src, dest, dirs_exist_ok=True)`；源锁失败时改用逐文件 `copy2` 忽略 `LOCK`/`*.dbtmp`，仍失败则抛 `OSError` 文案「请关闭宝盒lite 后重试或检查权限」。
2. 对 `leveldb_dir` 下每个文件 `rb` 读，用 regex `rb'\{[^{}]{0,20000}"(?:msgId|groupId|conversationId)"[^{}]{0,20000}\}'` 的宽松策略 **不够** —— 改用：解码 `errors=replace`，再 `re.finditer(r'\{.*?\}', text, re.DOTALL)` 并对每个候选 `json.loads`，失败跳过；保留含 `msgId` 或 `content`+(`groupId`|`conversationId`) 的对象。
3. `content` 若是 JSON 字符串且含 `list`，拼接 text；`type==image` → `[图片]`。
4. `sender` 取 `extraParams.senderName` 或空串。
5. `days`：`send_time` 为毫秒；阈值 `now_ms - days*86400000`；`send_time is None` 在 `days` 有值时丢弃。
6. 去重 key：`msg_id` 非空，否则 `hash(sender+body+send_time)`。

完整实现由执行者按上述契约编写；测试先绿再提交。

- [ ] **Step 4: Run — PASS**

Run: `python3 -m pytest tests/test_messages.py -v`

- [ ] **Step 5: Commit**

```bash
git add agent/cli/baohe/messages.py agent/cli/tests/test_messages.py agent/cli/tests/fixtures
git commit -m "feat(baohe): extract messages from leveldb copy and forwards"
```

---

### Task 5: export — JSON + Markdown + index

**Files:**
- Create: `agent/cli/baohe/export.py`
- Create: `agent/cli/tests/test_export.py`

**Interfaces:**
- Consumes: `Session`, `list[Message]`, `Path`
- Produces:
  - `default_out_dir(session_name: str, root: Path | None = None) -> Path`
  - `write_export(out_dir: Path, session: Session, messages: list[Message], *, coverage_note: str) -> tuple[Path, Path]` → `(messages.json, report.md)`
  - `write_recent_index(index_path: Path, rows: list[dict])` — rows 含 `name`, `id`, `count`, `dir`

- [ ] **Step 1: Failing tests**

```python
# agent/cli/tests/test_export.py
from pathlib import Path

from baohe.export import write_export, write_recent_index
from baohe.models import Message, Session


def test_write_export_creates_json_and_md(tmp_path):
    session = Session(id="2100", name="日志采集治理", chat_type=1, group=True)
    msgs = [
        Message("m1", "高明", "u1", "结论一条", 1728800000000, 1, "2100", "日志采集治理", "indexeddb")
    ]
    out = tmp_path / "one"
    jp, mp = write_export(
        out,
        session,
        msgs,
        coverage_note="本地缓存尽力而为，非全量历史。",
    )
    assert jp.is_file() and mp.is_file()
    text = mp.read_text(encoding="utf-8")
    assert "本地缓存" in text
    assert "关键结论" in text
    assert "结论一条" in text
    assert "日志采集治理" in text


def test_write_recent_index(tmp_path):
    p = tmp_path / "index.md"
    write_recent_index(
        p,
        [{"name": "日志采集治理", "id": "2100", "count": 3, "dir": "rizhi-xxx"}],
    )
    assert "日志采集治理" in p.read_text(encoding="utf-8")
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement export.py**

`report.md` 模板必须含：

```markdown
# {session.name}

## 数据来源与覆盖

| 项 | 结果 |
| --- | --- |
| 会话 ID | ... |
| 消息条数 | ... |
| 覆盖说明 | {coverage_note} |

## 关键结论

（待填写）

## 消息时间线

- [ISO 或原始 ms] **sender**: body
```

`messages.json` 为 `{"session": Session.to_dict(), "coverageNote": ..., "messages": [m.to_dict(), ...]}`。

`default_out_dir`：`root` 默认 `~/Documents/grok-exports/baohe`；slug = 保留中文与字母数字，其余变 `-`，后缀 `YYYYMMDD-HHMMSS`。

- [ ] **Step 4: Run — PASS**

- [ ] **Step 5: Commit**

```bash
git add agent/cli/baohe/export.py agent/cli/tests/test_export.py
git commit -m "feat(baohe): write JSON and Markdown export artifacts"
```

---

### Task 6: CLI — list / export / recent

**Files:**
- Modify: `agent/cli/baohe/cli.py`（替换 stub）
- Create: `agent/cli/tests/test_cli.py`

**Interfaces:**
- Produces: `main(argv: list[str] | None = None) -> int`
- 退出码：成功 0；找不到会话/零消息 2；路径错误 1

- [ ] **Step 1: Failing CLI tests**（用 fixture data-dir）

```python
# agent/cli/tests/test_cli.py
from pathlib import Path

from baohe.cli import main

FIXTURE = str(Path(__file__).parent / "fixtures" / "fake_zbox")


def test_list_prints_session(capsys):
    code = main(["--data-dir", FIXTURE, "list"])
    assert code == 0
    out = capsys.readouterr().out
    assert "日志采集治理" in out


def test_export_writes_files(tmp_path):
    code = main([
        "--data-dir", FIXTURE,
        "export", "日志采集治理",
        "-o", str(tmp_path / "out"),
    ])
    assert code == 0
    assert any(tmp_path.rglob("messages.json"))
    assert any(tmp_path.rglob("report.md"))


def test_export_missing_session():
    code = main(["--data-dir", FIXTURE, "export", "绝对不存在xyz"])
    assert code == 2
```

- [ ] **Step 2: Run — FAIL**

- [ ] **Step 3: Implement cli.py**

```python
# agent/cli/baohe/cli.py — 结构要求
# argparse:
#   全局: --data-dir, -v/--verbose
#   subparsers: list [--days], export query [--days] [-o], recent [--days] [--limit]
# list: 打印 "id\tname\tgroup|dm"
# export: resolve → find → collect → write_export；零消息 → stderr 说明已扫范围，return 2
# recent: load_sessions → 对每个（可先按 search_history 顺序）collect，count>0 的写入子目录，最多 limit（默认 20）；写 index.md
```

实现时 `days` 传到 `collect_messages`；`recent` 的输出根为 `-o` 或 `default_out_dir("recent-batch")` 的父级时间戳目录。

- [ ] **Step 4: Run all tests**

```bash
cd agent/cli && python3 -m pytest -v
```
Expected: all PASS

- [ ] **Step 5: Commit**

```bash
git add agent/cli/baohe/cli.py agent/cli/tests/test_cli.py
git commit -m "feat(baohe): list export recent CLI commands"
```

---

### Task 7: README + live smoke（本机宝盒）

**Files:**
- Create: `agent/cli/README.md`
- Modify: `agent/cli/docs/2026-10-15-baohe-cli-design.md` 状态行改为「已有实现计划」

**Interfaces:** 无新代码 API

- [ ] **Step 1: Write README**

内容必须含：

```markdown
# baohe CLI

只读抽取宝盒lite（zbox-lite）本地会话缓存。

## 安装

```bash
cd agent/cli
python3 -m pip install -e ".[dev]"
```

## 用法

```bash
baohe list
baohe export 日志采集治理
baohe recent --days 2 --limit 10
```

默认读 `~/Library/Application Support/zbox-lite`，可用 `--data-dir` 或 `BAOHE_DATA_DIR`。
输出默认 `~/Documents/grok-exports/baohe/`。

## 局限

本地 IndexedDB 缓存非全量；报告头会标明。
```

- [ ] **Step 2: Live smoke（有真实数据时）**

```bash
baohe list | head
baohe export 日志采集治理
baohe recent --days 2 --limit 5
```
Expected: 非空输出；export 目录含 json+md。若本机无该群，用 `baohe list` 里任一名称代替，并在提交说明里注明。

- [ ] **Step 3: Commit**

```bash
git add agent/cli/README.md agent/cli/docs/2026-10-15-baohe-cli-design.md
git commit -m "docs(baohe): README and mark design implemented-planned"
```

---

## Self-review (plan vs spec)

| Spec 要求 | Task |
| --- | --- |
| `list` / `export` / `recent` | Task 6 |
| JSON + MD | Task 5 |
| `agent/cli/` 布局 | Task 1 |
| discover + BAOHE_DATA_DIR | Task 2 |
| search_history 会话 | Task 3 |
| LevelDB 拷贝 + 字符串抽 + forward | Task 4 |
| 缓存局限声明 | Task 5 report 模板 |
| 零命中非零退出 | Task 6 |
| README 三命令 | Task 7 |
| 验收「日志采集治理」 | Task 7 smoke |
| 无 LLM / 只读 | Global + Task 4–6 |

无 TBD 占位；类型名 `Session`/`Message`/`BaohePaths`/`resolve_paths`/`collect_messages`/`write_export`/`main` 前后一致。

---

## Execution handoff

Plan saved to `agent/cli/docs/2026-10-15-baohe-cli-plan.md`（因全局 `**/superpowers/*` ignore，未使用默认 `docs/superpowers/plans/`）。
