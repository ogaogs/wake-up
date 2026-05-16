import Foundation
import Combine
import WakeupCore

enum Screen: String, CaseIterable, Identifiable {
    case onboard, setHome, setTime, idle, armed, ringing, stopped, settings
    var id: String { rawValue }

    var jumpLabel: String {
        switch self {
        case .onboard: return "Onboard"
        case .setHome: return "Set home"
        case .setTime: return "Set time"
        case .idle: return "Idle"
        case .armed: return "Armed"
        case .ringing: return "Ringing"
        case .stopped: return "Stopped"
        case .settings: return "Settings"
        }
    }
}

/// Drives navigation and the real `EvaluateAlarmUseCase` state machine from
/// WakeupCore. Distance scrubbing on Ringing stands in for live CoreLocation
/// the same way the web prototype's slider did.
@MainActor
final class WakeupViewModel: ObservableObject {
    @Published var screen: Screen = .idle
    @Published var alarmState: AlarmState = .idle

    @Published var homeAddress: String = "512 Larkin St, San Francisco"
    @Published var wakeHour: Int = 6
    @Published var wakeMinute: Int = 30

    /// Meters from home while ringing (prototype substitute for live GPS).
    @Published var distance: Double = 0

    let geofenceMeters = WakeupConfig.geofenceRadiusMeters
    private let useCase = EvaluateAlarmUseCase(
        homeRadiusMeters: WakeupConfig.geofenceRadiusMeters)
    private let calendar = Calendar.current

    // Fixed home coordinate matching the address shown in the prototype.
    private let homeCoordinate = Coordinate(latitude: 37.7821, longitude: -122.4185)

    private var schedule: AlarmSchedule {
        AlarmSchedule(hour: wakeHour, minute: wakeMinute)
            ?? AlarmSchedule(hour: 6, minute: 30)!
    }

    var home: HomeLocation {
        HomeLocation(coordinate: homeCoordinate, address: homeAddress)
    }

    // MARK: Derived display values

    var wakeTime12h: (h: Int, m: String, ampm: String) {
        let h12 = ((wakeHour + 11) % 12) + 1
        return (h12, String(format: "%02d", wakeMinute),
                wakeHour < 12 ? "AM" : "PM")
    }

    /// Hours/minutes from now until the next wake occurrence.
    var countdown: (h: Int, m: Int) {
        let trigger = schedule.nextTrigger(after: Date(), calendar: calendar)
        let secs = max(0, trigger.timeIntervalSinceNow)
        return (Int(secs) / 3600, (Int(secs) % 3600) / 60)
    }

    var remainingToGeofence: Double { max(geofenceMeters - distance, 0) }
    var geofenceProgress: Double { min(distance / geofenceMeters, 1) }

    // MARK: Commands (real domain transitions)

    func goOnboarding() { screen = .onboard }

    func completeOnboarding() { screen = .setHome }

    func arm() {
        alarmState = useCase.arm(schedule: schedule, now: Date(), calendar: calendar)
        screen = .armed
    }

    func disarm() {
        alarmState = useCase.disarm()
        screen = .idle
    }

    /// Simulate the wake time being reached (prototype: you can't wait 8h).
    func triggerNow() {
        if case .armed = alarmState {} else {
            alarmState = useCase.arm(schedule: schedule, now: Date(), calendar: calendar)
        }
        alarmState = .ringing(since: Date())
        distance = 0
        pendingStop = false
        screen = .ringing
    }

    private var pendingStop = false

    /// Feed an observed distance into the state machine while ringing. The
    /// display caps at the 300 m radius; once reached we let the success copy
    /// breathe briefly (mirrors the prototype's 0.9s pause) before the domain
    /// transition to `.stopped` fires.
    func updateDistance(_ meters: Double) {
        distance = min(max(meters, 0), geofenceMeters)
        guard distance >= geofenceMeters, !pendingStop,
              case .ringing = alarmState else { return }
        pendingStop = true
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 900_000_000)
            guard case .ringing = alarmState else { pendingStop = false; return }
            alarmState = useCase.nextState(
                from: alarmState, now: Date(),
                distanceFromHome: geofenceMeters + 1)
            pendingStop = false
            if case .stopped = alarmState { screen = .stopped }
        }
    }

    func finishMorning() {
        alarmState = .idle
        distance = 0
        screen = .idle
    }

    func openSettings() { screen = .settings }
    func closeSettings() { screen = .idle }
    func editHome() { screen = .setHome }
    func editTime() { screen = .setTime }
    func confirmHome() { screen = .setTime }
    func confirmTime() { screen = .idle }

    // Prototype jump bar — teleport without losing real domain semantics.
    func jump(to target: Screen) {
        switch target {
        case .armed:
            alarmState = useCase.arm(schedule: schedule, now: Date(), calendar: calendar)
        case .ringing:
            alarmState = .ringing(since: Date())
            distance = 0
            pendingStop = false
        case .stopped:
            alarmState = .stopped
        case .idle:
            alarmState = .idle
            distance = 0
            pendingStop = false
        default:
            break
        }
        screen = target
    }
}
