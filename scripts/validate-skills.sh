#!/usr/bin/env bash
set -uo pipefail

cd "$(dirname "$0")/.."

fail=0
skill_count=0
json_runner=()

if command -v node >/dev/null 2>&1; then
  json_runner=(node)
elif command -v node.exe >/dev/null 2>&1; then
  json_runner=(node.exe)
elif [[ -x '/mnt/c/Program Files/nodejs/node.exe' ]]; then
  json_runner=('/mnt/c/Program Files/nodejs/node.exe')
elif command -v python3 >/dev/null 2>&1; then
  json_runner=(python3)
else
  printf '::error::no JSON interpreter is available\n' >&2
  exit 1
fi

err() {
  printf '::error::%s\n' "$*"
  fail=1
}

json_valid() {
  if [[ "${json_runner[0]}" == python3 ]]; then
    "${json_runner[@]}" -c 'import json, sys; json.load(open(sys.argv[1], encoding="utf-8"))' "$1" >/dev/null </dev/null
  else
    "${json_runner[@]}" -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' "$1" >/dev/null </dev/null
  fi
}

json_descriptions_match() {
  if [[ "${json_runner[0]}" == python3 ]]; then
    "${json_runner[@]}" -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as file:
    package = json.load(file)
with open(sys.argv[2], encoding="utf-8") as file:
    plugin = json.load(file)
if not package.get("description") or not plugin.get("description"):
    sys.exit(1)
sys.exit(package["description"] != plugin["description"])
' package.json .claude-plugin/plugin.json >/dev/null </dev/null
  else
    "${json_runner[@]}" -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const plugin = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
if (!pkg.description || !plugin.description) process.exit(1);
process.exit(pkg.description === plugin.description ? 0 : 1);
' package.json .claude-plugin/plugin.json >/dev/null </dev/null
  fi
}

json_plugin_skills() {
  if [[ "${json_runner[0]}" == python3 ]]; then
    "${json_runner[@]}" -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as file:
    plugin = json.load(file)
for skill in plugin.get("skills", []):
    print(skill)
' .claude-plugin/plugin.json </dev/null
  else
    "${json_runner[@]}" -e '
const fs = require("fs");
const plugin = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
for (const skill of plugin.skills || []) console.log(skill);
' .claude-plugin/plugin.json </dev/null
  fi
}

json_skill_registered() {
  if [[ "${json_runner[0]}" == python3 ]]; then
    "${json_runner[@]}" -c '
import json, sys
with open(sys.argv[1], encoding="utf-8") as file:
    plugin = json.load(file)
sys.exit(f"./skills/{sys.argv[2]}" not in plugin.get("skills", []))
' .claude-plugin/plugin.json "$1" </dev/null
  else
    "${json_runner[@]}" -e '
const fs = require("fs");
const plugin = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
process.exit((plugin.skills || []).includes(`./skills/${process.argv[2]}`) ? 0 : 1);
' .claude-plugin/plugin.json "$1" </dev/null
  fi
}

plugin_valid=1
if ! json_valid .claude-plugin/plugin.json; then
  err '.claude-plugin/plugin.json is not valid JSON'
  plugin_valid=0
fi

if (( plugin_valid )); then
  if ! json_descriptions_match; then
    err 'package.json description does not match .claude-plugin/plugin.json description'
  fi

  while IFS= read -r plugin_skill; do
    if [[ ! -d "$plugin_skill" || ! -f "$plugin_skill/SKILL.md" ]]; then
      err "plugin skill path $plugin_skill does not resolve to a directory containing SKILL.md"
    fi
  done < <(json_plugin_skills)
fi

while IFS= read -r skill_file; do
  skill_count=$((skill_count + 1))
  skill_dir=$(dirname "$skill_file")
  skill_name=$(basename "$skill_dir")

  if [[ "$skill_dir" != "skills/$skill_name" ]]; then
    err "$skill_file is nested below skills/<name>/SKILL.md"
    continue
  fi

  if ! awk '
    { sub(/\r$/, "") }
    NR == 1 { valid = ($0 == "---"); next }
    !valid { exit 2 }
    $0 == "---" { closed = 1; exit }
    END { if (!valid || !closed) exit 1 }
  ' "$skill_file"; then
    err "$skill_file has invalid or unterminated frontmatter"
    continue
  fi

  if ! awk '
    { sub(/\r$/, "") }
    NR == 1 { next }
    $0 == "---" { exit }
    /^[[:space:]]*$/ || /^[[:space:]]*#/ { next }
    !/^[A-Za-z][A-Za-z0-9_-]*:[[:space:]]*/ { exit 1 }
  ' "$skill_file"; then
    err "$skill_file frontmatter is not YAML-ish key/value"
  fi

  declared_name=$(awk '
    { sub(/\r$/, "") }
    NR == 1 { next }
    $0 == "---" { exit }
    /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; exit }
  ' "$skill_file")
  description=$(awk '
    { sub(/\r$/, "") }
    NR == 1 { next }
    $0 == "---" { exit }
    /^description:[[:space:]]*/ { sub(/^description:[[:space:]]*/, ""); print; exit }
  ' "$skill_file")

  if [[ -z "$declared_name" ]]; then
    err "$skill_file frontmatter is missing name"
  elif [[ "$declared_name" != "$skill_name" ]]; then
    err "$skill_file name $declared_name does not match directory $skill_name"
  fi

  if [[ -z "$description" ]]; then
    err "$skill_file frontmatter is missing description"
  else
    if [[ "$description" == \"*\" && "$description" == *\" ]]; then
      description=${description:1:${#description}-2}
    fi
    if (( ${#description} > 800 )); then
      err "$skill_file description exceeds 800 characters"
    fi
  fi

  if [[ $(grep -cE '^## +Goal[[:space:]]*$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Goal section"
  fi
  if [[ $(grep -cE '^## +Workflow[[:space:]]*$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Workflow section"
  fi
  if [[ $(grep -cE '^## +Rules[[:space:]]*$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Rules section"
  fi
  if [[ $(grep -cE '^## +Verification[[:space:]]*$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Verification section"
  fi

  if (( plugin_valid )) && ! json_skill_registered "$skill_name"; then
    err "$skill_file is not registered in .claude-plugin/plugin.json"
  fi

  if ! grep -Fq "skills/$skill_name/SKILL.md" README.md; then
    err "$skill_file is not listed in README.md as skills/$skill_name/SKILL.md"
  fi

  if grep -rn --include='*.md' -E '(\]\([[:space:]]*|^[[:space:]]*\[[^]]+\]:[[:space:]]*)<?\.\./' "$skill_dir" >/dev/null; then
    err "$skill_dir contains a relative link with ../"
  fi
done < <(find skills -mindepth 2 -name SKILL.md 2>/dev/null | sort)

while IFS= read -r skill_dir; do
  if [[ ! -f "$skill_dir/SKILL.md" ]]; then
    err "$skill_dir exists but contains no SKILL.md"
  fi
done < <(find skills -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)

while IFS= read -r listed_name; do
  if [[ ! -f "skills/$listed_name/SKILL.md" ]]; then
    err "README.md lists skills/$listed_name/SKILL.md which does not exist"
  fi
done < <(grep -oE 'skills/[A-Za-z0-9_-]+/SKILL\.md' README.md | cut -d/ -f2 | sort -u)

if (( skill_count == 0 )); then
  err 'no skills/<name>/SKILL.md was found, so no skill was validated'
fi

if (( fail )); then
  printf 'Skill catalog validation failed for %s skills.\n' "$skill_count"
  exit 1
fi

printf 'Skill catalog valid: %s skills.\n' "$skill_count"
