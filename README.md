# chief-of-agent

Decision instruments for turning submitted material into criteria a decider can check.

## Quickstart

```bash
npx skills@latest add LilMGenius/chief-of-agent --global --agent '*'
```

Every skill here carries `disable-model-invocation: true`, so an agent does not pick one up on its own. Name the skill when you want it. A skill directory is self-contained, so copying one into the folder your agent reads works without its siblings.

## Skill index

| Skill | Purpose |
| --- | --- |
| [skills/decide/SKILL.md](./skills/decide/SKILL.md) | Extracts checkable decision criteria from submitted material. |
| [skills/incorp/SKILL.md](./skills/incorp/SKILL.md) | Lands handed-over material at the tier an existing knowledge base already defines. |

## Gates

Run from a checkout; the gates are repo tooling, not part of what an installed skill needs.

```bash
bash scripts/validate-skills.sh
bash scripts/check-links.sh
```

The first validates the skill catalog against the manifests; the second resolves every relative link in every tracked markdown file. Both name the file for each problem and exit non-zero when any problem was reported.

Authoring rules, the full list of what each gate enforces, and the commit convention live in [AGENTS.md](./AGENTS.md).
