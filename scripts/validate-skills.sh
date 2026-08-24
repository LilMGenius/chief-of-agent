#!/usr/bin/env bash
set -uo pipefail

cd "$(dirname "$0")/.."

fail=0
skill_count=0

err() {
  printf '::error::%s\n' "$*"
  fail=1
}

if ! node -e 'JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"))' .claude-plugin/plugin.json >/dev/null 2>&1; then
  err '.claude-plugin/plugin.json is not valid JSON'
fi

if ! node -e '
const fs = require("fs");
const pkg = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
const plugin = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
process.exit(pkg.description === plugin.description ? 0 : 1);
' package.json .claude-plugin/plugin.json >/dev/null 2>&1; then
  err 'package.json description does not match .claude-plugin/plugin.json description'
fi

while IFS= read -r plugin_skill; do
  if [[ ! -d "$plugin_skill" || ! -f "$plugin_skill/SKILL.md" ]]; then
    err "plugin skill path $plugin_skill does not resolve to a directory containing SKILL.md"
  fi
done < <(node -e '
const fs = require("fs");
const plugin = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
for (const skill of plugin.skills || []) console.log(skill);
' .claude-plugin/plugin.json 2>/dev/null)

while IFS= read -r skill_file; do
  skill_count=$((skill_count + 1))
  skill_dir=$(dirname "$skill_file")
  skill_name=$(basename "$skill_dir")

  if ! awk '
    NR == 1 { valid = ($0 == "---"); next }
    !valid { exit 2 }
    $0 == "---" { closed = 1; exit }
    END { if (!valid || !closed) exit 1 }
  ' "$skill_file"; then
    err "$skill_file has invalid or unterminated frontmatter"
    continue
  fi

  if ! awk '
    NR == 1 { next }
    $0 == "---" { exit }
    /^[[:space:]]*$/ || /^[[:space:]]*#/ { next }
    !/^[A-Za-z][A-Za-z0-9_-]*:[[:space:]]*/ { exit 1 }
  ' "$skill_file"; then
    err "$skill_file frontmatter is not YAML-ish key/value"
  fi

  declared_name=$(awk '
    NR == 1 { next }
    $0 == "---" { exit }
    /^name:[[:space:]]*/ { sub(/^name:[[:space:]]*/, ""); print; exit }
  ' "$skill_file")
  description=$(awk '
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

  if [[ $(grep -cE '^## +Goal$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Goal section"
  fi
  if [[ $(grep -cE '^## +Workflow$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Workflow section"
  fi
  if [[ $(grep -cE '^## +Rules$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Rules section"
  fi
  if [[ $(grep -cE '^## +Verification$' "$skill_file") -ne 1 ]]; then
    err "$skill_file must contain exactly one ## Verification section"
  fi

  if ! node -e '
    const fs = require("fs");
    const plugin = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
    process.exit((plugin.skills || []).includes(`./skills/${process.argv[2]}`) ? 0 : 1);
  ' .claude-plugin/plugin.json "$skill_name" >/dev/null 2>&1; then
    err "$skill_file is not registered in .claude-plugin/plugin.json"
  fi

  if ! grep -Fq "skills/$skill_name/SKILL.md" README.md; then
    err "$skill_file is not listed in README.md as skills/$skill_name/SKILL.md"
  fi

  if rg -n '\]\([^)]*\.\./' "$skill_dir" --glob '*.md' >/dev/null; then
    err "$skill_dir contains a relative link with ../"
  fi
done < <(find skills -mindepth 2 -maxdepth 2 -type f -name SKILL.md 2>/dev/null | sort)

if (( fail )); then
  printf 'Skill catalog validation failed for %s skills.\n' "$skill_count"
  exit 1
fi

printf 'Skill catalog valid: %s skills.\n' "$skill_count"
