import SwiftUI

struct SetHomeScreen: View {
    @ObservedObject var vm: WakeupViewModel
    var onContinue: () -> Void
    var onBack: () -> Void

    @State private var query: String = ""
    @State private var confirmed: Bool = true
    @FocusState private var focused: Bool

    private let suggestions: [(addr: String, sub: String)] = [
        ("東京都渋谷区渋谷2丁目21番1号", "マンション · 渋谷区, 東京"),
        ("東京都渋谷区渋谷2丁目", "渋谷区, 東京"),
        ("東京都新宿区新宿3丁目", "新宿区, 東京"),
    ]

    private var showSuggestions: Bool {
        focused && !query.isEmpty && !confirmed
    }

    private var applyEnabled: Bool {
        !query.isEmpty && query != vm.homeAddress
    }

    var body: some View {
        ZStack {
            Theme.bgCream.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 12) {
                    CircleIconButton(systemName: "chevron.left", action: onBack)
                    Text("Step 1 of 2").monoLabel(11, tracking: 1.2)
                }
                .padding(.horizontal, 24).padding(.top, 60).padding(.bottom, 16)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Where is home?")
                        .font(Theme.display(30, .semibold)).tracking(-0.5)
                        .foregroundColor(Theme.ink)
                    Text("We'll draw a 300 m circle around it. You'll need to leave this circle to stop the alarm.")
                        .font(Theme.ui(15)).foregroundColor(Theme.ink2).lineSpacing(2)
                }
                .padding(.horizontal, 24).padding(.bottom, 16)

                // Search bar + dropdown
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 16)).foregroundColor(Theme.ink3)
                        TextField("Search address", text: $query)
                            .font(Theme.ui(16)).foregroundColor(Theme.ink)
                            .focused($focused)
                            .submitLabel(.search)
                            .onSubmit { applyTypedAddress() }
                            .onChange(of: query) { _ in confirmed = false }
                        Button(action: applyTypedAddress) {
                            Image(systemName: confirmed
                                  ? "checkmark.circle.fill"
                                  : "arrow.right.circle.fill")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(applyEnabled
                                                 ? Theme.coralDeep : Theme.ink3)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .disabled(!applyEnabled)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Theme.hairline, lineWidth: 0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color(hex: 0x2B1810, alpha: 0.04), radius: 8, y: 2)

                    if showSuggestions {
                        VStack(spacing: 0) {
                            ForEach(Array(suggestions.enumerated()), id: \.offset) { i, s in
                                Button {
                                    select(s.addr)
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "mappin")
                                            .font(.system(size: 16))
                                            .foregroundColor(Theme.ink3)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(s.addr).font(Theme.ui(15))
                                                .foregroundColor(Theme.ink)
                                            Text(s.sub).font(Theme.ui(12))
                                                .foregroundColor(Theme.ink3)
                                        }
                                        Spacer()
                                    }
                                    .padding(.horizontal, 14).padding(.vertical, 12)
                                    .contentShape(Rectangle())
                                }
                                .buttonStyle(TappableStyle())
                                if i < suggestions.count - 1 {
                                    Rectangle().fill(Theme.hairline).frame(height: 0.5)
                                }
                            }
                        }
                        .background(Color.white)
                        .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Theme.hairline, lineWidth: 0.5))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .shadow(color: Color(hex: 0x2B1810, alpha: 0.12), radius: 30, y: 12)
                    }
                }
                .padding(.horizontal, 24).padding(.top, 12)
                .zIndex(10)

                Spacer(minLength: 0)

                VStack(spacing: 18) {
                    HomeMapView(coordinate: vm.homeCoordinate, size: 320)
                        .overlay(Circle().strokeBorder(Theme.hairline, lineWidth: 1))
                        .shadow(color: Color(hex: 0x2B1810, alpha: 0.12), radius: 40, y: 12)
                    HStack(spacing: 8) {
                        Circle().fill(Theme.coralDeep).frame(width: 8, height: 8)
                        Text("300 m geofence")
                            .font(Theme.ui(13.5, .medium)).foregroundColor(Theme.coralDeep)
                    }
                    .padding(.horizontal, 14).padding(.vertical, 8)
                    .background(Theme.coral.opacity(0.10))
                    .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)

                Spacer(minLength: 0)

                BigButton(title: "Confirm home address", variant: .primary,
                          disabled: query.isEmpty) {
                    vm.homeAddress = query
                    confirmed = true
                    focused = false
                    onContinue()
                }
                    .padding(.horizontal, 24)
                    .padding(.top, 24).padding(.bottom, 40)
            }
        }
        .onAppear { query = vm.homeAddress; confirmed = !vm.homeAddress.isEmpty }
    }

    private func select(_ addr: String) {
        query = addr
        confirmed = false
        focused = false
    }

    private func applyTypedAddress() {
        guard !query.isEmpty else { return }
        vm.homeAddress = query
        confirmed = true
        focused = false
    }
}
