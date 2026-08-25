#!/usr/bin/env bash
set -uo pipefail

cd "$(dirname "$0")/.."

fail=0
resolved_links=0
declare -A refs=()

err() {
  printf '::error::%s\n' "$*"
  fail=1
}

mapfile -t files < <(
  find skills -type f -name '*.md' 2>/dev/null
  find . -maxdepth 1 -type f -name '*.md' -print
)

if (( ${#files[@]} == 0 )); then
  err 'no markdown file was found, so no link was checked'
  printf 'Checked 0 resolved links across 0 files.\n'
  exit 1
fi

check_target() {
  local target=$1
  local source_file=$2
  local source_dir
  local resolved_path

  target=${target%%#*}
  target=${target%%\?*}
  target=${target#<}
  target=${target%>}

  if [[ -z "$target" || "$target" == http://* || "$target" == https://* || "$target" == //* || "$target" == mailto:* || "$target" == tel:* ]]; then
    return
  fi

  source_dir=$(dirname "$source_file")
  resolved_path="$source_dir/$target"
  resolved_links=$((resolved_links + 1))
  if [[ ! -e "$resolved_path" ]]; then
    err "$source_file links to missing $target"
  fi
}

while IFS= read -r file; do
  refs=()
  content=$(sed -E 's/!\[[^]]*\]\([^)]*\)//g' "$file")

  while IFS=$'\t' read -r label target; do
    refs["${label,,}"]=$target
  done < <(printf '%s\n' "$content" | sed -nE 's/^[[:space:]]*\[([^]]+)\]:[[:space:]]*(.+)[[:space:]]*$/\1\t\2/p')

  while IFS= read -r raw_link; do
    target=${raw_link:2:${#raw_link}-3}
    check_target "$target" "$file"
  done < <(printf '%s\n' "$content" | grep -oE '\]\([^)]+\)' || true)

  while IFS= read -r raw_reference; do
    label=${raw_reference:2:${#raw_reference}-3}
    target=${refs["${label,,}"]-}
    if [[ -z "$target" ]]; then
      err "$file references undefined link $label"
    else
      check_target "$target" "$file"
    fi
  done < <(printf '%s\n' "$content" | grep -oE '\]\[[^]]+\]' || true)
done < <(printf '%s\n' "${files[@]}")

printf 'Checked %s resolved links across %s files.\n' "$resolved_links" "${#files[@]}"
if (( fail )); then
  exit 1
fi
