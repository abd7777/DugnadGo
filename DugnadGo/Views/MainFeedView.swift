import SwiftUI

struct MainFeedView: View {
    private let items = DugnadRepository.sampleItems
    private let cities = DugnadRepository.filterCities

    @StateObject private var locationManager = LocationManager()
    @State private var selectedCity: String?
    @State private var isUsingGPS = false

    private var isScanningGPS: Bool {
        if case .scanning = locationManager.fetchState { return true }
        return false
    }

    private var gpsStatusMessage: String? {
        locationManager.fetchState.statusMessage
    }

    private var filteredItems: [DugnadItem] {
        if isUsingGPS, locationManager.userCoordinate != nil {
            return locationManager.filterItems(items)
        }
        guard let selectedCity else { return items }
        return items.filter { $0.city == selectedCity }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Image("aurora_bg")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()

                ResponsiveContainer {
                    List {
                        Section {
                            MainFeedHeaderView()
                                .listRowInsets(EdgeInsets())
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }

                        Section {
                            ActionPromptCardView()
                                .listRowInsets(EdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }

                        Section {
                            LocationFilterHeader(
                                cities: cities,
                                selectedCity: selectedCity,
                                isUsingGPS: isUsingGPS,
                                gpsStatusMessage: gpsStatusMessage,
                                isScanningGPS: isScanningGPS,
                                onGPSTap: activateGPS,
                                onCityTap: selectCity,
                                onClearFilter: clearFilter
                            )
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                        }

                        if isUsingGPS, isScanningGPS {
                            Section {
                                HStack(spacing: 12) {
                                    ProgressView()
                                    Text("Henter posisjon og søker etter dugnader i nærområdet…")
                                        .font(.subheadline)
                                        .foregroundStyle(.white.opacity(0.92))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .glassPanel(cornerRadius: 14)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        }

                        if filteredItems.isEmpty, !isScanningGPS {
                            Section {
                                ContentUnavailableView(
                                    "Ingen dugnader funnet",
                                    systemImage: "mappin.slash",
                                    description: Text(emptyStateMessage)
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 24)
                                .padding(.horizontal, 16)
                                .glassPanel(cornerRadius: 16)
                                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                            }
                        } else if !isScanningGPS {
                            Section {
                                ForEach(filteredItems) { item in
                                    DugnadCardView(item: item)
                                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                            }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var emptyStateMessage: String {
        if isUsingGPS {
            return "Ingen dugnader funnet innenfor søkeradiusen. Prøv et annet sted eller vis alle aktiviteter."
        }
        return "Prøv et annet sted eller vis alle aktiviteter."
    }

    private func activateGPS() {
        isUsingGPS = true
        selectedCity = nil

        Task {
            await locationManager.requestLocation()
        }
    }

    private func selectCity(_ city: String) {
        isUsingGPS = false
        selectedCity = selectedCity == city ? nil : city
        locationManager.reset()
    }

    private func clearFilter() {
        isUsingGPS = false
        selectedCity = nil
        locationManager.reset()
    }
}

#Preview {
    MainFeedView()
}
