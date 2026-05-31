/// The persisted registration: where home is and when to wake.
public struct RegisteredAlarm: Codable, Equatable, Sendable {
    public let home: HomeLocation
    public let schedule: AlarmSchedule

    public init(home: HomeLocation, schedule: AlarmSchedule) {
        self.home = home
        self.schedule = schedule
    }
}

/// Persistence boundary for the registered home + alarm time.
public protocol HomeRepository: Sendable {
    func save(home: HomeLocation, schedule: AlarmSchedule) throws
    func load() throws -> RegisteredAlarm?
    func clear() throws
}
