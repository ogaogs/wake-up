import Foundation

/// `HomeRepository` backed by `UserDefaults` (sufficient for the single-record
/// MVP). `@unchecked Sendable` is safe: `UserDefaults` is documented as
/// thread-safe and we hold it immutably.
public struct UserDefaultsHomeRepository: HomeRepository, @unchecked Sendable {
    private static let key = "wakeup.registeredAlarm"
    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    public func save(home: HomeLocation, schedule: AlarmSchedule) throws {
        let data = try JSONEncoder().encode(RegisteredAlarm(home: home, schedule: schedule))
        defaults.set(data, forKey: Self.key)
    }

    public func load() throws -> RegisteredAlarm? {
        guard let data = defaults.data(forKey: Self.key) else { return nil }
        return try JSONDecoder().decode(RegisteredAlarm.self, from: data)
    }

    public func clear() throws {
        defaults.removeObject(forKey: Self.key)
    }
}
