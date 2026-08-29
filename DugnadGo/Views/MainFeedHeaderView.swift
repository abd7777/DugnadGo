import SwiftUI

struct MainFeedHeaderView: View {
    private let subtitleYellow = Color(red: 1.0, green: 215 / 255, blue: 0.0)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                NorwegianFlagWaveText(
                    text: "Dugnad Go",
                    font: .system(size: 34, weight: .bold)
                )

                NorwegianFlagHeartIcon()
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Frivillighet i Norge")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(subtitleYellow)
                    .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)

                HStack(alignment: .center, spacing: 8) {
                    Text("Sammen skaper vi lys i hverdagen.")
                        .font(.subheadline.weight(.medium))
                        .italic()
                        .foregroundStyle(subtitleYellow)
                        .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)

                    Text("🤝")
                        .font(.system(size: 60))
                        .shadow(color: subtitleYellow.opacity(0.9), radius: 10)
                        .shadow(color: subtitleYellow.opacity(0.6), radius: 20)
                        .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 2)
                        .accessibilityHidden(true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.clear)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Dugnad Go. Frivillighet i Norge.")
    }
}

#Preview {
    ZStack {
        Image("aurora_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        MainFeedHeaderView()
    }
}
