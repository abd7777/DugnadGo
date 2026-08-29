import Foundation

struct DugnadItem: Identifiable, Codable {
    let id: UUID
    let title: String
    let date: String
    let location: String
    let city: String
    let municipality: String
    let region: String
    let latitude: Double
    let longitude: Double
    let workType: String
    let description: String
    let foodService: String

    var coordinate: GeoCoordinate {
        GeoCoordinate(latitude: latitude, longitude: longitude)
    }
}

struct GeoCoordinate: Codable, Equatable {
    let latitude: Double
    let longitude: Double
}

extension DugnadItem {
    func distance(from userCoordinate: GeoCoordinate) -> Double {
        LocationFilterEngine.haversineDistance(
            from: userCoordinate,
            to: coordinate
        )
    }
}
