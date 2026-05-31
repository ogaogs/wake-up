import Foundation
import Testing
@testable import WakeupCore

@Suite("HomeLocation")
struct HomeLocationTests {

    @Test("round-trips through Codable")
    func codableRoundTrip() throws {
        let home = HomeLocation(
            coordinate: Coordinate(latitude: 35.681236, longitude: 139.767125),
            address: "Tokyo Station")
        let data = try JSONEncoder().encode(home)
        let decoded = try JSONDecoder().decode(HomeLocation.self, from: data)
        #expect(decoded == home)
    }
}

@Suite("AlarmSchedule")
struct AlarmScheduleTests {

    // A fixed UTC calendar keeps these tests independent of machine timezone.
    var utcCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    @Test("rejects out-of-range hour or minute")
    func validation() {
        #expect(AlarmSchedule(hour: 24, minute: 0) == nil)
        #expect(AlarmSchedule(hour: -1, minute: 0) == nil)
        #expect(AlarmSchedule(hour: 7, minute: 60) == nil)
        #expect(AlarmSchedule(hour: 7, minute: -1) == nil)
        #expect(AlarmSchedule(hour: 0, minute: 0) != nil)
        #expect(AlarmSchedule(hour: 23, minute: 59) != nil)
    }

    @Test("next trigger today when reference is before the alarm time")
    func nextTriggerLaterToday() throws {
        let cal = utcCalendar
        let schedule = AlarmSchedule(hour: 7, minute: 0)!
        // 2026-05-16 05:00:00 UTC
        let reference = cal.date(from: DateComponents(
            year: 2026, month: 5, day: 16, hour: 5, minute: 0))!
        let next = schedule.nextTrigger(after: reference, calendar: cal)
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: next)
        #expect(comps.year == 2026 && comps.month == 5 && comps.day == 16)
        #expect(comps.hour == 7 && comps.minute == 0)
    }

    @Test("next trigger rolls to tomorrow when reference is past the alarm time")
    func nextTriggerTomorrow() throws {
        let cal = utcCalendar
        let schedule = AlarmSchedule(hour: 7, minute: 0)!
        // 2026-05-16 09:00:00 UTC (past 07:00)
        let reference = cal.date(from: DateComponents(
            year: 2026, month: 5, day: 16, hour: 9, minute: 0))!
        let next = schedule.nextTrigger(after: reference, calendar: cal)
        let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: next)
        #expect(comps.year == 2026 && comps.month == 5 && comps.day == 17)
        #expect(comps.hour == 7 && comps.minute == 0)
    }
}

@Suite("AlarmState")
struct AlarmStateTests {

    @Test("states with the same payload are equal")
    func equality() {
        let t = Date(timeIntervalSince1970: 1_000)
        #expect(AlarmState.idle == AlarmState.idle)
        #expect(AlarmState.armed(nextTrigger: t) == AlarmState.armed(nextTrigger: t))
        #expect(AlarmState.ringing(since: t) != AlarmState.idle)
        #expect(AlarmState.stopped == AlarmState.stopped)
    }
}
