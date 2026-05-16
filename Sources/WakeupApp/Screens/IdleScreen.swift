import SwiftUI

struct IdleScreen: View {
    @ObservedObject var vm: WakeupViewModel

    var body: some View {
        let t = vm.wakeTime12h
        ZStack(alignment: .top) {
            Theme.bgCream.ignoresSafeArea()
            // soft sunrise glow at top
            RadialGradient(
                colors: [Color(hex: 0xFFD9B0, alpha: 0.7), .clear],
                center: .top, startRadius: 0, endRadius: 380)
                .frame(height: 380)
                .frame(maxWidth: .infinity, alignment: .top)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    HStack(spacing: 8) {
                        WakeupMark(size: 22, color: Theme.ink)
                        Text("Wakeup").font(Theme.display(16, .bold)).tracking(-0.2)
                            .foregroundColor(Theme.ink)
                    }
                    Spacer()
                    CircleIconButton(systemName: "gearshape.fill",
                                     action: vm.openSettings)
                }
                .padding(.horizontal, 24).padding(.top, 60)

                VStack(alignment: .leading, spacing: 12) {
                    StatePill(text: "Disarmed", color: Theme.ink3)
                    Text("No alarm\nset for tonight.")
                        .font(Theme.display(36, .bold)).tracking(-0.8)
                        .foregroundColor(Theme.ink)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 24).padding(.top, 32)

                VStack(spacing: 12) {
                    infoCard {
                        HStack(spacing: 16) {
                            SunIcon(size: 28, color: Theme.terracotta)
                                .frame(width: 56, height: 56)
                                .background(LinearGradient(
                                    colors: [Color(hex: 0xFFE4C8), Color(hex: 0xFFB985)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing))
                                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Wake at").monoLabel(10, tracking: 1.2)
                                HStack(alignment: .firstTextBaseline, spacing: 0) {
                                    Text("\(t.h):\(t.m)")
                                        .font(Theme.display(30, .semibold)).tracking(-0.5)
                                        .monospacedDigit().foregroundColor(Theme.ink)
                                    Text(t.ampm).font(Theme.mono(14)).foregroundColor(Theme.ink3)
                                        .padding(.leading, 6)
                                }
                            }
                            Spacer()
                        }
                    }
                    infoCard {
                        HStack(spacing: 16) {
                            WakeupMapView(size: 56, showUser: false, variant: .light)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Home").monoLabel(10, tracking: 1.2)
                                Text(vm.homeAddress)
                                    .font(Theme.ui(15, .medium)).tracking(-0.2)
                                    .foregroundColor(Theme.ink)
                                    .lineLimit(1)
                            }
                            Spacer()
                        }
                    }
                }
                .padding(.horizontal, 24).padding(.top, 32)

                Spacer(minLength: 0)

                BigButton(title: "Arm alarm", variant: .coral,
                          systemIcon: "bell.fill", action: vm.arm)
                    .padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 40)
            }
        }
    }

    private func infoCard<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        content()
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .overlay(RoundedRectangle(cornerRadius: 22, style: .continuous)
                .strokeBorder(Theme.hairline, lineWidth: 0.5))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}
