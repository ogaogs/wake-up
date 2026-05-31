import Foundation

/// Geofence monitoring boundary. The Infra layer implements this with
/// `CLLocationManager` region monitoring, which iOS can deliver even after
/// the app is terminated.
public protocol LocationMonitoring: AnyObject {
    /// Invoked when the device exits the monitored region.
    var onExitRegion: (() -> Void)? { get set }
    func startMonitoring(center: Coordinate, radiusMeters: Double)
    func stopMonitoring()
}

/// Alarm sound boundary. The Infra layer implements this with `AVAudioSession`
/// + `AVAudioPlayer`. `keepAlive` is the silent background-audio trick that
/// keeps the app alive so the alarm can fire at the exact time.
public protocol AlarmAudioPlaying: AnyObject {
    var isPlayingAlarm: Bool { get }
    func startAlarm()
    func stopAlarm()
    func startKeepAlive()
    func stopKeepAlive()
}

/// Local-notification boundary. Backup trigger in case the app is not alive
/// at the alarm time. The Infra layer implements this with
/// `UNUserNotificationCenter`.
public protocol NotificationScheduling: AnyObject {
    func requestAuthorization() async -> Bool
    /// Schedules several spaced notifications starting at `trigger`.
    func scheduleAlarmNotifications(at trigger: Date)
    func cancelAlarmNotifications()
}
