"""Authorized metadata-only plans using the common local write protocol."""
import copy
from datetime import datetime, timezone
from pathlib import Path
import re
from . import evidence as ev
from .context import Snapshot, resolve
from federation_write.operations import Plan
from federation_write.manifests import observe_snapshot


def record_path(doc,key):
    if not ev.KEY.fullmatch(key): raise ValueError('非法证据编号')
    path=Path(doc).resolve()/'governance/evidence'/f'{key}.md'
    if path.is_symlink() or path.parent.resolve()!=path.parent: raise ValueError('证据路径含软链')
    return path


def inspect(doc):
    snapshot=Snapshot(); ctx=resolve(doc,snapshot=snapshot)
    if Path(ctx['bundle']).resolve()!=Path(doc).resolve(): raise ValueError('须指定文档根')
    contents=ev.scan(doc,snapshot)
    if contents['issues']: raise ValueError('证据范围无法核实: '+str(contents['issues']))
    return snapshot,ctx,contents


def bind_sources(data,doc,snapshot):
    from .federation import okf_cross_layer
    for source in data['sources']:
        if source['repository']=='不适用':
            text=source.pop('inline_text',None)
            if text is None: raise ValueError('新建内联证据须提供 inline_text 以核对原始字节；不会保存原文')
            import hashlib
            digest=hashlib.sha256(text.encode('utf-8')).hexdigest()
        else:
            repo=okf_cross_layer.resolve_link_path(Path(doc),source['repository']['path'])
            path=ev.secure_file(repo,source['path']); digest=ev.observe_bytes(snapshot,path)
        if source.get('sha256') and source['sha256']!=digest: raise ValueError('来源哈希与当前原始字节不符')
        source['sha256']=digest
        source.setdefault('commit','未验证')
        source.setdefault('captured_at',datetime.now(timezone.utc).isoformat())
        source.setdefault('dependency','待建立'); source.setdefault('release_basis','无')
        if source['commit'] not in ('无','未验证'):
            if source['repository']=='不适用' or ev.git_hash(repo,source['commit'],source['path'])!=digest:
                raise ValueError('指定 Git commit 与来源字节不符')
            source['recoverability']='已核验可从指定 Git 版本恢复'
        else: source.setdefault('recoverability','当前原件可读但无持久版本保证' if source['repository']!='不适用' else '待核实')


def create_plan(doc,payload):
    doc=Path(doc).resolve(); snapshot,ctx,contents=inspect(doc); data=copy.deepcopy(payload)
    used={r['data']['id'] for r in contents['records']}
    if 'id' not in data:
        number=max([int(k[5:]) for k in used] or [0])+1
        data['id']=f'EVID-{number:06d}'
    path=record_path(doc,data['id'])
    if path.exists(): raise ValueError('证据编号已存在；版本变化必须新建记录')
    data.setdefault('buffer','无'); data.setdefault('previous','无'); data.setdefault('review_status','待核验')
    data.setdefault('reviewer','尚未核验'); data.setdefault('conclusion','尚未核验'); data.setdefault('processing','待落盘')
    data.setdefault('target_sha256','尚无')
    if data['previous']!='无' and data['previous'] not in used: raise ValueError('前序证据不存在')
    previous=next((r['data'] for r in contents['records'] if r['data']['id']==data['previous']),None)
    if previous is not None and previous['target_identity']!=data['target_identity']:
        raise ValueError('前序证据属于不同目标身份')
    bind_sources(data,doc,snapshot)
    result=ev.audit(data,doc,snapshot)
    if data['review_status']=='已核验' and result['status']!='PASS': raise ValueError('版本或依据未核实，不能登记已核验: '+str(result['checks']))
    plan=Plan(doc,[doc],'evidence-create')
    observe_snapshot(plan,snapshot); plan.file(path,ev.render(data))
    plan.record['validation']={'mode':'evidence','source':str(doc),'records':[str(path)]}
    return plan


def update_plan(doc,key,changes):
    doc=Path(doc).resolve(); snapshot,ctx,contents=inspect(doc)
    row=next((r for r in contents['records'] if r['data']['id']==key),None)
    if row is None: raise ValueError('证据记录不存在')
    data=copy.deepcopy(row['data']); allowed={'review_status','reviewer','conclusion','processing','buffer','target_sha256','sources'}
    if set(changes)-allowed: raise ValueError('版本身份/来源定位不可原地修改；须新建证据')
    target=ev.secure_file(Path(ctx['repo']),data['target_path'])
    if 'target_sha256' in changes:
        if data['target_sha256']!='尚无': raise ValueError('已绑定目标版本不可覆盖')
        if changes['target_sha256']!=ev.observe_bytes(snapshot,target): raise ValueError('目标哈希与实际内容不符')
    updates=changes.get('sources',[])
    if not isinstance(updates,list): raise ValueError('sources 更新须为含 index 的数组')
    seen=set()
    for update in updates:
        if set(update)-{'index','dependency','release_basis','commit','recoverability','inline_text'}: raise ValueError('来源版本不可原地修改')
        index=update.get('index')
        if not isinstance(index,int) or isinstance(index,bool) or not 1<=index<=len(data['sources']) or index in seen: raise ValueError('来源更新编号非法或重复')
        source=data['sources'][index-1]
        if source['commit'] not in ('无','未验证') and update.get('commit',source['commit'])!=source['commit']:
            raise ValueError('已验证 Git commit 不可覆盖；须新建版本记录')
        if 'inline_text' in update:
            import hashlib
            if source['repository']!='不适用' or hashlib.sha256(update['inline_text'].encode('utf-8')).hexdigest()!=source['sha256']:
                raise ValueError('内联原文字节与已登记版本不符')
        seen.add(index); source.update({k:v for k,v in update.items() if k not in ('index','inline_text')})
    data.update({k:v for k,v in changes.items() if k!='sources'})
    if data['review_status']=='已核验' and row['data']['review_status']!='已核验':
        for index,source in enumerate(data['sources'],1):
            if source['repository']=='不适用' and source['dependency']!='已解除' and not any(u['index']==index and 'inline_text' in u for u in updates):
                raise ValueError('核验内联来源须重新提供 inline_text 核对原文字节')
    result=ev.audit(data,doc,snapshot)
    confirms=data['review_status']=='已核验' or any(s.get('dependency')=='已解除' or s.get('recoverability')=='已核验可从指定 Git 版本恢复' for s in updates)
    if confirms and result['status']!='PASS': raise ValueError('状态确认依赖未通过的版本/来源核验: '+str(result['checks']))
    plan=Plan(doc,[doc],'evidence-update'); observe_snapshot(plan,snapshot)
    plan.file(row['path'],ev.render(data))
    plan.record['validation']={'mode':'evidence','source':str(doc),'records':[row['path']]}
    return plan


def refresh_plan(doc):
    doc=Path(doc).resolve(); snapshot,ctx,contents=inspect(doc)
    plan=Plan(doc,[doc],'evidence-refresh'); changed=[]
    for row in contents['records']:
        result=row['audit']
        if result['impacts'] or any(c['rule'] in ('target.changed','target.unreadable') and c['status']=='UNVERIFIED' for c in result['checks']):
            data=copy.deepcopy(row['data']); data['review_status']='待复核'
            data['conclusion']='检测到来源或目标变化；原版本信息保留，需人工复核支持范围。'
            plan.file(row['path'],ev.render(data)); changed.append(row['path'])
    observe_snapshot(plan,snapshot)
    plan.record['validation']={'mode':'evidence','source':str(doc),'records':changed}
    return plan


def check(doc):
    snapshot=Snapshot(); ctx=resolve(doc,snapshot=snapshot); result=ev.scan(doc,snapshot)
    states=[r['audit']['status'] for r in result['records']]
    result['status']='FAIL' if 'FAIL' in states else 'INCOMPLETE' if result['issues'] or 'INCOMPLETE' in states or snapshot.changed() else 'PASS'
    result['coverage']={'doc':str(Path(doc).resolve()),'records':len(result['records']),'empty_is_not_fact_approval':True}
    result['source_hashes']=snapshot.files
    return result
