# Learning Feedback Between Feature Loops

A feature loop (Phase 1 → 4 for one feature) is independent, but the *learning* from each loop should accumulate. Without this, the same class of mistake repeats every feature.

## What counts as a learning signal

- A Stage 4 (Logic) miss caught by the human.
- A Stage 5 (Design) rejection that needed rework.
- A phase-gate failure that sent work back a phase.
- An integrated-verification (Phase 4) failure.

Each of these is *evidence* that the current rules / templates / prompts didn't prevent the mistake.

## Three mechanisms

### Mechanism 1: local accumulation

Record failures in a local log, **not committed to git**. The log lives at `.claude/.feature-loop-log.md` — add it to `.gitignore` if it isn't already covered. Without a fixed location the "promote after three" threshold can't work, because the next loop has no prior entries to count against.

One line per failure, pipe-delimited so instances are easy to scan and group:

```
| date | phase/stage | class | fix needed | status |
```

- **date** — pass it in (the AI can't read the clock); use the session date.
- **phase/stage** — e.g. `3a / Stage 4`.
- **class** — short tag for the kind of failure, reused across entries so recurrence is countable (e.g. `nil-handling`, `missing-edge-case`, `module-boundary`).
- **fix needed** — what actually corrected it.
- **status** — `open` or `promoted`.

The local log is a buffer. Single failures stay here — they don't yet justify a rule change. The buffer exists so a one-off mistake doesn't trigger an over-correction.

### Mechanism 2: promotion to a rule

When the same pattern shows up enough times (rule of thumb: three), promote it.

**Promotion judgment:**

- The class of failure is the same across instances.
- The fix needed was similar.
- The phase/stage was the same.

**Where to promote to (the rule's home depends on stage):**

| Recurring at...           | Promote to...                                    |
|---------------------------|--------------------------------------------------|
| Stage 2 (Lint)            | Linter config                                    |
| Stage 4 (Logic)           | Acceptance-criteria template / `CLAUDE.md`       |
| Stage 5 (Design)          | Basic-design template                            |
| Stage 6 (Architecture)    | Architecture-decision rules / ADR template       |

**Process:** AI proposes a promotion candidate (citing the three instances). Human approves. The rule is written into the relevant source of truth. Mark the failures in the local log as "promoted" so they don't trigger again.

### Mechanism 3: retrospective

After each feature loop ships, do a short retrospective. Look beyond the local failure log for things the log can't capture:

- Commit history (where did the AI need extra correction?)
- Hand-edits the human made to AI output (often signal a missing rule)
- Notes from verification (surprises, confusions, near-misses)

Classify each finding by *category* (where the fix goes) and *priority* (how broadly to apply it).

**Category → fix location:**

| Category                  | Fix location                          |
|---------------------------|---------------------------------------|
| Code style                | Linter config                         |
| Architecture violation    | Rules update                          |
| Domain knowledge gap      | Memory update                         |
| External integration miss | Skills / OpenAPI update               |
| Dangerous operation       | Hook (settings.json)                  |

**Priority:**

- **Immediate / personal:** apply right away to your own setup; don't ship.
- **PR-level:** worth landing as a team / project-level change.
- **Note only:** one-off; keep as a personal note; do not rule-ify.

**Exception:** dangerous-operation findings go straight to PR-level (hook addition), even on a first occurrence. One foot-gun is enough.

## Why the threshold matters

The rule "promote after three" is a guard against two failure modes:

- **Under-reaction.** Without a log, repeated mistakes feel like a string of unrelated incidents instead of one pattern.
- **Over-reaction.** Without a threshold, every single failure becomes a rule, and the rule set becomes a fortress that slows the AI without preventing what matters.

Three is a starting point; tune it from experience.

## What to rule-ify vs. not

Use this test: **"if I delete this rule, will the AI go wrong?"** If yes, keep the rule. If no, don't add it.

Don't rule-ify:

- Generic best practices the model already knows.
- Things readable from two or three files of code.
- Things already in `CLAUDE.md` or a doc the AI reads.

Do rule-ify:

- Project-specific conventions that aren't obvious from the code.
- Recurring AI errors that the model wouldn't predict from training.
- Trade-offs where the project's choice contradicts a common default.

## The closed loop

```
Failure during feature loop
    ↓ record locally
Local log (git-ignored)
    ↓ same pattern × N (≈3)
Promotion proposal (AI)
    ↓ approval (human)
Source of truth updated (CLAUDE.md / rules / template / linter config)
    ↓ next feature loop reads the update
Fewer occurrences of the same pattern

+ Retrospective at end of each feature loop:
  commits / hand-edits / verification notes
    ↓ classify by category and priority
Pushed to memory / rules / hook / skills
```
