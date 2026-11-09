#!/usr/bin/env python3
"""Upgrade diagnostics and final read-only compatibility gate."""
import argparse
import json
from pathlib import Path
import sys
from knowledge_validation.upgrade import check


def main(argv=None):
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--doc',type=Path,required=True)
    p.add_argument('--assessment',type=Path)
    p.add_argument('--diagnostic',action='store_true',help='诊断不阻塞模板修复；仍明确输出未闭环状态')
    a=p.parse_args(argv)
    try:
        assessment=json.loads(a.assessment.read_text()) if a.assessment else None
        result=check(a.doc,assessment)
        print(json.dumps(result,ensure_ascii=False,indent=2))
        return 0 if a.diagnostic or result['can_advance_version'] else 1
    except (OSError,ValueError,TypeError,KeyError,RuntimeError) as exc:
        print(json.dumps({'status':'INCOMPLETE','can_advance_version':False,'error':str(exc)},ensure_ascii=False))
        return 1

if __name__=='__main__': raise SystemExit(main())
