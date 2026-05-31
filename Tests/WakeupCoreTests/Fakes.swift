import Foundation
@testable import WakeupCore

// Reusable test doubles. These also back the app's ViewModel tests later,
// once the Xcode target exists.

final class FakeClock: Clock, @unchecked Sendable {
    var nowValue: Date
    init(_ now: Date) { self.nowValue = now }
    var now: Date { nowValue }
}

final class FakeLocationProviding: LocationProviding, @unchecked Sendable {
    var currentCoordinate: Coordinate?
    init(_ coordinate: Coordinate? = nil) { self.currentCoordinate = coordinate }
}

final class InMemoryHomeRepository: HomeRepository, @unchecked Sendable {
    private var stored: RegisteredAlarm?
    init() {}
    func save(home: HomeLocation, schedule: AlarmSchedule) throws {
        stored = RegisteredAlarm(home: home, schedule: schedule)
    }
    func load() throws -> RegisteredAlarm? { stored }
    func clear() throws { stored = nil }
}

final class SpyLocationMonitoring: LocationMonitoring {
    var onExitRegion: (() -> Void)?
    private(set) var monitoredCenter: Coordinate?
    private(set) var monitoredRadius: Double?
    private(set) var stopCount = 0

    func startMonitoring(center: Coordinate, radiusMeters: Double) {
        monitoredCenter = center
        monitoredRadius = radiusMeters
    }
    func stopMonitoring() { stopCount += 1 }
    func simulateExit() { onExitRegion?() }
}

final class SpyAlarmAudio: AlarmAudioPlaying {
    private(set) var isPlayingAlarm = false
    private(set) var keepAliveOn = false
    func startAlarm() { isPlayingAlarm = true }
    func stopAlarm() { isPlayingAlarm = false }
    func startKeepAlive() { keepAliveOn = true }
    func stopKeepAlive() { keepAliveOn = false }
}

final class SpyNotificationScheduling: NotificationScheduling {
    var authorizationResult = true
    private(set) var scheduledAt: Date?
    private(set) var cancelCount = 0
    func requestAuthorization() async -> Bool { authorizationResult }
    func scheduleAlarmNotifications(at trigger: Date) { scheduledAt = trigger }
    func cancelAlarmNotifications() { cancelCount += 1 }
}
