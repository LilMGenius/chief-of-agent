# chief-of-agent

Decision instruments for turning submitted material into criteria a decider can check.

## Quickstart

```bash
npx skills@latest add LilMGenius/chief-of-agent --global --agent '*'
```

That command works once this repo is published. Until then, clone it and point your agent at the `skills/` folder directly.

Both skills carry `disable-model-invocation: true`, so an agent does not pick them up on its own. Name the skill when you want it.

## Gates

```bash
bash scripts/validate-skills.sh
bash scripts/check-links.sh
```

The first checks that every skill on disk is registered, listed, and structurally complete, and that every registered or listed skill exists on disk. The second resolves every relative link in every markdown file. Both report every problem they find, name the file, and exit non-zero when any problem was reported. They need bash plus node or python3 on PATH. CI runs them on every push.

## Skill index

| Skill | Purpose |
| --- | --- |
| `skills/decide/SKILL.md` | Extracts checkable decision criteria from submitted material. |
| `skills/incorp/SKILL.md` | Lands handed-over material at the tier an existing knowledge base already defines. |
