import SwiftUI

struct RootView: View {
    @StateObject private var vm = WakeupViewModel()
    @State private var showJumpBar = true

    var body: some View {
        ZStack(alignment: .bottom) {
            screenBody
                .id(vm.screen)
                .transition(.opacity)
                .animation(.easeInOut(duration: 0.35), value: vm.screen)

            if showJumpBar {
                PrototypeJumpBar(vm: vm, hide: { showJumpBar = false })
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            } else {
                Button {
                    withAnimation { showJumpBar = true }
                } label: {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(Theme.ink2)
                        .padding(10)
                        .background(.ultraThinMaterial, in: Circle())
                }
                .padding(.trailing, 18).padding(.bottom, 14)
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .preferredColorScheme(.light)
    }

    @ViewBuilder private var screenBody: some View {
        switch vm.screen {
        case .onboard:
            OnboardingScreen(onComplete: vm.completeOnboarding)
        case .setHome:
            SetHomeScreen(vm: vm, onContinue: vm.confirmHome, onBack: vm.goOnboarding)
        case .setTime:
            SetTimeScreen(vm: vm, onContinue: vm.confirmTime, onBack: vm.editHome)
        case .idle:
            IdleScreen(vm: vm)
        case .armed:
            ArmedScreen(vm: vm)
        case .ringing:
            RingingScreen(vm: vm)
        case .stopped:
            StoppedScreen(vm: vm)
        case .settings:
            SettingsScreen(vm: vm, onBack: vm.closeSettings)
        }
    }
}

/// Prototype-only chrome: teleport between the eight screens and scrub the
/// ringing distance, since you can't wait eight hours for the real alarm.
private struct PrototypeJumpBar: View {
    @ObservedObject var vm: WakeupViewModel
    var hide: () -> Void

    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                WakeupMark(size: 14, color: Theme.ink)
                Text("Wakeup · Prototype")
                    .font(Theme.mono(10, .medium)).tracking(1.2)
                    .textCase(.uppercase).foregroundColor(Theme.ink3)
                Spacer()
                Button(action: hide) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Theme.ink3)
                }
            }

            FlowChips(screens: Screen.allCases, current: vm.screen) { target in
                withAnimation { vm.jump(to: target) }
            }

            if vm.screen == .ringing {
                HStack(spacing: 10) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 13)).foregroundColor(Theme.coralDeep)
                    Text("Walking… \(Int(vm.distance.rounded()))m / 300m")
                        .font(Theme.mono(11)).tracking(0.5)
                        .foregroundColor(Theme.coralDeep)
                    Slider(
                        value: Binding(
                            get: { vm.distance },
                            set: { vm.updateDistance($0) }),
                        in: 0...vm.geofenceMeters)
                        .tint(Theme.coral)
                }
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Theme.coral.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(12)
        .background(.ultraThinMaterial)
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous)
            .strokeBorder(Theme.ink.opacity(0.12), lineWidth: 0.5))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color(hex: 0x2B1810, alpha: 0.12), radius: 16, y: 4)
        .padding(.horizontal, 16).padding(.bottom, 16)
    }
}

private struct FlowChips: View {
    var screens: [Screen]
    var current: Screen
    var onTap: (Screen) -> Void

    private let cols = [GridItem(.adaptive(minimum: 78), spacing: 6)]

    var body: some View {
        LazyVGrid(columns: cols, spacing: 6) {
            ForEach(screens) { s in
                Button { onTap(s) } label: {
                    Text(s.jumpLabel)
                        .font(Theme.ui(13, .medium)).tracking(-0.1)
                        .foregroundColor(current == s ? Theme.peach50 : Theme.ink2)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8).padding(.horizontal, 12)
                        .background(current == s ? Theme.ink : .clear)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
                .buttonStyle(TappableStyle())
            }
        }
    }
}
