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

if command -v git >/dev/null 2>&1 && git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mapfile -t files < <(git ls-files '*.md' | sort)
else
  mapfile -t files < <(
    find . -type f -name '*.md' -not -path './.git/*' -not -path './node_modules/*' 2>/dev/null | sed 's|^\./||' | sort
  )
fi

if (( ${#files[@]} == 0 )); then
  err 'no markdown file was found, so no link was checked'
  printf 'Checked 0 resolved links across 0 files.\n'
  exit 1
fi

path_exists_cased() {
  local candidate=$1
  local parent base
  [[ -e "$candidate" ]] || return 1
  while [[ "$candidate" == */ ]]; do candidate=${candidate%/}; done
  while [[ "$candidate" == *"/./"* ]]; do candidate=${candidate//\/.\//\/}; done
  parent=$(dirname "$candidate")
  base=$(basename "$candidate")
  [[ "$base" == "." || "$base" == ".." ]] && return 0
  ls -a1 "$parent" 2>/dev/null | grep -qxF -- "$base"
}

check_target() {
  local target=$1
  local source_file=$2
  local source_dir
  local resolved_path

  target=${target%%#*}
  target=${target%%\?*}
  if [[ "$target" == "<"*">" ]]; then
    target=${target#<}
    target=${target%>}
  else
    target=${target%% *}
  fi

  if [[ -z "$target" || "$target" == http://* || "$target" == https://* || "$target" == //* || "$target" == mailto:* || "$target" == tel:* ]]; then
    return
  fi

  source_dir=$(dirname "$source_file")
  resolved_path="$source_dir/$target"
  resolved_links=$((resolved_links + 1))
  if [[ ! -e "$resolved_path" ]]; then
    err "$source_file links to missing $target"
  elif ! path_exists_cased "$resolved_path"; then
    err "$source_file links to $target, which differs from the file on disk by case and breaks on a case-sensitive checkout"
  fi
}

while IFS= read -r file; do
  refs=()
  content=$(sed -E 's/\r$//' "$file" | awk '
    /^[[:space:]]*(```|~~~)/ { fenced = !fenced; next }
    fenced { next }
    {
      line = $0
      out = ""
      while (match(line, /`+/)) {
        ticks = substr(line, RSTART, RLENGTH)
        out = out substr(line, 1, RSTART - 1)
        rest = substr(line, RSTART + RLENGTH)
        close_at = index(rest, ticks)
        if (close_at == 0) { line = rest; continue }
        line = substr(rest, close_at + length(ticks))
      }
      print out line
    }
    END { if (fenced) exit 3 }
  ')
  if (( $? == 3 )); then
    err "$file leaves a code fence open, so every link after it went unchecked"
  fi

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
