"""Strict reader for the project's single-line YAML scalar/inline-list profile.

Unsupported YAML constructs fail explicitly; they never become string values.
"""
import json
import re


def strip_comment(value):
    quote=None
    escaped=False
    for i,char in enumerate(value):
        if quote:
            if escaped:
                escaped=False
            elif char=='\\' and quote=='"':
                escaped=True
            elif char==quote:
                quote=None
        elif char in ('"',"'") and (i==0 or value[i-1] in ' [,'):
            quote=char
        elif char=='#' and (i==0 or value[i-1].isspace()):
            return value[:i].rstrip()
    if quote:
        raise ValueError('未闭合 YAML 引号')
    return value.strip()


def scalar(raw):
    value=strip_comment(raw.strip())
    if value.startswith('"'):
        try:
            parsed=json.loads(value)
        except ValueError as exc:
            raise ValueError('无效双引号字符串或不支持的 YAML 转义') from exc
        if not isinstance(parsed,str):
            raise ValueError('预期字符串')
        return parsed
    if value.startswith("'"):
        if not re.fullmatch(r"'(?:[^']|'')*'",value):
            raise ValueError('无效单引号字符串')
        return value[1:-1].replace("''", "'")
    if value.startswith('['):
        if not value.endswith(']'):
            raise ValueError('未闭合 YAML 列表')
        inner=value[1:-1]
        parts=[]; current=''; quote=None; escaped=False
        for char in inner:
            if quote:
                current+=char
                if escaped:
                    escaped=False
                elif char=='\\' and quote=='"':
                    escaped=True
                elif char==quote:
                    quote=None
            elif char in ('"',"'"):
                quote=char; current+=char
            elif char==',':
                parts.append(current); current=''
            else:
                current+=char
        if quote:
            raise ValueError('未闭合列表引号')
        if current.strip():
            parts.append(current)
        return [scalar(part) for part in parts]
    if not value or value.lower() in ('null','~'):
        return None
    if value.lower() in ('true','false','yes','no','on','off'):
        return value.lower() in ('true','yes','on')
    if re.fullmatch(r'[-+]?(?:\d[\d_]*(?:\.\d*)?|\.\d+)(?:[eE][-+]?\d+)?',value):
        return float(value.replace('_',''))
    if value.startswith(('{','}','&','*','!','|','>','@','`',']','%')) or ': ' in value:
        raise ValueError('不支持 YAML 映射、锚点、标签或块标量；使用单行字符串/行内列表')
    return value


def parse(block):
    meta={}
    for line in block.splitlines():
        if not line.strip() or line.lstrip().startswith('#'):
            continue
        match=re.fullmatch(r'([A-Za-z_][A-Za-z0-9_-]*):(?:\s+(.*))?',line)
        if not match:
            raise ValueError('frontmatter 仅支持顶层单行字段与行内列表')
        key,value=match.groups()
        if key in meta:
            raise ValueError(f'重复 YAML 字段: {key}')
        meta[key]=scalar(value or '')
    return meta
