# Basic Design: <feature name>

> **Audience:** senior engineer evaluating the approach.
> **What goes here:** what the feature is and the design decisions that downstream work depends on. Not how it's implemented internally.

## Feature overview

<One paragraph: what this feature is and the user value it delivers.>

## Acceptance criteria

<List of measurable / testable statements. Each one becomes a verification item in Phase 4.>

- [ ] <criterion 1: observable, with the metric or condition spelled out>
- [ ] <criterion 2>
- [ ] <criterion 3>

## Scope

### In scope

- <bullet>

### Out of scope

- <explicit non-scope; helps prevent feature creep and clarifies follow-ups>

## Interface contract

For a **local feature** (the default in this iOS app), the contract is the public Swift surface, documented at `<path>/interface-contract.md` (from `assets/interface-contract.md`). For a **network-boundary feature**, it's `<path>/openapi.yaml` instead. That file is authoritative; this section just summarizes.

- Owning target: <e.g., `WakeupCore` use cases vs `WakeupApp` views>
- Public entry points: <use-case protocols / view models / endpoints>
- Notable shapes: <anything non-obvious about inputs/outputs or response bodies>

## Data model

<Entities, relationships, ownership. ERD or a table.>

| Entity | Fields                       | Notes                          |
|--------|------------------------------|--------------------------------|
| Foo    | id, name, created_at         | -                              |
| Bar    | id, foo_id, status           | belongs_to Foo                 |

## External dependencies

| Dependency | Purpose             | Failure mode                       |
|------------|---------------------|------------------------------------|
| <service>  | <what it does>      | <what happens if it's down>        |
| <lib>      | <what it does>      | <license / version constraints>    |

## Non-functional requirements

- **Performance:** <p95 latency target, throughput, etc.>
- **Security:** <auth, authz, data sensitivity>
- **Accessibility:** <a11y level, specific concerns>
- **Reliability:** <availability target, retry semantics>
- **Observability:** <metrics, traces, logs needed>

## Architecture decisions

> Stage 6 work. Each decision needs rationale — that's what makes it useful for future changes.

### Decision: <short name>

- **Context:** <what forced the decision>
- **Choice:** <what was chosen>
- **Alternatives considered:** <what was rejected and why>
- **Consequences:** <what becomes easier / harder>

### Decision: <next>

...

## Open questions

> Only questions that can be resolved during Phase 3a without invalidating anything above. If a question could change the API contract, data model, or architecture, it does *not* belong here — resolve it in Phase 2.

- [ ] <question — proposed resolution if any>
- [ ] <question>

## Detail design

> Filled in by Phase 3a per TDD cycle. Append below this line.

<detail design entries appear here as cycles complete>
