---
name: decide
description: "Turn submitted decision material into a traceable, checkable instrument that routes each item to the least senior defensible answerer and preserves what the material cannot establish."
disable-model-invocation: true
---

## Goal

Turn material submitted for a decision into a checkable instrument for the person holding the decision. Never render the decision. Its defensible property is traceability, not neutrality.

## Workflow

Run the extraction pass before the surface pass. The extraction pass emits this eight-element vocabulary:

- IRREDUCIBLE: 1. Material identity, binding the instrument to one identified version of the submitted material.
- IRREDUCIBLE: 2. Gates, binary conditions and what breaks when each is false.
- IRREDUCIBLE: 3. Judgments, discretionary calls and the condition each unmet call creates.
- 4. Forks, values the decision holder must supply and any fallback.
- 5. Human intervention points, moments during execution that require the decision holder's time or authority.
- 6. Exclusions, what approval does not authorize.
- 7. Admitted risks, risks named by the material and its stated handling for each.
- IRREDUCIBLE: 8. Verdict and decision record, the rule-derived state and text that records the decision and its conditions.

Elements 1, 2, 3, and 8 are always present. Emit elements 4 through 7 only when the material contains them, and report each absent element as missing criteria. Every emitted item carries a citation to its source location, a claim-versus-evidence mark, and an ANSWERER tag from the closed set `artifact`, `submitter`, `delegate`, or `decider`. State an unsupported assertion as unverifiable rather than dropping it. Choose the least senior defensible answerer.

Build the interactive instrument when the count of gate items is greater than 3 OR at least one judgment item exists; otherwise emit prose carrying the same eight elements and stating the verdict rule in words instead of computing it. Read this trigger from the extraction, never from the invoker. Use the [rendering contract](./references/rendering-contract.md) for the interactive surface.

## Rules

- Never state or imply a recommended outcome.
- Never claim neutrality.
- Never invent a gate to make the shape look complete.
- Every criterion must be checkable by someone reading it, with a stated test instead of an unsupported quality judgment.
- Missing criteria are output, not silence.
- Group any item a non-decider can answer away from the decider block.
- Use no fixed template or size dial; size falls out of the material.

## Verification

Check that every item traces to a source location. Check that the count of decider-tagged items is strictly less than the total item count. Check that the chosen surface matches the D10 rule computed from the extraction. Check that the verdict uses only `blocked`, `conditional`, or `clear`. Check that no sentence in the output recommends an outcome.
