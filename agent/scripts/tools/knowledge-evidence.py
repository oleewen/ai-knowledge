#!/usr/bin/env python3
"""Evidence metadata lifecycle; create/update/refresh write only with --apply."""
import argparse
import json
from pathlib import Path
import sys
from knowledge_validation import evidence_write as writer
from federation_write.operations import resume


def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('action',choices=('check','create','update','refresh','resume'))
    p.add_argument('--doc',type=Path,required=True)
    p.add_argument('--input',type=Path,help='JSON metadata or status changes; source bodies are never persisted')
    p.add_argument('--id'); p.add_argument('--operation-id')
    mode=p.add_mutually_exclusive_group(); mode.add_argument('--apply',action='store_true'); mode.add_argument('--dry-run',action='store_true')
    a=p.parse_args(argv)
    try:
        if a.action=='check':
            if a.apply or a.input or a.id or a.operation_id: raise ValueError('check 只读且不接受写入参数')
            result=writer.check(a.doc); print(json.dumps(result,ensure_ascii=False,indent=2)); return 0 if result['status']=='PASS' else 1
        if a.action=='resume':
            import re
            if not a.operation_id or not re.fullmatch('[0-9a-f]{32}',a.operation_id) or a.input or a.id: raise ValueError('resume 仅接受原操作 ID')
            result=resume(a.doc.resolve()/'governance/operations'/f'{a.operation_id}.yaml',dry_run=not a.apply)
        else:
            if a.operation_id: raise ValueError('新动作不接受原操作 ID')
            data=json.loads(a.input.read_text()) if a.input else None
            if a.action=='create' and data is not None and not a.id: plan=writer.create_plan(a.doc,data)
            elif a.action=='update' and data is not None and a.id: plan=writer.update_plan(a.doc,a.id,data)
            elif a.action=='refresh' and data is None and not a.id: plan=writer.refresh_plan(a.doc)
            else: raise ValueError('create/update 须提供 --input；update 须提供 --id；refresh 不接受输入')
            result=plan.execute(dry_run=not a.apply)
        print(json.dumps({k:v for k,v in result.items() if not k.startswith('_')},ensure_ascii=False,indent=2)); return 0
    except (ValueError,OSError,KeyError,TypeError,RuntimeError) as exc:
        print(f'错误: {exc}',file=sys.stderr); return 1

if __name__=='__main__': raise SystemExit(main())
