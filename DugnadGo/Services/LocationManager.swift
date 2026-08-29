import CoreLocation
import Foundation

@MainActor
final class LocationManager: NSObject, ObservableObject {
    enum AuthorizationStatus: Equatable {
        case notDetermined
        case authorized
        case denied
        case restricted
    }

    enum FetchState: Equatable {
        case idle
        case scanning
        case located(placeName: String, coordinate: GeoCoordinate)
        case failed(message: String)

        var statusMessage: String? {
            switch self {
            case .idle:
                return nil
            case .scanning:
                return "Skanner GPS…"
            case .located(let placeName, let coordinate):
                return "\(placeName) · \(formattedCoordinate(coordinate))"
            case .failed(let message):
                return message
            }
        }

        private func formattedCoordinate(_ coordinate: GeoCoordinate) -> String {
            String(format: "%.4f°N, %.4f°E", coordinate.latitude, coordinate.longitude)
        }
    }

    /// Rural Nordland test coordinate near Meløy – useful for validating remote-area coverage.
    static let demoRuralNordlandCoordinate = GeoCoordinate(latitude: 66.8219, longitude: 13.3489)

    @Published private(set) var authorizationStatus: AuthorizationStatus = .notDetermined
    @Published private(set) var fetchState: FetchState = .idle
    @Published private(set) var userCoordinate: GeoCoordinate?

    private let coreLocationManager = CLLocationManager()
    private var locationContinuation: CheckedContinuation<GeoCoordinate, Error>?

    /// Set to `true` to simulate a rural Nordland GPS fix instead of calling Core Location hardware.
    var usesSimulatedLocation = true

    override init() {
        super.init()
        coreLocationManager.delegate = self
        coreLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        coreLocationManager.distanceFilter = 50
        updateAuthorizationStatus(coreLocationManager.authorizationStatus)
    }

    func requestLocation() async {
        fetchState = .scanning
        userCoordinate = nil

        do {
            let coordinate: GeoCoordinate
            if usesSimulatedLocation {
                coordinate = try await fetchSimulatedLocation()
            } else {
                coordinate = try await fetchDeviceLocation()
            }

            userCoordinate = coordinate
            let placeName = LocationFilterEngine.placeDescription(for: coordinate)
            fetchState = .located(placeName: placeName, coordinate: coordinate)
        } catch {
            fetchState = .failed(message: error.localizedDescription)
        }
    }

    func filterItems(_ items: [DugnadItem]) -> [DugnadItem] {
        guard let userCoordinate else { return items }
        return LocationFilterEngine.filterItems(items, near: userCoordinate)
    }

    func reset() {
        fetchState = .idle
        userCoordinate = nil
    }

    private func fetchSimulatedLocation() async throws -> GeoCoordinate {
        try await Task.sleep(nanoseconds: 1_600_000_000)
        return Self.demoRuralNordlandCoordinate
    }

    private func fetchDeviceLocation() async throws -> GeoCoordinate {
        switch authorizationStatus {
        case .notDetermined:
            coreLocationManager.requestWhenInUseAuthorization()
            try await Task.sleep(nanoseconds: 400_000_000)
            return try await fetchDeviceLocation()
        case .denied, .restricted:
            throw LocationError.permissionDenied
        case .authorized:
            break
        }

        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            coreLocationManager.requestLocation()
        }
    }

    private func updateAuthorizationStatus(_ status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            authorizationStatus = .authorized
        case .denied:
            authorizationStatus = .denied
        case .restricted:
            authorizationStatus = .restricted
        case .notDetermined:
            authorizationStatus = .notDetermined
        @unknown default:
            authorizationStatus = .notDetermined
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            updateAuthorizationStatus(manager.authorizationStatus)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        Task { @MainActor in
            let coordinate = GeoCoordinate(
                latitude: location.coordinate.latitude,
                longitude: location.coordinate.longitude
            )
            locationContinuation?.resume(returning: coordinate)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(throwing: error)
            locationContinuation = nil
        }
    }
}

enum LocationError: LocalizedError {
    case permissionDenied

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "GPS-tilgang er avslått. Aktiver posisjon i Innstillinger."
        }
    }
}
