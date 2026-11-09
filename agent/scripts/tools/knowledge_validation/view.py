"""Presentation adapters: path keys stay stable, identity and coverage stay explicit."""
import hashlib
from pathlib import Path
from .federation import for_bundle


def world_for_output(root, layer=None, consumers=()):
    world=for_bundle(root,layer,consumers)
    unresolved=[r for r in world.records if r['valid'] and r['id'].split('-')[0] in ('MS','API') and r['identity_status']!='PASS']
    if unresolved:
        raise ValueError('归属身份未核实，停止受影响生成: '+'; '.join(str(r['path']) for r in unresolved))
    if world.catalog.duplicates():
        raise ValueError(f'完整身份冲突，停止生成: {list(world.catalog.duplicates())}')
    if any(i['status']=='FAIL' for i in world.issues):
        raise ValueError('联邦配置错误，停止生成: '+'; '.join(i['evidence'] for i in world.issues))
    return world


def identity_labels(world):
    return {r['path']:(r.get('full_id') or r['id']+'（身份待核实）') for r in world.records}


def enrich_graph(data, root, world):
    root=Path(root).resolve()
    by_path={r['path']:r for r in world.records}
    concepts=data['concepts']; edges=data['edges']
    def node(row):
        relative=row['path'].relative_to(row['root']).with_suffix('').as_posix()
        cid=relative if row['root']==root else 'external:'+hashlib.sha256(str(row['root']).encode()).hexdigest()[:16]+':'+relative
        if cid not in concepts:
            concepts[cid]={'id':cid,'title':row['meta'].get('title') or row['id'],
                           'type':row['meta'].get('type') or '', 'description':'已读取的外库实体',
                           'tags':[], 'body':row['body'],'backlinks':[]}
        concepts[cid].update(fullIdentity=row.get('full_id'),identityStatus=row['identity_status'],
                             sourceRoot=str(row['root']),external=row['root']!=root)
        return cid
    for row in world.records:
        if row['root']==root: node(row)
    keys=set()
    for row in world.records:
        if row['root']!=root or not row['valid'] or row['identity_status']!='PASS': continue
        for verb,target,_ in row['edges']:
            if verb=='uses_to' and row['id'].startswith('PD-') and target.startswith('SYS-'): continue
            dest,status,_=world.target(row,target)
            if status!='PASS': continue
            source_id,target_id=node(row),node(dest)
            key=(source_id,target_id,verb)
            if key not in keys:
                edges.append({'source':source_id,'target':target_id,'relation':verb,'status':'PASS'})
                keys.add(key)
                concepts[target_id]['backlinks'].append(source_id)
    consumption=world.consumption()
    for edge in consumption:
        source=by_path[Path(edge['source_path'])]
        source_id=node(source)
        dest=by_path.get(Path(edge['target_path'])) if edge['target_path'] else None
        if dest:
            target_id=node(dest)
        else:
            target_id='unverified:'+edge['target']+':'+hashlib.sha256(str(source['root']).encode()).hexdigest()[:16]
            concepts[target_id]={'id':target_id,'title':edge['target']+'（待核实）','type':'System',
                                 'description':edge['evidence'],'tags':[],'body':'','backlinks':[],
                                 'fullIdentity':edge['target'],'identityStatus':'UNVERIFIED'}
        edges.append({'source':source_id,'target':target_id,'relation':'uses_to','derived':True,'status':edge['status']})
        concepts[target_id]['backlinks'].append(source_id)
        concepts[target_id].setdefault('consumers',[]).append({'identity':edge['source'],'status':edge['status'],'sourceRoot':str(source['root'])})
    for concept in concepts.values():
        concept['backlinks']=sorted(set(concept['backlinks']))
    data.update(coverage=world.coverage,consumption=consumption,issues=world.issues,
                coverageNote='仅汇总当前库、显式消费库及已登记 child 的已读取声明；不可读库待核实，不代表全联邦消费清单。')
    return data
