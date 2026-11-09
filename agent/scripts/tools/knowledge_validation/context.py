"""Configuration and evidence snapshots; never evaluate configuration as shell code."""
from pathlib import Path
import hashlib
import os
import re
import shutil
import subprocess

AGENT = Path(__file__).resolve().parents[3]
LAYERS = {'application', 'system', 'solution', 'company'}


def contained(path, root):
    return path == root or root in path.parents


def git_info(path):
    result = {}
    for key, args in [('commit', ['rev-parse', 'HEAD']), ('version', ['describe', '--tags', '--always'])]:
        p = subprocess.run(['git', '-C', str(path), *args], capture_output=True, text=True)
        result[key] = p.stdout.strip() if p.returncode == 0 else None
    return result


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def resolve(start, bundle=None, layer=None, snapshot=None):
    start = Path(start).resolve()
    cfg = next((p / '.docsconfig' for p in (start, *start.parents) if (p / '.docsconfig').is_file()), None)
    if cfg is None:
        raise ValueError('缺少 .docsconfig；不能猜测文档根')
    if snapshot is not None:
        raw=snapshot.read(cfg)
        values=dict(re.findall(r'^([A-Z_]+)=(.*)$',raw,re.M))
        ar=values.get('AGENT_ROOT','').strip().strip('\"').strip("'")
        ad=values.get('AGENT_DIR','').strip().strip('\"').strip("'")
        if ar and ad:
            snapshot.observe_optional(Path(ar).expanduser()/ad/'configs')
    shell = os.environ.get('KNOWLEDGE_VALIDATION_BASH') or os.environ.get('BASH') or shutil.which('bash')
    script = '''source "$1" || exit 1
docsconfig_bootstrap_validate || exit 1
printf '%s\\0' "$CONFIG_OWNER_ROOT" "$(docsconfig_doc_abs)" "$KNOWLEDGE_TYPE" "$AGENT_ROOT" "$AGENT_DIR" "$WORK_SPACE"
'''
    p = subprocess.run([shell, '-c', script, 'knowledge-validation', str(AGENT / 'scripts/lib/docsconfig.sh')],
                       cwd=cfg.parent, capture_output=True)
    if p.returncode:
        raise ValueError(p.stderr.decode(errors='replace').strip() or '配置解析失败')
    values = p.stdout.decode().split('\0')
    if len(values) != 7:
        raise ValueError('配置解析器未返回完整上下文')
    repo, default, kind, agent_root, agent_dir, workspace = values[:6]
    if Path(agent_dir).is_absolute() or '..' in Path(agent_dir).parts:
        raise ValueError('AGENT_DIR 必须为不越界的相对路径')
    repo = Path(repo).resolve()
    if kind not in LAYERS | {'meta'}:
        raise ValueError('KNOWLEDGE_TYPE 非法或缺失')
    if kind == 'meta' and (not bundle or not layer):
        raise ValueError('元库必须显式指定 --layer 与 --bundle')
    if kind != 'meta' and layer and layer != kind:
        raise ValueError('--layer 与 .docsconfig 逻辑层冲突')
    layer = layer or kind
    if layer not in LAYERS:
        raise ValueError('逻辑层非法')
    target = Path(bundle) if bundle else Path(default)
    if not target.is_absolute():
        target = repo / target
    target = target.resolve()
    if not contained(target, repo) or not target.is_dir():
        raise ValueError('bundle 不存在或越出配置仓库')
    if '.superpowers' in target.parts or ('superpowers' in target.parts and any(x in target.parts for x in ('specs','plans'))):
        raise ValueError('会话目录不能作为知识校验目标')
    return {'repo': str(repo), 'bundle': str(target), 'doc_dir': default, 'layer': layer,
            'knowledge_type': kind, 'agent_root': agent_root, 'agent_dir': agent_dir,
            'workspace': workspace, 'config': str(cfg), 'source_revision': git_info(repo)}


class Snapshot:
    def __init__(self):
        self.files = {}
        self.absent = set()
        self.inventories = {}

    def read(self, path):
        path = Path(path).resolve()
        raw = path.read_bytes()
        self.files.setdefault(str(path), digest(raw))
        return raw.decode('utf-8')

    def observe_optional(self, path):
        path=Path(path).resolve()
        if path.is_file():
            return self.read(path)
        self.absent.add(str(path))
        return None

    def inventory(self, root, paths):
        self.inventories[str(root)]=set(map(str,paths))

    def changed(self):
        changed = [name for name in self.absent if Path(name).exists()]
        if self.inventories:
            import okf_lib
            for root,expected in self.inventories.items():
                actual=set(map(str,okf_lib.iter_bundle_markdown_files(Path(root))))
                if expected!=actual:
                    changed.append(root)
        for name, expected in self.files.items():
            try:
                actual = digest(Path(name).read_bytes())
            except OSError:
                actual = None
            if actual != expected:
                changed.append(name)
        return changed


def rule_baseline(snapshot):
    names = ['okf-spec.md','knowledge-validation.md','knowledge-profile-v2.md',
             'knowledge-governance.md','entity-relations.md','naming-conventions.md',
             'knowledge-reference-rules.md','federation-config.md','knowledge-evidence.md']
    paths = [AGENT / 'knowledge' / name for name in names]
    paths.extend(sorted((AGENT / 'knowledge').rglob('*-meta.md')))
    paths.append(AGENT / 'references/knowledge-layout.md')
    for path in paths:
        snapshot.read(path)
    return {**git_info(AGENT), 'profile': 'ai-knowledge/v2', 'files': {str(p.resolve()):snapshot.files[str(p.resolve())] for p in paths}}
