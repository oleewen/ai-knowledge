#!/usr/bin/env python3
"""Run isolated behavior scenarios with an executor and an independent scorer."""
import argparse, json, os, shutil, subprocess, tempfile
from datetime import datetime, timezone
from pathlib import Path

ROOT=Path(__file__).resolve().parents[4]
HERE=Path(__file__).resolve().parent
SCENARIOS=json.loads((HERE/'scenarios.json').read_text())

def run_codex(prompt, work, output, timeout, model, events, sandbox='workspace-write'):
    env=os.environ.copy()
    env['HOME']=str(work/'home'); (work/'home').mkdir(exist_ok=True)
    codex_home=work/'codex-home'; codex_home.mkdir(exist_ok=True)
    auth=Path('/Users/only/.codex/auth.json')
    if auth.is_file(): shutil.copy2(auth,codex_home/'auth.json')
    env['CODEX_HOME']=str(codex_home)
    cmd=['codex','exec','--ignore-user-config','--ignore-rules','--ephemeral','--skip-git-repo-check',
         '--sandbox',sandbox,'--cd',str(work),'--add-dir',str(work),'--model',model,
         '--color','never','--json','--output-last-message',str(output)]
    try:
        p=subprocess.run(cmd,input=prompt,text=True,capture_output=True,timeout=timeout,env=env)
    except subprocess.TimeoutExpired as exc:
        def as_text(value):
            return value.decode(errors='replace') if isinstance(value,bytes) else (value or '')
        events.write_text(as_text(exc.stdout))
        (work/(events.stem+'-stderr.log')).write_text(as_text(exc.stderr))
        return {'status':'not_run','error':f'timeout after {timeout}s','stdout':exc.stdout or '','stderr':exc.stderr or ''}
    events.write_text(p.stdout or '')
    (work/(events.stem+'-stderr.log')).write_text(p.stderr or '')
    if p.returncode!=0:
        return {'status':'not_run','error':f'codex exit {p.returncode}','stdout':p.stdout[-4000:],'stderr':p.stderr[-4000:]}
    return {'status':'completed','stdout':p.stdout[-4000:],'stderr':p.stderr[-4000:]}

def main():
    ap=argparse.ArgumentParser(); ap.add_argument('--out',type=Path,default=HERE/'results-2026-11-09.json'); ap.add_argument('--id',action='append',help='只运行指定场景 ID，可重复'); ap.add_argument('--timeout',type=int,default=600); ap.add_argument('--limit',type=int); ap.add_argument('--start',type=int,default=0); ap.add_argument('--model',default='gpt-5.6-luna')
    args=ap.parse_args(); results=[]
    if args.id:
        by_id={case['id']:case for case in SCENARIOS}; unknown=[x for x in args.id if x not in by_id]
        if unknown: ap.error(f'未知场景 ID: {", ".join(unknown)}')
        selected=[by_id[x] for x in dict.fromkeys(args.id)]
    else:
        selected=SCENARIOS[args.start:args.start+args.limit if args.limit is not None else None]
    for index,case in enumerate(selected,1):
        run_dir=Path(tempfile.mkdtemp(prefix=f'behavior-{case["id"]}-'))
        (run_dir/'README.md').write_text('isolated behavior fixture\n')
        (run_dir/'scenario.json').write_text(json.dumps(case,ensure_ascii=False,indent=2))
        meta=run_dir/'meta'; shutil.copytree(ROOT/'agent',meta/'agent',ignore=shutil.ignore_patterns('__pycache__','*.pyc','.pytest_cache'))
        prompt=f'''你在隔离临时目录 {run_dir} 中执行行为评测。只允许读写该目录；不得访问、修改或引用真实工作区中的业务文件。\nBash 5 固定入口：/opt/homebrew/opt/bash/bin/bash；调用仓库脚本必须显式使用该入口，不得用系统 bash 3.2 作为环境失败前提。\n技能入口：{meta}/{case['entry']}；元库根：{meta}\n用户场景：{case['prompt']}\n评测约束：必须实际执行可用的本地命令和文件操作；关键命令的原始输出应保留在隔离目录，供独立评分复核。若前提不具备，写 behavior.json，status 为 not_run 并说明原因。完成后确保 behavior.json 是合法 JSON。'''
        executor=run_codex(prompt,run_dir,run_dir/'executor-output.txt',args.timeout,args.model,run_dir/'executor-events.jsonl')
        marker=run_dir/'behavior.json'
        if executor['status']!='completed' or not marker.exists():
            results.append({'eval_id':case['id'],'status':'not_run','error':executor.get('error','behavior.json missing'),'artifact':run_dir.name}); continue
        try: marker_data=json.loads(marker.read_text())
        except Exception as exc:
            results.append({'eval_id':case['id'],'status':'failed','error':f'invalid behavior.json: {exc}','artifact':run_dir.name}); continue
        score_prompt=f'''你是独立评分器。只读取当前隔离目录中的 behavior.json、scenario.json、executor-output.txt、executor-events.jsonl、executor-events-stderr.log 及其他隔离产物，不能读取真实工作区。你只能新建 score.json，不得修改已有文件。\n逐项检查 scenario.marker.required 是否与 behavior.json 对应；只有全部匹配且 status=passed 才输出 score.json: {{"status":"passed","failed":[]}}，否则输出 {{"status":"failed","failed":[...],"reason":"..."}}。不要相信 behavior.json 的叙述，必须逐项检查隔离产物中的文件内容、结构及命令证据；若证据不足或互相矛盾标 failed。'''
        scorer=run_codex(score_prompt,run_dir,run_dir/'scorer-output.txt',args.timeout,args.model,run_dir/'scorer-events.jsonl','workspace-write')
        score_file=run_dir/'score.json'
        if scorer['status']!='completed':
            results.append({'eval_id':case['id'],'status':'not_run','error':scorer.get('error','scorer failed'),'artifact':run_dir.name}); continue
        if not score_file.exists():
            try: score=json.loads((run_dir/'scorer-output.txt').read_text())
            except Exception as exc:
                results.append({'eval_id':case['id'],'status':'not_run','error':f'score.json missing: {exc}','artifact':run_dir.name}); continue
        else:
            try: score=json.loads(score_file.read_text())
            except Exception as exc: results.append({'eval_id':case['id'],'status':'failed','error':f'invalid score.json: {exc}','artifact':run_dir.name}); continue
        results.append({'eval_id':case['id'],'status':score.get('status','failed'),'failed':score.get('failed',[]),'artifact':run_dir.name})
        print(f'[{index}/{len(selected)}] {case["id"]}: {results[-1]["status"]}',flush=True)
    payload={'schema':1,'run_at':datetime.now(timezone.utc).isoformat(),'scenario_count':len(results),'results':results,'limits':['行为评测仅覆盖临时夹具；未执行项为 not_run；不代表元仓四层模板全绿']}
    args.out.write_text(json.dumps(payload,ensure_ascii=False,indent=2)+'\n')
    print(json.dumps({'out':str(args.out),'summary':{s:sum(r['status']==s for r in results) for s in ('passed','failed','not_run')}},ensure_ascii=False))
    return 0 if all(r['status']=='passed' for r in results) else 1
if __name__=='__main__': raise SystemExit(main())
