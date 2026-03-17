#!/usr/bin/env bash
# sdx-init：从 ai-sdd-docs 仓库初始化当前目录的 SDD 开发环境
# 用法（在仓库内）：REPO_ROOT=/path/to/ai-sdd-docs ./scripts/sdx-init.sh [选项] [目标目录]
# 用法（bootstrap）：由 scripts/sdx-init-bootstrap.sh 拉取仓库后调用，目标目录默认为当前目录

set -euo pipefail

# 默认值
REPO_ROOT="${REPO_ROOT:-}"
TARGET_DIR="${TARGET_DIR:-$(pwd)}"
DOCS_DIR="${DOCS_DIR:-docs/system}"
# 独立模式：application（单目录，无 app-APPNAME）；联邦模式：applications/app-APPNAME
SDX_MODE="${SDX_MODE:-standalone}"
AI_DIR="${AI_DIR:-.ai}"
CURSOR_DIR="${CURSOR_DIR:-.cursor}"
TREA_DIR="${TREA_DIR:-.trea}"
# skills 默认行为：若未指定 --skills，仅安装 agent/knowledge 相关 skill（不含 sdx-*）；--skills=all 安装全部
SKILLS_OPT="${SKILLS_OPT:-}"
DRY_RUN="${DRY_RUN:-0}"
FORCE="${FORCE:-0}"
# 要初始化的 Agent 列表：cursor,trea 或 all（仓库中存在的均初始化）
AGENTS_OPT="${AGENTS_OPT:-cursor}"
# 默认：仅拷贝 knowledge 目录及 system 根目录同级文件到目标 docs/system；--ds=full 拷贝完整 system
DOCS_SCOPE="${DOCS_SCOPE:-knowledge-only}"
# 默认不包含 .ai/rules 下的 solution、analysis 模板
AI_RULES_SCOPE="${AI_RULES_SCOPE:-no-solution-analysis}"
GIT_REPO_URL="${GIT_REPO_URL:-https://github.com/oleewen/ai-sdd-docs.git}"

# 支持的 Agent：目录名与仓库内 .<name> 对应
SUPPORTED_AGENTS=(cursor trea)
# 默认安装的 skill 列表（仅 agent、knowledge 相关，不含 sdx-*）；若仓库中无匹配则用此默认
AGENT_KNOWLEDGE_SKILLS_DEFAULT=(knowledge-build agent-guide)

usage() {
  cat <<'USAGE'
用法: sdx-init [选项] [目标目录]

从 ai-sdd-docs 仓库初始化当前（或指定）目录的 SDD 开发环境：
  1) 文档：仓库 system 拷贝到 docs/system（可改 --dd）；应用知识库按模式：独立模式为 docs/application（单目录），联邦模式为 docs/applications 并在其下新建 app-<工程目录名>；联邦模式还会在目标 .gitignore 中忽略文档根目录，并将当前仓库 .git 拷贝至文档根
  2) 将 .ai 目录拷贝到目标目录的 {ai-dir}（默认不包含 rules 下的 solution、analysis）
  3) 将选定的 skills 安装到 {ai-dir}/skills，并为选定的 Agent（Cursor、Trea 等）生成/拷贝配置

选项:
  --mode=MODE         初始化模式：standalone（独立，默认）| federation（联邦）
  --dd=DIR            system 文档目录，相对目标目录（默认: docs/system）；应用目录为同级的 application 或 applications
  --ds=SCOPE          docs 范围：knowledge-only（默认）| full
  --ad=DIR            .ai 配置目录（默认: .ai）
  --as=SCOPE          .ai/rules 范围：no-solution-analysis（默认）| full
  --agents=LIST       要初始化的 Agent，逗号分隔或 all（默认: cursor）
                      可选: cursor, trea（仓库中存在的才会处理）
  --cursor-dir=DIR    Cursor 配置目录（默认: .cursor）
  --trea-dir=DIR      Trea 配置目录（默认: .trea）
  --skills=LIST       要安装的 skills，逗号分隔或 all；未指定时仅安装 agent/knowledge 相关（knowledge-build、agent-guide），不含 sdx-*
  --force             若目标路径已存在则提示确认后覆盖；未指定时若已存在则警告并退出
  --dry-run           仅打印将要执行的操作，不实际拷贝
  -h, --help          显示此帮助

环境变量（供 bootstrap 使用）:
  REPO_ROOT           仓库根目录（克隆后的路径），必须设置
  TARGET_DIR          目标目录，未传参时也可由此指定
  SDX_MODE            standalone | federation，与 --mode 等价
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
  if [[ -d "$src" ]] && [[ -d "$dst" ]]; then
    # 目标目录已存在：只合并，覆盖同名文件，不删除目标目录
    rsync -a "$src"/ "$dst"/
  else
    # 目标为文件或不存在：删除后复制，避免 cp -R 产生嵌套
    [[ -e "$dst" ]] && rm -rf "$dst"
    cp -R "$src" "$dst"
  fi
}

# 解析参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode=*)         SDX_MODE="${1#*=}"; SDX_MODE="${SDX_MODE// /}"; shift ;;
    --dd=*)           DOCS_DIR="${1#*=}"; shift ;;
    --ds=*)           DOCS_SCOPE="${1#*=}"; shift ;;
    --ad=*)           AI_DIR="${1#*=}"; shift ;;
    --as=*)           AI_RULES_SCOPE="${1#*=}"; shift ;;
    --agents=*)       AGENTS_OPT="${1#*=}"; shift ;;
    --cursor-dir=*)   CURSOR_DIR="${1#*=}"; shift ;;
    --trea-dir=*)     TREA_DIR="${1#*=}"; shift ;;
    --skills=*)       SKILLS_OPT="${1#*=}"; shift ;;
    --force)          FORCE=1; shift ;;
    --dry-run)        DRY_RUN=1; shift ;;
    -h|--help)        usage; exit 0 ;;
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
  if [[ ! -d "$REPO_ROOT/.ai" ]]; then
    echo "错误: 未设置 REPO_ROOT 且当前推断的仓库根目录不存在 .ai: $REPO_ROOT" >&2
    echo "请通过 bootstrap 方式运行，或设置 REPO_ROOT 后重试。" >&2
    exit 1
  fi
fi

if [[ ! -d "$REPO_ROOT" ]]; then
  echo "错误: 仓库根目录不存在: $REPO_ROOT" >&2
  exit 1
fi

# 在 REPO_ROOT 确定后，根据仓库 .ai/skills 构建可安装列表（避免 set -u 下空 REPO_ROOT 导致 unbound）
CURSOR_SKILLS=()
AGENT_KNOWLEDGE_SKILLS=()
if [[ -d "$REPO_ROOT/.ai/skills" ]]; then
  for skilldir in "$REPO_ROOT/.ai/skills/"*; do
    [[ -d "$skilldir" ]] || continue
    skillname="$(basename "$skilldir")"
    CURSOR_SKILLS+=("$skillname")
    if [[ ! "$skillname" =~ ^sdx- ]] && { [[ "$skillname" == knowledge-* ]] || [[ "$skillname" == agent-* ]]; }; then
      AGENT_KNOWLEDGE_SKILLS+=("$skillname")
    fi
  done
fi
# 若仓库中无 agent/knowledge 类 skill，使用默认列表
[[ ${#AGENT_KNOWLEDGE_SKILLS[@]} -eq 0 ]] && AGENT_KNOWLEDGE_SKILLS=("${AGENT_KNOWLEDGE_SKILLS_DEFAULT[@]}")

mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
DOCS_ABS="$TARGET_DIR/$DOCS_DIR"
DOCS_ROOT="$(dirname "$DOCS_DIR")"
# 独立模式：application（单目录）；联邦模式：applications
SDX_MODE="${SDX_MODE:-standalone}"
case "${SDX_MODE}" in
  standalone)  APPLICATIONS_DIR="$DOCS_ROOT/application" ;;
  federation) APPLICATIONS_DIR="$DOCS_ROOT/applications" ;;
  *)
    echo "错误: --mode 必须为 standalone 或 federation，当前: $SDX_MODE" >&2
    exit 1
    ;;
esac
APPLICATIONS_DIR="${APPLICATIONS_DIR:-$DOCS_ROOT/application}"
APPLICATIONS_ABS="$TARGET_DIR/$APPLICATIONS_DIR"
AI_ABS="$TARGET_DIR/$AI_DIR"
CURSOR_ABS="$TARGET_DIR/$CURSOR_DIR"
TREA_ABS="$TARGET_DIR/$TREA_DIR"

# 解析要启用的 Agent 列表
declare -a ENABLED_AGENTS
if [[ "$AGENTS_OPT" == "all" ]]; then
  for a in "${SUPPORTED_AGENTS[@]}"; do
    if [[ "$a" == "cursor" ]]; then
      ENABLED_AGENTS+=("cursor")
    else
      [[ -d "$REPO_ROOT/.$a" ]] && ENABLED_AGENTS+=("$a")
    fi
  done
else
  IFS=',' read -ra ENABLED_AGENTS <<< "$AGENTS_OPT"
fi

# 检查将要写入的路径是否已存在；交互模式下无论是否 --force 都提示是否覆盖；选 N 则跳过这些路径、继续其余初始化；非交互且无 --force 则退出
SKIP_OVERWRITE_PATHS=()
EXISTING_PATHS=()
[[ -e "$DOCS_ABS" ]] && EXISTING_PATHS+=("$DOCS_ABS")
[[ -e "$APPLICATIONS_ABS" ]] && EXISTING_PATHS+=("$APPLICATIONS_ABS")
[[ -e "$AI_ABS" ]] && EXISTING_PATHS+=("$AI_ABS")
for agent in "${ENABLED_AGENTS[@]}"; do
  agent="${agent// /}"
  [[ -z "$agent" ]] && continue
  case "$agent" in
    cursor) [[ -e "$CURSOR_ABS" ]] && EXISTING_PATHS+=("$CURSOR_ABS") ;;
    trea)   [[ -e "$TREA_ABS" ]] && EXISTING_PATHS+=("$TREA_ABS") ;;
    *)      path="$TARGET_DIR/.$agent"; [[ -e "$path" ]] && EXISTING_PATHS+=("$path") ;;
  esac
done

if [[ ${#EXISTING_PATHS[@]} -gt 0 ]]; then
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "[dry-run] 以下路径已存在、执行时将覆盖："
    printf '  - %s\n' "${EXISTING_PATHS[@]}"
  elif [[ -t 0 ]]; then
    echo "以下路径已存在，继续执行将覆盖：" >&2
    printf '  - %s\n' "${EXISTING_PATHS[@]}" >&2
    echo -n "全部覆盖(Y) / 全部跳过(N) [y/N]: " >&2
    read -r reply
    case "$reply" in
      [yY]|[yY][eE][sS]|[aA]) ;;
      *) SKIP_OVERWRITE_PATHS=("${EXISTING_PATHS[@]}"); echo "已跳过上述路径的覆盖，继续其余初始化。" >&2 ;;
    esac
  else
    if [[ "$FORCE" != "1" ]]; then
      echo "警告: 以下路径已存在，且为非交互模式无法确认。请使用 --force 强制覆盖，或先备份/移除后再执行。" >&2
      printf '  - %s\n' "${EXISTING_PATHS[@]}" >&2
      exit 1
    else
      echo "已指定 --force，将覆盖已存在路径（非交互模式，跳过确认）。" >&2
    fi
  fi
fi

# 判断某路径是否在「跳过覆盖」列表中
skip_overwrite() {
  local path="$1" p
  for p in "${SKIP_OVERWRITE_PATHS[@]:-}"; do
    [[ "$p" == "$path" ]] && return 0
  done
  return 1
}

echo "sdx-init 配置:"
echo "  模式: $SDX_MODE"
echo "  仓库根: $REPO_ROOT"
echo "  目标目录: $TARGET_DIR"
echo "  文档目录: $DOCS_DIR -> $DOCS_ABS (范围: $DOCS_SCOPE)"
echo "  应用目录: $APPLICATIONS_DIR -> $APPLICATIONS_ABS"
echo "  .ai 目录: $AI_DIR -> $AI_ABS (rules: $AI_RULES_SCOPE)"
echo "  Agents: ${ENABLED_AGENTS[*]} (Cursor: $CURSOR_DIR, Trea: $TREA_DIR)"
echo "  Skills: $SKILLS_OPT"
[[ "$DRY_RUN" == "1" ]] && echo "  [dry-run 模式]"
echo ""

# 1) 拷贝到文档：system -> DOCS_ABS；应用目录按模式（独立 application / 联邦 applications + app-APPNAME）；联邦模式追加 .gitignore 并拷贝 .git
echo ">>> 1/3 拷贝文档与知识库（${DOCS_DIR:-} + ${APPLICATIONS_DIR:-}）..."
if skip_overwrite "$DOCS_ABS"; then
  echo "  已跳过（用户选择不覆盖）: $DOCS_ABS"
else
  mkdir -p "$DOCS_ABS"
  # 1a) 仓库根 README.md -> system 文档根
  if [[ -f "$REPO_ROOT/README.md" ]]; then
    cp_safe "$REPO_ROOT/README.md" "$DOCS_ABS/README.md"
  fi
  # 1b) system 目录 -> docs/system；默认仅 knowledge/ 与根目录同级文件，--ds=full 时拷贝完整
  if [[ -d "$REPO_ROOT/system" ]]; then
    if [[ "$DOCS_SCOPE" == "full" ]]; then
      for item in "$REPO_ROOT/system"/*; do
        [[ -e "$item" ]] || continue
        name="$(basename "$item")"
        cp_safe "$item" "$DOCS_ABS/$name"
      done
      for item in "$REPO_ROOT/system"/.*; do
        [[ -e "$item" ]] || continue
        name="$(basename "$item")"
        [[ "$name" == "." || "$name" == ".." ]] && continue
        cp_safe "$item" "$DOCS_ABS/$name"
      done
    else
      # knowledge-only：仅 knowledge/ 目录及 system 根目录下所有文件（不含其他子目录）
      if [[ -d "$REPO_ROOT/system/knowledge" ]]; then
        cp_safe "$REPO_ROOT/system/knowledge" "$DOCS_ABS/knowledge"
      fi
      for item in "$REPO_ROOT/system"/*; do
        [[ -e "$item" ]] || continue
        [[ -f "$item" ]] || continue
        name="$(basename "$item")"
        cp_safe "$item" "$DOCS_ABS/$name"
      done
      for item in "$REPO_ROOT/system"/.*; do
        [[ -e "$item" ]] || continue
        [[ -f "$item" ]] || continue
        name="$(basename "$item")"
        [[ "$name" == "." || "$name" == ".." ]] && continue
        cp_safe "$item" "$DOCS_ABS/$name"
      done
    fi
  else
    echo "  警告: 仓库内无 system 目录，跳过." >&2
  fi
fi
# 1c) 应用目录：独立模式为 application（单目录）；联邦模式为 applications 并新建 app-<工程目录名>
if skip_overwrite "$APPLICATIONS_ABS"; then
  echo "  已跳过（用户选择不覆盖）: $APPLICATIONS_ABS"
elif [[ -d "$REPO_ROOT/applications" ]]; then
  cp_safe "$REPO_ROOT/applications" "$APPLICATIONS_ABS"
fi
if [[ "$SDX_MODE" == "federation" ]]; then
  # 联邦模式：在 applications 下新建 app-<工程目录名>（已存在则不新建）
  APPNAME="$(basename "$TARGET_DIR")"
  APP_DIR="$APPLICATIONS_ABS/app-$APPNAME"
  if [[ "$DRY_RUN" == "1" ]]; then
    echo "  [dry-run] 确保存在: $APPLICATIONS_DIR/app-$APPNAME/"
  else
    mkdir -p "$APPLICATIONS_ABS"
    if [[ ! -d "$APP_DIR" ]]; then
      mkdir -p "$APP_DIR"
      echo "  已新建应用知识库目录: $APPLICATIONS_DIR/app-$APPNAME/"
    fi
  fi
fi
# 1d) 联邦模式：目标 .gitignore 增加忽略文档根目录，并将当前仓库 .git 拷贝至文档根，使 docs 可与当前工程用 git 汇合
if [[ "$SDX_MODE" == "federation" ]] && [[ "$DRY_RUN" != "1" ]]; then
  GITIGNORE="$TARGET_DIR/.gitignore"
  DOCS_ROOT_ABS="$TARGET_DIR/$DOCS_ROOT"
  if [[ -n "$DOCS_ROOT" ]] && [[ "$DOCS_ROOT" != "." ]]; then
    if [[ -f "$GITIGNORE" ]]; then
      if ! grep -q "^${DOCS_ROOT%/}\$" "$GITIGNORE" 2>/dev/null && ! grep -q "^${DOCS_ROOT%/}/" "$GITIGNORE" 2>/dev/null; then
        echo "" >> "$GITIGNORE"
        echo "# sdx-init 联邦模式：忽略文档根目录" >> "$GITIGNORE"
        echo "${DOCS_ROOT%/}" >> "$GITIGNORE"
        echo "  已在 .gitignore 中忽略: $DOCS_ROOT"
      fi
    else
      printf '%s\n' "# sdx-init 联邦模式：忽略文档根目录" "${DOCS_ROOT%/}" >> "$GITIGNORE"
      echo "  已创建 .gitignore 并忽略: $DOCS_ROOT"
    fi
    # 拷贝当前仓库 .git 到文档根，使目标 docs 可作为独立工作区与当前工程同一远程汇合
    if [[ -d "$REPO_ROOT/.git" ]]; then
      mkdir -p "$DOCS_ROOT_ABS"
      rm -rf "$DOCS_ROOT_ABS/.git"
      cp -R "$REPO_ROOT/.git" "$DOCS_ROOT_ABS/.git"
      # 将工作区指向目标文档根，使 docs 内 git 操作与当前工程同一远程汇合
      (cd "$DOCS_ROOT_ABS" && git config core.worktree "$DOCS_ROOT_ABS" 2>/dev/null) || true
      echo "  已拷贝当前仓库 .git 至文档根: $DOCS_ROOT/.git（可在 docs 内 git push/pull 与当前工程汇合）"
    else
      echo "  警告: 当前仓库无 .git（如从压缩包运行），无法拷贝至文档根；目标 docs 无法与当前工程 git 汇合。" >&2
    fi
  else
    echo "  警告: 文档根为项目根（--dd 未指定子目录），跳过 .git 拷贝，避免覆盖目标工程 .git。" >&2
  fi
elif [[ "$SDX_MODE" == "standalone" ]] && [[ "$DRY_RUN" != "1" ]]; then
  # 独立模式：删除文档根下的 .git，并移除 .gitignore 中忽略文档根的配置，使 docs 由目标工程统一版本管理
  _docs_root_abs="$TARGET_DIR/$DOCS_ROOT"
  if [[ -n "$DOCS_ROOT" ]] && [[ "$DOCS_ROOT" != "." ]]; then
    if [[ -d "$_docs_root_abs/.git" ]]; then
      rm -rf "$_docs_root_abs/.git"
      echo "  已删除文档根下 .git: $DOCS_ROOT/.git"
    fi
    _gitignore="$TARGET_DIR/.gitignore"
    _docs_glob="${DOCS_ROOT%/}"
    if [[ -f "$_gitignore" ]] && (grep -q "^# sdx-init 联邦模式：忽略文档根目录" "$_gitignore" 2>/dev/null || grep -q "^${_docs_glob}\$" "$_gitignore" 2>/dev/null); then
      _tmp_ignore="${_gitignore}.sdx-init.tmp"
      grep -v "^# sdx-init 联邦模式：忽略文档根目录$" "$_gitignore" | grep -v "^${_docs_glob}\$" > "$_tmp_ignore" && mv "$_tmp_ignore" "$_gitignore"
      echo "  已从 .gitignore 中移除对文档根的忽略: $_docs_glob"
    fi
  fi
fi
echo "  完成."
echo ""

# 2) 拷贝 .ai 到目标 .ai；默认排除 rules/solution、rules/analysis；不拷贝 skills（由步骤 3 按 --skills 安装）
echo ">>> 2/3 拷贝 .ai 配置到 $AI_DIR ..."
if skip_overwrite "$AI_ABS"; then
  echo "  已跳过（用户选择不覆盖）: $AI_ABS"
elif [[ "$DRY_RUN" != "1" ]]; then
  for item in "$REPO_ROOT/.ai"/*; do
    [[ -e "$item" ]] || continue
    name="$(basename "$item")"
    [[ "$name" == "skills" ]] && continue
    cp_safe "$item" "$AI_ABS/$name"
  done
  for item in "$REPO_ROOT/.ai"/.*; do
    [[ -e "$item" ]] || continue
    name="$(basename "$item")"
    [[ "$name" == "." || "$name" == ".." ]] && continue
    cp_safe "$item" "$AI_ABS/$name"
  done
else
  for item in "$REPO_ROOT/.ai"/*; do
    [[ -e "$item" ]] || continue
    name="$(basename "$item")"
    [[ "$name" == "skills" ]] && continue
    echo "  [dry-run] 拷贝: $item -> $AI_ABS/$name"
  done
  echo "  [dry-run] 实际执行时将排除 .ai/skills（由步骤 3 按 --skills 安装）"
fi
if ! skip_overwrite "$AI_ABS"; then
  if [[ "$AI_RULES_SCOPE" == "no-solution-analysis" ]] && [[ "$DRY_RUN" != "1" ]]; then
    [[ -d "$AI_ABS/rules/solution" ]] && rm -rf "$AI_ABS/rules/solution"
    [[ -d "$AI_ABS/rules/analysis" ]] && rm -rf "$AI_ABS/rules/analysis"
    echo "  已排除 .ai/rules/solution 与 .ai/rules/analysis"
  elif [[ "$AI_RULES_SCOPE" == "no-solution-analysis" ]] && [[ "$DRY_RUN" == "1" ]]; then
    echo "  [dry-run] 将排除 .ai/rules/solution 与 .ai/rules/analysis"
  fi
fi
echo "  完成."
echo ""

# 3) 直接为各 Agent 安装 skills（从仓库 .ai/skills 复制到 .cursor/.trea 等）
echo ">>> 3/3 安装 skills 并为 Agent（Cursor、Trea 等）生成/拷贝配置 ..."

# 3a) 计算本次要安装的 skills 列表
# 未显式指定 --skills 时：仅安装 agent/knowledge 相关（默认排除 sdx-*）；--skills=all 安装全部
declare -a INSTALL_SKILLS
if [[ -n "$SKILLS_OPT" ]]; then
  if [[ "$SKILLS_OPT" == "all" ]]; then
    INSTALL_SKILLS=("${CURSOR_SKILLS[@]}")
  else
    IFS=',' read -ra INSTALL_SKILLS <<< "$SKILLS_OPT"
  fi
else
  INSTALL_SKILLS=("${AGENT_KNOWLEDGE_SKILLS[@]}")
fi

# 3b) 按 Agent 分别处理（直接安装到各 Agent 目录）
for agent in "${ENABLED_AGENTS[@]}"; do
  agent="${agent// /}"
  [[ -z "$agent" ]] && continue
  case "$agent" in
    cursor)
      if skip_overwrite "$CURSOR_ABS"; then
        echo "  Cursor: 已跳过（用户选择不覆盖）: $CURSOR_ABS"
      else
      # 为 Cursor 安装 skills 到 .cursor/skills，并生成 README（Slash 命令索引）
      CURSOR_README="$CURSOR_ABS/README.md"
      if [[ "$DRY_RUN" != "1" ]]; then
        mkdir -p "$CURSOR_ABS/skills"
        for skill in "${INSTALL_SKILLS[@]}"; do
          skill="${skill// /}"
          [[ -z "$skill" ]] && continue
          src_skill="$REPO_ROOT/.ai/skills/$skill"
          if [[ -d "$src_skill" ]]; then
            cp_safe "$src_skill" "$CURSOR_ABS/skills/$skill"
          fi
        done
        cat > "$CURSOR_README" <<'HEADER'
# Cursor 项目配置

## Slash 命令（Skills，位于 .ai/skills）

| 命令 | 说明 |
|------|------|
HEADER
        for skill in "${INSTALL_SKILLS[@]}"; do
          skill="${skill// /}"
          [[ -z "$skill" ]] && continue
          skill_file="$CURSOR_ABS/skills/$skill/SKILL.md"
          if [[ -f "$skill_file" ]]; then
            desc=$(awk '/^description:/{getline; gsub(/^[ \t]+|[ \t]+$/,""); print; exit}' "$skill_file" 2>/dev/null)
            [[ -z "$desc" ]] && desc="见 .cursor/skills/$skill/SKILL.md"
            echo "| \`/$skill\` | $desc |" >> "$CURSOR_README"
          fi
        done
        cat >> "$CURSOR_README" <<'FOOTER'

在 Chat 中输入 `/` 后选择对应命令即可调用；或使用 `@技能名` 将 Skill 作为上下文附加。
FOOTER
        echo "  Cursor: 已生成 $CURSOR_DIR/README.md"
      else
        echo "  [dry-run] Cursor: 将生成 $CURSOR_DIR/skills 及 README.md"
      fi
      fi
      ;;
    trea)
      if skip_overwrite "$TREA_ABS"; then
        echo "  Trea: 已跳过（用户选择不覆盖）: $TREA_ABS"
      elif [[ -d "$REPO_ROOT/.trea" ]]; then
      # 若仓库存在 .trea，整目录拷贝到目标，并直接安装 skills 到 .trea/skills，便于 Trea 直接使用
        cp_safe "$REPO_ROOT/.trea" "$TREA_ABS"
        if [[ "$DRY_RUN" != "1" ]]; then
          mkdir -p "$TREA_ABS/skills"
          for skill in "${INSTALL_SKILLS[@]}"; do
            skill="${skill// /}"
            [[ -z "$skill" ]] && continue
            src_skill="$REPO_ROOT/.ai/skills/$skill"
            if [[ -d "$src_skill" ]]; then
              cp_safe "$src_skill" "$TREA_ABS/skills/$skill"
            fi
          done
        else
          echo "  [dry-run] Trea: 将同步 skills 到 $TREA_DIR/skills"
        fi
        echo "  Trea: 已拷贝 .trea -> $TREA_DIR"
      else
        echo "  Trea: 仓库无 .trea，跳过"
      fi
      ;;
    *)
      dst_agent_abs="$TARGET_DIR/.$agent"
      if skip_overwrite "$dst_agent_abs"; then
        echo "  $agent: 已跳过（用户选择不覆盖）: $dst_agent_abs"
      elif [[ -d "$REPO_ROOT/.$agent" ]]; then
        cp_safe "$REPO_ROOT/.$agent" "$dst_agent_abs"
        echo "  $agent: 已拷贝 .$agent -> .$agent"
      else
        echo "  $agent: 仓库无 .$agent，跳过"
      fi
      ;;
  esac
done
echo "  完成."
echo ""

echo "sdx-init 已完成。"
echo "  - 文档 system: $DOCS_ABS"
echo "  - 应用目录 ($APPLICATIONS_DIR): $APPLICATIONS_ABS"
echo "  - AI 配置: $AI_ABS"
echo "  - Skills 已为以下 Agent 安装: ${ENABLED_AGENTS[*]}"
echo "  - Agents: ${ENABLED_AGENTS[*]}"
