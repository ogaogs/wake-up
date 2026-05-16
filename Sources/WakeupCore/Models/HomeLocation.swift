/// The user's registered home: where the geofence is centered.
public struct HomeLocation: Codable, Equatable, Sendable {
    public let coordinate: Coordinate
    /// Human-readable address the user typed, kept for display only.
    public let address: String?

    public init(coordinate: Coordinate, address: String? = nil) {
        self.coordinate = coordinate
        self.address = address
    }
}
