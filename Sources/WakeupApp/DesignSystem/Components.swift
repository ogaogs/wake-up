import SwiftUI

// MARK: - Sun mark / logo (custom — the brand signature)

/// Wordmark sun: a filled disc sitting on a horizon line with rays fanning up.
/// Mirrors `WakeupMark` in wakeup-ui.jsx.
struct WakeupMark: View {
    var size: CGFloat = 28
    var color: Color = Theme.ink

    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 32
            let cx = 16 * s, cy = 20 * s
            // disc
            ctx.fill(
                Path(ellipseIn: CGRect(x: cx - 9 * s, y: cy - 9 * s,
                                       width: 18 * s, height: 18 * s)),
                with: .color(color))
            // horizon
            var horizon = Path()
            horizon.move(to: CGPoint(x: 3 * s, y: cy))
            horizon.addLine(to: CGPoint(x: 29 * s, y: cy))
            ctx.stroke(horizon, with: .color(color),
                       style: StrokeStyle(lineWidth: 2 * s, lineCap: .round))
            // rays
            for a in [-50.0, -30, -10, 10, 30, 50] {
                let rad = (a - 90) * .pi / 180
                var ray = Path()
                ray.move(to: CGPoint(x: cx + cos(rad) * 11 * s,
                                     y: cy + sin(rad) * 11 * s))
                ray.addLine(to: CGPoint(x: cx + cos(rad) * 14 * s,
                                        y: cy + sin(rad) * 14 * s))
                ctx.stroke(ray, with: .color(color),
                           style: StrokeStyle(lineWidth: 2 * s, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

/// Full radiant sun (8 rays) used in cards. Mirrors `Icon.Sun`.
struct SunIcon: View {
    var size: CGFloat = 24
    var color: Color = Theme.ink

    var body: some View {
        Canvas { ctx, sz in
            let s = sz.width / 24
            let c = CGPoint(x: 12 * s, y: 12 * s)
            ctx.fill(
                Path(ellipseIn: CGRect(x: c.x - 4.5 * s, y: c.y - 4.5 * s,
                                       width: 9 * s, height: 9 * s)),
                with: .color(color))
            for a in stride(from: 0.0, to: 360, by: 45) {
                let rad = a * .pi / 180
                var ray = Path()
                ray.move(to: CGPoint(x: c.x + cos(rad) * 7.5 * s,
                                     y: c.y + sin(rad) * 7.5 * s))
                ray.addLine(to: CGPoint(x: c.x + cos(rad) * 10.5 * s,
                                        y: c.y + sin(rad) * 10.5 * s))
                ctx.stroke(ray, with: .color(color),
                           style: StrokeStyle(lineWidth: 2 * s, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Big primary button

enum BigButtonVariant {
    case primary, coral, light, ghost, night, danger
}

struct BigButton: View {
    var title: String
    var variant: BigButtonVariant = .primary
    var systemIcon: String? = nil
    var disabled: Bool = false
    var action: () -> Void

    private var bg: Color {
        switch variant {
        case .primary: return Theme.ink
        case .coral: return Theme.coral
        case .light: return .white
        case .ghost: return .clear
        case .night: return Color(hex: 0xFFEFDD, alpha: 0.95)
        case .danger: return Color.white.opacity(0.16)
        }
    }
    private var fg: Color {
        switch variant {
        case .primary: return Theme.peach50
        case .coral: return .white
        case .light: return Theme.ink
        case .ghost: return Theme.ink
        case .night: return Theme.nightBg
        case .danger: return Theme.peach50
        }
    }
    private var border: Color? {
        switch variant {
        case .ghost: return Theme.ink.opacity(0.2)
        case .danger: return Color(hex: 0xFFEFDD, alpha: 0.3)
        default: return nil
        }
    }
    private var shadow: (Color, CGFloat, CGFloat) {
        switch variant {
        case .primary: return (Color(hex: 0x2B1810, alpha: 0.25), 20, 6)
        case .coral: return (Color(hex: 0xF26B3A, alpha: 0.40), 26, 10)
        case .light: return (Color(hex: 0x2B1810, alpha: 0.10), 14, 4)
        case .night: return (Color.black.opacity(0.3), 20, 6)
        default: return (.clear, 0, 0)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemIcon {
                    Image(systemName: systemIcon).font(.system(size: 18, weight: .semibold))
                }
                Text(title)
            }
            .font(Theme.ui(17, .semibold))
            .tracking(-0.2)
            .foregroundColor(fg)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(bg)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(border ?? .clear, lineWidth: border == nil ? 0 : 1.5))
            .shadow(color: shadow.0, radius: shadow.1, x: 0, y: shadow.2)
            .opacity(disabled ? 0.5 : 1)
        }
        .buttonStyle(TappableStyle())
        .disabled(disabled)
    }
}

// MARK: - Small reusable pieces

/// The uppercase status line with a leading dot (Idle/Armed/Stopped eyebrows).
struct StatePill: View {
    var text: String
    var color: Color
    var glow: Bool = false
    var breathing: Bool = false

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(color)
                .frame(width: 7, height: 7)
                .shadow(color: glow ? color : .clear, radius: glow ? 6 : 0)
                .modifier(BreatheModifier(active: breathing))
            Text(text)
        }
        .monoLabel(10.5, tracking: 1.5, color: color)
    }
}

/// Rounded "round button" used for back / settings / gear in headers.
struct CircleIconButton: View {
    var systemName: String
    var dark: Bool = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(dark ? Theme.nightText : Theme.ink)
                .frame(width: 40, height: 40)
                .background(
                    (dark ? Theme.nightText : Theme.ink).opacity(dark ? 0.08 : 0.06))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(TappableStyle())
    }
}
