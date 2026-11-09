"""Strict writable manifest subset and identity-verified dependency plans."""
import json
from pathlib import Path
import re

from knowledge_validation.context import Snapshot, resolve
from knowledge_validation.federation import World, parse_entries, link_scalar
from .operations import Plan, fingerprint

FIELDS = {'type','repository','path','dir','name','label','target_layer','entity_ids'}


def read(path, maintenance=False):
    path=Path(path)
    if fingerprint(path)['kind']=='absent': return []
    if fingerprint(path)['kind']!='file': raise ValueError(f'清单必须为普通文件: {path}')
    text=path.read_text(encoding='utf-8')
    header=False; empty=False; indent=None; field_indent=None; rows=[]; row=None
    for line in text.splitlines():
        if not line.strip() or line.lstrip().startswith('#'): continue
        if re.fullmatch(r'links:\s*(\[\])?\s*(?:#.*)?',line):
            if header: raise ValueError('重复 links')
            header=True; empty='[]' in line; continue
        if not header or empty: raise ValueError('清单缺少 links 或空列表后存在条目')
        first=re.fullmatch(r'( *)-( +)([a-z_]+):\s*(.*)',line)
        following=re.fullmatch(r'( +)([a-z_]+):\s*(.*)',line)
        if first:
            depth=len(first[1]); indent=depth if indent is None else indent
            if depth!=indent: raise ValueError('条目缩进不一致')
            field_indent=depth+1+len(first[2]); key=first[3]
            row={}; rows.append(row)
        elif following and field_indent==len(following[1]): key=following[2]
        else: raise ValueError('清单结构或缩进不合法')
        if maintenance:
            if key in row:
                if key=='type': raise ValueError('重复 type')
                row['_invalid']=True
            if key not in FIELDS: row['_invalid']=True
            value=first[4] if first else following[3]
            try: row[key]=link_scalar(value)
            except ValueError:
                if key=='type': raise
                row['_invalid']=True
        elif key not in FIELDS: raise ValueError(f'未知或旧清单字段: {key}')
    if not header: raise ValueError('缺少 links')
    if maintenance:
        if any(e.get('type') not in ('parent','child','meta','dependency') for e in rows):
            raise ValueError('非法清单 type')
        return rows
    entries=parse_entries(text)
    for e in entries:
        if not e.get('path'): raise ValueError('清单条目缺少 path')
        if e['type']!='dependency' and any(k in e for k in ('entity_ids','target_layer')):
            raise ValueError('消费字段只能用于 dependency')
    return entries


def render(entries):
    if not entries: return 'links: []\n'
    result=['# 知识库建联清单（由联邦写入工具维护）','links:']
    for entry in entries:
        result.append('  - type: '+entry['type'])
        for key,value in entry.items():
            if key=='type': continue
            if key not in FIELDS: raise ValueError('未知清单字段')
            if key=='entity_ids':
                encoded='['+', '.join(json.dumps(v,ensure_ascii=False) for v in value)+']'
            else:
                if not isinstance(value,str) or any(ord(c)<32 or ord(c)==127 for c in value):
                    raise ValueError('清单字段必须是无控制字符的单行字符串')
                encoded=json.dumps(value,ensure_ascii=False)
            result.append(f'    {key}: {encoded}')
    text='\n'.join(result)+'\n'
    parse_entries(text)
    return text


def context(doc, snapshot=None):
    ctx=resolve(Path(doc),snapshot=snapshot)
    if Path(ctx['doc_dir']).resolve()!=Path(doc).resolve(): raise ValueError('目标必须是配置 DOC_DIR')
    return ctx


def observe_snapshot(plan, snapshot):
    if snapshot.changed(): raise ValueError('预检期间来源指纹变化')
    for path,value in snapshot.files.items():
        current=plan.observe(path)
        if current.get('sha256')!=value: raise ValueError('来源指纹变化')
    for path in snapshot.absent: plan.observe(path)
    for root, paths in snapshot.inventories.items():
        plan.record.setdefault('inventories',{})[root]=sorted(paths)


def validate_paths(doc, entries):
    from knowledge_validation.federation import okf_cross_layer
    for e in entries:
        # Bootstrap may clone a local Git repository and retain that origin for
        # its meta source. Ownership and dependency entries still require URLs.
        if not e.get('repository') or (e['type']!='meta' and not re.match(r'^(https?://|ssh://|[^\s/@]+@[^\s/:]+:)',e['repository'])):
            raise ValueError('repository 须为 Git remote URL')
        base=okf_cross_layer.resolve_link_path(Path(doc),e['path'])
        directory=e.get('dir','')
        if directory and (Path(directory).is_absolute() or '..' in Path(directory).parts or not (base/directory).resolve().is_relative_to(base)):
            raise ValueError('dir 越出登记仓库')


def active_references(world, ids, roots=None):
    """Fail closed for active references; evidence lifecycle remains a separate tool."""
    findings=[]
    roots=set(world.consumer_roots if roots is None else roots)
    for root in sorted(roots):
        knowledge_paths=sorted((root/'knowledge').rglob('*.md'))
        world.snapshot.inventory(root/'knowledge',knowledge_paths)
        for path in knowledge_paths:
            if path.is_symlink(): raise ValueError('引用扫描拒绝实体软链')
            text=world.snapshot.read(path)
            for eid in ids:
                if re.search(r'(?<![\w/-])'+re.escape(eid)+r'(?![\w/-])',text):
                    findings.append(f'{path}: 有效引用 {eid}')
        from knowledge_validation.evidence import blockers
        findings.extend(blockers(root,ids,world.snapshot))
    return findings


def dependency_plan(source, target, repository, ids, *, remove=False, clear=False, consumers=()):
    source=Path(source).resolve(); target=Path(target).resolve()
    snapshot=Snapshot(); sc=context(source,snapshot); tc=context(target,snapshot)
    source_file=source/'knowledge-links.yaml'
    plan=Plan(source,[source,target], 'dependency-remove' if remove else 'dependency-add')
    plan.observe(source_file)
    entries=read(source_file); validate_paths(source,entries)
    world=World(source,sc['layer'],consumers,snapshot)
    if any(i['status']!='PASS' for i in world.issues):
        raise ValueError('登记范围存在冲突或外库未核实: '+str(world.issues))
    from knowledge_validation.federation import okf_cross_layer
    matches=[e for e in entries if e['type']=='dependency' and
             (okf_cross_layer.resolve_link_path(source,e['path'])/e['dir']).resolve()==target]
    if len(matches)>1: raise ValueError('同一目标库存在多个登记，请先核实')
    if len(set(ids))!=len(ids): raise ValueError('entity_ids 重复')
    old=matches[0] if matches else None
    if remove:
        if not ids and not clear: raise ValueError('须指定 ID 或显式清空')
        if ids and clear: raise ValueError('不能同时指定 ID 与清空')
        if not old: raise ValueError('未找到消费登记')
        removing=old['entity_ids'] if clear else ids
        if set(removing)-set(old['entity_ids']): raise ValueError('注销 ID 未登记')
        findings=active_references(world,removing)
        if findings: raise ValueError('有效依赖或引用未解除: '+'; '.join(findings))
        remaining=[i for i in old['entity_ids'] if i not in removing]
        if remaining: old['entity_ids']=remaining
        else: entries.remove(old)
        affected=[]
    else:
        if not ids or clear: raise ValueError('登记须提供非空 ID 列表')
        destination=World(target,tc['layer'],snapshot=snapshot)
        if destination.issues: raise ValueError('目标库范围未核实: '+str(destination.issues))
        for eid in ids:
            row,status,_=destination.catalog.resolve(eid)
            if status!='PASS' or row['root']!=target or row.get('full_id')!=eid:
                raise ValueError(f'目标完整身份未核实: {eid}')
            current,status,_=world.target({'root':source},eid)
            if status=='PASS' and (not old or eid not in old['entity_ids']):
                raise ValueError(f'身份已由归属链或其他登记定位: {eid}')
        if old:
            if repository and repository.removesuffix('/')!=old['repository'].removesuffix('/'):
                raise ValueError('登记目标 repository 不同')
            old['entity_ids']=list(dict.fromkeys(old['entity_ids']+list(ids)))
        else:
            if not repository: raise ValueError('新登记须指定目标 repository')
            workspace=Path(sc['workspace']).resolve(); repo=Path(tc['repo']).resolve()
            try: relative=repo.relative_to(workspace)
            except ValueError as exc: raise ValueError('目标越出工作区') from exc
            entries.append({'type':'dependency','repository':repository,'path':'${WORK_SPACE}'+('/'+relative.as_posix() if relative.parts else ''),
                            'dir':target.relative_to(repo).as_posix(),'name':repo.name,'label':repo.name,
                            'target_layer':tc['layer'],'entity_ids':list(ids)})
        affected=list(ids)
    validate_paths(source,entries)
    observe_snapshot(plan,snapshot)
    plan.file(source_file,render(entries))
    plan.record['validation']={'mode':'dependency','source':str(source),'layer':sc['layer'],'ids':affected,'removed_ids':list(removing) if remove else [],'consumers':list(map(str,consumers))}
    return plan


def meta_plan(doc, repository, path, layer):
    doc=Path(doc).resolve(); plan=Plan(doc,[doc],'meta-upsert')
    target=doc/'knowledge-links.yaml'; plan.observe(target)
    entries=read(target)
    replacement={'type':'meta','repository':repository,'path':path,'dir':layer}
    result=[]; seen=False
    for entry in entries:
        if entry['type']=='meta':
            if not seen: result.append(replacement); seen=True
        else: result.append(entry)
    if not seen: result.append(replacement)
    validate_paths(doc,result)
    plan.file(target,render(result))
    return plan
