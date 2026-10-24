#!/usr/bin/env bash

version_normalize() {
  local raw="${1:-}"
  if [[ "$raw" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{2}$ ]]; then
    local month="${raw:3:2}" day="${raw:6:2}"
    ((10#$month >= 1 && 10#$month <= 12 && 10#$day >= 1 && 10#$day <= 31)) || return 1
    printf '20%s.%s%s.0\n' "${raw:0:2}" "$month" "$day"
  elif [[ "$raw" =~ ^[0-9]{4}\.[0-9]{4}\.[0-9]+$ ]]; then
    local md month day patch
    md="${raw#*.}"; month="${md:0:2}"; day="${md:2:2}"
    ((10#$month >= 1 && 10#$month <= 12 && 10#$day >= 1 && 10#$day <= 31)) || return 1
    patch="${raw##*.}"
    printf '%s.%d\n' "${raw%.*}" "$((10#$patch))"
  else
    return 1
  fi
}

version_key() {
  local normalized
  normalized="$(version_normalize "$1")" || return 1
  local date_part="${normalized%.*}" patch="${normalized##*.}"
  printf '%s%s%08d\n' "${date_part%%.*}" "${date_part#*.}" "$patch"
}

version_compare() {
  local a b
  a="$(version_key "$1")" b="$(version_key "$2")" || return 2
  if ((10#$a > 10#$b)); then return 0; fi
  if ((10#$a == 10#$b)); then return 1; fi
  return 2
}

version_next_from_files() {
  local current="" value raw file max_patch=0 date_part today legacy=0
  for file in "$@"; do
    [[ -f "$file" ]] || continue
    value="$(sed -n 's/^version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$file" | head -1)"
    [[ -n "$value" ]] || continue
    raw="$value"
    [[ "$raw" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]{2}$ ]] && legacy=1
    value="$(version_normalize "$value")" || return 2
    if [[ -z "$current" ]]; then current="$value"; else [[ "$current" == "$value" ]] || return 3; fi
  done
  today="$(date +%Y.%m%d)"
  if [[ -z "$current" ]]; then printf '%s.0\n' "$today"; return; fi
  date_part="${current%.*}"
  if [[ "$date_part" > "$today" ]]; then
    printf '当前版本日期晚于系统日期，请核实版本或时钟\n' >&2
    return 4
  fi
  if [[ "$legacy" == 1 ]]; then printf '%s.0\n' "$today"; return; fi
  if [[ "$date_part" == "$today" ]]; then
    max_patch="${current##*.}"
    printf '%s.%d\n' "$date_part" "$((10#$max_patch + 1))"
  else
    printf '%s.0\n' "$today"
  fi
}

version_commit_sha() {
  local repo="$1" version="$2" revision="${3:---all}" subject
  while IFS=$'\t' read -r sha subject; do
    if [[ "$subject" == "docs-publish: version $version" ]]; then
      printf '%s\n' "$sha"
      return 0
    fi
  done < <(git -C "$repo" log --format='%H%x09%s' "$revision" --grep='^docs-publish: version ')
  return 1
}

version_previous_commit_sha() {
  local repo="$1" version="$2" sha
  sha="$(version_commit_sha "$repo" "$version" || true)"
  [[ -n "$sha" ]] || return 1
  git -C "$repo" log --format='%H' --all "${sha}^" --grep='^docs-publish: version ' | head -1
}

version_latest_from_log() {
  local repo="$1" revision="${2:---all}" line subject version best=""
  while IFS= read -r line; do
    subject="${line#*$'\t'}"
    version="${subject#docs-publish: version }"
    [[ "$subject" == docs-publish:\ version\ * ]] || continue
    version_normalize "$version" >/dev/null 2>&1 || continue
    if [[ -z "$best" ]] || version_compare "$version" "$best"; then best="$(version_normalize "$version")"; fi
  done < <(git -C "$repo" log --format='%H%x09%s' "$revision" --grep='^docs-publish: version ')
  [[ -n "$best" ]] && printf '%s\n' "$best"
}
