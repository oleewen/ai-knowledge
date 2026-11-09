"""Convert the existing shell's fully checked memory plan into journaled steps."""
import json
from pathlib import Path
import re
from urllib.parse import unquote

from knowledge_validation.context import Snapshot
from knowledge_validation.federation import World, okf_cross_layer
from .operations import Plan, fingerprint
from .manifests import read, render, context, observe_snapshot, validate_paths, active_references


def manifest_rows(values):
    result=[]
    for row in values:
        entry=dict(zip(('type','repository','path','dir','name','label'),row))
        if entry['type']=='meta': entry.pop('name'); entry.pop('label')
        elif not entry['label']: entry['label']=entry['name']
        result.append(entry)
    return result


def add_manifest(plan, doc, rows):
    target=Path(doc)/'knowledge-links.yaml'
    plan.observe(target)
    entries=manifest_rows(rows)
    entries.extend(e for e in read(target) if e['type']=='dependency')
    validate_paths(doc,entries)
    plan.file(target,render(entries))


def http_steps(plan, doc, old_parent, source, downgrade, rewrite):
    old_base=okf_cross_layer.web_base_from_repo(old_parent.get('repository',''),old_parent.get('dir',''))
    if not old_base: return
    snapshot=Snapshot(); ctx=context(doc,snapshot)
    world=World(doc,ctx['layer'],snapshot=snapshot)
    new_base=okf_cross_layer.web_base_from_repo(source.get('repository',''),source.get('dir','')) if source else None
    for path in sorted((Path(doc)/'knowledge').rglob('*.md')):
        if path.is_symlink() or not path.resolve().is_relative_to(Path(doc)/'knowledge'):
            raise ValueError('HTTP 改写路径越界或软链')
        text=snapshot.read(path); replacements={}
        for match in okf_cross_layer.MD_LINK_RE.finditer(text):
            label,url=match.group(1),match.group(2)
            if not (url==old_base or url.startswith(old_base+'/')): continue
            if downgrade:
                if not rewrite: raise ValueError('注销含 HTTP 引用；须在预览中明确 --downgrade-http')
                suffix=unquote(url[len(old_base):].split('#',1)[0].lstrip('/'))
                root=okf_cross_layer.resolve_link_path(Path(doc),old_parent['path'])/old_parent['dir']
                actual=(root/suffix).resolve()
                rows=[r for r in world.records if r['path'].resolve()==actual and r.get('full_id') and r['valid']]
                if len(rows)!=1: raise ValueError(f'HTTP 目标身份待核实: {url}')
                full=rows[0]['full_id']
                if re.fullmatch(r'[A-Z]+-[\w/-]+',label) and label not in (full,rows[0]['id']):
                    raise ValueError('HTTP 标签与目标身份不符')
                replacements[match.group(0)]=full
            elif rewrite and new_base:
                # Preserve established prefix rewrite behavior; post-check reports unresolved targets.
                replacements[match.group(0)]=f'[{label}]({new_base}{url[len(old_base):]})'
        if replacements: plan.replace(path,replacements)
    observe_snapshot(plan,snapshot)


def legacy_plan(args):
    source=Path(args.source).resolve(); target=Path(args.target_doc).resolve() if args.target_doc else None
    old_entries=read(target/'knowledge-links.yaml',maintenance=args.action=='repair') if target else []
    old_parent=next((e for e in old_entries if e['type']=='parent'),None)
    stale_cleanup=bool(args.action=='unlink' and target and old_parent and
        (okf_cross_layer.resolve_link_path(target,old_parent['path'])/old_parent['dir']).resolve()!=source)
    roots=[source]+([target] if target and not stale_cleanup else [])
    plan=Plan(source,roots,args.action)
    for path,expected in args.baseline:
        if fingerprint(path)!=json.loads(expected): raise ValueError(f'预检后指纹变化: {path}')
        plan.observe(path)
    snapshot=Snapshot(); sc=context(source,snapshot)
    if args.action=='unlink' and target:
        world=World(source,sc['layer'],args.consumer_root,snapshot)
        relevant_issues=[i for i in world.issues if not stale_cleanup or Path(i['root']) in (source,target)]
        if relevant_issues: raise ValueError('注销跨库范围待核实: '+str(relevant_issues))
        ids=[r['full_id'] for r in world.records if r['root']==target and r.get('full_id')]
        consumer_roots=set(world.consumer_roots)-{target}
        findings=active_references(world,ids,consumer_roots) if ids else []
        # Evidence in the child can still depend on the parent after its HTTP is downgraded.
        source_ids=[r['full_id'] for r in world.records if r['root']==source and r.get('full_id')]
        from knowledge_validation.evidence import blockers
        findings.extend(blockers(target,source_ids,snapshot))
        if findings: raise ValueError('有效消费或事实依赖未解除: '+'; '.join(findings))
    if args.action!='repair':
        add_manifest(plan,source,args.source_entry)
        if target and not stale_cleanup: add_manifest(plan,target,args.target_entry)
    if args.action in ('link','repair'):
        plan.symlink(args.slot,str(target))
        if args.old_slot:
            a,b=Path(args.old_slot),Path(args.slot)
            # On case-insensitive filesystems two spellings can identify one directory entry.
            same=a.is_symlink() and b.is_symlink() and a.lstat().st_ino==b.lstat().st_ino and a.name not in [p.name for p in a.parent.iterdir() if p.name==b.name]
            if not same: plan.symlink(a,None)
    else:
        plan.symlink(args.slot,None)
    new_parent=next((e for e in manifest_rows(args.target_entry) if e['type']=='parent'),None)
    if target and old_parent and not stale_cleanup and args.action in ('link','unlink'):
        http_steps(plan,target,old_parent,new_parent,args.action=='unlink',args.downgrade_http if args.action=='unlink' else args.rewrite_http)
    observe_snapshot(plan,snapshot)
    plan.record['validation']={'mode':'legacy','action':args.action,'source':str(source),'layer':sc['layer'],
                               'target':str(target) if target else None,'stale_cleanup':stale_cleanup,'slot':args.slot,'old_parent':old_parent,'consumers':args.consumer_root}
    if not target: plan.record['limitations'].append('目标侧未更新、跨库待核实')
    return plan
