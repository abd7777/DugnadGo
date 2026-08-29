import SwiftUI

enum NorwegianFlagColors {
    static let red = Color(red: 186 / 255, green: 12 / 255, blue: 47 / 255)
    static let blue = Color(red: 0 / 255, green: 32 / 255, blue: 91 / 255)
    static let white = Color.white
    static let waveDuration: TimeInterval = 28.0

    static func waveGradient(phase: CGFloat) -> LinearGradient {
        let stops: [Gradient.Stop] = [
            .init(color: red, location: 0.00),
            .init(color: red, location: 0.14),
            .init(color: white, location: 0.14),
            .init(color: white, location: 0.16),
            .init(color: blue, location: 0.16),
            .init(color: blue, location: 0.19),
            .init(color: white, location: 0.19),
            .init(color: white, location: 0.21),
            .init(color: red, location: 0.21),
            .init(color: red, location: 0.35),
            .init(color: white, location: 0.35),
            .init(color: white, location: 0.37),
            .init(color: blue, location: 0.37),
            .init(color: blue, location: 0.40),
            .init(color: white, location: 0.40),
            .init(color: white, location: 0.42),
            .init(color: red, location: 0.42),
            .init(color: red, location: 0.56),
            .init(color: white, location: 0.56),
            .init(color: white, location: 0.58),
            .init(color: blue, location: 0.58),
            .init(color: blue, location: 0.61),
            .init(color: white, location: 0.61),
            .init(color: white, location: 0.63),
            .init(color: red, location: 0.63),
            .init(color: red, location: 1.00),
        ]

        let offset = phase.truncatingRemainder(dividingBy: 1.0)
        return LinearGradient(
            stops: stops,
            startPoint: UnitPoint(x: -0.5 + offset, y: 0.5),
            endPoint: UnitPoint(x: 0.5 + offset, y: 0.5)
        )
    }
}

struct NorwegianFlagWaveTimeline<Content: View>: View {
    @ViewBuilder var content: (CGFloat) -> Content

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
            let phase = CGFloat(
                timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: NorwegianFlagColors.waveDuration)
                    / NorwegianFlagColors.waveDuration
            )
            content(phase)
        }
    }
}

struct NorwegianFlagWaveText: View {
    let text: String
    let font: Font

    var body: some View {
        NorwegianFlagWaveTimeline { phase in
            Text(text)
                .font(font)
                .foregroundStyle(NorwegianFlagColors.waveGradient(phase: phase))
                .shadow(color: .black.opacity(0.7), radius: 0.5, x: 0, y: 0)
                .shadow(color: .black.opacity(0.45), radius: 2, x: 0, y: 1)
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
        }
    }
}

struct NorwegianFlagHeartIcon: View {
    var size: CGFloat = 52

    var body: some View {
        NorwegianFlagWaveTimeline { phase in
            Image(systemName: "heart.fill")
                .font(.system(size: size * 0.52, weight: .semibold))
                .foregroundStyle(NorwegianFlagColors.waveGradient(phase: phase))
                .shadow(color: .black.opacity(0.55), radius: 1, x: 0, y: 0)
                .shadow(color: .black.opacity(0.4), radius: 2, x: 0, y: 1)
        }
        .accessibilityHidden(true)
    }
}
