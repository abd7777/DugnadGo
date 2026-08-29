import SwiftUI

struct ActionPromptCardView: View {
    private let actionOrange = Color(red: 255 / 255, green: 167 / 255, blue: 38 / 255)

    var body: some View {
        Text("Bli med på dugnad eller opprett en annonsering for frivillige")
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(actionOrange)
            .shadow(color: .black.opacity(0.7), radius: 0.5, x: 0, y: 0)
            .shadow(color: .black.opacity(0.5), radius: 2, x: 0, y: 1)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .glassPanel(cornerRadius: 18)
    }
}

#Preview {
    ZStack {
        Image("aurora_bg")
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()

        ActionPromptCardView()
            .padding()
    }
}
