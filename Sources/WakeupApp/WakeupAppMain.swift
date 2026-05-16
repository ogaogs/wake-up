import SwiftUI

/// Public entry point for the Xcode iOS app target. `@main` must live in the
/// app target (an executable), not in this library, so the app's scene simply
/// embeds `WakeupRootView()`. See `App/Wakeup.xcodeproj`.
public struct WakeupRootView: View {
    public init() {}
    public var body: some View {
        RootView()
    }
}
