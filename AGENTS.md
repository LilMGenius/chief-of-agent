# chief-of-agent

chief-of-agent is a plugin of plain-Markdown skills for the seat that has to approve things. A skill here takes material somebody else wrote and turns it into criteria the decider can check. This file is the canon for how the repo is laid out, authored, gated, packaged, and committed. It is itself a skill artifact, so rewrite it when it drifts.

## Philosophy

- The instrument never renders the verdict. A skill sets the criteria and computes an outcome from answers the decider gives. It does not recommend, rank toward an outcome, or state a preference.
- The claim is traceability, not neutrality. Deciding that one sentence is a binary gate and the next is a discretionary judgment is itself a judgment, and the highest-leverage one in the pipeline. So every emitted item cites the line of source material it came from, and the decider can edit the instrument before a single box is ticked.
- Structure is extracted, never selected. Size falls out of the material. A one-paragraph ask yields a few items; a long proposal yields many. There is no size dial and no fixed section template, because a template invites padding to fill its shape.
- Never fabricate an item to fill the shape. One gate in the material means one gate out. An invented plausible criterion is worse than a missing one, because the decider trusts it.
- Thin material must read as thin. Extraction alone has an approval-by-default failure mode: a vague submission yields few criteria, and a short list reads as little to object to. What could not be turned into a criterion is first-class output, not silence.
- Subtract from the seat. Every item names who can answer it, and the extractor prefers any defensible answerer other than the decider. Reformatting the queue without shortening it is staffing the seat more efficiently, which is not the job.

## Layout

```
skills/<name>/SKILL.md
```

Flat, one directory per skill. Topic domains belong in separate plugins, so a skill that is not about exercising decision authority over material somebody else submitted belongs in a different plugin, not in a new folder here.

A grouped layout (`skills/<group>/<name>/`) is a future option, not a supported one: the catalog gate rejects a `SKILL.md` below `skills/<name>/`, so adopting it means changing the walk and this section together. Consider it only when both conditions hold: there are at least 4 skills, and at least 2 of them share a grouping a stranger would guess. Until then the flat form is correct, and a grouping invented before those conditions hold is a shape with nothing in it.

Name a skill for the reflex it fires: a plain real word (`decide`) or a tight compression of a real term. No opaque coinage, and never a model brand name, because the mechanism has to outlive any one model.

## SKILL.md format

```
---
name: <kebab-name>            # matches the directory and the invocation
description: "<trigger-rich one-liner, at most 800 characters>"
# disable-model-invocation: true   <- user-invoked skills only
---

<one line: what the skill does>

## Goal
## Workflow
## Rules
## Verification
```

Exactly those four sections, once each, in that order. Detail that outgrows the body splits into `references/<topic>.md` inside the same skill directory, and the reference file is named for the skill that owns it so one term does not become two.

A skill ships and runs installed alone: `npx skills add` can pull one directory without its siblings and without this file. So a skill states the rules it needs inline, and every relative link inside it resolves inside its own directory. A link containing `../` is dead the moment the skill travels.

Default to model-invoked. Set `disable-model-invocation: true` when the model must never reach the skill on its own, either because the trigger is a deliberate human act or because the skill merely being in reach would bias the agent.

## Gates

```bash
bash scripts/validate-skills.sh
bash scripts/check-links.sh
```

Both need bash. The first also needs a JSON reader, taken from `node`, `node.exe`, a Windows Node install, or `python3`, in that order. Each names the file for every problem it finds and exits non-zero when it reported any. CI runs both on every push to `main` and on every pull request, and the release workflow runs both before it publishes.

`scripts/validate-skills.sh` enforces:

- every skill on disk is registered in `.claude-plugin/plugin.json` and listed in the README table, and every registered or listed skill exists on disk;
- `package.json` `description` and `.claude-plugin/plugin.json` `description` are byte-identical, and the manifest is an object whose `skills` is an array of in-repo paths;
- `SKILL.md` sits exactly at `skills/<name>/SKILL.md`, with no BOM and with terminated YAML-ish frontmatter that declares each key once;
- frontmatter `name` matches the directory, and `description` is present and at most 800 characters;
- the body carries exactly Goal, Workflow, Rules, Verification, once each and in that order, counting headings outside fenced blocks;
- no `../` link inside a skill directory, and no em-dash in any tracked file.

`scripts/check-links.sh` resolves every relative inline and reference-style link in every tracked markdown file, skipping fenced blocks and inline code spans, and errors on a file that leaves a fence open. Link targets are matched case-sensitively, because CI runs on a case-sensitive filesystem and a case-only mismatch that passes locally fails there.

## Packaging

- No build step. The package ships the repo as-is from a clean checkout.
- No `.npmignore` and no `files` allowlist. npm falls back to `.gitignore`, so the tarball withholds exactly what git withholds. `npm pack --dry-run` says so in its own words: `No .npmignore file found, using .gitignore for file exclusion`.
- No `scripts` field in `package.json`. The gates are shell scripts under `scripts/`, run directly, so npm has nothing to wrap.

## Commit convention

- Conventional commits: `type(scope): subject`. Types are `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`.
- Scope is the thing touched, the last meaningful unit of the path. Omit it when the change is repo-wide.
- Subject states the problem the commit solved, in past tense, no trailing period, at most 72 characters. The body then lists what changed, one unwrapped line per durable change, keyword-first, and nothing the diff or the version already proves.
- English throughout, subject and body. The git log is a surface outsiders read.
- BREAKING CHANGE goes in the body under that exact name.
- Always GPG sign. No AI co-author tag; the sole author is the founder.
- Write every document fresh, as a v1. No change history, no provenance notes, no self-version and no last-updated line inside a file. Git owns that.
