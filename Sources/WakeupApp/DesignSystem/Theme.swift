import SwiftUI

// Design tokens ported from wakeup-tokens.css. The web prototype landed on a
// single clean sans (Geist) at multiple weights + a mono for labels; the
// native equivalents are the system font and the monospaced system design.

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha)
    }
}

enum Theme {
    // Cream warm palette
    static let bgCream = Color(hex: 0xFBF1E4)
    static let bgCard = Color.white
    static let ink = Color(hex: 0x2B1810)
    static let ink2 = Color(hex: 0x6A4233)
    static let ink3 = Color(hex: 0x9C7560)
    static let hairline = Color(hex: 0x2B1810, alpha: 0.10)

    // Sunrise
    static let peach50 = Color(hex: 0xFFEFDD)
    static let peach100 = Color(hex: 0xFFD9B0)
    static let peach200 = Color(hex: 0xFFB985)
    static let coral = Color(hex: 0xF26B3A)
    static let coralDeep = Color(hex: 0xD04A1F)
    static let terracotta = Color(hex: 0xA1351F)
    static let amber = Color(hex: 0xF4A547)
    static let gold = Color(hex: 0xE8B860)

    // Night
    static let nightBg = Color(hex: 0x1B1530)
    static let nightText = Color(hex: 0xF5E7D8)
    static let nightText2 = Color(hex: 0xF5E7D8, alpha: 0.6)
    static let nightText3 = Color(hex: 0xF5E7D8, alpha: 0.4)
    static let nightCard = Color(hex: 0xFFF0DC, alpha: 0.06)
    static let nightLine = Color(hex: 0xFFF0DC, alpha: 0.14)

    // State accents
    static let stopped = Color(hex: 0x5B8A4F)

    // Gradients ───────────────────────────────────────────────
    static let sunriseSoft = LinearGradient(
        stops: [
            .init(color: Color(hex: 0xFFEFDD), location: 0),
            .init(color: Color(hex: 0xFFD9B0), location: 0.60),
            .init(color: Color(hex: 0xFFB985), location: 1),
        ],
        startPoint: .top, endPoint: .bottom)

    static let dawn = LinearGradient(
        stops: [
            .init(color: Color(hex: 0x1B1530), location: 0),
            .init(color: Color(hex: 0x3A1F3E), location: 0.30),
            .init(color: Color(hex: 0x8C3A2E), location: 0.60),
            .init(color: Color(hex: 0xF26B3A), location: 0.85),
            .init(color: Color(hex: 0xFFB985), location: 1),
        ],
        startPoint: .top, endPoint: .bottom)

    static func night(_ size: CGSize) -> RadialGradient {
        // radial 120% 70% at 50% 0%
        RadialGradient(
            stops: [
                .init(color: Color(hex: 0x2D1B45), location: 0),
                .init(color: Color(hex: 0x1B1530), location: 0.50),
                .init(color: Color(hex: 0x0D081A), location: 1),
            ],
            center: .top,
            startRadius: 0,
            endRadius: max(size.width, size.height) * 1.1)
    }

    // Type ─────────────────────────────────────────────────────
    static func ui(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }

    static func display(_ size: CGFloat, _ weight: Font.Weight = .semibold) -> Font {
        .system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight, design: .monospaced)
    }
}

// Tappable scale-on-press button style (mirrors .tappable in tokens.css).
struct TappableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .opacity(configuration.isPressed ? 0.85 : 1)
            .animation(.spring(response: 0.18, dampingFraction: 0.7),
                       value: configuration.isPressed)
    }
}

extension View {
    /// Uppercase mono label used throughout the design for eyebrow text.
    func monoLabel(_ size: CGFloat = 11, tracking: CGFloat = 1.5,
                   color: Color = Theme.ink3) -> some View {
        self.font(Theme.mono(size, .medium))
            .tracking(tracking)
            .textCase(.uppercase)
            .foregroundColor(color)
    }
}
