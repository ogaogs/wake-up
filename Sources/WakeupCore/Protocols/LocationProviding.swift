/// Supplies the most recent known device location to the app coordinator,
/// which feeds it into `EvaluateAlarmUseCase`. The Infra layer implements
/// this on top of CoreLocation.
public protocol LocationProviding: Sendable {
    var currentCoordinate: Coordinate? { get }
}
