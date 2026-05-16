/// WakeupCore — platform-agnostic domain & data layer for the Wakeup app.
///
/// Contains pure logic (distance, alarm state machine, persistence) with no
/// iOS-framework imports, so it is fully unit-testable via `swift test`.
/// The Xcode app target (SwiftUI presentation + CoreLocation/AVAudio infra)
/// depends on this package and conforms to the protocols defined here.
public enum WakeupCore {}
