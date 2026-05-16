import SwiftUI

struct SetTimeScreen: View {
    @ObservedObject var vm: WakeupViewModel
    var onContinue: () -> Void
    var onBack: () -> Void

    private var h12: Int { ((vm.wakeHour + 11) % 12) + 1 }
    private var ampm: String { vm.wakeHour < 12 ? "AM" : "PM" }

    var body: some View {
        ZStack {
            Theme.bgCream.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    CircleIconButton(systemName: "chevron.left", action: onBack)
                    Text("Step 2 of 2").monoLabel(11, tracking: 1.2)
                }
                .padding(.horizontal, 24).padding(.top, 60).padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("When do you wake?")
                        .font(Theme.display(30, .semibold)).tracking(-0.5)
                        .foregroundColor(Theme.ink)
                    Text("One time. Repeats every day. You can change it later.")
                        .font(Theme.ui(15)).foregroundColor(Theme.ink2)
                }
                .padding(.horizontal, 24).padding(.bottom, 24)

                Spacer(minLength: 0)

                VStack(spacing: 22) {
                    ZStack {
                        // faint sun glow behind
                        Circle()
                            .fill(RadialGradient(
                                colors: [Color(hex: 0xF4A547, alpha: 0.35), .clear],
                                center: .center, startRadius: 0, endRadius: 120))
                            .frame(width: 240, height: 240)
                            .offset(y: 120)

                        VStack(spacing: 18) {
                            HStack(alignment: .center, spacing: 8) {
                                timeColumn(value: String(format: "%02d", h12),
                                           up: { adjustHour(1) }, down: { adjustHour(-1) })
                                Text(":")
                                    .font(Theme.display(60, .medium))
                                    .foregroundColor(Theme.ink)
                                    .offset(y: -6)
                                timeColumn(value: String(format: "%02d", vm.wakeMinute),
                                           up: { adjustMinute(5) }, down: { adjustMinute(-5) })
                                VStack(spacing: 4) {
                                    ampmButton("AM")
                                    ampmButton("PM")
                                }
                                .padding(.leading, 8).padding(.top, 6)
                            }
                            (Text("That's in ")
                             + Text("\(vm.countdown.h)h \(vm.countdown.m)m")
                                .font(Theme.ui(13, .semibold)).foregroundColor(Theme.ink)
                             + Text("."))
                                .font(Theme.ui(13))
                                .foregroundColor(Theme.ink2)
                        }
                        .padding(.vertical, 32).padding(.horizontal, 16)
                    }
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(colors: [Color(hex: 0xFFF8EA), Color(hex: 0xFFE4C8)],
                                       startPoint: .top, endPoint: .bottom))
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Theme.hairline, lineWidth: 0.5))
                    .shadow(color: Color(hex: 0xF26B3A, alpha: 0.12), radius: 40, y: 12)

                    HStack(spacing: 10) {
                        Image(systemName: "figure.walk")
                            .font(.system(size: 15)).foregroundColor(Theme.ink3)
                        Text("You'll need to walk 300 m to silence it.")
                            .font(Theme.ui(13)).foregroundColor(Theme.ink2)
                    }
                }
                .padding(.horizontal, 24)

                Spacer(minLength: 0)

                BigButton(title: "Set wake time", variant: .primary, action: onContinue)
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 40)
            }
        }
    }

    private func timeColumn(value: String, up: @escaping () -> Void,
                            down: @escaping () -> Void) -> some View {
        VStack(spacing: 0) {
            Button(action: up) {
                Image(systemName: "chevron.up").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.ink3).padding(4)
            }.buttonStyle(TappableStyle())
            Text(value)
                .font(Theme.display(88, .medium))
                .monospacedDigit()
                .foregroundColor(Theme.ink)
            Button(action: down) {
                Image(systemName: "chevron.down").font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Theme.ink3).padding(4)
            }.buttonStyle(TappableStyle())
        }
    }

    private func ampmButton(_ p: String) -> some View {
        Button {
            vm.wakeHour = p == "AM" ? vm.wakeHour % 12 : (vm.wakeHour % 12) + 12
        } label: {
            Text(p)
                .font(Theme.mono(13, .medium)).tracking(0.5)
                .foregroundColor(ampm == p ? Theme.peach50 : Theme.ink3)
                .padding(.horizontal, 12).padding(.vertical, 6)
                .background(ampm == p ? Theme.ink : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
        .buttonStyle(TappableStyle())
    }

    private func adjustHour(_ d: Int) {
        vm.wakeHour = (vm.wakeHour + d + 24) % 24
    }
    private func adjustMinute(_ d: Int) {
        vm.wakeMinute = (vm.wakeMinute + d + 60) % 60
    }
}
