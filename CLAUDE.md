# chief-of-agent

chief-of-agent is a plugin of plain-Markdown skills for the seat that has to approve things. A skill here takes material that somebody else wrote and turns it into criteria the decider can actually check. This file is the authoring guide, and it is itself a skill artifact: rewrite it when it drifts.

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

Promote to a grouped layout (`skills/<group>/<name>/`) only when both conditions hold at once: there are at least 4 skills, and at least 2 of them genuinely share a grouping that a stranger would guess. Until then the flat form is correct, and a grouping invented for 2 skills is a shape with nothing in it. The condition is written here rather than the outcome, so a later contributor inherits the trigger and rules on it themselves.

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

Exactly those four sections, each once. Detail that outgrows the body splits into `references/<topic>.md` inside the same skill directory.

A skill ships and runs installed alone: `npx skills add` can pull one directory without its siblings and without this file. So a skill states the rules it needs inline, and every relative link inside it resolves inside its own directory. A link containing `../` is dead the moment the skill travels.

Default to model-invoked. Set `disable-model-invocation: true` when the model must never reach the skill on its own, either because the trigger is a deliberate human act or because the skill merely being in reach would bias the agent.

## Conventions

- No build step, ever. The package ships the repo as-is through `.gitignore` from a clean CI checkout.
- No `.npmignore`. It would publish the `*.local` scratch files that `.gitignore` correctly withholds.
- No `scripts` field in `package.json`. There is nothing to run.
- `package.json` `description` and `.claude-plugin/plugin.json` `description` are byte-identical, and `scripts/validate-skills.sh` asserts it.
- A released skill is registered in `.claude-plugin/plugin.json` and listed in the README table, both or neither.

## Commit convention

Inherited unchanged from daedal-games.

- Conventional commits: `type(scope): subject`. Types are `feat`, `fix`, `docs`, `refactor`, `perf`, `test`, `chore`.
- Scope is the thing touched, the last meaningful unit of the path. Omit it when the change is repo-wide.
- Subject states the problem the commit solved, in past tense, no trailing period, at most 72 characters. The body then lists what changed, one unwrapped line per durable change, keyword-first, and nothing the diff or the version already proves.
- English throughout, subject and body. The git log is a surface outsiders read.
- BREAKING CHANGE goes in the body under that exact name.
- Always GPG sign. No AI co-author tag; the sole author is the founder.
- Write every document fresh, as a v1. No change history, no provenance notes, no self-version and no last-updated line inside a file. Git owns that.
- No em-dash anywhere in the repo.
