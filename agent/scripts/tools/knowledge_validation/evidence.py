"""Version-bound evidence metadata. No source bodies, network reads or Git writes."""
from datetime import datetime
import hashlib
import json
from pathlib import Path
import re
import subprocess

from .context import Snapshot, resolve, contained

RECORD_FIELDS = {'target_identity':'目标身份','target_path':'目标定位','target_sha256':'目标原始文件 SHA-256',
    'buffer':'缓冲位置','previous':'前序证据编号','review_status':'核验状态','reviewer':'核验人及时间',
    'conclusion':'核验结论','processing':'处理状态'}
SOURCE_FIELDS = {'identity':'来源身份','repository':'仓库定位','path':'仓内路径与选取范围',
    'sha256':'原始字节 SHA-256','commit':'已验证 Git commit','captured_at':'采集时间',
    'recoverability':'可恢复性','dependency':'事实依赖','release_basis':'解除依据'}
REVIEW = {'待核验','已核验','待复核','不成立'}
PROCESS = {'待落盘','已落盘','部分完成','已结束'}
DEPENDENCY = {'待建立','有效','解除待核实','已解除'}
RECOVERY = {'已核验可从指定 Git 版本恢复','当前原件可读但无持久版本保证','无法恢复','待核实'}
KEY = re.compile(r'EVID-[0-9]{6}')
HASH = re.compile(r'[0-9a-f]{64}')
COMMIT = re.compile(r'[0-9a-f]{40}(?:[0-9a-f]{24})?')
IDENTITY = re.compile(r'[A-Z]+-[\w.-]+(?:/[A-Z]+-[\w.-]+)*')
NONE = {'','无','尚无','未验证','尚未核验'}


def file_hash(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def timestamp(value):
    try:
        return bool(isinstance(value,str) and datetime.fromisoformat(value.replace('Z','+00:00')).tzinfo)
    except ValueError:
        return False


def relative(value):
    if not isinstance(value,str) or not value or '\x00' in value or '\\' in value:
        raise ValueError('路径须为非空仓内相对路径')
    path=value.split('#',1)[0]
    p=Path(path)
    if not path or p.is_absolute() or '..' in p.parts or path.startswith('-'):
        raise ValueError('路径须为不越界的仓内相对路径')
    return path


def validate(data):
    if set(data)!=set(RECORD_FIELDS)|{'id','sources'} or not KEY.fullmatch(str(data.get('id',''))):
        raise ValueError('证据记录字段或编号不合法')
    if data['review_status'] not in REVIEW or data['processing'] not in PROCESS:
        raise ValueError('证据核验/处理状态非法')
    if data['previous']!='无' and not KEY.fullmatch(data['previous']): raise ValueError('前序证据编号非法')
    if data['previous']==data['id']: raise ValueError('前序证据不能指向自身')
    relative(data['target_path'])
    if data['target_sha256']!='尚无' and not HASH.fullmatch(data['target_sha256']): raise ValueError('目标哈希非法')
    if data['target_sha256']=='尚无' and data['processing'] not in ('待落盘','部分完成'): raise ValueError('已落盘目标缺少哈希')
    for key in ('target_identity','buffer','conclusion'):
        if not isinstance(data[key],str) or not data[key].strip(): raise ValueError(f'证据字段为空: {key}')
    reviewer=data['reviewer']
    if reviewer!='尚未核验':
        if not isinstance(reviewer,dict) or set(reviewer)!={'name','at'} or not str(reviewer['name']).strip() or not timestamp(reviewer['at']):
            raise ValueError('核验人及时间须含 name 和带时区 ISO8601 at')
    if data['review_status'] in ('已核验','不成立') and (reviewer=='尚未核验' or data['conclusion'] in NONE):
        raise ValueError('人工核验结论缺少核验人、时间或依据')
    if data['review_status']=='已核验' and data['target_sha256']=='尚无': raise ValueError('目标尚未落盘不能已核验')
    if not isinstance(data['sources'],list) or not data['sources']: raise ValueError('证据必须有来源')
    for source in data['sources']:
        if set(source)!=set(SOURCE_FIELDS): raise ValueError('来源字段缺失或未知')
        if source['dependency'] not in DEPENDENCY or source['recoverability'] not in RECOVERY: raise ValueError('来源状态非法')
        if not isinstance(source['identity'],str) or not source['identity'].strip(): raise ValueError('来源身份为空')
        if not HASH.fullmatch(source['sha256']) or not timestamp(source['captured_at']): raise ValueError('来源哈希/采集时间非法')
        if source['commit'] not in ('无','未验证') and not COMMIT.fullmatch(source['commit']): raise ValueError('须指定完整 Git commit，不接受可移动 ref')
        if source['recoverability']=='已核验可从指定 Git 版本恢复' and source['commit'] in ('无','未验证'): raise ValueError('可恢复声明缺少已核验提交')
        if source['dependency']=='已解除' and (source['release_basis'] in NONE or reviewer=='尚未核验'): raise ValueError('解除依赖必须有人工核验者和具体解除依据')
        repo=source['repository']
        if repo=='不适用':
            if not source['path'].startswith('message:'): raise ValueError('内联来源须有 message: 消息定位')
            if source['commit'] not in ('无','未验证'): raise ValueError('内联来源不能冒充 Git 提交')
        elif isinstance(repo,dict) and set(repo)<= {'path','dir','repository'} and repo.get('path'):
            if repo['path']!='${WORK_SPACE}' and not repo['path'].startswith('${WORK_SPACE}/'): raise ValueError('来源仓库 path 须使用 WORK_SPACE 占位符')
            relative(source['path'])
            if repo.get('dir'): relative(repo['dir'])
        else: raise ValueError('来源仓库定位须为含 path 的 JSON 对象；旧自由文本需人工规范化')
    return data


def cell(value):
    text=json.dumps(value,ensure_ascii=False,sort_keys=True) if isinstance(value,dict) else str(value)
    if any(ord(c)<32 for c in text): raise ValueError('证据表格值须为单行文本')
    return text.replace('|',r'\|')


def render(data):
    validate(data)
    lines=[f'# 证据 {data["id"]}','','| 记录项 | 值 |','| --- | --- |']
    lines.extend(f'| {label} | {cell(data[key])} |' for key,label in RECORD_FIELDS.items())
    for i,source in enumerate(data['sources'],1):
        lines.extend(['',f'## 来源 {i}','','| 来源项 | 值 |','| --- | --- |'])
        lines.extend(f'| {label} | {cell(source[key])} |' for key,label in SOURCE_FIELDS.items())
    return '\n'.join(lines)+'\n'


def parse(text, expected_id=None):
    data={}; sections=[]; current=data; labels={v:k for k,v in RECORD_FIELDS.items()}
    for line in text.splitlines():
        if not line.strip(): continue
        title=re.fullmatch(r'# 证据 (EVID-[0-9]{6})',line)
        heading=re.fullmatch(r'## 来源 ([1-9][0-9]*)',line)
        if title:
            if data: raise ValueError('证据有重复 H1')
            data['id']=title[1]
        elif heading:
            if int(heading[1])!=len(sections)+1: raise ValueError('来源编号须连续且不重复')
            current={}; sections.append(current); labels={v:k for k,v in SOURCE_FIELDS.items()}
        elif line.startswith('|') and line.endswith('|'):
            cells=[s.strip().replace(r'\|','|') for s in re.split(r'(?<!\\)\|',line)[1:-1]]
            if len(cells)!=2: raise ValueError('证据表格须为两列')
            label,value=cells
            if label in ('记录项','来源项') or re.fullmatch(r':?-+:?',label): continue
            if label not in labels or labels[label] in current: raise ValueError(f'未知/重复证据字段: {label}')
            key=labels[label]
            if key in ('repository','reviewer') and value.startswith('{'):
                value=json.loads(value)
            current[key]=value
        else: raise ValueError('证据只接受单 H1、来源 H2 与规定表格')
    data['sources']=sections
    if expected_id and data.get('id')!=expected_id: raise ValueError('证据编号与文件名不一致')
    return validate(data)


def secure_file(repo, locator):
    path=repo/relative(locator)
    if not contained(path.resolve(),repo.resolve()) or any(p.is_symlink() for p in (path,*path.parents) if p!=repo and contained(p,repo)):
        raise ValueError('证据路径越界或包含软链')
    if any(p in ('.superpowers','superpowers') for p in path.relative_to(repo).parts): raise ValueError('不能引用会话文件')
    return path


def observe_bytes(snapshot,path):
    raw=path.read_bytes(); value=hashlib.sha256(raw).hexdigest()
    snapshot.files.setdefault(str(path.resolve()),value)
    return value


def git_hash(repo,commit,path):
    if not COMMIT.fullmatch(commit): raise ValueError('恢复核验必须指定完整 commit')
    relative(path)
    p=subprocess.run(['git','-C',str(repo),'rev-parse','--show-toplevel'],capture_output=True,text=True)
    if p.returncode or Path(p.stdout.strip()).resolve()!=repo.resolve(): raise ValueError('来源不是实际 Git 根')
    check=subprocess.run(['git','-C',str(repo),'cat-file','-t',commit],capture_output=True,text=True)
    if check.returncode or check.stdout.strip()!='commit': raise ValueError('指定对象不是可读提交')
    p=subprocess.run(['git','-C',str(repo),'cat-file','blob',f'{commit}:{relative(path)}'],capture_output=True)
    if p.returncode: raise ValueError('指定提交的来源路径无法恢复')
    return hashlib.sha256(p.stdout).hexdigest()


def location_checks(path, identity, locator, doc, snapshot):
    """An identity label must describe the actual file, never a similarly named one."""
    checks=[]
    if not path.is_file(): return checks
    if '#' in locator:
        from validate_link_reachable import markdown_anchors
        from urllib.parse import unquote
        try:
            text=path.read_text()
            if unquote(locator.split('#',1)[1]) not in markdown_anchors(text):
                checks.append(('FAIL','location.anchor','选取锚点不存在'))
        except UnicodeError:
            checks.append(('FAIL','location.anchor','非文本来源不能核验 Markdown 锚点'))
    try:
        from .federation import World
        # Narrative sources need no entity identity, but entity files cannot be
        # relabeled as a narrative location to bypass their canonical identity.
        text=path.read_text() if path.suffix=='.md' else ''
        candidate=IDENTITY.fullmatch(identity) or re.search(r'^id:',text,re.M)
        if candidate:
            ctx=resolve(doc,snapshot=snapshot)
            world=World(Path(doc),ctx['layer'],snapshot=snapshot)
            rows=[r for r in world.records if r['path'].resolve()==path.resolve()]
            if len(rows)!=1 or rows[0].get('identity_status')!='PASS':
                checks.append(('UNVERIFIED','location.identity','目标文件完整身份未核实'))
            elif rows[0].get('full_id')!=identity:
                checks.append(('FAIL','location.identity','登记身份与实际 SSOT 文件不一致'))
    except (ValueError,OSError,UnicodeError) as exc:
        checks.append(('UNVERIFIED','location.identity',str(exc)))
    return checks


def dependencies(data):
    return [s['identity'] for s in data['sources'] if s['dependency']!='已解除']


def audit(data,doc,snapshot=None):
    validate(data); snapshot=snapshot or Snapshot(); ctx=resolve(doc,snapshot=snapshot)
    repo=Path(ctx['repo']); checks=[]; sources=[]; impacts=[]
    def add(status,rule,evidence): checks.append({'status':status,'rule':rule,'evidence':str(evidence)})
    target=secure_file(repo,data['target_path'])
    if not contained(target,Path(doc).resolve()): raise ValueError('目标必须位于本库文档根')
    historical=data['processing']=='已结束'
    if not historical:
        for item in location_checks(target,data['target_identity'],data['target_path'],doc,snapshot): add(*item)
    try:
        current=observe_bytes(snapshot,target)
        if data['target_sha256']=='尚无': add('UNVERIFIED','target.pending','目标尚未绑定实际版本')
        elif current!=data['target_sha256']:
            add('NOT_APPLICABLE' if historical else 'UNVERIFIED','target.changed','历史目标版本' if historical else '目标字节已变化，须新建版本记录')
    except OSError:
        snapshot.absent.add(str(target)); add('NOT_APPLICABLE' if historical else 'UNVERIFIED','target.unreadable',target)
    from .federation import okf_cross_layer
    for i,source in enumerate(data['sources'],1):
        recovery='UNVERIFIED'; changed=False; path=None
        if source['repository']=='不适用':
            state='NOT_APPLICABLE' if source['dependency']=='已解除' else 'PASS' if data['review_status']=='已核验' else 'UNVERIFIED'
            add(state,'source.inline',f'来源 {i}: 仅采用人工原文核验声明；未保存原文，哈希不提供恢复')
        else:
            try:
                source_repo=okf_cross_layer.resolve_link_path(Path(doc),source['repository']['path'])
                path=secure_file(source_repo,source['path'])
                try:
                    current=observe_bytes(snapshot,path)
                    if current!=source['sha256']:
                        changed=True
                        add('NOT_APPLICABLE' if source['dependency']=='已解除' else 'UNVERIFIED','source.changed',f'来源 {i}: {path}')
                except OSError:
                    snapshot.absent.add(str(path)); changed=True
                    add('NOT_APPLICABLE' if source['dependency']=='已解除' else 'UNVERIFIED','source.unreadable',path)
                if source['dependency']!='已解除':
                    source_doc=source_repo/source['repository'].get('dir','')
                    for item in location_checks(path,source['identity'],source['path'],source_doc,snapshot): add(*item)
                if source['commit'] not in ('无','未验证'):
                    try:
                        restored=git_hash(source_repo,source['commit'],source['path'])
                        if restored!=source['sha256']:
                            recovery='FAIL'; add('FAIL','source.git_hash',f'来源 {i}: commit 字节与登记哈希不符')
                        else: recovery='PASS'; add('PASS','source.git_hash',f'来源 {i}: 指定版本可恢复')
                    except (ValueError,OSError) as exc:
                        add('UNVERIFIED','source.git_unreadable',exc)
            except (ValueError,OSError,RuntimeError) as exc:
                changed=True; add('UNVERIFIED','source.location',exc)
        sources.append({'index':i,'identity':source['identity'],'path':str(path) if path else None,'recovery_status':recovery,'changed':changed,'dependency':source['dependency']})
        if changed and source['dependency']!='已解除': impacts.append({'record':data['id'],'target_identity':data['target_identity'],'target_path':str(target),'source':i})
    if data['review_status']!='已核验' and not historical: add('UNVERIFIED','facts.review',f'人工核验状态: {data["review_status"]}')
    if data['processing'] not in ('已落盘','已结束'): add('UNVERIFIED','target.processing',data['processing'])
    if snapshot.changed(): add('UNVERIFIED','snapshot.changed','证据核验期间文件变化')
    status='FAIL' if any(c['status']=='FAIL' for c in checks) else 'INCOMPLETE' if any(c['status']=='UNVERIFIED' for c in checks) else 'PASS'
    return {'id':data['id'],'status':status,'checks':checks,'sources':sources,'impacts':impacts,'target_path':str(target),'human_review':data['review_status'],'historical':historical}


def scan(doc,snapshot=None):
    snapshot=snapshot or Snapshot(); directory=Path(doc)/'governance/evidence'
    if directory.is_symlink() or (directory.exists() and directory.resolve()!=directory.absolute()): raise ValueError('证据目录含软链')
    paths=sorted(directory.rglob('*.md')); snapshot.inventory(directory,paths)
    records=[]; issues=[]
    for path in paths:
        try:
            if path.parent!=directory or path.is_symlink(): raise ValueError('证据须为目录直属普通文件')
            data=parse(snapshot.read(path),path.stem)
            records.append({'path':str(path),'data':data,'audit':audit(data,doc,snapshot)})
        except (OSError,UnicodeError,ValueError,TypeError,KeyError) as exc:
            issues.append({'path':str(path),'status':'UNVERIFIED','evidence':str(exc)})
    ids={r['data']['id'] for r in records}
    by_id={r['data']['id']:r for r in records}
    for r in records:
        previous=r['data']['previous']
        if previous!='无' and previous not in ids: issues.append({'path':r['path'],'status':'UNVERIFIED','evidence':'前序证据缺失'})
        visited={r['data']['id']}
        while previous in by_id:
            if previous in visited:
                issues.append({'path':r['path'],'status':'UNVERIFIED','evidence':'前序证据成环'})
                break
            visited.add(previous)
            prior=by_id[previous]['data']
            if prior['target_identity']!=r['data']['target_identity']:
                issues.append({'path':r['path'],'status':'UNVERIFIED','evidence':'前序证据属于不同目标身份'})
                break
            previous=prior['previous']
    return {'records':records,'issues':issues}


def blockers(doc, identities, snapshot=None):
    """Fail closed on malformed records, and inspect each source's own state."""
    contents=scan(doc,snapshot); result=[f"{i['path']}: 证据待核实: {i['evidence']}" for i in contents['issues']]
    wanted=set(identities)
    for row in contents['records']:
        for source in row['data']['sources']:
            if source['identity'] not in wanted: continue
            if source['dependency']!='已解除': result.append(f"{row['path']}: 有效事实依赖未解除: {source['identity']}")
            elif row['audit']['status']!='PASS': result.append(f"{row['path']}: 解除记录仍待核实")
    return result


def integrate(report,root,entities):
    contents=scan(root,report.snapshot)
    report.context['evidence']={'records':[{k:r[k] for k in ('path','audit')} for r in contents['records']],'issues':contents['issues']}
    for issue in contents['issues']:
        report.add('evidence',issue['status'],issue['path'],'evidence.record',issue['evidence'])
    for row in contents['records']:
        result=row['audit']; report.add('evidence','PASS' if result['status']=='PASS' else 'FAIL' if result['status']=='FAIL' else 'UNVERIFIED',row['path'],'evidence.versions',result['checks'] or '证据结构与当前版本一致；可恢复性单独报告')
        data=row['data']
        related=[r for r in contents['records'] if r['audit']['target_path']==result['target_path'] and not r['audit']['historical']]
        if not contents['issues'] and all(r['audit']['status']=='PASS' for r in related) and result['status']=='PASS' and data['review_status']=='已核验' and not result['historical']:
            entity=next((r for r in entities if str(r['path'])==result['target_path'] and r.get('full_id')==data['target_identity']),None)
            if entity:
                for item in report.checks:
                    if item['domain']=='facts' and item['object']==result['target_path']:
                        item.update(status='PASS',rule='facts.attestation',evidence=f"人工核验声明 {data['id']} 与当前版本绑定；工具未独立判断事实支持性")
