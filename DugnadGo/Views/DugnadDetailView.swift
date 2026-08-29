import SwiftUI

struct DugnadDetailView: View {
    let item: DugnadItem

    @State private var isRegistered = false

    var body: some View {
        ScrollView {
            ResponsiveContainer {
                VStack(alignment: .leading, spacing: 24) {
                Text(item.title)
                    .font(.largeTitle.bold())
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 0) {
                    detailRow(icon: "calendar", iconColor: .blue, title: "Dato og tid", value: item.date)
                    Divider().padding(.leading, 52)
                    detailRow(icon: "mappin.and.ellipse", iconColor: .red, title: "Sted", value: item.location)
                    Divider().padding(.leading, 52)
                    detailRow(icon: "hammer.fill", iconColor: .purple, title: "Arbeidstype", value: item.workType)
                }
                .padding(.vertical, 4)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 10) {
                    Label("Om dugnaden", systemImage: "text.alignleft")
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(item.description)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Label("Servering", systemImage: "fork.knife")
                        .font(.headline)
                        .foregroundStyle(.orange)

                    Text(item.foodService)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color.orange.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.orange.opacity(0.25), lineWidth: 1)
                )

                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isRegistered.toggle()
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isRegistered ? "checkmark.circle.fill" : "person.badge.plus")
                            .font(.title3)
                        Text(isRegistered ? "Påmeldt – Registered" : "Meld deg på")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundStyle(isRegistered ? Color.green : Color.white)
                    .background(isRegistered ? Color.green.opacity(0.15) : Color.accentColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(isRegistered ? Color.green.opacity(0.4) : Color.clear, lineWidth: 1.5)
                    )
                }
                .buttonStyle(.plain)
                .padding(.top, 4)
                }
                .padding()
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func detailRow(icon: String, iconColor: Color, title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28, height: 28)
                .background(iconColor.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 7))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

#Preview {
    NavigationStack {
        DugnadDetailView(item: DugnadRepository.sampleItems[0])
    }
}
