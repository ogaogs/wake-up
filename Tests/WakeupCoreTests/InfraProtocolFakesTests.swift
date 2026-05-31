import Foundation
import Testing
@testable import WakeupCore

/// Proves the boundary protocols are implementable and that the shared fakes
/// behave, so they can safely back later ViewModel/coordinator tests.
@Suite("Infra protocol fakes")
struct InfraProtocolFakesTests {

    @Test("location-monitoring spy records the geofence and forwards exit")
    func locationMonitoring() {
        let spy = SpyLocationMonitoring()
        var exited = false
        spy.onExitRegion = { exited = true }

        let home = Coordinate(latitude: 35.681236, longitude: 139.767125)
        spy.startMonitoring(center: home, radiusMeters: 300)
        #expect(spy.monitoredCenter == home)
        #expect(spy.monitoredRadius == 300)

        spy.simulateExit()
        #expect(exited)

        spy.stopMonitoring()
        #expect(spy.stopCount == 1)
    }

    @Test("alarm-audio spy tracks alarm and keep-alive independently")
    func alarmAudio() {
        let audio = SpyAlarmAudio()
        #expect(audio.isPlayingAlarm == false)
        audio.startKeepAlive()
        audio.startAlarm()
        #expect(audio.isPlayingAlarm)
        audio.stopAlarm()
        #expect(audio.isPlayingAlarm == false)
    }

    @Test("notification spy records schedule and cancel")
    func notifications() async {
        let notif = SpyNotificationScheduling()
        #expect(await notif.requestAuthorization())
        let t = Date(timeIntervalSince1970: 2_000)
        notif.scheduleAlarmNotifications(at: t)
        #expect(notif.scheduledAt == t)
        notif.cancelAlarmNotifications()
        #expect(notif.cancelCount == 1)
    }

    @Test("in-memory repository round-trips and clears")
    func inMemoryRepo() throws {
        let repo = InMemoryHomeRepository()
        #expect(try repo.load() == nil)
        let home = HomeLocation(
            coordinate: Coordinate(latitude: 1, longitude: 2), address: "x")
        let schedule = AlarmSchedule(hour: 8, minute: 15)!
        try repo.save(home: home, schedule: schedule)
        #expect(try repo.load() == RegisteredAlarm(home: home, schedule: schedule))
        try repo.clear()
        #expect(try repo.load() == nil)
    }

    @Test("fake clock returns the injected time")
    func fakeClock() {
        let t = Date(timeIntervalSince1970: 42)
        #expect(FakeClock(t).now == t)
    }
}
