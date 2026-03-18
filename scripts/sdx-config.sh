#!/usr/bin/env bash
# sdx-config.sh：sdx-init 的共享常量与校验函数
# 约束：需要 Bash 5+，可使用关联数组与 mapfile

sdx_require_bash5() {
    if (( BASH_VERSINFO[0] < 5 )); then
        printf '错误: 需要 Bash 5+，当前版本: %s\n' "$BASH_VERSION" >&2
        exit 1
    fi
}

# ----------------------------------------------------------------------------
# 默认值（sdx-init.sh 会允许环境变量/参数覆盖）
# ----------------------------------------------------------------------------

declare -grA SDX_DEFAULTS=(
    [DOCS_DIR]="docs"
    [SDX_MODE]="standalone" # standalone | federation
    [AI_DIR]=".ai"
    [DOCS_SCOPE]="knowledge" # knowledge | full
    [AI_RULES_SCOPE]="no-solution-analysis" # no-solution-analysis | full
    [AGENTS_OPT]="cursor" # cursor | trea | all | csv
)

# 默认安装的技能命名前缀
readonly SDX_DEFAULT_SKILL_PREFIXES=(knowledge- agent-)
readonly SDX_DEFAULT_SKILLS=(knowledge-build agent-guide)

# 供 bootstrap 脚本或外部引用（sdx-init.sh 本身不依赖它）
readonly SDX_GIT_REPO_URL="https://github.com/oleewen/ai-sdd-docs.git"

# ----------------------------------------------------------------------------
# 能力集
# ----------------------------------------------------------------------------

readonly SDX_SUPPORTED_AGENTS=(cursor trea)

# ----------------------------------------------------------------------------
# 校验函数（返回 0 表示合法）
# ----------------------------------------------------------------------------

sdx_validate_mode() {
    case "${1:-}" in
        standalone|federation) return 0 ;;
        *) return 1 ;;
    esac
}

sdx_validate_docs_scope() {
    case "${1:-}" in
        knowledge|full) return 0 ;;
        *) return 1 ;;
    esac
}

sdx_validate_ai_rules_scope() {
    case "${1:-}" in
        no-solution-analysis|full) return 0 ;;
        *) return 1 ;;
    esac
}