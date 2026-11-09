"""Shared read-only engine. Every conclusion carries a rule, evidence and coverage."""
from collections import Counter
from datetime import datetime
from pathlib import Path
import hashlib
import re
import sys
from urllib.parse import unquote, urlsplit, urlunsplit

from .context import AGENT, Snapshot, contained, resolve, rule_baseline, git_info
from . import relations, frontmatter

sys.path.insert(0, str(AGENT / 'skills/docs-okf/scripts'))
import okf_lib
import okf_cross_layer
sys.path.insert(0, str(AGENT / 'scripts/tools'))
from validate_link_reachable import markdown_links, markdown_anchors, prose_only, markdown_body


class Report:
    def __init__(self):
        self.context = {}
        self.checks = []
        self.snapshot = Snapshot()

    def add(self, domain, status, obj, rule, evidence, limits=None):
        self.checks.append({'domain':domain,'status':status,'object':str(obj),'rule':rule,
                            'evidence':evidence,'limits':limits or []})

    def finish(self):
        changes = self.snapshot.changed()
        if changes:
            for item in self.checks:
                if item['status']=='PASS':
                    item['status']='UNVERIFIED'
                    item['limits'].append('读取期间快照变化；需重新核验')
            for key in ('identities','consumption','coverage'):
                for row in self.context.get(key,[]):
                    if row.get('status')=='PASS':
                        row['status']='UNVERIFIED'
                        row['evidence']='读取期间来源变化，需重新核验'
            if 'migration' in self.context:
                self.context['migration']['blockers'].append('读取期间来源变化，需重新预览')
            self.add('context','UNVERIFIED',changes,'snapshot.changed','读取期间来源变化')
        counts = Counter(x['status'] for x in self.checks)
        status = 'FAIL' if counts['FAIL'] else 'INCOMPLETE' if counts['UNVERIFIED'] or counts['NOT_RUN'] else 'PASS'
        self.context['source_hashes'] = dict(self.snapshot.files)
        return {'schema_version':1,'status':status,'context':self.context,'checks':self.checks,
                'summary':{s:counts[s] for s in ('PASS','FAIL','UNVERIFIED','NOT_APPLICABLE','NOT_RUN')}}


def entity_candidate(path, root, meta):
    rel = path.relative_to(root)
    if len(rel.parts)<2 or rel.parts[0]!='knowledge':
        return False
    if path.name in okf_lib.OKF_RESERVED_NAMES | {'README.md','extraction_report.md'} or path.name.endswith(('-meta.md','-entities.md')):
        return False
    if any(p in ('chapters','overview') for p in rel.parts[1:-1]):
        return False
    return bool(meta.get('id') or meta.get('hierarchy') or meta.get('type') in okf_lib.HIERARCHY_TO_TYPE.values() or re.match(r'^[A-Z]+-',path.stem))


def structure(report, path, root, layer, text, selected=True):
    meta, body = okf_lib.parse_frontmatter(text)
    if not entity_candidate(path,root,meta):
        return None
    errors=[]
    fm=okf_lib.FRONTMATTER_RE.match(text)
    if fm:
        try:
            meta=frontmatter.parse(fm[1])
        except ValueError as exc:
            errors.append(f'frontmatter YAML: {exc}')
    def fail(msg):
        errors.append(msg)
    for field in okf_lib.REQUIRED_FRONTMATTER_FIELDS:
        value = meta.get(field)
        if field=='tags':
            if not isinstance(value,list) or not all(isinstance(x,str) for x in value):
                fail('tags 必须为字符串数组')
        elif not isinstance(value,str) or not value.strip():
            fail(f'{field} 必须为非空字符串')
    # The project's simple YAML profile is intentional; do not silently accept duplicate keys.
    fm = okf_lib.FRONTMATTER_RE.match(text)
    if fm:
        keys = re.findall(r'^([\w-]+):',fm[1],re.M)
        for key,value in re.findall(r'^([\w-]+):\s*(.*?)\s*$',fm[1],re.M):
            if key in okf_lib.REQUIRED_FRONTMATTER_FIELDS and key!='tags' and re.fullmatch(r'(?:[-+]?\d+(?:\.\d+)?|true|false|True|False)',value):
                fail(f'{key} 必须为字符串，数值/布尔标量需显式引用')
        if len(set(keys))!=len(keys):
            fail('frontmatter 重复字段')
    eid=meta.get('id'); hierarchy=meta.get('hierarchy'); perspective=meta.get('perspective')
    if not isinstance(hierarchy,str) or hierarchy not in okf_lib.HIERARCHY_TO_TYPE:
        fail('非法 hierarchy')
    else:
        if meta.get('type')!=okf_lib.hierarchy_to_type(hierarchy):
            fail('type 与 hierarchy 不一致')
        if not isinstance(eid,str) or not eid.startswith(hierarchy+'-') or eid!=path.stem:
            fail('id、hierarchy 与文件名不一致')
        if perspective!=okf_lib.hierarchy_to_perspective(hierarchy) or path.relative_to(root).parts[1]!=perspective:
            fail('perspective 与 hierarchy/实体树位置不一致')
        if isinstance(eid,str) and okf_lib.hierarchy_first_layer(hierarchy,eid)!=layer:
            fail('实体首次定义层与显式逻辑层不一致')
    if meta.get('layer_scope')!=layer:
        fail('layer_scope 与显式逻辑层不一致')
    tags=meta.get('tags',[])
    if isinstance(tags,list) and (perspective not in tags or hierarchy not in tags):
        fail('tags 必须包含 perspective 与 hierarchy')
    timestamp=meta.get('timestamp')
    if not isinstance(timestamp,str) or not okf_lib.ISO8601_RE.fullmatch(timestamp):
        fail('timestamp 必须为 +08:00 ISO8601 字符串')
    else:
        try:
            datetime.fromisoformat(timestamp)
        except ValueError:
            fail('timestamp 日期或时间无效')
    clean=prose_only(body,keep_inline_code=True)
    headings=re.findall(r'^# (.*?)\s*$',clean,re.M)
    if headings != [meta.get('title')]:
        fail('必须有与 title 一致的唯一 H1')
    if re.findall(r'^## (.*?)\s*$',clean,re.M)!=list(okf_lib.REQUIRED_SECTIONS):
        fail('正文必须有四个有序中文 H2')
    if not re.search(r'<!-- markdownlint-disable-next-line MD025 -->\r?\n# ',body):
        fail('H1 前缺少 MD025 单行豁免')
    edges,declarations=relations.parse(body,prose_only)
    record={'id':eid if isinstance(eid,str) and eid else path.stem,'meta':meta,'path':path,'edges':edges,'declarations':declarations,
            'valid':not errors,'selected':selected,'root':root,'layer':layer,'body':body}
    if selected:
        if errors:
            for error in errors:
                report.add('structure','FAIL',path,'structure.profile',error)
        else:
            report.add('structure','PASS',path,'structure.profile','九字段、类型映射、显式逻辑层、文件名与四段正文通过')
        report.add('facts','NOT_RUN',path,'facts.review','业务事实及证据支持性需人工核实；格式通过不证明真实')
    return record


def path_check(report,e,catalog=None):
    if not e['valid'] or not e['selected']:
        return
    hierarchy=e['meta']['hierarchy']
    clean=prose_only(e['body'],keep_inline_code=True)
    for label,href in re.findall(r'\[([^\]]+)\]\(([^)]+)\)',clean):
        ids=relations.ID.findall(label)
        if len(ids)!=1 or not any(t==ids[0] for v,t,section in e['edges']):
            continue
        destination=urlsplit(href)
        if destination.scheme in ('http','https'):
            plain=urlunsplit((destination.scheme,destination.netloc,destination.path,'',''))
            try:
                matched=next(((parent,base) for parent,base in okf_cross_layer.collect_web_bases(e['root']) if plain.startswith(base+'/')),None)
                if not matched:
                    report.add('relations','UNVERIFIED',e['path'],'relations.link_identity','HTTP 目标不在已核实父链')
                    continue
                parent,base=matched
                target=(parent.local_doc_root()/unquote(plain[len(base)+1:])).resolve()
                if not contained(target,parent.local_doc_root().resolve()): continue
            except (OSError,UnicodeError,ValueError):
                report.add('relations','UNVERIFIED',e['path'],'relations.link_identity','父链不可读')
                continue
        elif destination.scheme:
            continue
        else:
            target=((e['root']/unquote(destination.path).lstrip('/')) if destination.path.startswith('/') else e['path'].parent/unquote(destination.path)).resolve()
            if not contained(target,e['root']): continue
        if target.is_file():
            try:
                target_meta,_=okf_lib.parse_frontmatter(report.snapshot.read(target))
                target_row=next((r for r in catalog.records if r['path']==target),None) if catalog else None
                if target_row and target_row['identity_status']!='PASS':
                    report.add('relations','UNVERIFIED',e['path'],'relations.link_identity',target_row['identity_evidence'])
                    continue
                target_id=target_row.get('full_id') if target_row else target_meta.get('id')
                resolved=catalog.resolve(ids[0])[0] if catalog else None
                if target_id!=ids[0] and (not resolved or resolved['path']!=target):
                    report.add('relations','FAIL',e['path'],'relations.link_identity',f'{ids[0]} 显示身份与目标文件 id 不一致')
            except (OSError,UnicodeError):
                pass  # Reference read diagnostics are emitted by references().
    if hierarchy in ('MS','API') and e.get('identity_status')!='PASS':
        return
    if hierarchy=='MS':
        relative=e['path'].relative_to(e['root']).as_posix()
        app=e['full_id'].split('/')[0]
        if relative==f'knowledge/application/{e["id"]}.md' or e['path'].parent.name==app:
            return  # 已核实归属、无重复身份的旧扁平落点只读兼容。
    if hierarchy=='API':
        full=e['full_id']; app,ms,_=full.split('/')
        actual=e['path'].relative_to(e['root']).as_posix()
        expected=okf_lib.entity_relpath('application',e['id'],path_parent=f'{app}/{ms}',bundle='application')
        legacy=f'knowledge/application/{ms}/{e["id"]}.md'
        if actual not in (expected,legacy):
            report.add('structure','FAIL',e['path'],'structure.layout',f'API 目录与已核实归属不一致，应为 {expected}（兼容旧路径 {legacy}）')
        return
    rel=e['path'].relative_to(e['root']).as_posix()
    # Physical chain is checked as layout only, never asserted as verified identity.
    parts=rel.split('/')[2:-1]
    if parts and parts[-1]==e['id']:
        parts=parts[:-1]
    path_parent='/'.join(p for p in parts if re.match(r'^[A-Z]+-',p)) or None
    declared = [t for v,t,s in e['edges'] if v=='parent'] or [t for v,t,s in e['edges'] if v=='implements_to']
    if declared and path_parent:
        # Only compare the host type that actually owns this nested path.
        last=path_parent.rsplit('/',1)[-1]
        same_type=[t for t in declared if relations.kind(t)==relations.kind(last)]
        if same_type and last not in same_type:
            report.add('structure','FAIL',e['path'],'structure.layout','目录宿主与正文 parent/implements_to 不一致')
    try:
        expected=okf_lib.entity_relpath(e['meta']['perspective'],e['id'],path_parent=path_parent,bundle=e['layer'])
        if expected!=rel:
            report.add('structure','FAIL',e['path'],'structure.layout',f'目录应为 {expected}')
    except ValueError as exc:
        report.add('structure','FAIL',e['path'],'structure.layout',str(exc))


def references(report,path,root,text):
    for href in markdown_links(text):
        url=urlsplit(href)
        if url.scheme in ('http','https'):
            # Only entity-style links within knowledge are federation references.
            if 'knowledge' not in path.relative_to(root).parts or '/knowledge/' not in url.path:
                report.add('references','UNVERIFIED',path,'references.remote',f'离线未读取 {href}')
                continue
            plain=urlunsplit((url.scheme,url.netloc,url.path,url.query,''))
            try:
                error=okf_cross_layer.validate_http_href(root,plain)
                bases=okf_cross_layer.collect_web_bases(root)
            except (OSError,ValueError,RuntimeError) as exc:
                report.add('references','FAIL',path,'references.http_form',str(exc)); continue
            if error:
                report.add('references','FAIL',path,'references.http_form',error); continue
            report.add('references','PASS',path,'references.http_form',href)
            matched=next(((parent,base) for parent,base in bases if plain.startswith(base+'/')),None)
            if matched:
                parent,base=matched
                external=parent.local_doc_root()
                target=(external/unquote(plain[len(base)+1:])).resolve()
                if not contained(target,external.resolve()):
                    report.add('references','FAIL',path,'references.boundary',href)
                elif not external.is_dir():
                    report.add('references','UNVERIFIED',path,'references.target',f'外库不可读: {external}')
                else:
                    check_target(report,path,target,unquote(url.fragment))
            continue
        if url.scheme or href.startswith('//'):
            report.add('references','NOT_APPLICABLE',path,'references.nonlocal',href); continue
        raw=unquote(url.path)
        target=((root/raw.lstrip('/')) if raw.startswith('/') else path.parent/raw).resolve() if raw else path
        allowed_meta = {str((AGENT/'knowledge'/f'{p}-meta.md').resolve()) for p in okf_lib.VALID_PERSPECTIVES}
        if str(target) in allowed_meta:
            check_target(report,path,target,unquote(url.fragment)); continue
        is_knowledge = path.relative_to(root).parts[0]=='knowledge'
        allowed_root = root/'knowledge' if is_knowledge else Path(report.context['repo'])
        if not is_knowledge and contained(target,AGENT):
            check_target(report,path,target,unquote(url.fragment)); continue
        if not contained(target,allowed_root):
            report.add('references','FAIL',path,'references.boundary',f'knowledge 不得引用外部文档: {href}'); continue
        check_target(report,path,target,unquote(url.fragment))


def check_target(report,source,target,anchor):
    if not target.exists():
        report.add('references','FAIL',source,'references.target',f'必需引用不存在: {target}'); return
    try:
        if target.is_file():
            if target.suffix=='.md':
                text=report.snapshot.read(target)
                if anchor and anchor not in markdown_anchors(text):
                    report.add('references','FAIL',source,'references.anchor',f'{target}#{anchor}'); return
            else:
                report.snapshot.files.setdefault(str(target),hashlib.sha256(target.read_bytes()).hexdigest())
        report.add('references','PASS',source,'references.target',f'{target}'+('#'+anchor if anchor else ''))
    except (OSError,UnicodeError) as exc:
        report.add('references','UNVERIFIED',source,'references.read',str(exc))


def federation_snapshot(report, root):
    """Capture inputs before helpers read them; retain absent paths to detect later creation."""
    report.context['external_revisions'] = {}
    pending=[root]
    visited=set()
    while pending:
        current=pending.pop()
        if current in visited:
            continue
        visited.add(current)
        cfg=next((p/'.docsconfig' for p in (current,*current.parents) if (p/'.docsconfig').is_file()),None)
        if cfg:
            report.snapshot.read(cfg)
            values=okf_cross_layer._config_values(cfg)
            home=Path(values.get('AGENT_ROOT','')).expanduser()
            report.snapshot.observe_optional(home/values.get('AGENT_DIR','')/'configs')
        text=report.snapshot.observe_optional(current/'knowledge-links.yaml')
        if text is None:
            continue
        entries=okf_cross_layer._parse_link_entries(text)
        parents=[entry for entry in entries if entry.get('type')=='parent']
        if len(parents)>1:
            report.add('context','FAIL',current,'context.federation','联邦只能登记一个 parent')
            continue
        for entry in parents:
            try:
                base=okf_cross_layer.resolve_link_path(current,entry.get('path',''))
                report.snapshot.observe_optional(base/'.docsconfig')
                doc=(base/entry.get('dir','')).resolve()
                if not contained(doc,base.resolve()):
                    raise ValueError('parent dir 越出登记仓库')
                report.context['external_revisions'][str(base)]=git_info(base) if base.is_dir() else {'commit':None,'version':None}
                if doc.is_dir():
                    pending.append(doc)
                else:
                    report.add('context','UNVERIFIED',doc,'context.federation','外库不可读')
            except (OSError,ValueError,RuntimeError) as exc:
                report.add('context','FAIL',current,'context.federation',str(exc))


def validate(start, bundle=None, layer=None, files=(), scopes=(), consumers=(), move_identity=None, to_owner=None):
    report=Report()
    try:
        report.context=resolve(start,bundle,layer,report.snapshot)
        report.context['rules']=rule_baseline(report.snapshot)
        report.snapshot.read(report.context['config'])
        root=Path(report.context['bundle'])
        if okf_lib.is_session_excluded(root):
            raise ValueError('会话工作稿不得作为校验范围')
        report.context['selection']={'files':list(map(str,files)),'scopes':list(map(str,scopes)),
                                     'partial':bool(files or scopes),'excluded':['隐藏目录','目录软链','会话工作稿']}
        selected_paths=[]
        for value in files:
            p=Path(value)
            p=(Path.cwd()/p if not p.is_absolute() else p).resolve()
            if not contained(p,root) or not p.is_file() or p.suffix!='.md' or okf_lib.is_session_excluded(p):
                raise ValueError(f'--file 不存在、越界或不是允许的 Markdown: {value}')
            selected_paths.append(p)
        scoped=[]
        for value in scopes:
            p=(root/value).resolve()
            if not contained(p,root) or not p.is_dir() or okf_lib.is_session_excluded(p):
                raise ValueError(f'--scope 不存在或越界: {value}')
            scoped.append(p)
    except (OSError,UnicodeError,ValueError,RuntimeError) as exc:
        report.add('context','FAIL',start,'context.config',str(exc)); return report.finish()
    report.add('context','PASS',root,'context.config','配置、逻辑层及范围已解析')
    try:
        federation_snapshot(report,root)
    except (OSError,UnicodeError,ValueError) as exc:
        report.add('context','UNVERIFIED',root,'context.federation_read',str(exc))
    profile=root/'governance/profile.md'
    if profile.is_file():
        try:
            report.snapshot.read(profile)
        except (OSError,UnicodeError) as exc:
            report.add('context','UNVERIFIED',profile,'context.profile_read',str(exc))
    report.add('context','UNVERIFIED',profile,'context.adoption','本次按记录的规则基线只读诊断；未自动确认旧库基线、Profile 采用或迁移完成')
    entities=[]; selected=[]
    paths=sorted(okf_lib.iter_bundle_markdown_files(root))
    report.snapshot.inventory(root,paths)
    for path in paths:
        if path.is_symlink():
            report.add('context','UNVERIFIED',path,'coverage.symlink','不读取文件软链'); continue
        chosen=not(files or scopes) or path.resolve() in selected_paths or any(contained(path.resolve(),s) for s in scoped)
        try:
            text=report.snapshot.read(path)
            record=structure(report,path,root,report.context['layer'],text,chosen)
            if record:
                entities.append(record)
            if chosen:
                selected.append(path)
                references(report,path,root,text)
        except (OSError,UnicodeError,ValueError) as exc:
            report.add('structure','FAIL',path,'structure.read',str(exc))
    if not selected:
        report.add('context','UNVERIFIED',root,'coverage.empty','没有可校验文件，不代表知识库通过')
    for requested in selected_paths:
        if requested not in selected:
            report.add('context','FAIL',requested,'coverage.selection','指定文件未被扫描（隐藏/软链/排除范围）')
    report.context['objects']=[{'path':str(e['path']),'id':e['id'],'nature':'template/example' if report.context['knowledge_type']=='meta' or 'EXAMPLE' in e['id'] or isinstance(e['meta'].get('tags'),list) and 'example' in e['meta']['tags'] else 'business','selected':e['selected']} for e in entities]
    from .federation import World
    from .identity import Catalog
    world=World(root,report.context['layer'],consumers,report.snapshot)
    local={e['path']:e for e in entities}
    world.records=[local.get(e['path'],e) for e in world.records]
    present={e['path'] for e in world.records}
    world.records.extend(e for e in entities if e['path'] not in present)
    world.catalog=Catalog(world.records,world.owner_candidates)
    report.context['coverage']=world.coverage
    report.context['external_revisions'].update(world.revisions)
    report.context['identities']=world.catalog.public()
    for issue in world.issues:
        report.add('context',issue['status'],issue['root'],'context.federation',issue['evidence'])
    for e in entities:
        report.add('identity',e['identity_status'],e['path'],'identity.resolved',e['identity_evidence'])
        path_check(report,e,world.catalog)
    for identity,rows in world.catalog.duplicates().items():
        report.add('identity','FAIL',identity,'identity.local_unique',f'已读范围有多个 SSOT: {[str(r["path"]) for r in rows]}')
    report.add('identity','UNVERIFIED',root,'identity.federation_unique','仅核对实际读取范围；未证明全联邦覆盖')
    # Canonicalize references only after evidence has uniquely resolved their ownership.
    for row in world.records:
        row['raw_edges']=list(row['edges'])
        canonical=[]
        for verb,target,section in row['edges']:
            resolved,status,_=world.target(row,target)
            canonical.append((verb,resolved['full_id'] if status=='PASS' else target,section))
        row['edges']=canonical
    def resolve_target(eid,index,source):
        return world.target(source,eid)
    relations.check(report,entities,resolve_target,lambda k:okf_lib.hierarchy_to_perspective('BSD' if k.startswith('BSD') else k))
    report.context['consumption']=world.consumption()
    for edge in report.context['consumption']:
        report.add('relations',edge['status'],edge['source_path'],'relations.consumption',f'{edge["source"]} → {edge["target"]}: {edge["evidence"]}')
    if move_identity or to_owner:
        from .migration import preview
        report.context['migration']=preview(world,move_identity,to_owner)
        for blocker in report.context['migration']['blockers']:
            report.add('identity','UNVERIFIED',move_identity,'migration.blocked',blocker)
    from .evidence import integrate
    try:
        integrate(report,root,entities)
    except (ValueError,OSError,UnicodeError,TypeError,KeyError) as exc:
        report.add('evidence','UNVERIFIED',root,'evidence.read',str(exc))
    return report.finish()


def render(result):
    lines=[f'统一知识校验: {result["status"]}',f'逻辑层: {result["context"].get("layer","未解析")}']
    for item in result['checks']:
        if item['status']!='PASS':
            lines.append(f'[{item["status"]}] {item["domain"]} {item["rule"]} {item["object"]}: {item["evidence"]}')
    lines.append('；'.join(f'{k}={v}' for k,v in result['summary'].items()))
    if result['status']=='INCOMPLETE':
        lines.append('仅报告已执行范围；仍有待核实/未执行项，不能宣称整体通过。')
    return '\n'.join(lines)
