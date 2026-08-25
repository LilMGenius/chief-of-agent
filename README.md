# chief-of-agent

Decision instruments for turning submitted material into criteria a decider can check.

## Quickstart

This repo is not published yet, so neither route below resolves until it is. Today, copy a skill directory from a local checkout into the folder your agent reads. A skill directory is self-contained, so one of them works without its siblings.

```bash
npx skills@latest add LilMGenius/chief-of-agent --global --agent '*'
```

Once the repo is public at `https://github.com/LilMGenius/chief-of-agent` and the package is on npm, that command installs both skills.

Both skills carry `disable-model-invocation: true`, so an agent does not pick them up on its own. Name the skill when you want it.

## Gates

```bash
bash scripts/validate-skills.sh
bash scripts/check-links.sh
```

The first checks that every skill on disk is registered, listed, and structurally complete, and that every registered or listed skill exists on disk. The second resolves every relative inline and reference-style link in every markdown file in the repo, outside fenced code blocks. Both name the file for each problem and exit non-zero when any problem was reported. A skill whose frontmatter is unparseable is reported and skipped, so its remaining checks run only once the frontmatter is fixed. Both need bash; the first also needs a JSON reader, which it takes from `node`, `node.exe`, a Windows Node install, or `python3`, in that order. CI runs both on every push to `main` and on every pull request, and the release workflow runs both before it publishes.

Authoring rules for a new skill live in [CLAUDE.md](./CLAUDE.md).

## Skill index

| Skill | Purpose |
| --- | --- |
| [skills/decide/SKILL.md](./skills/decide/SKILL.md) | Extracts checkable decision criteria from submitted material. |
| [skills/incorp/SKILL.md](./skills/incorp/SKILL.md) | Lands handed-over material at the tier an existing knowledge base already defines. |
