import Foundation

/// The alarm state machine. A pure reducer: given the current state and the
/// observed world (time, distance from home) it returns the next state.
/// Keeping it side-effect-free is what makes the core fully unit-testable;
/// the app coordinator performs the actual sound/geofence side effects.
public struct EvaluateAlarmUseCase: Sendable {
    public let homeRadiusMeters: Double

    public init(homeRadiusMeters: Double) {
        self.homeRadiusMeters = homeRadiusMeters
    }

    /// User command: arm tonight's alarm.
    public func arm(schedule: AlarmSchedule, now: Date, calendar: Calendar) -> AlarmState {
        .armed(nextTrigger: schedule.nextTrigger(after: now, calendar: calendar))
    }

    /// User command: cancel the alarm.
    public func disarm() -> AlarmState {
        .idle
    }

    /// Automatic transition driven by observed time and distance.
    /// - Parameter distanceFromHome: meters from the registered home, or
    ///   `nil` when the current location is not yet known.
    public func nextState(
        from current: AlarmState,
        now: Date,
        distanceFromHome: Double?
    ) -> AlarmState {
        switch current {
        case .idle:
            return .idle

        case .armed(let trigger):
            return now >= trigger ? .ringing(since: now) : current

        case .ringing:
            if let distance = distanceFromHome, distance > homeRadiusMeters {
                return .stopped
            }
            return current

        case .stopped:
            return .stopped
        }
    }
}
