import SwiftUI
import MapKit
import WakeupCore

/// Real MapKit map centered on the user's confirmed home coordinate.
/// Used on SetHome to show *where* the typed address actually is.
struct HomeMapView: View {
    let coordinate: Coordinate
    var size: CGFloat = 320
    var spanMeters: Double = 800

    @State private var region: MKCoordinateRegion

    init(coordinate: Coordinate, size: CGFloat = 320, spanMeters: Double = 800) {
        self.coordinate = coordinate
        self.size = size
        self.spanMeters = spanMeters
        _region = State(initialValue: Self.region(for: coordinate, meters: spanMeters))
    }

    var body: some View {
        Map(coordinateRegion: $region,
            interactionModes: [],
            annotationItems: [HomePin(coordinate: coordinate)]) { pin in
            MapMarker(coordinate: pin.clLocation, tint: Theme.coralDeep)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .onChange(of: coordinate) { new in
            withAnimation(.easeInOut(duration: 0.4)) {
                region = Self.region(for: new, meters: spanMeters)
            }
        }
    }

    private static func region(for c: Coordinate, meters: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: c.latitude, longitude: c.longitude),
            latitudinalMeters: meters, longitudinalMeters: meters)
    }
}

private struct HomePin: Identifiable {
    let coordinate: Coordinate
    var id: String { "\(coordinate.latitude),\(coordinate.longitude)" }
    var clLocation: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude,
                               longitude: coordinate.longitude)
    }
}
