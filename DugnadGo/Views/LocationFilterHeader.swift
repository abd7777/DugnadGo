import SwiftUI

struct LocationFilterHeader: View {
    let cities: [String]
    let selectedCity: String?
    let isUsingGPS: Bool
    let gpsStatusMessage: String?
    let isScanningGPS: Bool
    let onGPSTap: () -> Void
    let onCityTap: (String) -> Void
    let onClearFilter: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Filtrer etter sted")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.92))
                Spacer()
                if selectedCity != nil || isUsingGPS {
                    Button("Vis alle", action: onClearFilter)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color(red: 1.0, green: 215 / 255, blue: 0.0))
                }
            }

            Button(action: onGPSTap) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        if isScanningGPS {
                            ProgressView()
                                .controlSize(.small)
                                .tint(isUsingGPS ? .white : .white)
                        } else {
                            Text("📍")
                        }
                        Text(isScanningGPS ? "Skanner GPS…" : "My Location (GPS)")
                            .font(.subheadline.weight(.semibold))
                    }

                    if let gpsStatusMessage, isUsingGPS, !isScanningGPS {
                        Text(gpsStatusMessage)
                            .font(.caption)
                            .foregroundStyle(isUsingGPS ? Color.white.opacity(0.88) : Color.white.opacity(0.75))
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isUsingGPS ? Color.accentColor.opacity(0.85) : Color.white.opacity(0.12))
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(isUsingGPS ? 0.15 : 0.28), lineWidth: 1)
                )
            }
            .buttonStyle(.plain)
            .disabled(isScanningGPS)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(cities, id: \.self) { city in
                        Button {
                            onCityTap(city)
                        } label: {
                            Text(city)
                                .font(.subheadline.weight(.medium))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(isCitySelected(city) ? Color.accentColor.opacity(0.9) : Color.white.opacity(0.14))
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                                .overlay(
                                    Capsule()
                                        .stroke(Color.white.opacity(isCitySelected(city) ? 0.2 : 0.28), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .glassPanel(cornerRadius: 18)
        .padding(.horizontal, 16)
        .padding(.top, 4)
    }

    private func isCitySelected(_ city: String) -> Bool {
        !isUsingGPS && selectedCity == city
    }
}

#Preview {
    ZStack {
        Image("aurora_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        LocationFilterHeader(
            cities: DugnadRepository.filterCities,
            selectedCity: nil,
            isUsingGPS: true,
            gpsStatusMessage: "Meløy, Nordland · 66.8219°N, 13.3489°E",
            isScanningGPS: false,
            onGPSTap: {},
            onCityTap: { _ in },
            onClearFilter: {}
        )
    }
}
