# Six-Stage Responsibility Model

A model for splitting work between AI and human based on how unique the right answer is. The more open-ended the problem, the more human judgment dominates.

## The stages

| Stage | Concern        | AI share | Human share | Typical tooling (this project)  |
|-------|----------------|----------|-------------|---------------------------------|
| 1     | Format         | 100%     | 0%          | `swift-format`                  |
| 2     | Lint           | 100%     | 0%          | SwiftLint                       |
| 3     | Style          | 90%      | 10%         | Claude Code Review, CodeRabbit  |
| 4     | Logic          | 60%      | 40%         | Claude Code Review              |
| 5     | Design         | 30%      | 70%         | Pair review                     |
| 6     | Architecture   | 0%       | 100%        | Senior engineer / tech lead     |

**Principle:** as the stage number grows, the space of correct answers grows. Format has one right answer; architecture has many, and the choice depends on context the AI can't fully see.

## When each stage runs in the flow

- **Stage 6 (Architecture):** in Phase 2 (Basic Design). Human owns; AI surfaces existing patterns and inconsistencies.
- **Stages 1, 2 (Format, Lint):** inside every TDD cycle in Phase 3a, automated by tooling.
- **Stages 3, 4 (Style, Logic):** at the end of every TDD cycle in Phase 3a. AI proposes, human approves.
- **Stage 5 (Design):** once, at the end of Phase 3a, over the whole implementation block.

## The Stage 4 trap

Stage 4 is where most production bugs slip through. The reason is structural: at 60% AI coverage, the AI catches enough that the human's attention quietly drifts. The cases AI catches feel like "the review", and the cases AI misses feel like "edge cases someone else will spot".

**Counter-rule:** the AI-flagged findings can be handled by AI. The findings the AI *didn't* surface are where the human should spend their attention. Use Stage 4 review time to:

- Cross-check the implementation against each acceptance criterion (from Phase 1).
- Walk through spec-derived edge cases the AI might not have framed as risks.
- Probe assumptions the AI made silently (defaults, null handling, ordering).

## How Stage 5 differs from Stage 4

Stage 4 is about *whether the code is right*. Stage 5 is about *whether the structure is right*: responsibility decomposition, module boundaries, fit with existing patterns. AI can offer mechanical hints — function length, complexity, duplication — but the judgment belongs to the human.

Run Stage 5 once over the entire Phase 3a output, not per cycle. Per-cycle Stage 5 review pulls the human into local fights when the win is at the system level.

## Documentation as an AI-share lever

Writing things down moves work down the stage table. An undocumented architecture decision is a pure Stage 6 problem — the AI can't help. The same decision, written as an ADR, is now Stage 4–5 work for future changes that touch it.

This is why the flow is document-driven. Documents are an investment in AI leverage on future iterations.

## The inverted-attention rule

In every stage that involves human review:

- **Where AI flagged something:** trust the AI's read; spot-check.
- **Where AI flagged nothing:** apply human focus. The silent region is where surprises live.

This is counterintuitive — instinct is to look at the flags. The discipline is to look at what didn't get flagged.
