import Foundation
import Testing
@testable import WakeupCore

@Suite("UserDefaultsHomeRepository")
struct UserDefaultsHomeRepositoryTests {

    // Each test gets an isolated UserDefaults suite so they don't collide.
    func makeIsolated() -> (UserDefaultsHomeRepository, String, UserDefaults) {
        let suite = "test.wakeup.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        return (UserDefaultsHomeRepository(defaults: defaults), suite, defaults)
    }

    let home = HomeLocation(
        coordinate: Coordinate(latitude: 35.681236, longitude: 139.767125),
        address: "Tokyo Station")
    let schedule = AlarmSchedule(hour: 7, minute: 0)!

    @Test("load returns nil when nothing has been saved")
    func emptyByDefault() throws {
        let (repo, suite, defaults) = makeIsolated()
        defer { defaults.removePersistentDomain(forName: suite) }
        #expect(try repo.load() == nil)
    }

    @Test("save then load round-trips")
    func roundTrip() throws {
        let (repo, suite, defaults) = makeIsolated()
        defer { defaults.removePersistentDomain(forName: suite) }
        try repo.save(home: home, schedule: schedule)
        let loaded = try repo.load()
        #expect(loaded == RegisteredAlarm(home: home, schedule: schedule))
    }

    @Test("saving again overwrites the previous value")
    func overwrite() throws {
        let (repo, suite, defaults) = makeIsolated()
        defer { defaults.removePersistentDomain(forName: suite) }
        try repo.save(home: home, schedule: schedule)

        let newSchedule = AlarmSchedule(hour: 6, minute: 30)!
        try repo.save(home: home, schedule: newSchedule)

        #expect(try repo.load() == RegisteredAlarm(home: home, schedule: newSchedule))
    }

    @Test("clear removes the stored value")
    func clear() throws {
        let (repo, suite, defaults) = makeIsolated()
        defer { defaults.removePersistentDomain(forName: suite) }
        try repo.save(home: home, schedule: schedule)
        try repo.clear()
        #expect(try repo.load() == nil)
    }
}
