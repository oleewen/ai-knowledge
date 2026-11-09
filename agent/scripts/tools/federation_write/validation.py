"""Current-state readback and semantic checks, including after Git integration."""
from pathlib import Path
from knowledge_validation.context import Snapshot
from knowledge_validation.federation import World, okf_cross_layer
from .manifests import read, context, active_references


def linked_doc(root, entry):
    return (okf_cross_layer.resolve_link_path(root,entry['path'])/entry['dir']).resolve()


def matches(root, entry, target):
    if entry.get('_invalid'): return False
    try: return linked_doc(root,entry)==target
    except (ValueError,OSError,RuntimeError,KeyError): return False


def validate_result(record):
    spec=record['validation']; source=Path(spec['source']); issues=[]; coverage=[]
    if spec['mode']=='evidence':
        from knowledge_validation.evidence import parse
        for value in spec['records']:
            path=Path(value)
            parse(path.read_text(),path.stem)
        return {'complete':True,'issues':[],'coverage':[{'root':str(source),'purpose':'证据元数据已写入；事实完成状态单独检查'}]}
    if spec['mode']=='dependency':
        world=World(source,spec['layer'],spec.get('consumers',()))
        issues=list(world.issues); coverage=world.coverage
        for eid in spec.get('ids',[]):
            _,status,evidence=world.target({'root':source},eid)
            if status!='PASS': issues.append({'status':status,'evidence':f'{eid}: {evidence}'})
        for evidence in active_references(world,spec.get('removed_ids',[])) if spec.get('removed_ids') else []:
            issues.append({'status':'FAIL','evidence':evidence})
        if world.snapshot.changed(): issues.append({'status':'UNVERIFIED','evidence':'校验时来源变化'})
    else:
        target=Path(spec['target']) if spec.get('target') else None
        snapshot=Snapshot()
        for root in [source]+([target] if target else []):
            context(root,snapshot); snapshot.observe_optional(root/'knowledge-links.yaml')
            coverage.append({'root':str(root),'purpose':'参与库双边核对'})
        maintenance=spec['action']=='repair'
        src=read(source/'knowledge-links.yaml',maintenance=maintenance)
        if target:
            parents=[e for e in read(target/'knowledge-links.yaml',maintenance=maintenance) if e['type']=='parent']
            children=[e for e in src if e['type']=='child' and matches(source,e,target)]
            back=[e for e in parents if matches(target,e,source)]
            action=spec['action']
            if action in ('link','repair') and (len(children)!=1 or len(back)!=1):
                issues.append({'status':'FAIL','evidence':'双边登记不一致'})
            if action=='unlink' and (children or back):
                issues.append({'status':'FAIL','evidence':'双边注销不一致'})
            slot=Path(spec['slot'])
            if action in ('link','repair') and (not slot.is_symlink() or slot.resolve()!=target):
                issues.append({'status':'FAIL','evidence':'槽位指向不一致'})
            if action=='unlink' and slot.is_symlink():
                issues.append({'status':'FAIL','evidence':'槽位尚未移除'})
            # repair's boundary is the selected slot, not unrelated child libraries or body links.
            if action!='repair' and not spec.get('stale_cleanup'):
                from knowledge_validation.core import Report, references
                report=Report(); report.context=context(target,report.snapshot)
                for path in sorted((target/'knowledge').rglob('*.md')):
                    if path.is_symlink():
                        report.add('references','UNVERIFIED',path,'references.symlink','正文软链待核实')
                    else: references(report,path,target,report.snapshot.read(path))
                result=report.finish()
                issues.extend(c for c in result['checks'] if c['status'] in ('FAIL','UNVERIFIED'))
                previous=spec.get('old_parent')
                if action=='link' and previous:
                    old=linked_doc(target,previous)
                    if old!=source:
                        if not old.is_dir(): issues.append({'status':'UNVERIFIED','evidence':'旧父不可读，换父关联单元未闭合'})
                        elif any(e['type']=='child' and linked_doc(old,e)==target for e in read(old/'knowledge-links.yaml')):
                            issues.append({'status':'UNVERIFIED','evidence':'旧父仍登记目标，须处理已授权关联注销单元'})
        else:
            issues.append({'status':'UNVERIFIED','evidence':'目标侧未更新、跨库待核实'})
        if snapshot.changed(): issues.append({'status':'UNVERIFIED','evidence':'双边校验期间来源变化'})
    return {'complete':not issues,'issues':issues,'coverage':coverage}
