import SwiftUI

enum AppLayout {
    static let contentMaxWidth: CGFloat = 720
}

struct ResponsiveContainer<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: AppLayout.contentMaxWidth)
            .frame(maxWidth: .infinity)
    }
}
