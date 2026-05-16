import Foundation
import Testing
@testable import WakeupCore

@Suite("Coordinate distance (Haversine)")
struct DistanceTests {

    // Tokyo Station, used as a stable reference origin.
    let origin = Coordinate(latitude: 35.681236, longitude: 139.767125)

    // Meters per degree of latitude on a sphere of radius 6_371_000 m.
    static let metersPerDegreeLat = (Double.pi / 180.0) * 6_371_000.0

    @Test("distance to itself is zero")
    func zeroForSamePoint() {
        #expect(origin.distance(to: origin) == 0)
    }

    @Test("distance is symmetric")
    func symmetric() {
        let other = Coordinate(latitude: 35.690, longitude: 139.770)
        let ab = origin.distance(to: other)
        let ba = other.distance(to: origin)
        #expect(abs(ab - ba) < 1e-6)
    }

    @Test("0.001 deg of latitude is ~111.19 m")
    func oneMilliDegreeLatitude() {
        let north = Coordinate(latitude: origin.latitude + 0.001,
                               longitude: origin.longitude)
        let expected = 0.001 * Self.metersPerDegreeLat // ~111.19 m
        #expect(abs(origin.distance(to: north) - expected) < 0.5)
    }

    @Test("a point 300 m due north is ~300 m away")
    func threeHundredMetersNorth() {
        let deltaLat = 300.0 / Self.metersPerDegreeLat
        let north = Coordinate(latitude: origin.latitude + deltaLat,
                               longitude: origin.longitude)
        #expect(abs(origin.distance(to: north) - 300.0) < 1.0)
    }

    @Test("a point 300 m due east is ~300 m away")
    func threeHundredMetersEast() {
        let metersPerDegreeLon =
            Self.metersPerDegreeLat * cos(origin.latitude * .pi / 180.0)
        let deltaLon = 300.0 / metersPerDegreeLon
        let east = Coordinate(latitude: origin.latitude,
                              longitude: origin.longitude + deltaLon)
        #expect(abs(origin.distance(to: east) - 300.0) < 1.0)
    }

    @Test("boundary: 299 m is under and 301 m is over the 300 m threshold")
    func boundaryAroundThreshold() {
        let under = Coordinate(
            latitude: origin.latitude + 299.0 / Self.metersPerDegreeLat,
            longitude: origin.longitude)
        let over = Coordinate(
            latitude: origin.latitude + 301.0 / Self.metersPerDegreeLat,
            longitude: origin.longitude)
        #expect(origin.distance(to: under) < 300.0)
        #expect(origin.distance(to: over) > 300.0)
    }
}
