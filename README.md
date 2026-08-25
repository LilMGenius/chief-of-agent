# chief-of-agent

Decision instruments for turning submitted material into criteria a decider can check.

## Quickstart

```bash
npx skills@latest add LilMGenius/chief-of-agent --global --agent '*'
```

That command works once this repo is published. Until then, clone `https://github.com/LilMGenius/chief-of-agent` and point your agent at the `skills/` folder directly. A skill directory is self-contained, so copying one of them alone also works.

Both skills carry `disable-model-invocation: true`, so an agent does not pick them up on its own. Name the skill when you want it.

## Gates

```bash
bash scripts/validate-skills.sh
bash scripts/check-links.sh
```

The first checks that every skill on disk is registered, listed, and structurally complete, and that every registered or listed skill exists on disk. The second resolves every relative inline and reference-style link in every markdown file in the repo, outside fenced code blocks. Both report every problem they find, name the file, and exit non-zero when any problem was reported. Both need bash; the first also needs a JSON reader, which it takes from `node`, `node.exe`, a Windows Node install, or `python3`, in that order. CI runs them on every push.

Authoring rules for a new skill live in [CLAUDE.md](./CLAUDE.md).

## Skill index

| Skill | Purpose |
| --- | --- |
| [skills/decide/SKILL.md](./skills/decide/SKILL.md) | Extracts checkable decision criteria from submitted material. |
| [skills/incorp/SKILL.md](./skills/incorp/SKILL.md) | Lands handed-over material at the tier an existing knowledge base already defines. |
