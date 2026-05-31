import Foundation

/// Time source. Injected so the alarm logic is testable with a fixed clock.
public protocol Clock: Sendable {
    var now: Date { get }
}

public struct SystemClock: Clock {
    public init() {}
    public var now: Date { Date() }
}
