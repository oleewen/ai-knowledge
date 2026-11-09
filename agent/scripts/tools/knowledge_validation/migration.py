"""Impact-only ownership migration preview. No write or apply mode is provided."""
from .relations import ID, kind
import okf_lib
from pathlib import Path
from urllib.parse import urlsplit, urlunsplit, unquote


def preview(world, identity, owner):
    result={'identity':identity,'owner':owner,'executable':False,'changes':[],
            'references':[],'blockers':[], 'limits':['仅覆盖已读取库；不代表迁移授权或全联邦引用完整性']}
    source,status,evidence=world.catalog.resolve(identity or '')
    target,owner_status,owner_evidence=world.catalog.resolve(owner or '')
    if status!='PASS': result['blockers'].append(evidence)
    if owner_status!='PASS': result['blockers'].append(owner_evidence)
    if not source or not target: return result
    if kind(identity) not in ('MS','API') or kind(owner)!=('APP' if kind(identity)=='MS' else 'MS'):
        result['blockers'].append('预览仅接受 MS→APP 或 API→完整 MS 的归属变更')
        return result
    old=source['full_id']; new=target['full_id']+'/'+source['id']
    if old==new:
        result['blockers'].append('归属未发生变化')
        return result
    for row in world.records:
        full=row.get('full_id','')
        if full!=old and not full.startswith(old+'/'): continue
        proposed=new+full[len(old):]
        conflicts=world.catalog.full.get(proposed,[])
        if conflicts: result['blockers'].append(f'完整身份冲突: {proposed}')
        if kind(full)=='API':
            app,ms,local=proposed.split('/')
            dest=row['root']/okf_lib.entity_relpath('application',local,path_parent=f'{app}/{ms}',bundle='application')
            if old.split('/')[0]!=new.split('/')[0]:
                result['blockers'].append(f'{full}: APP 变化后目标应用库需另行核实，所列路径仅为当前库候选')
        else:
            dest=target['path'].parent/row['id']/(row['id']+'.md')
        if dest.exists() and dest!=row['path']:
            result['blockers'].append(f'目标路径已存在: {dest}')
        result['changes'].append({'from_identity':full,'to_identity':proposed,'from_path':str(row['path']),
                                  'proposed_path':str(dest),'from_owner':full.rsplit('/',1)[0],'to_owner':proposed.rsplit('/',1)[0]})
    old_ids={change['from_identity'] for change in result['changes']}
    for root,entries in getattr(world,'entries',{}).items():
        for index,entry in enumerate(entries):
            for eid in entry.get('entity_ids',[]):
                if eid in old_ids:
                    result['references'].append({'path':str(root/'knowledge-links.yaml'),'identity':eid,
                        'resolved_identity':eid,'field':f'links[{index}].entity_ids'})
                    result['blockers'].append(f'{root}/knowledge-links.yaml: dependency 登记须随身份变更；本轮不执行清单写入')
    old_paths={Path(c["from_path"]):c["from_identity"] for c in result["changes"]}
    from .core import prose_only, markdown_links
    import okf_cross_layer
    for root in sorted(world.readable):
        for path in okf_lib.iter_bundle_markdown_files(root):
            if path.is_symlink():
                result['blockers'].append(f'引用文件为软链: {path}'); continue
            try:
                text=world.snapshot.read(path)
                for href in markdown_links(text):
                    url=urlsplit(href)
                    destination=None
                    if url.scheme in ('http','https'):
                        plain=urlunsplit((url.scheme,url.netloc,url.path,'',''))
                        for parent,base in okf_cross_layer.collect_web_bases(root):
                            if plain.startswith(base+'/'):
                                destination=(parent.local_doc_root()/unquote(plain[len(base)+1:])).resolve()
                                break
                    elif not url.scheme and url.path:
                        destination=((root/unquote(url.path).lstrip('/')) if url.path.startswith('/') else path.parent/unquote(url.path)).resolve()
                    if destination in old_paths:
                        result['references'].append({'path':str(path),'identity':old_paths[destination],
                                                     'href':href,'target_path':str(destination)})
                tokens=set(ID.findall(prose_only(text,keep_inline_code=True)))
                for token in tokens:
                    row,status,_=world.catalog.resolve(token)
                    if token in old_ids or (row and row.get('full_id') in old_ids):
                        result['references'].append({'path':str(path),'identity':token,
                                                     'resolved_identity':row.get('full_id') if row else token})
                    elif status!='PASS' and token in {x.rsplit('/',1)[-1] for x in old_ids}:
                        result['blockers'].append(f'{path}: 裸引用 {token} 有歧义')
            except (OSError,UnicodeError,ValueError,RuntimeError) as exc:
                result['blockers'].append(str(exc))
    for issue in world.issues:
        result['blockers'].append(f'{issue["root"]}: {issue["evidence"]}')
    result['blockers']=sorted(set(result['blockers']))
    return result
