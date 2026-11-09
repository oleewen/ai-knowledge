"""Read-only upgrade compatibility gate, separate from template application."""
import copy
import json
from pathlib import Path
from .context import AGENT, Snapshot, contained
from .core import validate
from . import evidence as ev


def reviewed(value):
    if not isinstance(value,dict): return False
    reviewer=value.get('reviewer')
    return bool(isinstance(reviewer,dict) and reviewer.get('name') and ev.timestamp(reviewer.get('at')) and value.get('conclusion') not in (None,'','无','尚未核验'))


def old_baseline(doc,repo,assessment,snapshot):
    item=assessment.get('old_baseline',{})
    if not reviewed(item): raise ValueError('旧基线缺少人工核验人、时间与结论')
    path=ev.secure_file(repo,item['path'])
    if not contained(path,doc/'governance'): raise ValueError('旧基线报告须位于本库 governance')
    if ev.observe_bytes(snapshot,path)!=item.get('sha256'): raise ValueError('旧基线报告快照不符')
    data=json.loads(path.read_text())
    if data.get('schema_version')!=1 or not isinstance(data.get('checks'),list): raise ValueError('旧基线须为原始统一校验报告')
    context=data.get('context',{})
    if Path(context.get('bundle','')).resolve()!=doc: raise ValueError('旧基线文档根不符')
    rules=context.get('rules',{}); files=rules.get('files',{})
    if not files: raise ValueError('旧规则基线缺失')
    for name,digest in files.items():
        path=Path(name)
        if not contained(path,AGENT): raise ValueError('旧规则路径不属于当前 Agent 规则树，需另行核实')
        if path.is_file() and ev.observe_bytes(snapshot,path)==digest: continue
        commit=rules.get('commit') or ''
        if not ev.COMMIT.fullmatch(commit) or ev.git_hash(AGENT.parent,commit,path.relative_to(AGENT.parent).as_posix())!=digest:
            raise ValueError('旧规则字节无法从当前文件或指定 Git 提交核实')
    return data


def check(doc,assessment=None):
    doc=Path(doc).resolve(); result=validate(doc); context=result.get('context',{})
    repo=Path(context.get('repo',doc.parent)); snapshot=Snapshot(); checks=copy.deepcopy(result['checks'])
    blockers=[]; old=None
    def block(message): blockers.append(str(message))
    hashes=context.get('source_hashes',{})
    objects=[o for o in context.get('objects',[]) if o['nature']=='business']
    entity_files={str(Path(o['path']).relative_to(repo)):hashes.get(o['path']) for o in objects}
    document_files={str(Path(p).relative_to(repo)):h for p,h in hashes.items() if contained(Path(p),doc) and '/governance/' not in p}
    roots=sorted({c['root'] for c in context.get('coverage',[]) if c.get('root')})
    template={'schema':1,'doc':str(doc),'target_rules':context.get('rules',{}).get('files',{}),
              'scope':{'roots':roots,'files':entity_files,'sources':hashes,'affected':sorted(entity_files),'reviewer':None,'conclusion':''},
              'template':{'files':document_files,'reviewer':None,'conclusion':''},
              'old_baseline':{'path':'','sha256':'','reviewer':None,'conclusion':''}}
    scope_ok=False; template_ok=False; baseline_ok=False
    if assessment is None:
        block('尚未提供模板、影响范围与旧基线的最终人工核验记录')
    else:
        if not isinstance(assessment,dict):
            block('兼容评估须为 JSON 对象'); assessment={}
        if set(assessment)!=set(template) or assessment.get('schema')!=1 or assessment.get('doc')!=str(doc): block('兼容评估格式或文档根不符')
        if assessment.get('target_rules')!=template['target_rules']: block('目标规则快照变化或未覆盖全部规则')
        scope=assessment.get('scope',{}); tm=assessment.get('template',{})
        if not isinstance(scope,dict): scope={}
        if not isinstance(tm,dict): tm={}
        scope_ok=reviewed(scope) and scope.get('files')==entity_files and scope.get('roots')==roots and scope.get('sources')==hashes
        if not scope_ok: block('影响范围核验缺失或实体/跨库覆盖快照变化')
        affected=scope.get('affected',[])
        if not isinstance(affected,list) or any(not isinstance(p,str) or p not in entity_files for p in affected) or len(set(affected))!=len(affected):
            scope_ok=False; block('受影响实体清单不合法')
        template_ok=reviewed(tm) and tm.get('files')==document_files
        if not template_ok: block('模板计划未核验或文档快照变化')
        try:
            old=old_baseline(doc,repo,assessment,snapshot); baseline_ok=True
        except (ValueError,OSError,KeyError,TypeError) as exc: block(exc)
    for item in checks:
        if item['rule']=='context.adoption':
            item.update(status='PASS' if baseline_ok else 'UNVERIFIED',evidence='兼容检查核实旧基线；不自动修改 Profile 采用状态')
        elif item['rule'] in ('identity.federation_unique','relations.federation_coverage') and scope_ok:
            item.update(status='PASS',evidence='人工确认的本次影响范围已核对；不宣称范围外全联邦唯一')
        elif item['domain']=='facts' and item['status']=='NOT_RUN':
            obj=next((o for o in context.get('objects',[]) if o['path']==item['object']),None)
            if obj and obj['nature']=='template/example':
                item.update(status='NOT_APPLICABLE',evidence='模板/示例不作为真实业务事实')
            elif old is not None and scope_ok and obj:
                path=item['object']; rel=str(Path(path).relative_to(repo))
                old_checks=old['checks']; old_hash=old['context'].get('source_hashes',{}).get(path)
                # Conservative inheritance: a retained target hash alone cannot
                # prove that the original fact's inputs still hold. Without a
                # finer dependency proof, require all old non-rule inputs.
                old_inputs={p:h for p,h in old['context'].get('source_hashes',{}).items() if not contained(Path(p),AGENT)}
                stable_inputs=bool(old_inputs) and all(hashes.get(p)==h for p,h in old_inputs.items())
                if rel not in assessment['scope']['affected'] and stable_inputs and old_hash==hashes.get(path) and any(c.get('domain')=='facts' and c.get('status')=='PASS' and c.get('object')==path for c in old_checks):
                    item.update(status='PASS',evidence='未受影响实体沿用已核实旧报告；字节版本一致')
    for item in checks:
        if item['status'] in ('FAIL','UNVERIFIED','NOT_RUN'):
            block({'domain':item['domain'],'object':item['object'],'rule':item['rule'],'status':item['status'],'evidence':item['evidence']})
    # Check the input report snapshot again after baseline and attestation checks.
    for path,digest in hashes.items():
        try:
            if ev.file_hash(path)!=digest: block('核验期间源快照变化: '+path)
        except OSError: block('核验期间源文件不可读: '+path)
    if snapshot.changed(): block('旧基线核验期间快照变化')
    def status(items):
        return 'FAIL' if any(i['status']=='FAIL' for i in items) else 'INCOMPLETE' if any(i['status'] in ('NOT_RUN','UNVERIFIED') for i in items) else 'PASS'
    sections={'template':'PASS' if template_ok else 'INCOMPLETE',
              'business':status([i for i in checks if i['domain'] in ('structure','identity','relations','facts')]),
              'cross_library':status([i for i in checks if i['domain']=='references' or i['rule'].startswith(('context.federation','identity.federation'))]),
              'evidence':status([i for i in checks if i['domain'] in ('facts','evidence')]),
              'baseline':'PASS' if baseline_ok else 'INCOMPLETE'}
    return {'schema':1,'status':'PASS' if not blockers else 'FAIL' if any(i['status']=='FAIL' for i in checks) else 'INCOMPLETE',
            'can_advance_version':not blockers,'sections':sections,'blockers':blockers,'checks':checks,
            'assessment_template':template,'context':context,
            'limits':['仅覆盖报告列出的库及实体；不执行迁移或更新 DESIGN.version','人工事实结论由证据核验者提供；未提交来源的历史恢复另列状态']}
