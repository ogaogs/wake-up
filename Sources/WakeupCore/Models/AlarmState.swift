import Foundation

/// The alarm lifecycle. Transitions are enforced by `EvaluateAlarmUseCase`,
/// not by this type.
public enum AlarmState: Equatable, Sendable {
    /// Not armed; nothing scheduled.
    case idle
    /// Armed and waiting for `nextTrigger`.
    case armed(nextTrigger: Date)
    /// Time reached; sound playing until the user leaves the geofence.
    case ringing(since: Date)
    /// User left the geofence; alarm satisfied for this occurrence.
    case stopped
}
