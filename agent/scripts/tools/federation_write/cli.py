"""CLI bridge used by docs-link and docs-install; no Git writes or network calls."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys

from .operations import Plan, Locks, fingerprint, resume, load_journal, verify_record


def remote(repo):
    p=subprocess.run(['git','-C',str(repo),'remote','get-url','origin'],capture_output=True,text=True)
    if p.returncode: raise ValueError('目标仓库缺少 origin remote')
    return p.stdout.strip()


def require_git_root(repo):
    result=subprocess.run(['git','-C',str(repo),'rev-parse','--show-toplevel'],capture_output=True,text=True)
    if result.returncode or Path(result.stdout.strip()).resolve()!=Path(repo).resolve():
        raise ValueError('须使用实际 Git 仓库根')


def show(record):
    print(json.dumps(record,ensure_ascii=False,indent=2))


def guard_install(doc, command):
    """Keep the same kernel lock across installer reset/copy/meta child processes."""
    with Locks([doc]) as locks:
        locks.pending()
        inherited={root:handle.fileno() for root,_,handle in locks.handles}
        env={**os.environ,'KNOWLEDGE_WRITE_LOCKS':json.dumps(inherited),
             'KNOWLEDGE_INSTALL_GUARD':str(Path(doc).resolve()),'PYTHONDONTWRITEBYTECODE':'1'}
        result=subprocess.run(command,env=env,pass_fds=tuple(inherited.values()))
        locks.verify()
        return result.returncode


def main(argv=None):
    p=argparse.ArgumentParser()
    sub=p.add_subparsers(dest='command',required=True)
    guard=sub.add_parser('guard-install'); guard.add_argument('doc'); guard.add_argument('argv',nargs=argparse.REMAINDER)
    check=sub.add_parser('guard-check'); check.add_argument('doc')
    preview=sub.add_parser('guard-preview'); preview.add_argument('doc')
    old=sub.add_parser('read-old'); old.add_argument('file')
    verify=sub.add_parser('verify-manifest'); verify.add_argument('doc')
    fp=sub.add_parser('fingerprint'); fp.add_argument('file')
    meta=sub.add_parser('meta-upsert'); meta.add_argument('doc'); meta.add_argument('repository'); meta.add_argument('path'); meta.add_argument('layer'); meta.add_argument('--dry-run',action='store_true')
    meta.add_argument('--baseline')
    legacy=sub.add_parser('legacy')
    legacy.add_argument('--source',required=True); legacy.add_argument('--target-doc',default='')
    legacy.add_argument('--action',choices=['link','unlink','repair'],required=True)
    legacy.add_argument('--slot',required=True); legacy.add_argument('--old-slot',default='')
    legacy.add_argument('--source-entry',nargs=6,action='append',default=[])
    legacy.add_argument('--target-entry',nargs=6,action='append',default=[])
    legacy.add_argument('--baseline',nargs=2,action='append',default=[])
    legacy.add_argument('--rewrite-http',action='store_true'); legacy.add_argument('--downgrade-http',action='store_true')
    legacy.add_argument('--consumer-root',action='append',default=[]); legacy.add_argument('--dry-run',action='store_true')
    direct=sub.add_parser('direct')
    actions=direct.add_mutually_exclusive_group(required=True)
    actions.add_argument('--dependency-add',action='store_true'); actions.add_argument('--dependency-remove',action='store_true')
    actions.add_argument('--resume'); actions.add_argument('--operation-check')
    direct.add_argument('--target'); direct.add_argument('--entity-id',action='append',default=[])
    direct.add_argument('--clear',action='store_true'); direct.add_argument('--dry-run',action='store_true')
    direct.add_argument('--consumer-root',action='append',default=[])
    a=p.parse_args(argv)
    try:
        if a.command=='guard-install':
            command=a.argv[1:] if a.argv and a.argv[0]=='--' else a.argv
            if not command: raise ValueError('安装 guard 缺少命令')
            return guard_install(a.doc,command)
        if a.command=='guard-preview':
            with Locks([a.doc],readonly=True) as locks: locks.pending()
            return 0
        if a.command=='guard-check':
            root=str(Path(a.doc).resolve())
            if root not in json.loads(os.environ.get('KNOWLEDGE_WRITE_LOCKS','{}')):
                raise ValueError('安装器未持有文档根锁')
            with Locks([root]) as locks: locks.pending()
            return 0
        if a.command=='fingerprint': show(fingerprint(a.file)); return 0
        # Configuration-only installs and lock/fingerprint checks do not need
        # entity parsing or the optional skill scripts in an installed layout.
        from .manifests import read, context, dependency_plan, meta_plan, validate_paths
        if a.command=='read-old':
            for e in read(a.file):
                if e['type']=='dependency': continue
                print('\x1f'.join(e.get(k,'') for k in ('path','repository','dir','name','label','type')))
            return 0
        if a.command=='verify-manifest':
            entries=read(Path(a.doc)/'knowledge-links.yaml'); validate_paths(a.doc,entries)
            if any(e['type']!='meta' and not e.get('name') for e in entries): raise ValueError('清单缺少 name')
            return 0
        if a.command=='legacy':
            from .legacy import legacy_plan
            show(legacy_plan(a).execute(dry_run=a.dry_run)); return 0
        if a.command=='meta-upsert':
            plan=meta_plan(a.doc,a.repository,a.path,a.layer)
            if a.baseline and plan.record['checks'][str(Path(a.doc).resolve()/'knowledge-links.yaml')]!=json.loads(a.baseline):
                raise ValueError('安装清单指纹变化，保留外部编辑')
            show(plan.execute(dry_run=a.dry_run)); return 0
        from knowledge_validation.context import resolve
        ctx=resolve(Path.cwd())
        if Path.cwd().resolve()!=Path(ctx['repo']).resolve(): raise ValueError('须在源 Git 仓库根执行')
        require_git_root(Path.cwd())
        doc=Path(ctx['doc_dir']).resolve()
        if a.resume or a.operation_check:
            if a.target or a.entity_id or a.clear or a.consumer_root: raise ValueError('续办/复核使用原计划，不能追加参数')
            oid=a.resume or a.operation_check
            if not re.fullmatch(r'[0-9a-f]{32}',oid): raise ValueError('非法操作 ID')
            journal=doc/'governance/operations'/f'{oid}.yaml'
            if a.resume: show(resume(journal,dry_run=a.dry_run))
            else:
                record=load_journal(journal)
                if record['state'] not in ('complete','pending_validation') or set(record.get('done',[]))!={s['path'] for s in record['steps']}:
                    raise ValueError('操作步骤未完成；先按操作 ID 续办')
                from .validation import validate_result
                result=validate_result(record) if record['validation'] else {'complete':True,'issues':[]}
                show(result)
                return 0 if result['complete'] else 1
            return 0
        if not a.target: raise ValueError('消费登记须指定 --target')
        target=Path(a.target).resolve()
        require_git_root(target)
        tc=resolve(target)
        if Path(tc['repo']).resolve()!=target: raise ValueError('target 须为目标仓库根')
        target_doc=Path(tc['doc_dir']).resolve()
        repository=remote(target)
        show(dependency_plan(doc,target_doc,repository,a.entity_id,remove=a.dependency_remove,clear=a.clear,consumers=a.consumer_root).execute(dry_run=a.dry_run))
        return 0
    except (OSError,ValueError,RuntimeError,KeyError) as exc:
        print(f'错误: {exc}',file=sys.stderr)
        return 1
