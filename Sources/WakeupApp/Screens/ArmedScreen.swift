import SwiftUI

struct ArmedScreen: View {
    @ObservedObject var vm: WakeupViewModel

    private let stars: [(x: CGFloat, y: CGFloat)] = [
        (0.18, 0.12), (0.82, 0.09), (0.34, 0.22),
        (0.68, 0.26), (0.12, 0.32), (0.88, 0.38),
    ]

    var body: some View {
        let t = vm.wakeTime12h
        let cd = vm.countdown
        GeometryReader { geo in
            ZStack {
                Theme.night(geo.size).ignoresSafeArea()

                ForEach(Array(stars.enumerated()), id: \.offset) { i, s in
                    Circle().fill(Theme.nightText)
                        .frame(width: 2, height: 2)
                        .position(x: s.x * geo.size.width, y: s.y * geo.size.height)
                        .twinkle(delay: Double(i) * 0.4, duration: Double(3 + i % 3))
                }

                // dawn glow at bottom
                RadialGradient(
                    colors: [Color(hex: 0xF26B3A, alpha: 0.25), .clear],
                    center: .bottom, startRadius: 0, endRadius: 240)
                    .frame(height: 240)
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        HStack(spacing: 8) {
                            WakeupMark(size: 22, color: Theme.nightText)
                            Text("Wakeup").font(Theme.display(16, .bold)).tracking(-0.2)
                                .foregroundColor(Theme.nightText)
                        }
                        Spacer()
                        CircleIconButton(systemName: "gearshape.fill", dark: true,
                                         action: vm.openSettings)
                    }
                    .padding(.horizontal, 24).padding(.top, 60)

                    StatePill(text: "Armed · sleep tight", color: Theme.amber,
                              glow: true, breathing: true)
                        .padding(.horizontal, 24).padding(.top, 36)

                    Spacer()

                    VStack(spacing: 0) {
                        Text("Next wake in").monoLabel(11, tracking: 2,
                                                       color: Theme.nightText3)
                            .padding(.bottom, 8)
                        (Text("\(cd.h)")
                         + Text("h ").foregroundColor(Theme.nightText3)
                         + Text(String(format: "%02d", cd.m))
                         + Text("m").foregroundColor(Theme.nightText3))
                            .font(Theme.display(88, .semibold))
                            .monospacedDigit()
                            .tracking(-1)
                            .foregroundColor(Theme.nightText)
                        (Text("Wakes at ")
                            .foregroundColor(Theme.nightText2)
                         + Text("\(t.h):\(t.m) \(t.ampm)")
                            .font(Theme.display(17, .semibold))
                            .foregroundColor(Theme.nightText))
                            .font(Theme.ui(16))
                            .padding(.top, 24)

                        HStack(spacing: 8) {
                            Image(systemName: "mappin")
                                .font(.system(size: 12)).foregroundColor(Theme.nightText2)
                            Text("Geofence active around home")
                                .font(Theme.ui(12.5)).foregroundColor(Theme.nightText2)
                        }
                        .padding(.horizontal, 14).padding(.vertical, 8)
                        .background(Theme.nightText.opacity(0.08))
                        .clipShape(Capsule())
                        .padding(.top, 32)
                    }
                    .frame(maxWidth: .infinity)

                    Spacer()

                    BigButton(title: "Disarm", variant: .danger, action: vm.disarm)
                        .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 40)
                }
            }
        }
    }
}
