// TEMPORARY CLT smoke runner — see Package.swift. Mirrors the critical
// expectations from the Swift Testing suites so the pure core can be
// verified without Xcode. Remove once `swift test` works under Xcode.

import Foundation
import WakeupCore

var failures = 0
@MainActor
func check(_ condition: Bool, _ label: String) {
    if condition {
        print("  ok  - \(label)")
    } else {
        failures += 1
        print("  FAIL- \(label)")
    }
}

func utcCalendar() -> Calendar {
    var c = Calendar(identifier: .gregorian)
    c.timeZone = TimeZone(identifier: "UTC")!
    return c
}

print("Distance (Haversine)")
let origin = Coordinate(latitude: 35.681236, longitude: 139.767125)
let mPerDegLat = (Double.pi / 180) * 6_371_000
check(origin.distance(to: origin) == 0, "self distance is 0")
let north300 = Coordinate(latitude: origin.latitude + 300 / mPerDegLat,
                          longitude: origin.longitude)
check(abs(origin.distance(to: north300) - 300) < 1, "300 m north ≈ 300 m")
let under = Coordinate(latitude: origin.latitude + 299 / mPerDegLat,
                       longitude: origin.longitude)
let over = Coordinate(latitude: origin.latitude + 301 / mPerDegLat,
                      longitude: origin.longitude)
check(origin.distance(to: under) < 300, "299 m is under threshold")
check(origin.distance(to: over) > 300, "301 m is over threshold")

print("AlarmSchedule")
check(AlarmSchedule(hour: 24, minute: 0) == nil, "rejects hour 24")
check(AlarmSchedule(hour: 7, minute: 60) == nil, "rejects minute 60")
check(AlarmSchedule(hour: 0, minute: 0) != nil, "accepts 00:00")
let cal = utcCalendar()
let sched = AlarmSchedule(hour: 7, minute: 0)!
let before = cal.date(from: DateComponents(year: 2026, month: 5, day: 16, hour: 5))!
let laterToday = sched.nextTrigger(after: before, calendar: cal)
let c1 = cal.dateComponents([.day, .hour, .minute], from: laterToday)
check(c1.day == 16 && c1.hour == 7 && c1.minute == 0, "fires later today")
let after = cal.date(from: DateComponents(year: 2026, month: 5, day: 16, hour: 9))!
let tomorrow = sched.nextTrigger(after: after, calendar: cal)
let c2 = cal.dateComponents([.day, .hour, .minute], from: tomorrow)
check(c2.day == 17 && c2.hour == 7 && c2.minute == 0, "rolls to tomorrow")

print("EvaluateAlarmUseCase")
let sut = EvaluateAlarmUseCase(homeRadiusMeters: WakeupConfig.geofenceRadiusMeters)
let t0 = Date(timeIntervalSince1970: 1_000_000)
check(sut.nextState(from: .idle, now: t0, distanceFromHome: 9_999) == .idle,
      "idle stays idle")
check(sut.nextState(from: .armed(nextTrigger: t0.addingTimeInterval(60)),
                     now: t0, distanceFromHome: nil)
      == .armed(nextTrigger: t0.addingTimeInterval(60)),
      "armed before trigger unchanged")
check(sut.nextState(from: .armed(nextTrigger: t0), now: t0, distanceFromHome: 0)
      == .ringing(since: t0), "armed at trigger -> ringing")
check(sut.nextState(from: .ringing(since: t0), now: t0, distanceFromHome: 300)
      == .ringing(since: t0), "ringing at exactly 300 m keeps ringing")
check(sut.nextState(from: .ringing(since: t0), now: t0, distanceFromHome: 301)
      == .stopped, "ringing past 300 m -> stopped")
check(sut.nextState(from: .stopped, now: t0, distanceFromHome: 0) == .stopped,
      "stopped is terminal")
check(sut.arm(schedule: sched, now: before, calendar: cal)
      == .armed(nextTrigger: sched.nextTrigger(after: before, calendar: cal)),
      "arm produces armed(nextTrigger)")
check(sut.disarm() == .idle, "disarm -> idle")

print("UserDefaultsHomeRepository")
let suite = "smoke.wakeup.\(UUID().uuidString)"
let defaults = UserDefaults(suiteName: suite)!
let repo = UserDefaultsHomeRepository(defaults: defaults)
let home = HomeLocation(coordinate: origin, address: "Tokyo Station")
do {
    check(try repo.load() == nil, "empty by default")
    try repo.save(home: home, schedule: sched)
    check(try repo.load() == RegisteredAlarm(home: home, schedule: sched),
          "save/load round-trips")
    try repo.clear()
    check(try repo.load() == nil, "clear removes value")
} catch {
    failures += 1
    print("  FAIL- repository threw: \(error)")
}
defaults.removePersistentDomain(forName: suite)

print(failures == 0
      ? "\nALL SMOKE CHECKS PASSED"
      : "\n\(failures) SMOKE CHECK(S) FAILED")
exit(failures == 0 ? 0 : 1)
