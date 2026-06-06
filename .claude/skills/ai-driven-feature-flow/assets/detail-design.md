# Detail Design: <feature name>

> **Audience:** an engineer fluent in another language reading this codebase for the first time (e.g., a Rails engineer reading Go).
> **Granularity rule:** explain language- or framework-specific judgment calls. Skip generic programming concepts.
>
> This file lives next to the basic-design (often appended below it). One section per TDD cycle.

## Cycle: <short cycle name>

> Add one section like this for every TDD cycle in Phase 3a. Keep the cycle name short and intention-revealing.

### Module structure

<files / packages introduced or modified, and why these boundaries>

### Internal structure

<key types, their responsibilities, and how they collaborate. Diagram or short prose.>

### Processing flow

<step-by-step, at the level a non-native reader can follow without opening the code>

1. <step>
2. <step>

### Algorithms

<only where the choice was non-obvious — e.g., a particular sort, a deduping strategy, a caching approach. If the algorithm is "standard library X", you can skip.>

### Data transformations

<input shape → intermediate shape → output shape, with any normalization or filtering noted>

### Error handling

- <failure mode>: <handling, where the boundary is, what gets logged>
- <failure mode>: ...

### Unit test coverage

<which test file(s), which behaviors covered, and any deliberate gaps with rationale>

### Implementation judgment calls

<things you decided that wouldn't be obvious from reading the code. Examples: chose a specific lib over another, used a non-default config, leaned on a framework convention.>

- <decision>: <why>
- <decision>: ...

### Open questions (cycle-local)

> Only things scoped to this cycle. If something blocks the cycle, push it up to basic-design.

- [ ] <question>

---

## Cycle: <next cycle name>

...
