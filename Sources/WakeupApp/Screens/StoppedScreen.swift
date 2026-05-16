import SwiftUI

struct StoppedScreen: View {
    @ObservedObject var vm: WakeupViewModel

    var body: some View {
        let t = vm.wakeTime12h
        let walked = Int(max(vm.distance, vm.geofenceMeters).rounded())
        ZStack {
            Theme.sunriseSoft.ignoresSafeArea()

            // rising sun behind
            Circle()
                .fill(RadialGradient(
                    colors: [Color(hex: 0xFFD78A), Color(hex: 0xF26B3A), .clear],
                    center: .center, startRadius: 0, endRadius: 230))
                .frame(width: 460, height: 460)
                .shadow(color: Color(hex: 0xF4A547, alpha: 0.6), radius: 120)
                .frame(maxHeight: .infinity, alignment: .bottom)
                .offset(y: 200)
                .appearUp(distance: 40, duration: 1.5)
                .allowsHitTesting(false)

            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Theme.stopped)
                    Text("You're up")
                        .font(Theme.mono(10.5, .medium)).tracking(1.5)
                        .textCase(.uppercase).foregroundColor(Theme.stopped)
                }
                .padding(.horizontal, 24).padding(.top, 60)
                .appearUp(duration: 0.6)

                VStack(alignment: .leading, spacing: 20) {
                    Text("Good\nmorning.")
                        .font(Theme.display(52, .bold)).tracking(-1)
                        .foregroundColor(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                    (Text("You left the zone at ")
                     + Text("\(t.h):\(t.m)")
                        .font(Theme.display(19, .bold)).foregroundColor(Theme.ink)
                     + Text(". See you tomorrow."))
                        .font(Theme.ui(18))
                        .foregroundColor(Theme.ink2)
                        .lineSpacing(3)
                        .frame(maxWidth: 280, alignment: .leading)
                }
                .padding(.horizontal, 28).padding(.top, 32)
                .appearUp(delay: 0.1, duration: 0.7)

                HStack(spacing: 0) {
                    stat(value: "\(walked)", unit: "m", label: "Walked")
                    divider
                    stat(value: "\(t.h):\(t.m)", unit: t.ampm, label: "Awake at")
                    divider
                    stat(value: "7", unit: "days", label: "Streak")
                }
                .padding(.horizontal, 20).padding(.vertical, 18)
                .background(.ultraThinMaterial)
                .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.6), lineWidth: 0.5))
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                .padding(.horizontal, 24).padding(.top, 24)
                .appearUp(delay: 0.25, duration: 0.7)

                Spacer(minLength: 0)

                BigButton(title: "Start my day", variant: .primary,
                          action: vm.finishMorning)
                    .padding(.horizontal, 24).padding(.top, 32).padding(.bottom, 40)
            }
        }
    }

    private var divider: some View {
        Rectangle().fill(Theme.hairline).frame(width: 0.5, height: 36)
    }

    private func stat(value: String, unit: String, label: String) -> some View {
        VStack(spacing: 4) {
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value).font(Theme.display(22, .semibold)).monospacedDigit()
                    .foregroundColor(Theme.ink)
                Text(unit).font(Theme.mono(10)).tracking(0.5)
                    .foregroundColor(Theme.ink3)
            }
            Text(label).font(Theme.mono(9.5)).tracking(1.2)
                .textCase(.uppercase).foregroundColor(Theme.ink3)
        }
        .frame(maxWidth: .infinity)
    }
}
