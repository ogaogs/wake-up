import Foundation
import Testing
@testable import WakeupCore

@Suite("EvaluateAlarmUseCase")
struct EvaluateAlarmUseCaseTests {

    let sut = EvaluateAlarmUseCase(homeRadiusMeters: WakeupConfig.geofenceRadiusMeters)
    let t0 = Date(timeIntervalSince1970: 1_000_000)

    var utcCalendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = TimeZone(identifier: "UTC")!
        return c
    }

    // MARK: arming / disarming

    @Test("arm produces .armed with the schedule's next trigger")
    func arm() {
        let cal = utcCalendar
        let schedule = AlarmSchedule(hour: 7, minute: 0)!
        let now = cal.date(from: DateComponents(
            year: 2026, month: 5, day: 16, hour: 5))!
        let state = sut.arm(schedule: schedule, now: now, calendar: cal)
        #expect(state == .armed(nextTrigger: schedule.nextTrigger(after: now, calendar: cal)))
    }

    @Test("disarm returns to .idle")
    func disarm() {
        #expect(sut.disarm() == .idle)
    }

    // MARK: automatic transitions

    @Test(".idle is unaffected by time or distance")
    func idleStaysIdle() {
        #expect(sut.nextState(from: .idle, now: t0, distanceFromHome: 9_999) == .idle)
    }

    @Test(".armed stays armed before the trigger")
    func armedBeforeTrigger() {
        let trigger = t0.addingTimeInterval(60)
        let s = sut.nextState(from: .armed(nextTrigger: trigger),
                              now: t0, distanceFromHome: nil)
        #expect(s == .armed(nextTrigger: trigger))
    }

    @Test(".armed starts ringing exactly at the trigger")
    func armedAtTrigger() {
        let s = sut.nextState(from: .armed(nextTrigger: t0),
                              now: t0, distanceFromHome: 0)
        #expect(s == .ringing(since: t0))
    }

    @Test(".armed starts ringing after the trigger")
    func armedAfterTrigger() {
        let trigger = t0.addingTimeInterval(-60)
        let s = sut.nextState(from: .armed(nextTrigger: trigger),
                              now: t0, distanceFromHome: 10)
        #expect(s == .ringing(since: t0))
    }

    @Test(".ringing keeps ringing while location is unknown")
    func ringingNoLocation() {
        let s = sut.nextState(from: .ringing(since: t0),
                              now: t0, distanceFromHome: nil)
        #expect(s == .ringing(since: t0))
    }

    @Test(".ringing keeps ringing at exactly the radius (must exceed it)")
    func ringingAtBoundary() {
        let s = sut.nextState(from: .ringing(since: t0),
                              now: t0, distanceFromHome: 300)
        #expect(s == .ringing(since: t0))
    }

    @Test(".ringing keeps ringing at 299 m")
    func ringingUnderBoundary() {
        let s = sut.nextState(from: .ringing(since: t0),
                              now: t0, distanceFromHome: 299)
        #expect(s == .ringing(since: t0))
    }

    @Test(".ringing stops once past the radius (301 m)")
    func ringingStopsWhenFarEnough() {
        let s = sut.nextState(from: .ringing(since: t0),
                              now: t0, distanceFromHome: 301)
        #expect(s == .stopped)
    }

    @Test(".stopped is terminal for the occurrence")
    func stoppedStaysStopped() {
        #expect(sut.nextState(from: .stopped, now: t0, distanceFromHome: 0) == .stopped)
    }

    // MARK: protocol seams used by the app coordinator

    @Test("SystemClock returns a present-ish time")
    func systemClock() {
        let before = Date()
        let now = SystemClock().now
        #expect(now.timeIntervalSince(before) >= 0)
        #expect(now.timeIntervalSince(before) < 5)
    }
}
