#!/usr/bin/env bash
# lib/logging.sh — 日志流与命令探测；由 log-io.sh 管理加载。

log()   { printf '%s\n'       "$*" >&2; }
info()  { printf '信息: %s\n'  "$*" >&2; }
warn()  { printf '警告: %s\n'  "$*" >&2; }
error() { printf '错误: %s\n' "$*" >&2; exit 1; }

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

have_perl() {
  have_cmd perl
}
