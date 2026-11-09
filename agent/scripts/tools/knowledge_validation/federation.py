"""Read-only registered federation traversal, scoped identity catalog and consumption view."""
from pathlib import Path
import re
import sys

from .context import AGENT, Snapshot, contained, resolve, git_info
from .frontmatter import scalar
from .identity import Catalog
from .relations import ID, kind

sys.path.insert(0, str(AGENT/'skills/docs-okf/scripts'))
import okf_lib
import okf_cross_layer

PARENT = {'application':'system','system':'solution','solution':'company'}
CHILD = {v:k for k,v in PARENT.items()}


def link_scalar(value):
    value=value.strip()
    if any(ord(c)<32 or ord(c)==127 for c in value):
        raise ValueError('清单标量含控制字符')
    if value.startswith('"'):
        if re.search(r'\\(?![\\"])',value):
            raise ValueError('清单双引号只支持反斜杠和引号转义')
        parsed=scalar(value)
        if not isinstance(parsed,str):
            raise ValueError('清单字段必须为字符串')
        return parsed
    if value.startswith("'"):
        if not re.fullmatch(r"'(?:[^']|'')*'",value):
            raise ValueError('无效清单单引号')
        return value[1:-1].replace("''", "'")
    return value


def parse_entries(text):
    entries=[]; current=None
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith('#') or line.strip() in ('links:', 'links: []'):
            continue
        first=re.fullmatch(r'\s*-\s+([a-z_]+):\s*(.*)',line)
        field=first or re.fullmatch(r'\s+([a-z_]+):\s*(.*)',line)
        if not field or (current is None and not first):
            raise ValueError('无效 knowledge-links 单行字段')
        if first:
            current={}; entries.append(current)
        key,value=field.groups()
        if key in current:
            raise ValueError(f'重复清单字段 {key}')
        current[key]=scalar(value) if key=='entity_ids' else link_scalar(value)
    for entry in entries:
        if entry.get('type') not in ('parent','child','meta','dependency'):
            raise ValueError('非法清单 type')
        if entry['type']=='dependency':
            ids=entry.get('entity_ids')
            if not isinstance(ids,list) or not ids or any(not isinstance(x,str) or not ID.fullmatch(x) for x in ids) or len(set(ids))!=len(ids):
                raise ValueError('dependency entity_ids 须为非空无重复的身份字符串行内列表')
            if entry.get('target_layer') not in ('company','solution','system','application'):
                raise ValueError('dependency target_layer 非法')
            if any(not entry.get(k) for k in ('repository','path','dir','name')):
                raise ValueError('dependency 缺少 repository/path/dir/name')
    if sum(e['type']=='parent' for e in entries)>1:
        raise ValueError('联邦只能登记一个 parent')
    return entries


def read_records(root, layer, snapshot):
    # Reuse structural classification, including invalid entities. Never infer ownership from folders.
    from .core import Report, structure
    probe=Report(); probe.snapshot=snapshot
    rows=[]
    paths=list(okf_lib.iter_bundle_markdown_files(root/'knowledge'))
    snapshot.inventory(root/'knowledge',paths)
    for path in paths:
        if path.is_symlink():
            raise ValueError(f'实体软链未核实: {path}')
        text=snapshot.read(path)
        row=structure(probe,path,root,layer,text,False)
        if row:
            rows.append(row)
    return rows


class World:
    def __init__(self, root, layer, consumers=(), snapshot=None, *, allow_unconfigured=False):
        self.root=Path(root).resolve()
        self.snapshot=snapshot or Snapshot()
        self.records=[]; self.coverage=[]; self.issues=[]; self.entries={}; self.revisions={}
        self.consumer_roots=set(); self.bad_dependencies=set(); self.dependencies={}
        self.readable=set(); self.parents={}; self.layers={}; self.dependency_layers={}
        pending=[(self.root,layer,True)]+[(Path(p).resolve(),None,True) for p in consumers]
        scanned=set(); expanded=set(); processed_entries=set()
        while pending:
            doc,expected,consumer=pending.pop(0)
            if expected and doc in self.layers and self.layers[doc]!=expected:
                self.issue(doc,'FAIL',f'登记层 {expected} 与目标配置层 {self.layers[doc]} 不一致')
                continue
            if consumer: self.consumer_roots.add(doc)
            if (doc,consumer) in expanded:
                continue
            expanded.add((doc,consumer))
            if doc not in scanned:
                scanned.add(doc)
                try:
                    if not doc.is_dir():
                        raise OSError(f'外库不可读: {doc}')
                    has_config=any((p/'.docsconfig').is_file() for p in (doc,*doc.parents))
                    if not has_config and allow_unconfigured and doc==self.root:
                        actual=expected
                    else:
                        ctx=resolve(doc,str(doc),expected,self.snapshot)
                        if doc!=self.root and ctx['knowledge_type']!='meta' and Path(ctx['doc_dir']).resolve()!=doc:
                            raise ValueError('登记 dir 与目标 DOC_DIR 不一致')
                        actual=ctx['layer']
                        self.revisions[str(doc)]=ctx['source_revision']
                    self.layers[doc]=actual
                    text=self.snapshot.observe_optional(doc/'knowledge-links.yaml')
                    entries=parse_entries(text) if text else []
                    self.entries[doc]=entries
                    self.records.extend(read_records(doc,actual,self.snapshot))
                    self.readable.add(doc)
                    self.coverage.append({'root':str(doc),'layer':actual,'status':'PASS'})
                except (OSError,UnicodeError,ValueError,RuntimeError) as exc:
                    status='UNVERIFIED' if isinstance(exc,(OSError,UnicodeError)) else 'FAIL'
                    self.issue(doc,status,str(exc))
                    self.coverage.append({'root':str(doc),'layer':expected,'status':status})
                    continue
            if doc not in self.readable:
                continue
            for entry_number,entry in enumerate(self.entries[doc]):
                typ=entry['type']
                if typ=='meta' or (typ=='child' and not consumer):
                    continue
                if (doc,entry_number) in processed_entries:
                    continue
                processed_entries.add((doc,entry_number))
                try:
                    base=okf_cross_layer.resolve_link_path(doc,entry.get('path',''))
                    target=(base/entry.get('dir','')).resolve()
                    if not contained(target,base) or Path(entry.get('dir','')).is_absolute():
                        raise ValueError('登记 dir 越出仓库')
                    self.snapshot.observe_optional(base/'.docsconfig')
                    expected_layer=entry.get('target_layer') if typ=='dependency' else (PARENT if typ=='parent' else CHILD).get(self.layers[doc])
                    if not expected_layer:
                        raise ValueError(f'{self.layers[doc]} 不允许 {typ}')
                    if typ=='parent': self.parents[doc]=target
                    if typ=='dependency':
                        for eid in entry['entity_ids']:
                            key=(doc,eid)
                            if key in self.dependencies:
                                self.bad_dependencies.add(key)
                                self.issue(doc,'FAIL',f'重复 dependency 身份映射: {eid}')
                            self.dependencies[key]=target
                            self.dependency_layers[key]=expected_layer
                            _leaf = eid.rsplit('/',1)[-1]
                            _scope = next(((r.get('meta') or {}).get('layer_scope') for r in self.records if r['id']==_leaf), None)
                            if okf_lib.hierarchy_first_layer(_leaf.split('-',1)[0],_leaf,_scope)!=expected_layer:
                                self.bad_dependencies.add(key)
                                self.issue(doc,'FAIL',f'{eid} 首次定义层与 target_layer 不一致')
                    if target in self.layers and self.layers[target]!=expected_layer:
                        raise ValueError('登记层与目标配置层不一致')
                    pending.append((target,expected_layer,consumer and typ=='child'))
                except (OSError,UnicodeError,ValueError,RuntimeError) as exc:
                    self.issue(doc,'FAIL',str(exc))
        for entry in self.coverage:
            entry['purpose']='consumer' if Path(entry['root']) in self.consumer_roots else 'lookup'
        self.catalog=Catalog(self.records,self.owner_candidates)

    def issue(self,root,status,evidence):
        self.issues.append({'root':str(root),'status':status,'evidence':evidence})

    def scope(self, source, identity):
        root=source['root']
        key=(root,identity)
        if key in self.bad_dependencies:
            return set(),'dependency 重复或层级冲突'
        scope={root}; current=root
        while current in self.parents and self.parents[current] not in scope:
            current=self.parents[current]; scope.add(current)
        if key in self.dependencies: scope.add(self.dependencies[key])
        # Downward references are resolved only inside declared consumer traversal coverage.
        scope.update(self.consumer_roots)
        if key in self.dependencies:
            destination=self.dependencies[key]
            if destination not in self.readable or self.layers.get(destination)!=self.dependency_layers[key]:
                return set(),'登记目标库不可读或配置层未核实；不回退其他库'
            scope={destination}
        return scope,None

    def owner_candidates(self, source, identity, candidates):
        scope,error=self.scope(source,identity)
        return [] if error else [r for r in candidates if r['root'] in scope]

    def target(self, source, identity):
        root=source['root']; key=(root,identity)
        scope,error=self.scope(source,identity)
        if error: return None,'UNVERIFIED',error
        candidates=[r for r in self.catalog.records if r['root'] in scope and
                    (r.get('full_id')==identity if '/' in identity else r['id']==identity)]
        if len(candidates)==1:
            row=candidates[0]
            result=self.catalog.resolve(row.get('full_id') or identity)
            if result[1]=='PASS': return result
        if not candidates:
            scope_by_id={r['id']:(r.get('meta') or {}).get('layer_scope') for r in self.catalog.records}
            target_layer=okf_lib.hierarchy_first_layer(kind(identity, scope_by_id),identity,scope_by_id.get(identity.rsplit('/',1)[-1]))
            expected=self.dependencies.get(key)
            if expected and expected not in self.readable:
                return None,'UNVERIFIED','登记目标库不可读或配置未核实'
            if target_layer==self.layers.get(root) or (expected and expected in self.readable) or any(self.layers.get(r)==target_layer for r in scope if r in self.readable):
                return None,'FAIL','可读声明范围内未找到目标'
        return None,'UNVERIFIED','声明范围内目标不唯一、归属未核实或来源未覆盖'

    def consumption(self):
        result=[]; seen=set()
        for row in self.records:
            if row['root'] not in self.consumer_roots or kind(row['id'])!='PD': continue
            for verb,target,_ in row['edges']:
                if verb!='uses_to' or kind(target)!='SYS': continue
                key=(str(row['path']),target)
                if key in seen: continue
                seen.add(key)
                dest,status,evidence=self.target(row,target)
                if not row['valid']:
                    status='UNVERIFIED'; evidence='消费声明实体结构未通过'
                result.append({'source':row['id'],'target':target,'source_path':str(row['path']),
                               'target_path':str(dest['path']) if dest else None,
                               'status':status,'evidence':evidence,'derived':True})
        return result


def for_bundle(root, layer=None, consumers=()):
    """Adapter for existing generators; use configuration or declared entity metadata, never folder names."""
    root=Path(root).resolve()
    if layer is None:
        cfg=next((p/'.docsconfig' for p in (root,*root.parents) if (p/'.docsconfig').is_file()),None)
        if cfg:
            configured=okf_cross_layer._config_values(cfg).get('KNOWLEDGE_TYPE')
            if configured!='meta': layer=configured
        if layer is None:
            layers=set()
            for path in okf_lib.iter_bundle_markdown_files(root/'knowledge'):
                if path.is_symlink(): continue
                meta,_=okf_lib.parse_frontmatter(path.read_text(encoding='utf-8'))
                if meta.get('id') and meta.get('layer_scope'): layers.add(meta['layer_scope'])
            if len(layers)==1: layer=next(iter(layers))
    return World(root,layer,consumers,allow_unconfigured=True)
