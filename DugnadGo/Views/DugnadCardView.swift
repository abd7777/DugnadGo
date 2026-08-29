import SwiftUI

struct DugnadCardView: View {
    let item: DugnadItem

    var body: some View {
        NavigationLink {
            DugnadDetailView(item: item)
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                Text(item.title)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 8) {
                    Label(item.date, systemImage: "calendar")
                    Label(item.location, systemImage: "mappin.and.ellipse")
                    Label(item.workType, systemImage: "hammer.fill")
                }
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.82))

                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(Color(red: 1.0, green: 215 / 255, blue: 0.0))
                    Text(item.foodService)
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.92))
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .glassPanel(cornerRadius: 14)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ZStack {
        Image("aurora_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
        DugnadCardView(item: DugnadRepository.sampleItems[0])
            .padding()
    }
}
