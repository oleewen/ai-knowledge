"""Ordered local locks and fingerprint-checked, journaled file operations.

JSON is a YAML 1.2 subset. Journals contain manifest metadata and replacement
recipes, never an entity body. These are recoverable steps, not a distributed
transaction; uncooperative editors remain detectable at step boundaries.
"""
from contextlib import ExitStack
import fcntl
import hashlib
import json
import os
from pathlib import Path
import stat
import tempfile
import uuid


def canonical(path):
    p = Path(path).absolute()
    return p.parent.resolve() / p.name


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def fingerprint(path):
    p = Path(path)
    try:
        info = p.lstat()
    except FileNotFoundError:
        return {'kind': 'absent'}
    if stat.S_ISLNK(info.st_mode):
        name=p.name
        names=os.listdir(p.parent)
        if name not in names:
            name=next((n for n in names if (p.parent/n).lstat().st_ino==info.st_ino),name)
        return {'kind': 'symlink', 'target': os.readlink(p), 'entry_name':name}
    if not stat.S_ISREG(info.st_mode):
        raise ValueError(f'目标不是普通文件或软链: {p}')
    return {'kind': 'file', 'sha256': sha(p.read_bytes()), 'mode': stat.S_IMODE(info.st_mode)}


def lock_base(create=True):
    # Outside DOC_DIR: installation may replace DOC_DIR while holding this lock.
    p = Path(tempfile.gettempdir()) / f'ai-knowledge-locks-{os.getuid()}'
    if not create and not os.path.lexists(p): return p
    try:
        p.mkdir(mode=0o700)
    except FileExistsError:
        pass
    st = p.lstat()
    if not stat.S_ISDIR(st.st_mode) or st.st_uid != os.getuid() or stat.S_IMODE(st.st_mode) != 0o700:
        raise ValueError(f'无法确认锁目录所有者/权限: {p}')
    return p


class Locks:
    """Stable, never-unlinked lock files; kernel releases flock on process death."""
    def __init__(self, roots, readonly=False):
        self.roots = sorted({str(Path(r).resolve()) for r in roots})
        self.handles = []
        self.readonly = readonly

    def __enter__(self):
        try:
            for root in self.roots:
                path = lock_base(create=not self.readonly) / (sha(root.encode()) + '.lock')
                if self.readonly and not os.path.lexists(path): continue
                inherited = json.loads(os.environ.get('KNOWLEDGE_WRITE_LOCKS', '{}'))
                if root in inherited:
                    fd = os.dup(int(inherited[root]))
                    expected = path.lstat(); actual = os.fstat(fd)
                    if (expected.st_dev, expected.st_ino) != (actual.st_dev, actual.st_ino):
                        os.close(fd)
                        raise ValueError('继承锁与文档根不符')
                else:
                    flags = os.O_RDONLY if self.readonly else os.O_RDWR | os.O_CREAT
                    fd = os.open(path, flags | os.O_NOFOLLOW, 0o600)
                handle = os.fdopen(fd, 'r' if self.readonly else 'r+', encoding='utf-8')
                self.handles.append((root, path, handle))
                st = os.fstat(fd)
                if not stat.S_ISREG(st.st_mode) or st.st_uid != os.getuid() or st.st_nlink != 1:
                    raise ValueError(f'无法确认锁持有者: {root}')
                try:
                    fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                except BlockingIOError as exc:
                    raise ValueError(f'锁冲突: {root}') from exc
                self.verify()
            return self
        except BaseException:
            self.__exit__(None, None, None)
            raise

    def verify(self):
        for root, path, handle in self.handles:
            a, b = os.fstat(handle.fileno()), path.lstat()
            if (a.st_dev, a.st_ino) != (b.st_dev, b.st_ino):
                raise ValueError(f'锁文件已变化: {root}')

    def pending(self, allowed=None):
        self.verify()
        # Scan origin journals as well, including records received through Git
        # or left behind when a local registry pointer is unavailable.
        for root in self.roots:
            directory=Path(root)/'governance/operations'
            if canonical(directory/'probe') != directory/'probe':
                raise ValueError('操作记录目录含软链')
            for path in directory.glob('*.yaml'):
                if allowed and canonical(path)==canonical(allowed): continue
                try:
                    record=load_journal(path)
                    if record['state']=='complete' and set(record.get('done',[]))=={s['path'] for s in record['steps']}:
                        continue
                except (OSError,ValueError,KeyError,TypeError):
                    raise ValueError(f'未完成操作或操作记录无法核实: {path}')
                raise ValueError(f'未完成操作: {path}；使用操作 ID 显式续办')
        for root, _, handle in self.handles:
            handle.seek(0)
            raw = handle.read()
            if not raw:
                continue
            try:
                marker = json.loads(raw)
                journal = canonical(marker['journal'])
                if allowed and journal == canonical(allowed):
                    continue
                record = load_journal(journal)
                if record['state'] == 'complete' and root in record['roots']:
                    if set(record.get('done',[])) != {s['path'] for s in record['steps']}:
                        raise ValueError('完成状态与步骤不一致')
                    if any(fingerprint(s['path'])!=s['after'] for s in record['steps']):
                        raise ValueError('完成状态与实际文件不一致')
                    if record['limitations']:
                        raise ValueError('完成状态仍有未闭环项')
                    if record['validation']:
                        from .validation import validate_result
                        if not validate_result(record)['complete']: raise ValueError('完成校验未通过')
                    continue
            except (OSError, ValueError, KeyError, TypeError):
                raise ValueError(f'未完成操作或锁状态无法核实: {root}')
            raise ValueError(f'未完成操作: {journal}；使用操作 ID 显式续办')

    def mark(self, journal):
        self.verify()
        for _, _, handle in self.handles:
            handle.seek(0); handle.truncate()
            handle.write(json.dumps({'journal': str(journal)})); handle.flush(); os.fsync(handle.fileno())

    def clear(self):
        self.verify()
        for _, _, handle in self.handles:
            handle.seek(0); handle.truncate(); handle.flush(); os.fsync(handle.fileno())

    def __exit__(self, *args):
        for _, _, handle in reversed(self.handles):
            handle.close()
        self.handles = []


def atomic_bytes(path, raw, mode=0o644):
    path = canonical(path)
    if fingerprint(path)['kind'] not in ('file', 'absent'):
        raise ValueError(f'拒绝非普通文件: {path}')
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp = tempfile.mkstemp(prefix='.federation-', dir=path.parent)
    try:
        with os.fdopen(fd, 'wb') as stream:
            stream.write(raw); stream.flush(); os.fsync(stream.fileno())
        os.chmod(tmp, mode)
        if fingerprint(path)['kind'] not in ('file', 'absent'):
            raise ValueError(f'目标类型已变化: {path}')
        os.replace(tmp, path)
    finally:
        if os.path.lexists(tmp): os.unlink(tmp)


def save_journal(path, record):
    if canonical(path) != Path(path):
        raise ValueError('操作记录目录发生变化')
    expected=record.get('_journal_fingerprint', {'kind':'absent'})
    if fingerprint(path)!=expected:
        raise ValueError('操作记录指纹变化，保留外部日志编辑')
    payload={k:v for k,v in record.items() if not k.startswith('_')}
    atomic_bytes(path, (json.dumps(payload, ensure_ascii=False, indent=2)+'\n').encode())
    record['_journal_fingerprint']=fingerprint(path)


def plan_hash(record):
    keys = ('id', 'origin', 'roots', 'action', 'checks', 'steps', 'validation', 'limitations', 'inventories')
    stable = {k: record[k] for k in keys}
    return sha(json.dumps(stable, ensure_ascii=False, sort_keys=True).encode())


def load_journal(path):
    p = canonical(path)
    if fingerprint(p)['kind'] != 'file':
        raise ValueError('操作记录必须为普通文件')
    raw=p.read_bytes()
    record = json.loads(raw)
    record['_journal_fingerprint']=fingerprint(p)
    if record['_journal_fingerprint'].get('sha256')!=sha(raw): raise ValueError('操作记录读取期间变化')
    if record.get('schema') != 1 or record.get('plan_sha256') != plan_hash(record):
        raise ValueError('操作计划指纹不符')
    origin = Path(record['origin'])
    if canonical(origin/'governance/operations'/f"{record['id']}.yaml") != origin/'governance/operations'/f"{record['id']}.yaml":
        raise ValueError('操作记录目录含软链')
    if p != origin/'governance/operations'/f"{record['id']}.yaml":
        raise ValueError('操作记录位置与发起库不符')
    if str(origin.resolve()) != str(origin) or str(origin) not in record['roots']:
        raise ValueError('非法操作根')
    for step in record['steps']:
        validate_step_path(record, step['path'])
        if step['kind'] not in ('file', 'replace', 'symlink'):
            raise ValueError('未知操作步骤')
    return record


def validate_step_path(record, path):
    p = Path(path)
    if str(canonical(p)) != str(p) or not any(Path(r) in p.parents for r in record['roots']):
        raise ValueError(f'操作路径越界或祖先变化: {p}')
    if 'governance' in p.parts and 'operations' in p.parts:
        raise ValueError('业务步骤不能改操作记录')


def verify_record(record, before_only=False):
    revalidate = record['state'] == 'pending_validation'
    for root, expected in record['inventories'].items():
        if revalidate: continue
        actual = sorted(str(p) for p in Path(root).rglob('*.md') if p.is_file())
        allowed=set(expected)
        if not before_only:
            for step in record['steps']:
                path=Path(step['path'])
                if Path(root) in path.parents and path.suffix=='.md' and fingerprint(path)==step['after']:
                    if step['after']['kind']=='file': allowed.add(str(path))
                    elif step['after']['kind']=='absent': allowed.discard(str(path))
        if actual != sorted(allowed):
            raise ValueError(f'目录指纹变化: {root}')
    steps = {s['path']: s for s in record['steps']}
    for path, expected in record['checks'].items():
        if revalidate and path not in steps: continue
        validate_parent = canonical(path)
        if str(validate_parent) != path:
            raise ValueError(f'路径指纹变化: {path}')
        current = fingerprint(path)
        step = steps.get(path)
        permitted = [expected]
        if step and not before_only:
            permitted.append(step['after'])
            if revalidate or path in record.get('done', []): permitted = [step['after']]
        if current not in permitted:
            raise ValueError(f'指纹变化，保留他人编辑: {path}')
    for step in record['steps']: validate_step_path(record, step['path'])


def apply_step(step):
    path = Path(step['path'])
    if fingerprint(path) == step['after']:
        return
    if fingerprint(path) != step['before']:
        raise ValueError(f'写前指纹变化: {path}')
    if step['kind'] == 'symlink':
        target = step['target']
        path.parent.mkdir(parents=True, exist_ok=True)
        if target is None:
            if path.is_symlink(): path.unlink()
        else:
            tmp = path.parent/('.federation-link-'+uuid.uuid4().hex)
            try:
                tmp.symlink_to(target)
                if fingerprint(path) != step['before']: raise ValueError(f'槽位指纹变化: {path}')
                os.replace(tmp, path)
                old_name=step['before'].get('entry_name',path.name)
                if old_name!=path.name and old_name in os.listdir(path.parent):
                    os.rename(path.with_name(old_name),path)
            finally:
                if tmp.is_symlink(): tmp.unlink()
    else:
        if step['kind'] == 'replace':
            text = path.read_text(encoding='utf-8')
            for before, after in step['replacements'].items(): text = text.replace(before, after)
        else:
            text = step['text']
        raw = text.encode('utf-8')
        if sha(raw) != step['after']['sha256']:
            raise ValueError(f'变更配方与预期指纹不符: {path}')
        atomic_bytes(path, raw, step['after']['mode'])
    if fingerprint(path) != step['after']:
        raise ValueError(f'写后指纹不符: {path}')


class Plan:
    def __init__(self, origin, roots, action):
        origin = Path(origin).resolve()
        self.record = {'schema': 1, 'id': uuid.uuid4().hex, 'origin': str(origin),
                       'roots': sorted({str(Path(r).resolve()) for r in roots}|{str(origin)}),
                       'action': action, 'checks': {}, 'steps': [], 'done': [],
                       'validation': {}, 'limitations': [], 'inventories': {}, 'state': 'planned'}
        self.journal = origin/'governance/operations'/f"{self.record['id']}.yaml"
        if canonical(self.journal)!=self.journal:
            raise ValueError('操作记录路径越界或包含软链')

    def observe(self, path):
        p = canonical(path)
        value = fingerprint(p)
        previous = self.record['checks'].setdefault(str(p), value)
        if previous != value: raise ValueError(f'读取指纹变化: {p}')
        return value

    def _add(self, path, kind, after, **extra):
        p = canonical(path); validate_step_path(self.record, str(p))
        before = self.observe(p)
        if before == after: return
        if any(s['path'] == str(p) for s in self.record['steps']):
            raise ValueError('一个路径只能有一个计划步骤')
        self.record['steps'].append({'path': str(p), 'kind': kind, 'before': before, 'after': after, **extra})

    def file(self, path, text):
        before = self.observe(path)
        if before['kind'] not in ('absent', 'file'): raise ValueError('清单不能是软链或特殊文件')
        self._add(path, 'file', {'kind':'file','sha256':sha(text.encode()),'mode':before.get('mode',0o644)}, text=text)

    def replace(self, path, replacements):
        before = self.observe(path)
        if before['kind'] != 'file': raise ValueError('正文必须是普通文件')
        text = Path(path).read_text(encoding='utf-8')
        for old, new in replacements.items(): text = text.replace(old, new)
        self._add(path, 'replace', {'kind':'file','sha256':sha(text.encode()),'mode':before['mode']}, replacements=replacements)

    def symlink(self, path, target):
        before = self.observe(path)
        if before['kind'] not in ('absent', 'symlink'): raise ValueError('槽位被普通文件/目录占用')
        after = {'kind':'absent'} if target is None else {'kind':'symlink','target':str(target),'entry_name':Path(path).name}
        self._add(path, 'symlink', after, target=target)

    def execute(self, dry_run=False, held=None):
        self.record['plan_sha256'] = plan_hash(self.record)
        if dry_run:
            with Locks(self.record['roots'], readonly=True) as locks: locks.pending()
            verify_record(self.record, before_only=True)
            return {**self.record, 'journal': str(self.journal)}
        with ExitStack() as stack:
            locks = held or stack.enter_context(Locks(self.record['roots']))
            locks.pending()
            verify_record(self.record, before_only=True)
            # Register every root before publishing a journal or touching data.
            # An interrupted registry is unknown and must block, never disappear.
            locks.mark(self.journal)
            try:
                save_journal(self.journal, self.record)
            except (OSError, ValueError):
                if fingerprint(self.journal)['kind']=='absent': locks.clear()
                raise
            return run_record(self.journal, self.record, locks)


def run_record(journal, record, locks):
    revalidate = record['state'] == 'pending_validation'
    try:
        verify_record(record)
        # Completed writes awaiting semantic closure are only revalidated. Their
        # read dependencies may legitimately change in an associated operation.
        steps = [] if revalidate else record['steps']
        for step in steps:
            locks.verify(); verify_record(record)
            apply_step(step)
            if step['path'] not in record['done']: record['done'].append(step['path'])
            record['state'] = 'partial'
            save_journal(journal, record)
        verify_record(record)
        if record['validation']:
            from .validation import validate_result
            validation = validate_result(record)
            record['result'] = validation
            if not validation['complete']:
                record['state'] = 'pending_validation'
                save_journal(journal, record)
                raise ValueError('写入已处理，引用或跨库校验未闭环；使用操作 ID 复核')
        if record['limitations']:
            record['state'] = 'pending_validation'
            save_journal(journal, record)
            raise ValueError('操作仍有未闭环项: '+'; '.join(record['limitations']))
        record['state'] = 'complete'
        save_journal(journal, record)
        locks.clear()
        return {**record, 'journal': str(journal)}
    except (OSError, ValueError, RuntimeError) as exc:
        record['error'] = str(exc)
        if revalidate: record['state'] = 'pending_validation'
        elif record['state'] != 'pending_validation': record['state'] = 'partial'
        try: save_journal(journal, record)
        except (OSError, ValueError): pass  # Preserve external journal edits and propagate the original failure.
        raise type(exc)(f"{exc}；操作 ID: {record['id']}；记录: {journal}") from exc


def resume(journal, dry_run=False):
    record = load_journal(journal)
    if dry_run:
        with Locks(record['roots'], readonly=True) as locks: locks.pending(allowed=journal)
        verify_record(record)
        return {**record, 'journal': str(journal)}
    with Locks(record['roots']) as locks:
        locks.pending(allowed=journal)
        # Never execute a journal changed between reading and acquiring locks.
        if load_journal(journal) != record: raise ValueError('操作记录读取后变化')
        verify_record(record)
        locks.mark(journal)
        return run_record(journal, record, locks)
