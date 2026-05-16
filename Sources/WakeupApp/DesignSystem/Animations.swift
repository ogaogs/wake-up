import SwiftUI

// Reusable looping animations mirroring the @keyframes in wakeup-tokens.css.

struct BreatheModifier: ViewModifier {
    var active: Bool = true
    var duration: Double = 2
    var scale: CGFloat = 1.015
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(active && on ? scale : 1)
            .onAppear {
                guard active else { return }
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    on = true
                }
            }
    }
}

/// ring-pulse: gentle scale + opacity throb (the ringing sun/bell halo).
struct RingPulseModifier: ViewModifier {
    var duration: Double = 0.7
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(on ? 1.04 : 1)
            .opacity(on ? 0.93 : 1)
            .onAppear {
                withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
                    on = true
                }
            }
    }
}

/// ring-shake: small rotational jitter (the ringing bell).
struct RingShakeModifier: ViewModifier {
    @State private var on = false

    func body(content: Content) -> some View {
        content
            .rotationEffect(.degrees(on ? 2 : -2))
            .offset(x: on ? 2 : -2)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.2).repeatForever(autoreverses: true)) {
                    on = true
                }
            }
    }
}

/// radial-ping: a ring that expands outward and fades. Used for the pulse
/// halo on Ringing and the user dot on the map.
struct RadialPing: View {
    var color: Color
    var lineWidth: CGFloat = 1.5
    var baseSize: CGFloat
    var duration: Double = 2.6
    @State private var animating = false

    var body: some View {
        Circle()
            .strokeBorder(color, lineWidth: lineWidth)
            .frame(width: baseSize, height: baseSize)
            .scaleEffect(animating ? 2.4 : 0.6)
            .opacity(animating ? 0 : 0.9)
            .onAppear {
                withAnimation(.easeOut(duration: duration).repeatForever(autoreverses: false)) {
                    animating = true
                }
            }
    }
}

/// star-twinkle: opacity flicker for the night sky dots.
struct TwinkleModifier: ViewModifier {
    var delay: Double
    var duration: Double
    @State private var bright = false

    func body(content: Content) -> some View {
        content
            .opacity(bright ? 0.9 : 0.2)
            .onAppear {
                withAnimation(.easeInOut(duration: duration)
                    .repeatForever(autoreverses: true).delay(delay)) {
                    bright = true
                }
            }
    }
}

/// fade-up / sun-rise entrance: slide up + fade in once on appear.
struct AppearUpModifier: ViewModifier {
    var delay: Double = 0
    var distance: CGFloat = 10
    var duration: Double = 0.5
    @State private var shown = false

    func body(content: Content) -> some View {
        content
            .opacity(shown ? 1 : 0)
            .offset(y: shown ? 0 : distance)
            .onAppear {
                withAnimation(.easeOut(duration: duration).delay(delay)) {
                    shown = true
                }
            }
    }
}

extension View {
    func breathe(active: Bool = true, duration: Double = 2, scale: CGFloat = 1.015) -> some View {
        modifier(BreatheModifier(active: active, duration: duration, scale: scale))
    }
    func ringPulse(duration: Double = 0.7) -> some View {
        modifier(RingPulseModifier(duration: duration))
    }
    func ringShake() -> some View { modifier(RingShakeModifier()) }
    func twinkle(delay: Double, duration: Double) -> some View {
        modifier(TwinkleModifier(delay: delay, duration: duration))
    }
    func appearUp(delay: Double = 0, distance: CGFloat = 10, duration: Double = 0.5) -> some View {
        modifier(AppearUpModifier(delay: delay, distance: distance, duration: duration))
    }
}
