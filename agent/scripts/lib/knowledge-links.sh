#!/usr/bin/env bash
#
# lib/knowledge-links.sh — knowledge-links.yaml 读写
# 依赖：Python 3、lib/path.sh、lib/log-io.sh、lib/docsconfig.sh、lib/git-remote.sh
#

_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=docsconfig.sh
source "${_LIB_DIR}/docsconfig.sh"
# shellcheck source=git-remote.sh
source "${_LIB_DIR}/git-remote.sh"

if [[ -n "${_LIB_KNOWLEDGE_LINKS_LOADED:-}" ]]; then
  return 0 2>/dev/null || exit 0
fi
_LIB_KNOWLEDGE_LINKS_LOADED=1

# shellcheck source=bash.sh
source "${_LIB_DIR}/bash.sh"

# shellcheck source=knowledge-link-paths.sh
source "${_LIB_DIR}/knowledge-link-paths.sh"
# shellcheck source=knowledge-links-yaml.sh
source "${_LIB_DIR}/knowledge-links-yaml.sh"
