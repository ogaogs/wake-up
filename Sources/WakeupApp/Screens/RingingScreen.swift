import SwiftUI

struct RingingScreen: View {
    @ObservedObject var vm: WakeupViewModel

    private let ticker = Timer.publish(every: 0.24, on: .main, in: .common)
        .autoconnect()

    var body: some View {
        let t = vm.wakeTime12h
        let remaining = vm.remainingToGeofence
        ZStack {
            Theme.dawn.ignoresSafeArea()

            RadialPing(color: Color(hex: 0xFFEFDD, alpha: 0.35),
                       lineWidth: 1.5, baseSize: 200, duration: 2.6)
                .frame(height: 0)
                .frame(maxHeight: .infinity, alignment: .top)
                .offset(y: 120)
                .allowsHitTesting(false)

            VStack(spacing: 0) {
                HStack {
                    HStack(spacing: 8) {
                        Circle().fill(Color(hex: 0xFFEFDD))
                            .frame(width: 8, height: 8)
                            .shadow(color: Color(hex: 0xFFEFDD), radius: 5)
                            .breathe(duration: 0.8, scale: 1.25)
                        Text("Ringing · \(t.h):\(t.m) \(t.ampm)")
                            .font(Theme.mono(11, .medium)).tracking(1.5)
                            .textCase(.uppercase).foregroundColor(.white)
                    }
                    .padding(.horizontal, 12).padding(.vertical, 6)
                    .background(Color(hex: 0xFFEFDD, alpha: 0.18))
                    .clipShape(Capsule())
                    Spacer()
                }
                .padding(.horizontal, 24).padding(.top, 54)

                ZStack {
                    Circle()
                        .fill(RadialGradient(
                            colors: [Color(hex: 0xFFEFDD), Color(hex: 0xFFD78A),
                                     Color(hex: 0xF4A547)],
                            center: .center, startRadius: 0, endRadius: 60))
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: 0xFFEFDD, alpha: 0.6), radius: 30)
                        .shadow(color: Color(hex: 0xF4A547, alpha: 0.4), radius: 60)
                        .ringPulse(duration: 0.7)
                    Image(systemName: "bell.fill")
                        .font(.system(size: 50))
                        .foregroundColor(Theme.terracotta)
                        .ringShake()
                }
                .padding(.top, 36)

                VStack(spacing: 6) {
                    Text(remaining > 0 ? "Distance from home" : "You're outside the zone")
                        .font(Theme.mono(11, .medium)).tracking(2)
                        .textCase(.uppercase)
                        .foregroundColor(Color(hex: 0xFFEFDD, alpha: 0.7))
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(Int(vm.distance.rounded()))")
                            .font(Theme.display(72, .bold)).monospacedDigit()
                            .tracking(-1.5)
                            .foregroundColor(Color(hex: 0xFFEFDD))
                            .shadow(color: .black.opacity(0.3), radius: 15)
                        Text("m").font(Theme.mono(24))
                            .foregroundColor(Color(hex: 0xFFEFDD, alpha: 0.6))
                    }
                    Group {
                        if remaining > 0 {
                            Text("Walk ")
                            + Text("\(Int(remaining.rounded())) m")
                                .font(Theme.display(19, .semibold)).foregroundColor(.white)
                            + Text(" more to silence it.")
                        } else {
                            Text("Great. Have a beautiful morning.")
                        }
                    }
                    .font(Theme.ui(16, .medium))
                    .foregroundColor(Color(hex: 0xFFEFDD))
                    .multilineTextAlignment(.center)
                }
                .padding(.top, 32)

                // progress bar
                VStack(spacing: 8) {
                    GeometryReader { g in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(hex: 0xFFEFDD, alpha: 0.18))
                            Capsule()
                                .fill(LinearGradient(
                                    colors: [Color(hex: 0xFFEFDD), .white],
                                    startPoint: .leading, endPoint: .trailing))
                                .frame(width: g.size.width * vm.geofenceProgress)
                                .shadow(color: Color(hex: 0xFFEFDD, alpha: 0.6), radius: 6)
                                .animation(.easeInOut(duration: 0.3),
                                           value: vm.geofenceProgress)
                        }
                    }
                    .frame(height: 8)
                    HStack {
                        Text("Home"); Spacer(); Text("300 m")
                    }
                    .font(Theme.mono(10, .regular)).tracking(1.2)
                    .textCase(.uppercase)
                    .foregroundColor(Color(hex: 0xFFEFDD, alpha: 0.6))
                }
                .padding(.horizontal, 30).padding(.top, 24)

                Spacer(minLength: 0)

                WakeupMapView(size: 220, userDistM: vm.distance, userAngle: -50,
                              variant: .dawn, animateUser: true)
                    .overlay(Circle().strokeBorder(Color(hex: 0xFFEFDD, alpha: 0.2),
                                                   lineWidth: 1))
                    .padding(4)
                    .overlay(Circle().strokeBorder(Color(hex: 0xFFEFDD, alpha: 0.15),
                                                   lineWidth: 4))
                    .shadow(color: .black.opacity(0.3), radius: 40, y: 12)
                    .padding(.top, 12)

                Spacer(minLength: 0)

                HStack(spacing: 8) {
                    Image(systemName: "lock.fill").font(.system(size: 11))
                    Text("Cannot be dismissed")
                        .font(Theme.mono(11, .medium)).tracking(1.5)
                        .textCase(.uppercase)
                }
                .foregroundColor(Color(hex: 0xFFEFDD, alpha: 0.5))
                .padding(.top, 20).padding(.bottom, 40)
            }
        }
        .onReceive(ticker) { _ in
            guard vm.screen == .ringing, vm.distance < vm.geofenceMeters else { return }
            vm.updateDistance(vm.distance + 4)
        }
    }
}
