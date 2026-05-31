import SwiftUI

struct OnboardingScreen: View {
    var onComplete: () -> Void
    @State private var step = 0

    private let ctas = ["How it works", "Grant permissions", "Allow & continue"]

    var body: some View {
        ZStack {
            Theme.sunriseSoft.ignoresSafeArea()
            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    Group {
                        switch step {
                        case 0: intro
                        case 1: howItWorks
                        default: permissions
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 60)
                    .id(step)
                    .appearUp(duration: 0.5)
                }

                VStack(spacing: 20) {
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            Capsule()
                                .fill(i == step ? Theme.ink : Theme.ink.opacity(0.2))
                                .frame(width: i == step ? 22 : 6, height: 6)
                                .animation(.easeInOut(duration: 0.3), value: step)
                        }
                    }
                    BigButton(title: ctas[step], variant: .primary) {
                        if step < 2 { step += 1 } else { onComplete() }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
    }

    // MARK: Slides

    private var intro: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Theme.sunriseSoft)
                Circle()
                    .fill(RadialGradient(
                        colors: [Color(hex: 0xFFD78A), Color(hex: 0xF26B3A)],
                        center: .center, startRadius: 0, endRadius: 90))
                    .frame(width: 180, height: 180)
                    .offset(y: 90)
                    .appearUp(distance: 40, duration: 1.2)
            }
            .frame(height: 240)
            .clipped()
            .padding(.vertical, 20)
            .padding(.bottom, 16)

            Text("The alarm\nyou can't\nswitch off.")
                .font(Theme.display(36, .bold))
                .tracking(-0.8)
                .foregroundColor(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)

            Text("Wakeup keeps ringing until you've walked more than 300 meters from home. No snooze. No dismiss. You're up.")
                .font(Theme.ui(17))
                .foregroundColor(Theme.ink2)
                .lineSpacing(4)
                .padding(.top, 20)
        }
    }

    private var howItWorks: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("How it works").monoLabel(11, tracking: 1.5)
            Text("Three steps,\nthen never miss\nanother morning.")
                .font(Theme.display(28, .semibold))
                .tracking(-0.5)
                .foregroundColor(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            VStack(alignment: .leading, spacing: 22) {
                step(n: "1", t: "Pin your home", b: "A 300 m circle around your front door.")
                step(n: "2", t: "Set a wake time", b: "One alarm, repeats daily.")
                step(n: "3", t: "Leave the zone", b: "The only way to stop the alarm.")
            }
            .padding(.top, 36)
        }
    }

    private func step(n: String, t: String, b: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            Text(n)
                .font(Theme.display(22, .semibold))
                .foregroundColor(Theme.peach50)
                .frame(width: 40, height: 40)
                .background(Theme.ink)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 3) {
                Text(t).font(Theme.ui(18, .semibold)).tracking(-0.3)
                    .foregroundColor(Theme.ink)
                Text(b).font(Theme.ui(15)).foregroundColor(Theme.ink2)
            }
            .padding(.top, 4)
        }
    }

    private var permissions: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Permissions").monoLabel(11, tracking: 1.5)
            Text("Two things,\nand we'll never\nask again.")
                .font(Theme.display(28, .semibold))
                .tracking(-0.5)
                .foregroundColor(Theme.ink)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 12)

            VStack(spacing: 12) {
                permCard(icon: "mappin", t: "Always location",
                         b: "So the geofence works when your phone is locked or the app is closed.",
                         badge: "Required")
                permCard(icon: "bell.fill", t: "Notifications",
                         b: "Backup nudge in case the system pauses the audio.",
                         badge: "Recommended")
            }
            .padding(.top, 28)

            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 14)).foregroundColor(Theme.ink2)
                Text("Your location is processed on-device. Wakeup has no server, no account, no cloud.")
                    .font(Theme.ui(12.5)).foregroundColor(Theme.ink2).lineSpacing(3)
            }
            .padding(14)
            .background(Theme.ink.opacity(0.04))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .padding(.top, 18)
        }
    }

    private func permCard(icon: String, t: String, b: String, badge: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20)).foregroundColor(Theme.coral)
                    .frame(width: 36, height: 36)
                    .background(Theme.peach50)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(t).font(Theme.ui(16, .semibold)).foregroundColor(Theme.ink)
                Spacer()
                Text(badge)
                    .font(Theme.mono(9.5, .medium)).tracking(0.8)
                    .textCase(.uppercase)
                    .foregroundColor(Theme.coralDeep)
                    .padding(.horizontal, 8).padding(.vertical, 4)
                    .background(Theme.peach50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            Text(b).font(Theme.ui(14)).foregroundColor(Theme.ink2).lineSpacing(2)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous)
            .strokeBorder(Theme.hairline, lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
