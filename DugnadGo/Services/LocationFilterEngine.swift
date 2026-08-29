import Foundation

enum LocationFilterEngine {
    /// Urban centres use a tighter radius; rural and remote northern areas widen the search
    /// so users in sparsely populated municipalities still see relevant nearby dugnader.
    static func adaptiveSearchRadius(for coordinate: GeoCoordinate) -> Double {
        if isRemoteNorthernNorway(coordinate) { return 280_000 }
        if isRuralNorway(coordinate) { return 160_000 }
        if isSmallMunicipality(coordinate) { return 110_000 }
        return 65_000
    }

    static func filterItems(
        _ items: [DugnadItem],
        near userCoordinate: GeoCoordinate,
        includeRegionalFallback: Bool = true
    ) -> [DugnadItem] {
        let radius = adaptiveSearchRadius(for: userCoordinate)
        let userRegion = region(for: userCoordinate)

        let ranked = items
            .map { item in (item, item.distance(from: userCoordinate)) }
            .sorted { $0.1 < $1.1 }

        var results = ranked.filter { $0.1 <= radius }.map(\.0)

        if includeRegionalFallback {
            let minimumResults = isRemoteNorthernNorway(userCoordinate) ? 2 : 3
            if results.count < minimumResults {
                let existingIDs = Set(results.map(\.id))
                let regional = ranked
                    .filter { $0.0.region == userRegion && !existingIDs.contains($0.0.id) }
                    .prefix(max(minimumResults - results.count, 0))
                    .map(\.0)
                results.append(contentsOf: regional)
            }
        }

        return results
    }

    static func haversineDistance(from: GeoCoordinate, to: GeoCoordinate) -> Double {
        let earthRadius = 6_371_000.0
        let lat1 = from.latitude * .pi / 180
        let lat2 = to.latitude * .pi / 180
        let deltaLat = (to.latitude - from.latitude) * .pi /  180
        let deltaLon = (to.longitude - from.longitude) * .pi / 180

        let a = sin(deltaLat / 2) * sin(deltaLat / 2)
            + cos(lat1) * cos(lat2) * sin(deltaLon / 2) * sin(deltaLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return earthRadius * c
    }

    static func formattedDistance(_ meters: Double) -> String {
        if meters < 1_000 {
            return String(format: "%.0f m", meters)
        }
        if meters < 100_000 {
            return String(format: "%.1f km", meters / 1_000)
        }
        return String(format: "%.0f km", meters / 1_000)
    }

    static func region(for coordinate: GeoCoordinate) -> String {
        NorwegianRegions.closest(to: coordinate)?.name ?? "Norge"
    }

    static func placeDescription(for coordinate: GeoCoordinate) -> String {
        if let place = NorwegianPlaces.closest(to: coordinate) {
            return "\(place.municipality), \(place.region)"
        }
        return region(for: coordinate)
    }

    private static func isRemoteNorthernNorway(_ coordinate: GeoCoordinate) -> Bool {
        coordinate.latitude >= 66.0 && coordinate.longitude >= 10.0
    }

    private static func isRuralNorway(_ coordinate: GeoCoordinate) -> Bool {
        !NorwegianPlaces.isUrbanCentre(coordinate)
    }

    private static func isSmallMunicipality(_ coordinate: GeoCoordinate) -> Bool {
        guard let place = NorwegianPlaces.closest(to: coordinate) else { return true }
        return !place.isMajorCity
    }
}

private enum NorwegianRegions {
    struct Region {
        let name: String
        let latitude: Double
        let longitude: Double
    }

    static let all: [Region] = [
        Region(name: "Oslo", latitude: 59.9139, longitude: 10.7522),
        Region(name: "Viken", latitude: 59.75, longitude: 10.80),
        Region(name: "Innlandet", latitude: 61.15, longitude: 10.40),
        Region(name: "Vestland", latitude: 60.39, longitude: 5.32),
        Region(name: "Rogaland", latitude: 58.97, longitude: 5.73),
        Region(name: "Trøndelag", latitude: 63.43, longitude: 10.40),
        Region(name: "Nordland", latitude: 67.28, longitude: 14.40),
        Region(name: "Troms og Finnmark", latitude: 69.65, longitude: 18.96),
    ]

    static func closest(to coordinate: GeoCoordinate) -> Region? {
        all.min { lhs, rhs in
            LocationFilterEngine.haversineDistance(
                from: coordinate,
                to: GeoCoordinate(latitude: lhs.latitude, longitude: lhs.longitude)
            ) < LocationFilterEngine.haversineDistance(
                from: coordinate,
                to: GeoCoordinate(latitude: rhs.latitude, longitude: rhs.longitude)
            )
        }
    }
}

enum NorwegianPlaces {
    struct Place {
        let municipality: String
        let region: String
        let latitude: Double
        let longitude: Double
        let isMajorCity: Bool
    }

    static let catalog: [Place] = [
        Place(municipality: "Oslo", region: "Oslo", latitude: 59.9139, longitude: 10.7522, isMajorCity: true),
        Place(municipality: "Bergen", region: "Vestland", latitude: 60.3913, longitude: 5.3221, isMajorCity: true),
        Place(municipality: "Trondheim", region: "Trøndelag", latitude: 63.4305, longitude: 10.3951, isMajorCity: true),
        Place(municipality: "Stavanger", region: "Rogaland", latitude: 58.9700, longitude: 5.7331, isMajorCity: true),
        Place(municipality: "Fredrikstad", region: "Viken", latitude: 59.2181, longitude: 10.9298, isMajorCity: true),
        Place(municipality: "Tromsø", region: "Troms og Finnmark", latitude: 69.6492, longitude: 18.9553, isMajorCity: true),
        Place(municipality: "Bodø", region: "Nordland", latitude: 67.2804, longitude: 14.4049, isMajorCity: true),
        Place(municipality: "Meløy", region: "Nordland", latitude: 66.8219, longitude: 13.3489, isMajorCity: false),
        Place(municipality: "Røst", region: "Nordland", latitude: 67.5175, longitude: 12.0946, isMajorCity: false),
        Place(municipality: "Sømna", region: "Nordland", latitude: 65.2589, longitude: 12.0344, isMajorCity: false),
        Place(municipality: "Røros", region: "Trøndelag", latitude: 62.5748, longitude: 11.3844, isMajorCity: false),
        Place(municipality: "Karasjok", region: "Troms og Finnmark", latitude: 69.4719, longitude: 25.5112, isMajorCity: false),
        Place(municipality: "Geilo", region: "Innlandet", latitude: 60.5333, longitude: 8.2167, isMajorCity: false),
        Place(municipality: "Leknes", region: "Nordland", latitude: 68.1475, longitude: 13.6115, isMajorCity: false),
    ]

    static func closest(to coordinate: GeoCoordinate) -> Place? {
        catalog.min { lhs, rhs in
            LocationFilterEngine.haversineDistance(
                from: coordinate,
                to: GeoCoordinate(latitude: lhs.latitude, longitude: lhs.longitude)
            ) < LocationFilterEngine.haversineDistance(
                from: coordinate,
                to: GeoCoordinate(latitude: rhs.latitude, longitude: rhs.longitude)
            )
        }
    }

    static func isUrbanCentre(_ coordinate: GeoCoordinate) -> Bool {
        guard let place = closest(to: coordinate) else { return false }
        let distance = LocationFilterEngine.haversineDistance(
            from: coordinate,
            to: GeoCoordinate(latitude: place.latitude, longitude: place.longitude)
        )
        return place.isMajorCity && distance <= 25_000
    }
}
