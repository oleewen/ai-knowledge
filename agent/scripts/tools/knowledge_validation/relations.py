"""Deterministic relationship rules from entity-relations, governance and perspective meta."""
import re

INVERSE = {'parent':'children','implements_to':'implemented_by','maps_to':'mapped_by',
           'supports_to':'supported_by','uses_to':'used_by','depends_to':'depended_by'}
INVERSE.update({v:k for k,v in list(INVERSE.items())})
FORWARD = {
 'parent': [('BSD1','BD'),('BSD2','BSD1'),('BSD3','BSD2'),('BSP','BP')],
 'implements_to': [('CAP','VC'),('BC','BSD3'),('AGG','BC'),('AB','AGG'),('PD','PL'),('PM','PD'),('FT','PM'),('FR','FT'),('UC','FR'),('BR','FR'),('BP','SLN'),('BSP','PD'),('SYS','SLN'),('APP','SYS'),('MS','APP'),('API','MS'),('DS','MDG'),('ENT','DS'),('TBL','ENT'),('TS','TPL'),('MW','TS'),('CMP','MW')],
 'maps_to': [('BL','BSD1'),('BSD1','CAP'),('PL','BL'),('SLN','PL'),('PD','BS'),('BS','BSD2'),('SYS','PD'),('PM','BC'),('API','UC'),('UC','AB'),('MS','AGG'),('ENT','AGG')],
 'supports_to': [('BD','VC'),('APP','BC'),('API','FT')],
 'uses_to': [('PD','MDG'),('PD','TS'),('PD','SYS'),('APP','DS'),('APP','MW'),('MS','ENT'),('MW','DS')],
 'depends_to': [('PM','PM')],
}
ALLOWED = {verb:set(edges) for verb,edges in FORWARD.items()}
for verb, edges in FORWARD.items():
    ALLOWED[INVERSE[verb]] = {(b,a) for a,b in edges}
ALLOWED['implemented_by'].discard(('SLN','SYS'))
ALLOWED['mapped_by'].discard(('PD','SYS'))
REQUIRED = {'VC':[], 'CAP':['implements_to'], 'BD':['children'], 'BSD1':['parent'],
 'BL':['maps_to','mapped_by'],'BSD2':['parent'],'BS':['maps_to'],'BSD3':['parent'],
 'BC':['implements_to','implemented_by'],'AGG':['implements_to','implemented_by'],'AB':['implements_to'],
 'PL':['maps_to'],'PD':['implements_to','maps_to','implemented_by'],'BP':['implements_to'],
 'BSP':['parent','implements_to'],'PM':['implements_to','implemented_by'],
 'FT':['implements_to','implemented_by'],'FR':['implements_to','implemented_by'],
 'UC':['implements_to'],'BR':['implements_to'],'SLN':['maps_to','implemented_by'],
 'SYS':['implements_to','implemented_by'],'APP':['implements_to','implemented_by'],
 'MS':['implements_to','implemented_by'],'API':['implements_to'],
 'MDG':['implemented_by'],'DS':['implements_to','implemented_by'],
 'ENT':['implements_to','implemented_by'],'TBL':['implements_to'],
 'TPL':['implemented_by'],'TS':['implements_to','implemented_by'],'MW':['implements_to'],'CMP':['implements_to']}
ONE_TO_ONE = {('BL','maps_to','BSD1'),('BSD1','maps_to','CAP'),('PL','maps_to','BL'),
              ('PD','maps_to','BS'),('BS','maps_to','BSD2'),('SYS','maps_to','PD'),
              ('SLN','maps_to','PL'),('BP','implements_to','SLN')}
ID = re.compile(r'(?<![\w-])(?:[A-Z]+-[A-Za-z0-9_][A-Za-z0-9_-]*)(?:/[A-Z]+-[A-Za-z0-9_][A-Za-z0-9_-]*)*(?![\w-])')


def kind(eid):
    eid = eid.rsplit('/',1)[-1]
    prefix = eid.split('-',1)[0]
    if prefix == 'BSD':
        return 'BSD3' if eid.endswith('-L3') else 'BSD2' if eid.endswith('-L2') else 'BSD1'
    return prefix


def parse(body, prose):
    section = None
    verb = None
    edges = []
    declarations = set()
    for line in prose(body, keep_inline_code=True).splitlines():
        heading = re.match(r'^##\s+(.+?)\s*$', line)
        if heading:
            section = heading[1]; verb = None
        field = re.match(r'^\s*(?:[-*]\s+)?`?([a-z_]+)`?\s*:\s*(.*)$', line)
        if field:
            verb, value = field.groups()
            if section in ('关系','跨视角'):
                declarations.add(verb)
        elif verb and re.match(r'^\s+[-*]\s+',line):
            value = line
        else:
            if line.strip():
                verb = None
            continue
        if section not in ('关系','跨视角'):
            continue
        # IDs in link labels count, destinations do not create extra targets.
        value = re.sub(r'\[([^\]]*)\]\([^)]*\)',r'\1',value)
        for target in dict.fromkeys(ID.findall(value)):
            edges.append((verb,target,section))
    return edges, declarations


def check(report, entities, resolve_target, perspective):
    index = {}
    for e in entities:
        index.setdefault(e.get('full_id',e['id']),[]).append(e)
    incoming = {}
    for e in entities:
        if not e['selected']:
            continue
        add = lambda status,rule,msg: report.add('relations',status,e['path'],rule,msg)
        if not e['valid']:
            add('NOT_RUN','relations.dependencies','结构/身份字段错误，关系结论未执行')
            continue
        src = kind(e['id'])
        edges = e['edges']
        for required in REQUIRED.get(src,[]):
            values = [t for v,t,s in edges if v==required]
            add('PASS' if values else 'FAIL','relations.required',f'{required}: {len(values)} 个目标')
        for verb in e['declarations']:
            if verb not in ALLOWED:
                add('FAIL','relations.verb',f'未知或退役关系字段 {verb}')
        if src in ('MS','API') and e.get('identity_status')!='PASS':
            add('UNVERIFIED','relations.scoped_identity','完整宿主身份未核实')
            continue
        for verb,target,section in edges:
            dst = kind(target)
            if (src,dst) not in ALLOWED.get(verb,set()):
                add('FAIL','relations.allowed',f'不允许 {src}.{verb} → {dst}')
                continue
            add('PASS','relations.allowed',f'{verb} → {target}')
            wanted = '跨视角' if verb in ('uses_to','used_by') else '关系'
            optional_map = verb in ('maps_to','mapped_by') and verb not in REQUIRED.get(src,[]) and perspective(src)!=perspective(dst)
            if section != wanted and not (optional_map and section=='跨视角'):
                add('FAIL','relations.position',f'{verb} → {target} 应位于 {wanted}')
            if (src,verb,dst) in (('PD','uses_to','SYS'),('SYS','used_by','PD')):
                if src=='SYS':
                    add('UNVERIFIED','relations.consumption_legacy','已有 SYS.used_by 不作消费事实源；视图仅从已读 PD 声明派生')
                else:
                    add('NOT_APPLICABLE','relations.reverse','PD→SYS 消费单侧维护；由已读范围派生反向视图')
                continue
            target_entity, status, evidence = resolve_target(target, index, e)
            add(status,'relations.target',f'{target}: {evidence}')
            if status != 'PASS':
                add('NOT_RUN' if status=='FAIL' else 'UNVERIFIED','relations.reverse',f'{target}: 依赖目标核验')
                continue
            if (src,verb,dst) in (('SYS','implements_to','SLN'),('SYS','maps_to','PD')):
                add('NOT_APPLICABLE','relations.reverse','SYS 上游关系豁免反向回写')
            else:
                reverse = any(v==INVERSE[verb] and t==e.get('full_id',e['id']) for v,t,s in target_entity['edges'])
                add('PASS' if reverse else 'FAIL','relations.reverse',f'{target}.{INVERSE[verb]} → {e["id"]}')
        # A scalar parent and composition target have at most one host.
        for verb in ('parent','implements_to'):
            targets = set(t for v,t,s in edges if v==verb)
            add('FAIL' if len(targets)>1 else 'PASS','relations.cardinality',f'{verb} 宿主数量 {len(targets)}，上限 1')
        for sk,verb,tk in ONE_TO_ONE:
            if src != sk:
                continue
            targets = set(t for v,t,s in edges if v==verb and kind(t)==tk)
            add('FAIL' if len(targets)>1 else 'PASS','relations.cardinality',f'{verb} → {tk} 数量 {len(targets)}，上限 1')
    # Inspect all read entities for the reverse side of a 1:1 edge, even in a selected batch.
    for e in entities:
        if not e['valid']:
            continue
        for verb,target,section in e['edges']:
            key=(kind(e['id']),verb,kind(target))
            if key in ONE_TO_ONE:
                incoming.setdefault((key,target),set()).add(e.get('full_id',e['id']))
    for (key,target), sources in incoming.items():
        if len(sources)>1:
            report.add('relations','FAIL',target,'relations.cardinality',f'{key}: 多个入边 {sorted(sources)}')
    report.add('relations','UNVERIFIED',report.context['bundle'],'relations.federation_coverage','未覆盖整个联邦的入边与反向完整性；本地检查不能证明全局结论')
