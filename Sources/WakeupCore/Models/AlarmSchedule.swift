import Foundation

/// A daily wake-up time (MVP: a single repeating time-of-day).
public struct AlarmSchedule: Codable, Equatable, Sendable {
    public let hour: Int
    public let minute: Int

    /// Fails when the time-of-day is out of range.
    public init?(hour: Int, minute: Int) {
        guard (0...23).contains(hour), (0...59).contains(minute) else {
            return nil
        }
        self.hour = hour
        self.minute = minute
    }

    /// The next moment strictly after `reference` whose time-of-day matches.
    /// Uses `Calendar.nextDate`, which is DST-safe. Note: if `reference` is
    /// exactly at the alarm minute, this returns the following day's occurrence.
    public func nextTrigger(after reference: Date, calendar: Calendar) -> Date {
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = 0
        return calendar.nextDate(
            after: reference,
            matching: components,
            matchingPolicy: .nextTime)!
    }
}
