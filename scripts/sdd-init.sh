#!/usr/bin/env bash
# sdd-init：从 ai-sdd-docs 仓库初始化当前目录的 SDD 开发环境
# 用法（在仓库内）：REPO_ROOT=/path/to/ai-sdd-docs ./scripts/sdd-init.sh [选项] [目标目录]
# 用法（bootstrap）：由 scripts/sdd-init-bootstrap.sh 拉取仓库后调用，目标目录默认为当前目录

set -euo pipefail

# 默认值
REPO_ROOT="${REPO_ROOT:-}"
TARGET_DIR="${TARGET_DIR:-$(pwd)}"
DOCS_DIR="${DOCS_DIR:-docs}"
AI_DIR="${AI_DIR:-.ai}"
CURSOR_DIR="${CURSOR_DIR:-.cursor}"
SKILLS_OPT="${SKILLS_OPT:-all}"
DRY_RUN="${DRY_RUN:-0}"
GIT_REPO_URL="${GIT_REPO_URL:-https://github.com/oleewen/ai-sdd-docs.git}"

# 已知的 Cursor Skill 列表（与 .cursor/skills 下目录名一致）
CURSOR_SKILLS=(knowledge-build sdd-solution sdd-analysis sdd-prd sdd-design sdd-test)

usage() {
  cat <<'USAGE'
用法: sdd-init [选项] [目标目录]

从 ai-sdd-docs 仓库初始化当前（或指定）目录的 SDD 开发环境：
  1) 将 .ai 目录拷贝到目标目录的 .ai（可配置）
  2) 为 Agent 选用 .{agent} 目录下的 skills（及命令说明），写入目标目录的 .{agent}/skills/
  3) 将仓库内不以'.'开头的目录和文件拷贝到目标目录的 docs 文件夹（可配置）

选项:
  --docs-dir=DIR      文档根目录，相对目标目录（默认: docs）
  --ai-dir=DIR        .ai 配置目录，相对目标目录（默认: .ai）
  --agent-dir=DIR     Agent 配置目录，相对目标目录（默认: .agent）
  --skills=LIST       要安装的 Agent skills，逗号分隔或 all（默认: all）
                      可选: knowledge-build, sdd-solution, sdd-analysis, sdd-prd, sdd-design, sdd-test
  --dry-run           仅打印将要执行的操作，不实际拷贝
  -h, --help          显示此帮助

环境变量（供 bootstrap 使用）:
  REPO_ROOT           仓库根目录（克隆后的路径），必须设置
  TARGET_DIR          目标目录，未传参时也可由此指定
  DRY_RUN=1           与 --dry-run 等价
USAGE
}

cp_safe() {
  local src="$1" dst="$2"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[dry-run] 拷贝: $src -> $dst"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  cp -R "$src" "$dst"
}

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --docs-dir=*)   DOCS_DIR="${1#*=}"; shift ;;
    --ai-dir=*)     AI_DIR="${1#*=}"; shift ;;
    --cursor-dir=*) CURSOR_DIR="${1#*=}"; shift ;;
    --skills=*)     SKILLS_OPT="${1#*=}"; shift ;;
    --dry-run)      DRY_RUN=1; shift ;;
    -h|--help)      usage; exit 0 ;;
    -*)
      echo "未知选项: $1" >&2
      usage >&2
      exit 1
      ;;
    *)
      TARGET_DIR="$1"
      shift
      ;;
  esac
done

# 若由 bootstrap 调用，REPO_ROOT 已设置；否则尝试用脚本所在目录推断仓库根
if [[ -z "$REPO_ROOT" ]]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  if [[ ! -d "$REPO_ROOT/.ai" ]] || [[ ! -d "$REPO_ROOT/.cursor" ]]; then
    echo "错误: 未设置 REPO_ROOT 且当前推断的仓库根目录不存在 .ai 或 .cursor: $REPO_ROOT" >&2
    echo "请通过 bootstrap 方式运行，或设置 REPO_ROOT 后重试。" >&2
    exit 1
  fi
fi

if [[ ! -d "$REPO_ROOT" ]]; then
  echo "错误: 仓库根目录不存在: $REPO_ROOT" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DOCS_ABS="$TARGET_DIR/$DOCS_DIR"
AI_ABS="$TARGET_DIR/$AI_DIR"
CURSOR_ABS="$TARGET_DIR/$CURSOR_DIR"

echo "sdd-init 配置:"
echo "  仓库根: $REPO_ROOT"
echo "  目标目录: $TARGET_DIR"
echo "  文档目录: $DOCS_DIR -> $DOCS_ABS"
echo "  .ai 目录: $AI_DIR -> $AI_ABS"
echo "  Cursor 目录: $CURSOR_DIR -> $CURSOR_ABS"
echo "  Skills: $SKILLS_OPT"
[[ "$DRY_RUN" == "1" ]] && echo "  [dry-run 模式]"
echo ""

# 1) 拷贝除 .ai、.cursor、.git、scripts 外的内容到 docs
echo ">>> 1/3 拷贝文档与知识库到 $DOCS_DIR ..."
for item in "$REPO_ROOT"/*; do
  [[ -e "$item" ]] || continue
  name="$(basename "$item")"
  case "$name" in
    .ai|.cursor|.git) continue ;;
    *)
      cp_safe "$item" "$DOCS_ABS/$name"
      ;;
  esac
done
# 拷贝根目录下的隐藏文件（除 .ai .cursor .git 外）
for item in "$REPO_ROOT"/.*; do
  [[ -e "$item" ]] || continue
  name="$(basename "$item")"
  [[ "$name" == "." || "$name" == ".." ]] && continue
  case "$name" in
    .ai|.cursor|.git) continue ;;
    *)
      cp_safe "$item" "$DOCS_ABS/$name"
      ;;
  esac
done
echo "  完成."
echo ""

# 2) 拷贝 .ai 到目标 .ai
echo ">>> 2/3 拷贝 .ai 配置到 $AI_DIR ..."
cp_safe "$REPO_ROOT/.ai" "$AI_ABS"
echo "  完成."
echo ""

# 3) 为 Cursor 生成 skill 与 command 说明
echo ">>> 3/3 生成 Cursor 的 skills 与命令说明到 $CURSOR_DIR ..."
if [[ "$DRY_RUN" != "1" ]]; then
  mkdir -p "$CURSOR_ABS/skills"
fi

# 解析要安装的 skills
declare -a INSTALL_SKILLS
if [[ "$SKILLS_OPT" == "all" ]]; then
  INSTALL_SKILLS=("${CURSOR_SKILLS[@]}")
else
  IFS=',' read -ra INSTALL_SKILLS <<< "$SKILLS_OPT"
fi

for skill in "${INSTALL_SKILLS[@]}"; do
  skill="${skill// /}"
  [[ -z "$skill" ]] && continue
  src_skill="$REPO_ROOT/.cursor/skills/$skill"
  if [[ ! -d "$src_skill" ]]; then
    echo "  跳过不存在的 skill: $skill"
    continue
  fi
  cp_safe "$src_skill" "$CURSOR_ABS/skills/$skill"
  echo "  已安装 skill: $skill"
done

# 生成 .cursor/README.md（仅包含已安装的 command/skill 说明）
CURSOR_README="$CURSOR_ABS/README.md"
if [[ "$DRY_RUN" != "1" ]]; then
  mkdir -p "$CURSOR_ABS"
  cat > "$CURSOR_README" <<'HEADER'
# Cursor 项目配置

## Slash 命令（Skills）

| 命令 | 说明 |
|------|------|
HEADER
  for skill in "${INSTALL_SKILLS[@]}"; do
    skill="${skill// /}"
    [[ -z "$skill" ]] && continue
    skill_file="$CURSOR_ABS/skills/$skill/SKILL.md"
    if [[ -f "$skill_file" ]]; then
      desc=$(awk '/^description:/{getline; gsub(/^[ \t]+|[ \t]+$/,""); print; exit}' "$skill_file" 2>/dev/null)
      [[ -z "$desc" ]] && desc="见 skills/$skill/SKILL.md"
      echo "| \`/$skill\` | $desc |" >> "$CURSOR_README"
    fi
  done
  cat >> "$CURSOR_README" <<'FOOTER'

在 Chat 中输入 `/` 后选择对应命令即可调用；或使用 `@技能名` 将 Skill 作为上下文附加。
FOOTER
  echo "  已生成 $CURSOR_DIR/README.md（命令索引）"
fi
echo "  完成."
echo ""

echo "sdd-init 已完成。"
echo "  - 文档与知识库: $DOCS_ABS"
echo "  - AI 配置: $AI_ABS"
echo "  - Cursor skills: $CURSOR_ABS/skills/"
echo "  - 命令说明: $CURSOR_README"
