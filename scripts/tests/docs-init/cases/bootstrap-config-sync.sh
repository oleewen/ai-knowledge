#!/usr/bin/env bash
# docs-bootstrap 与 docs-config 预克隆后备 URL 一致性（见 spec 2026-04-11）

test_BS_URL_SYNC() {
  local root="$DOCS_INIT_TEST_REPO_ROOT"
  local url_cfg url_bs
  url_cfg="$(sed -n "s/^readonly SDX_GIT_REPO_URL='\\(.*\\)'$/\\1/p" "$root/scripts/docs-config.sh" | head -1)"
  url_bs="$(sed -n "s/^readonly SDX_BS_FALLBACK_REPO='\\(.*\\)'$/\\1/p" "$root/scripts/docs-bootstrap.sh" | head -1)"
  [[ -n "$url_cfg" && -n "$url_bs" ]] || {
    echo "test_BS_URL_SYNC: 无法从脚本解析 SDX_GIT_REPO_URL / SDX_BS_FALLBACK_REPO" >&2
    return 1
  }
  [[ "$url_cfg" == "$url_bs" ]] || {
    echo "test_BS_URL_SYNC: URL 漂移 config=[$url_cfg] bootstrap=[$url_bs]" >&2
    return 1
  }
}
