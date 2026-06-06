# Phase Gates (Definition of Done)

Each phase transitions to the next only when the gate criteria are met. The AI is responsible for running the check rigorously and reporting any gaps. If a criterion is not met, return to the phase that owns the gap — do not paper over it.

## Why gates exist

A missing acceptance criterion costs minutes to fix in Phase 1, hours in Phase 2, and days in Phase 3a. Gates make rework cheaper by catching problems near their source.

The cost of a false-positive gate ("we said it was done but it wasn't") is rework downstream. The cost of a false-negative gate ("we lingered when we could have moved on") is a few minutes of extra discussion. The asymmetry favors strict gates.

## Gate: Phase 1 → Phase 2 (Requirements → Basic Design)

- [ ] Feature purpose is written down (one paragraph that a stranger could understand).
- [ ] Every acceptance criterion is measurable or testable.
- [ ] No important ambiguity remains.

**Common gaps:** "fast", "good UX", "users should be happy", "should work on mobile" — none of these are testable. Restate them as observable conditions.

## Gate: Phase 2 → Phase 3a + Phase 3b (Basic Design → parallel Implementation + Verification Design)

- [ ] Feature overview written.
- [ ] Scope explicit (including non-scope).
- [ ] Interface contract exists. For a local iOS feature, the public Swift surface (types, protocols, module boundaries) is documented from `assets/interface-contract.md`. Only when the feature crosses a network boundary, an OpenAPI document exists instead.
- [ ] Data model defined.
- [ ] External dependencies listed.
- [ ] Non-functional requirements written.
- [ ] Architecture decisions recorded *with rationale*.
- [ ] Open questions are scoped to "resolvable in Phase 3a".

**The open-questions test:** for each unresolved item, ask "could this change the data model, interface contract, or architecture?" If yes, it does not belong in the open-questions list — resolve it before moving on. The point of the open-questions section is to record details that can move late without invalidating the implementation already done; anything that *can* invalidate work belongs in Phase 2.

## Gate: Phase 3a → Phase 4 (Iterative Implementation → Integrated Verification)

- [ ] Every TDD cycle has completed.
- [ ] Each cycle passed Stages 1–4.
- [ ] Stage 5 (design review) has been done once over the full block.
- [ ] All unit tests pass.
- [ ] Detail design is complete at the documented granularity (cross-language engineer can read it).
- [ ] Interface contract matches the implementation (the public Swift surface, or OpenAPI for a network feature).
- [ ] All open questions from basic design are now resolved.

**Common gap:** contract drift. The interface was written in Phase 2 and the implementation diverged — a renamed type, a changed method signature, a new error case, or (for network features) a tweaked response shape. Reconcile before moving on; do not let the contract rot.

## Gate: Phase 3b → Phase 4 (Verification Design → Integrated Verification)

- [ ] UI verification items cover every UI-visible acceptance criterion.
- [ ] E2E verification items cover the user journeys.
- [ ] Every acceptance criterion has at least one mapped verification item.

**Common gap:** an acceptance criterion with no verification item. If you can't verify it, you can't claim it's done.

## Gate: Phase 4 → Done

- [ ] All verification items pass.
- [ ] Every acceptance criterion is satisfied.

**On failure:** identify which phase owns the gap. Logic errors usually mean back to Phase 3a. Behavior that contradicts the spec usually means Phase 2 or even Phase 1.

## How to run a gate check

1. Read the checklist for the current phase.
2. For each criterion, name the specific evidence that satisfies it (file path + section, test name, etc.). "It's done" is not evidence; "see `docs/features/X/basic-design.md` § Data model" is.
3. If any criterion lacks evidence, surface it explicitly. Do not say "looks good" if you skipped a check.
4. If gaps exist, return to the owning phase.

## Open-questions placement

| Where the question can be resolved             | Where it lives                          |
|------------------------------------------------|-----------------------------------------|
| Inside Phase 3a (won't change design)          | Basic design § Open questions           |
| Inside a specific TDD cycle                    | Detail design § Open questions          |
| Affects interface contract, data model, architecture | Send it back to Phase 2; do not park it |

When unsure where a question belongs, propose a placement and ask the human to decide.
