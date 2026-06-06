# Interface Contract: <feature name>

> **Use this for LOCAL features** (no network boundary) — the default for this iOS app.
> If the feature crosses a network boundary (a backend, Slack, etc.), use `openapi.yaml` instead.
>
> **Audience:** an engineer who will call into or build on this feature without reading its implementation.
> **What goes here:** the *public* Swift surface only — what other modules/screens depend on. Internal types,
> private helpers, and implementation details belong in the detail design, not here.
> **Source of truth:** this contract is authoritative for the public API. Implementation and basic-design defer to it.

## Module / target

<Which SwiftPM target owns this — e.g. `WakeupCore` (domain/use cases) vs `WakeupApp` (UI). State why the boundary sits where it does.>

## Public types

> The structs / enums / classes other code constructs or receives. Include only public-facing members.

```swift
/// One-line purpose.
public struct <Name>: <Equatable/Codable/...> {
    public let <field>: <Type>   // meaning, units, invariants
    // ...
}

public enum <Name> {
    case <case>   // when this case applies
}
```

| Type | Kind | Purpose | Notable invariants |
|------|------|---------|--------------------|
| `Foo` | struct | <what it represents> | `count >= 0`, immutable |

## Public protocols / entry points

> The seams the feature exposes — use-case protocols, repositories, view models. This is what tests fake and what
> the UI layer calls. Give each method's contract, not its body.

```swift
public protocol <Name>UseCase {
    /// What it does, in terms of inputs → outputs.
    /// - Throws: <which errors, when>
    func <method>(_ input: <Type>) <async> <throws> -> <Type>
}
```

| Entry point | Inputs | Output | Errors / failure modes |
|-------------|--------|--------|------------------------|
| `evaluate(_:)` | `<Type>` | `<Type>` | `<Error case>` when `<condition>` |

## State & side effects

> For a SwiftUI feature, name the observable state and what drives changes.

- **Observable state:** <`@Published` / `@Observable` properties the views read>
- **Side effects:** <persistence (UserDefaults/file), notifications, location, audio, haptics, timers — and when each fires>
- **Threading:** <main-actor expectations, async boundaries>

## Errors

| Error | When it's thrown | How the caller is expected to handle it |
|-------|------------------|------------------------------------------|
| `<Error.case>` | <condition> | <recover / surface to user / fatal> |

## Dependencies (injected)

> What this feature needs handed to it — the protocols it depends on, so tests can substitute fakes.

| Dependency (protocol) | Why | Default implementation |
|-----------------------|-----|------------------------|
| `HomeRepository` | persist home location | `UserDefaultsHomeRepository` |

## What is intentionally NOT public

> List the internals you are deliberately keeping out of the contract, so a reader knows the omission is on purpose.

- <internal type / helper>: stays private because <reason>
