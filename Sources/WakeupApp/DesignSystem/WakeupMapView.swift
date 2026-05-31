import SwiftUI

enum MapVariant { case light, dark, dawn }

private struct MapPalette {
    let bg, road, block, water, park: Color
    let fenceFill, fenceStroke, home, user, pinHole: Color

    static func of(_ v: MapVariant) -> MapPalette {
        switch v {
        case .light:
            return .init(
                bg: Color(hex: 0xF4E5CF), road: .white,
                block: Color(hex: 0xFFF8EA), water: Color(hex: 0xD6E8E0),
                park: Color(hex: 0xC9DDB2),
                fenceFill: Color(hex: 0xF26B3A, alpha: 0.10),
                fenceStroke: Color(hex: 0xF26B3A),
                home: Color(hex: 0xA1351F), user: Color(hex: 0x2B1810),
                pinHole: .white)
        case .dawn:
            return .init(
                bg: Color(hex: 0x2D1F35),
                road: Color(hex: 0xFFDCB4, alpha: 0.18),
                block: Color(hex: 0xFFC896, alpha: 0.06),
                water: Color(hex: 0x50788C, alpha: 0.4),
                park: Color(hex: 0x788C5A, alpha: 0.3),
                fenceFill: Color(hex: 0xF26B3A, alpha: 0.18),
                fenceStroke: Color(hex: 0xFFB985),
                home: Color(hex: 0xFFB985), user: Color(hex: 0xFFEFDD),
                pinHole: Color(hex: 0x1A1226))
        case .dark:
            return .init(
                bg: Color(hex: 0x1A1226),
                road: Color(hex: 0xFFE7C8, alpha: 0.18),
                block: Color(hex: 0xFFE7C8, alpha: 0.04),
                water: Color(hex: 0x3C506E, alpha: 0.5),
                park: Color(hex: 0x647850, alpha: 0.25),
                fenceFill: Color(hex: 0xF4A547, alpha: 0.12),
                fenceStroke: Color(hex: 0xF4A547),
                home: Color(hex: 0xF4A547), user: Color(hex: 0xF5E7D8),
                pinHole: Color(hex: 0x1A1226))
        }
    }
}

/// Stylized "map": fake city grid + dashed 300 m geofence + home pin and an
/// optional moving user dot. Faithful port of `WakeupMap` in wakeup-ui.jsx.
struct WakeupMapView: View {
    var size: CGFloat = 320
    var userDistM: Double = 0
    var userAngle: Double = -60
    var showUser: Bool = true
    var variant: MapVariant = .light
    var geofenceM: Double = 300
    var animateUser: Bool = false

    private let mPerPx: Double = 1.7

    var body: some View {
        let p = MapPalette.of(variant)
        let c = size / 2
        let userR = CGFloat(userDistM / mPerPx)
        let rad = userAngle * .pi / 180
        let ux = c + CGFloat(cos(rad)) * userR
        let uy = c + CGFloat(sin(rad)) * userR

        ZStack {
            Canvas { ctx, sz in
                let s = sz.width
                ctx.fill(Path(CGRect(x: 0, y: 0, width: s, height: s)),
                         with: .color(p.bg))

                // city blocks (6×6, deterministic seed)
                let cell = s / 6
                for r in 0..<6 {
                    for col in 0..<6 {
                        let t = (r * 31 + col * 17) % 7
                        let x = CGFloat(col) * cell, y = CGFloat(r) * cell
                        if t == 0 {
                            ctx.fill(Path(CGRect(x: x, y: y, width: cell, height: cell)),
                                     with: .color(p.water))
                        } else if t == 1 {
                            ctx.fill(Path(CGRect(x: x, y: y, width: cell, height: cell)),
                                     with: .color(p.park))
                        } else {
                            let pad: CGFloat = 3
                            ctx.fill(
                                Path(roundedRect: CGRect(x: x + pad, y: y + pad,
                                                         width: cell - pad * 2,
                                                         height: cell - pad * 2),
                                     cornerRadius: 2),
                                with: .color(p.block))
                        }
                    }
                }

                // roads
                for i in 1...5 {
                    var h = Path()
                    h.move(to: CGPoint(x: 0, y: CGFloat(i) * cell))
                    h.addLine(to: CGPoint(x: s, y: CGFloat(i) * cell))
                    ctx.stroke(h, with: .color(p.road), lineWidth: 6)
                    var v = Path()
                    v.move(to: CGPoint(x: CGFloat(i) * cell, y: 0))
                    v.addLine(to: CGPoint(x: CGFloat(i) * cell, y: s))
                    ctx.stroke(v, with: .color(p.road), lineWidth: 6)
                }
                var diag = Path()
                diag.move(to: CGPoint(x: -20, y: s * 0.7))
                diag.addLine(to: CGPoint(x: s + 20, y: s * 0.15))
                ctx.stroke(diag, with: .color(p.road.opacity(0.7)), lineWidth: 8)

                // geofence circle (dashed)
                let fr = CGFloat(geofenceM / mPerPx) * (s / size)
                let fence = Path(ellipseIn: CGRect(x: s / 2 - fr, y: s / 2 - fr,
                                                   width: fr * 2, height: fr * 2))
                ctx.fill(fence, with: .color(p.fenceFill))
                ctx.stroke(fence, with: .color(p.fenceStroke),
                           style: StrokeStyle(lineWidth: 2, dash: [6, 4]))

                // home pin
                let hp = CGRect(x: s / 2 - 14, y: s / 2 - 14, width: 28, height: 28)
                ctx.fill(Path(ellipseIn: hp), with: .color(p.home))
                ctx.fill(Path(ellipseIn: CGRect(x: s / 2 - 5, y: s / 2 - 5,
                                                width: 10, height: 10)),
                         with: .color(p.pinHole))
            }
            .frame(width: size, height: size)

            // breathing ring around home
            Circle()
                .strokeBorder(p.home.opacity(0.4), lineWidth: 2)
                .frame(width: 28, height: 28)
                .breathe(duration: 3, scale: 1.18)
                .position(x: c, y: c)

            // user dot
            if showUser {
                ZStack {
                    RadialPing(color: p.user.opacity(0.5), lineWidth: 6,
                               baseSize: 22, duration: 1.6)
                    Circle().fill(p.user.opacity(0.25)).frame(width: 22, height: 22)
                    Circle().fill(p.user).frame(width: 14, height: 14)
                    Circle().fill(p.pinHole).frame(width: 6, height: 6)
                }
                .position(x: ux, y: uy)
                .animation(animateUser ? .easeInOut(duration: 0.6) : nil,
                           value: userDistM)
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
