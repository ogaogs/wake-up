import SwiftUI

struct SettingsScreen: View {
    @ObservedObject var vm: WakeupViewModel
    var onBack: () -> Void

    var body: some View {
        let t = vm.wakeTime12h
        ZStack {
            Theme.bgCream.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    CircleIconButton(systemName: "chevron.left", action: onBack)
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 60).padding(.bottom, 8)

                Text("Settings")
                    .font(Theme.display(34, .bold)).tracking(-0.7)
                    .foregroundColor(Theme.ink)
                    .padding(.horizontal, 24).padding(.top, 12).padding(.bottom, 24)

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        cardLabel("Home address")
                        card(tap: vm.editHome) {
                            HStack(alignment: .top, spacing: 14) {
                                WakeupMapView(size: 64, showUser: false, variant: .light)
                                    .clipShape(RoundedRectangle(cornerRadius: 16,
                                                                style: .continuous))
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vm.homeAddress.isEmpty ? "Not set" : vm.homeAddress)
                                        .font(Theme.ui(16, .medium)).tracking(-0.2)
                                        .foregroundColor(Theme.ink)
                                    Text("300 m geofence · 37.7821° N, 122.4185° W")
                                        .font(Theme.ui(13)).foregroundColor(Theme.ink3)
                                }
                                .padding(.top, 4)
                                Spacer()
                                chevron
                            }
                        }

                        cardLabel("Wake time").padding(.top, 14)
                        card(tap: vm.editTime) {
                            HStack(spacing: 14) {
                                SunIcon(size: 28, color: Theme.terracotta)
                                    .frame(width: 64, height: 64)
                                    .background(LinearGradient(
                                        colors: [Color(hex: 0xFFE4C8), Color(hex: 0xFFB985)],
                                        startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .clipShape(RoundedRectangle(cornerRadius: 16,
                                                                style: .continuous))
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack(alignment: .firstTextBaseline, spacing: 6) {
                                        Text("\(t.h):\(t.m)")
                                            .font(Theme.display(26, .semibold))
                                            .tracking(-0.5).monospacedDigit()
                                            .foregroundColor(Theme.ink)
                                        Text(t.ampm).font(Theme.mono(14))
                                            .foregroundColor(Theme.ink3)
                                    }
                                    Text("Repeats every day")
                                        .font(Theme.ui(13)).foregroundColor(Theme.ink3)
                                }
                                Spacer()
                                chevron
                            }
                        }

                        Text("Locked settings")
                            .font(Theme.mono(10, .medium)).tracking(1.4)
                            .textCase(.uppercase).foregroundColor(Theme.ink3)
                            .padding(.horizontal, 6).padding(.top, 24).padding(.bottom, 8)

                        cardLabel("Geofence radius")
                        lockedCard(title: "300 meters", sub: "Fixed in this version")
                        cardLabel("Snooze").padding(.top, 14)
                        lockedCard(title: "Disabled, forever",
                                   sub: "The whole point of the app.")

                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lock.fill")
                                .font(.system(size: 14)).foregroundColor(Theme.ink3)
                            Text("Wakeup runs entirely on your device. No accounts, no servers.")
                                .font(Theme.ui(12.5)).foregroundColor(Theme.ink2)
                                .lineSpacing(3)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Theme.ink.opacity(0.04))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .padding(.top, 24)
                    }
                    .padding(.horizontal, 24).padding(.bottom, 24)
                }
            }
        }
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 14, weight: .semibold)).foregroundColor(Theme.ink3)
    }

    private func cardLabel(_ s: String) -> some View {
        Text(s).font(Theme.mono(10, .medium)).tracking(1.4)
            .textCase(.uppercase).foregroundColor(Theme.ink3)
            .padding(.horizontal, 6).padding(.top, 14).padding(.bottom, 8)
    }

    private func card<C: View>(tap: (() -> Void)? = nil,
                               @ViewBuilder _ content: () -> C) -> some View {
        let inner = content()
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        return Group {
            if let tap {
                Button(action: tap) { inner }.buttonStyle(TappableStyle())
            } else {
                inner
            }
        }
    }

    private func lockedCard(title: String, sub: String) -> some View {
        card {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title).font(Theme.ui(16, .medium)).foregroundColor(Theme.ink)
                    Text(sub).font(Theme.ui(13)).foregroundColor(Theme.ink3)
                }
                Spacer()
                Image(systemName: "lock.fill")
                    .font(.system(size: 18)).foregroundColor(Theme.ink3)
            }
        }
        .opacity(0.72)
    }
}
