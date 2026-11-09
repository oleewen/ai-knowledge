#!/usr/bin/env python3
"""Unified read-only knowledge validation CLI."""
import argparse
import json
from pathlib import Path
from knowledge_validation.core import validate, render, Report


class Parser(argparse.ArgumentParser):
    def error(self, message):
        raise ValueError(message)


def main(argv=None):
    import sys
    argv = sys.argv[1:] if argv is None else argv
    parser=Parser(description=__doc__)
    parser.add_argument('--repo',type=Path,default=Path.cwd())
    parser.add_argument('--bundle')
    parser.add_argument('--layer')
    parser.add_argument('--file',action='append',default=[])
    parser.add_argument('--scope',action='append',default=[],help='文档根内的目录，可重复')
    parser.add_argument('--consumer-root',action='append',default=[],help='追加消费库文档根，可重复；递归已登记 child')
    parser.add_argument('--move-identity',help='只读预览需要变更归属的 MS/API 完整身份')
    parser.add_argument('--to-owner',help='迁移预览的新 APP 或完整 MS 身份')
    parser.add_argument('--json',action='store_true',help='stdout 仅输出一个 JSON 报告')
    try:
        args=parser.parse_args(argv)
        if bool(args.move_identity)!=bool(args.to_owner):
            raise ValueError('--move-identity 与 --to-owner 必须同时给出')
        result=validate(args.repo,args.bundle,args.layer,args.file,args.scope,args.consumer_root,args.move_identity,args.to_owner)
    except ValueError as exc:
        report=Report(); report.add('context','FAIL','CLI','context.arguments',str(exc)); result=report.finish()
    print(json.dumps(result,ensure_ascii=False,indent=2) if '--json' in argv else render(result))
    return 1 if result['summary']['FAIL'] else 0


if __name__=='__main__':
    raise SystemExit(main())
