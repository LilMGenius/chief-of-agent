---
name: incorp
description: "Land material of any shape into an existing knowledge base by reading that base's own routing documents first, editing the owning document in place, and emitting anything it cannot confidently place as unplaced rather than guessing at a destination."
disable-model-invocation: true
---

## Goal

Take material handed over in any shape and land it at the correct tier of a knowledge base that already exists, by editing the document that owns the subject rather than creating a neighbour beside it. The placement is decided from the target's own stated rules, read at run time. This skill does not research the subject it is handed, and it does not invent a tier to hold something that fits none.

## Workflow

Run these four phases in order. Phase 1 completes before any destination is named, and no byte is written before phase 4.

1. **Read the map.** Locate the target's own routing documents: the agent-facing map at the root, and the map at each tier below it. Read them and extract three things: the tier definitions with the test that separates them, the per-document ownership rows that say which document owns which subject, and any stated anti-pattern. This phase produces the candidate tier list. A run that skips it is guessing at a structure it never read.
2. **Classify the input.** Assign the material one of four shapes. **New information** adds a subject the target does not yet carry. **Correction** contradicts the headline of a line that is already live while its evidence still stands. **A bare reference** arrives as a link or citation with no framing around it. **A raw dump** carries several separable claims in one body. Split a dump into its claims here and route each claim independently, because one dump can legitimately land in two tiers.
3. **Place.** For each claim, name the owning document and quote the rule from phase 1 that puts it there. A placement with no cited rule is not a placement. Score placement confidence against the rule stated in the [intake grammars](./references/intake-grammars.md); below the confidence floor the claim is not written. Creating a new file is allowed only when the run can name why no existing tier can hold the claim, and that reason is emitted with the result.
4. **Write.** Record the SHA-256 of every file about to be touched before the first byte changes. Apply each edit in the grammar that document already uses. Then emit the result block: files touched with their before-hashes, claims placed with the cited rule and destination, claims left unplaced with the candidates rejected and the reason each failed, and any new file with the reason no tier fit. Committing is not part of this phase.

A dry-run flag exists as an option for an invoker who wants the result block without the edit. It is not the default path.

## Rules

- Never research the subject. Mark an unverified claim unverified and place it anyway.
- Never invent a tier, a folder, or a document class the target does not already define.
- Never write below the confidence floor. Emit the claim as unplaced instead.
- Never create a new file without a stated reason no existing tier can hold the material.
- Never commit, stage, or push. The human reads the diff and owns the commit.
- A correction rewrites the falsified line in place. It never appends a second line that contradicts the first.
- Every placement cites a rule read from the target, never a rule carried in from this skill.

## Verification

Check that every touched file has a recorded before-hash. Check that every placed claim cites a rule that is greppable in the target's own map documents. Check that every unplaced item lists at least two rejected candidates with a reason each. Check that no new file exists without its stated reason. Check that the target's version control status shows only the modifications the result block named.
