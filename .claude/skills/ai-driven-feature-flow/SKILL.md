---
name: ai-driven-feature-flow
description: Use this skill when the user wants to start building, designing, or shipping a new feature in a codebase — phrases like "let's build X", "I want to add a feature for Y", "I need to implement Z", "新機能を作りたい", "this app needs to do W". It drives a V-model-based, AI-driven flow (Requirements → Basic Design → Iterative Implementation ∥ Verification Design → Integrated Verification), enforces gate checks between phases, applies a six-stage AI/human responsibility model, and keeps basic-design / detail-design / OpenAPI as the single source of truth. Trigger this even when the user does not explicitly say "follow our process" — any non-trivial new-feature work benefits from it. Skip it for pure bug fixes, refactors, docs-only edits, or one-line tweaks.
---

# AI-Driven Feature Flow

## What this skill does

This skill turns a vague "let's build X" into a finished, verified feature by guiding you through four phases. The flow is designed around two ideas:

1. **Goal-orientation.** The human defines the *goal*; the AI's job is to reach it. Specs and design docs are *means*, not ends. If the goal is fuzzy, the AI detects that and pushes back instead of building the wrong thing.
2. **Documents are the source of truth.** Code is downstream. Basic design, detail design, and the interface contract are what an engineer would read to understand the feature without opening the code.

> **This project is an iOS app (SwiftUI + Swift Package Manager, `WakeupCore` / `WakeupApp`).** Most features are local — there is no client/server boundary. The "interface contract" for a local feature is the **public Swift surface** (the types, protocols, and module boundaries the rest of the app depends on), documented from `assets/interface-contract.md`. Only reach for OpenAPI (`assets/openapi.yaml`) when a feature actually crosses a network boundary (a backend, a third-party HTTP API like Slack, etc.). Everywhere this skill says "OpenAPI", read it as "the interface contract — OpenAPI if there's a network boundary, otherwise the Swift interface contract".

You will be alternating between writing docs, asking the user to confirm goals, writing code with TDD, and gating phase transitions. **Do not skip phases** — and do not rush past gates. The gate checks exist because "let's just push forward" is the most common cause of rework downstream.

## The flow at a glance

```
Phase 1: Requirements
    ↓
Phase 2: Basic Design
    ↓        ↓
Phase 3a:    Phase 3b:
Iterative    Verification
Implement.   Design
    ↓        ↓
Phase 4: Integrated Verification
```

Phase 2 → 3a + 3b is the only parallel split. Everything else is sequential. Phase 3a (iterative implementation) and 3b (verification design) start at the same time once the basic design is solid.

## Before you start: ambiguity check

Before writing anything, look at the user's ask and find what's underspecified. Examples of ambiguity worth surfacing:

- **Who is the user?** "Add a dashboard" — for whom? Admins? End users?
- **What does success look like?** "Make it faster" — how much? Measured how?
- **What's in scope?** "Add notifications" — push only, or email too? Which events?
- **What about edge cases?** Empty state, error state, offline, permissions.

If two or more important things are ambiguous, **stop and ask the user**. Use `AskUserQuestion` to surface the gaps explicitly rather than pattern-matching to a guess. This is the cheapest moment to course-correct.

If the goal is clear enough that you could explain it to a stranger in two sentences, proceed to Phase 1.

---

## Phase 1: Requirements (要求整理)

**Purpose:** Clarify the goal and produce acceptance criteria that are objectively verifiable.

**Owner:** Human defines the goal. You (AI) detect ambiguity and propose how to make it concrete.

### Steps

1. Write the feature's purpose and user value in one paragraph. If you can't write it, you don't understand it yet — ask.
2. Write acceptance criteria as **measurable or testable** statements. Bad: "the page should be fast." Good: "the page renders in under 200 ms on a mid-range mobile device." Bad: "users should be able to log in." Good: "given valid credentials, the user is redirected to /home within 2 s; given invalid credentials, an inline error appears."
3. Surface any remaining ambiguity to the user.
4. Wait for the user to confirm the goal.

### Where to write it

Put requirements at the top of the basic-design document (created in Phase 2). For now, keep them in a scratch note or directly in the conversation.

### Gate to Phase 2

Before moving on, confirm:

- [ ] The feature's purpose is written down in one paragraph.
- [ ] Every acceptance criterion is measurable or testable.
- [ ] No important ambiguity remains.

If any of these fail, stay in Phase 1.

---

## Phase 2: Basic Design (基本設計)

**Purpose:** Produce the minimum design needed to unblock parallel work on implementation and verification. The exit state of this phase is what makes Phase 3a and 3b able to start together.

**Owner:** Human makes design judgments (especially Stage 6 architecture). You (AI) check consistency with existing code and surface conflicts.

### What goes in the basic-design document

Use the template at `assets/basic-design.md` as a starting point. It must include:

- Feature overview
- Scope (and explicit non-scope)
- Reference to the interface contract (create from `assets/interface-contract.md`; use `assets/openapi.yaml` instead only if the feature crosses a network boundary)
- Data model
- External dependencies (services, libs, env)
- Non-functional requirements (perf, security, accessibility, etc.)
- Architecture decisions (this is Stage 6 — the human owns these, you support)
- Open questions, restricted to "things that can be resolved during Phase 3a"

### What does NOT belong in the basic design

- Internal implementation details
- Class layouts, function decomposition
- Specific algorithms

Those go in the detail design (written during Phase 3a). Keeping them out of basic design is what lets implementation iterate without invalidating the design.

### Steps

1. Copy `assets/basic-design.md` to the repo (suggested path: `docs/features/<feature-name>/basic-design.md`).
2. Fill in each section.
3. Create the interface contract: for a local feature, copy `assets/interface-contract.md` (suggested path: `docs/features/<feature-name>/interface-contract.md`) and document the public Swift surface; for a network-boundary feature, copy `assets/openapi.yaml` instead (suggested path: `docs/features/<feature-name>/openapi.yaml`).
4. List open questions. For each, decide: can it be resolved during implementation? If not, it belongs back in this phase — resolve it now.
5. Run the gate check.

### Gate to Phase 3a + 3b

See `references/phase-gates.md` for the full checklist. Briefly:

- [ ] All required sections populated
- [ ] Interface contract created (Swift interface contract, or OpenAPI if there's a network boundary)
- [ ] Data model defined
- [ ] Architecture decisions recorded (with rationale)
- [ ] Open questions are scoped to "resolvable in Phase 3a"

If any architecture/interface/data-model question is open, **go back to Phase 2** — do not start implementing.

---

## Phase 3a: Iterative Implementation (反復実装) — runs in parallel with 3b

**Purpose:** Implement the feature via small TDD cycles. Each cycle produces working code plus a corresponding detail-design entry.

**Owner:** AI drives the cycle (test → impl → refactor → doc). Human reviews at specific stage gates.

### The TDD cycle

For each unit of behavior:

1. **Write a failing test.** Cover the acceptance criterion or a clear sub-goal.
2. **Implement** until the test passes.
3. **Refactor** with tests still green.
4. **Update the detail-design document** — see "What goes in detail design" below.
5. **Stage 1 (Format)** — auto (formatter, e.g. `swift-format`)
6. **Stage 2 (Lint)** — auto (linter, e.g. SwiftLint)
7. **Stage 3 (Style)** — AI reviews → human signs off
8. **Stage 4 (Logic)** — AI reviews → human checks against acceptance criteria
9. **Cycle done.** Move to the next unit.

The Stage model is explained in detail in `references/stage-model.md`. Read it before your first cycle — the **Stage 4 trap** in particular (the part where AI catches 60% but human attention drifts) is the leading cause of bugs slipping through.

### What goes in detail design

Use the template at `assets/detail-design.md`. Append a new section per cycle. It must cover:

- Module structure
- Internal structure
- Processing flow
- Algorithms (only where non-obvious)
- Data transformations
- Error handling
- Unit test coverage
- Notes on implementation judgment calls

**Audience for the detail design:** an engineer fluent in another language reading this codebase for the first time (e.g., a Rails engineer reading Go). Write at *that* level — explain language-specific idioms and judgment calls, skip generic programming concepts.

### After all cycles complete

Once every acceptance criterion has been implemented through TDD:

1. Run **Stage 5 (Design review)** as one batch over the whole block. Human reviews:
   - Responsibility decomposition
   - Module dependencies
   - Consistency with existing codebase
   - Pattern consistency
2. Apply any feedback.
3. Run the gate check.

### Gate to Phase 4

- [ ] Every TDD cycle has passed Stages 1–4
- [ ] Stage 5 review is done
- [ ] All unit tests pass
- [ ] Detail design is complete at the documented granularity
- [ ] Interface contract matches the implementation (Swift contract, or OpenAPI for network features)
- [ ] All open questions from basic design are resolved

If any of these fail, stay in Phase 3a (or go back to Phase 2 if the gap is in basic design).

---

## Phase 3b: Verification Design (検証設計) — runs in parallel with 3a

**Purpose:** Design the verification that's *outside* unit tests — UI checks, E2E flows — and tie them back to acceptance criteria.

**Owner:** AI drafts the verification plan; human approves the coverage.

### Steps

1. Design UI verification items (what to click, what to observe).
2. Design E2E verification items (user journeys end-to-end).
3. Map each verification item back to a specific acceptance criterion from Phase 1.
4. Run the gate check.

### Boundary with Phase 3a

- **Unit tests** (anything testable in code): owned by Phase 3a, written during TDD cycles.
- **UI / E2E**: owned by Phase 3b, executed in Phase 4.

### Gate to Phase 4

- [ ] UI verification items cover all UI-visible acceptance criteria
- [ ] E2E verification items cover the user journeys
- [ ] Every acceptance criterion is linked to at least one verification item

---

## Phase 4: Integrated Verification (総合検証)

**Purpose:** Confirm the feature meets every acceptance criterion end-to-end.

### Steps

1. Execute UI verification.
2. Execute E2E verification.
3. Walk through the acceptance criteria list and confirm each is satisfied.
4. Run the gate check.

### Gate to Done

- [ ] All verification items pass
- [ ] Every acceptance criterion is satisfied

If anything fails, return to the phase that owns the gap (usually 3a for logic, 2 for design issues).

---

## Cross-cutting principles

### Six-stage responsibility model (Stage 1–6)

Different categories of judgment delegate to AI differently. Stage 1 (Format) is fully automated; Stage 6 (Architecture) is fully human. The middle stages — especially Stage 4 (Logic) — are the **danger zone**: AI catches enough that humans relax, but enough slips through to bite later.

**Rule of thumb:** the parts the AI flagged are the parts AI can handle. The parts the AI *didn't* flag are where the human needs to focus. Don't let the AI's confidence give you false comfort.

Full details, including each stage's timing inside the flow, are in `references/stage-model.md`. Read it once at the start of Phase 3a.

### Phase gates

Gate checks are not bureaucracy — they exist to make rework cheaper. A missing acceptance criterion costs minutes to fix in Phase 1, hours in Phase 2, days in Phase 3a.

When you (AI) run a gate check and find a gap, **report it explicitly to the user and go back a phase**. Don't quietly proceed.

The complete checklist for every gate is in `references/phase-gates.md`.

### Documents are the source of truth

Three documents carry the spec:

- **Basic design** — what the feature is, at the level a senior engineer needs to evaluate the approach.
- **Detail design** — how the code implements it, at the level a cross-language engineer can read.
- **Interface contract** — the public surface, period. No ambiguity, no drift. For a local iOS feature this is the public Swift API (types, protocols, module boundaries); for a network feature it's OpenAPI.

When code and docs diverge, **the docs are wrong until proven otherwise** — but in practice you'll often need to update both. The discipline: never let an implementation choice live only in code if it would surprise the doc's audience.

### Failure feedback (between feature loops)

When something goes wrong — a Stage 4 catch from the human, a phase-gate failure, a verification miss — it's a signal. Single failures stay as local notes. Patterns that recur become rule updates.

The mechanism is described in `references/learning-feedback.md`. You don't need to run it during a single feature; consult it after the feature ships or when the user asks to do a retrospective.

---

## How to behave during the flow

- **Narrate phase transitions.** When you finish a phase, say so. When you start the next, say which gate criteria you're about to verify.
- **Be specific about ambiguity.** "This is ambiguous" is useless. "It's unclear whether 'fast' means 'feels snappy' or 'p95 under 200 ms' — which?" is useful.
- **Push back on premature implementation.** If the user jumps to "just code it up" mid-Phase-2, name the cost: "We don't have the data model decided yet — if I implement now, we'll likely throw away the persistence layer."
- **Use the templates.** Copy from `assets/`. Don't reinvent doc structure.
- **Run gates honestly.** It's better to surface a gap than to pretend a phase is done.

## File layout reference

```
ai-driven-feature-flow/
├── SKILL.md              ← this file
├── assets/
│   ├── basic-design.md        ← template for Phase 2 output
│   ├── detail-design.md       ← template, extended during Phase 3a
│   ├── interface-contract.md  ← Phase 2 contract for LOCAL features (public Swift surface)
│   └── openapi.yaml           ← Phase 2 contract for NETWORK-boundary features only
└── references/
    ├── stage-model.md    ← the 6-stage AI/human boundary, in detail
    ├── phase-gates.md    ← the complete gate checklist per phase
    └── learning-feedback.md ← failure → rule loop
```
