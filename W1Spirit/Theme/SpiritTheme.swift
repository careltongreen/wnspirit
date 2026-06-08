import SwiftUI

enum SpiritColor {
    static let deepViolet = Color(red: 0.165, green: 0.020, blue: 0.416)
    static let midnightPurple = Color(red: 0.102, green: 0.008, blue: 0.290)
    static let ink = Color(red: 0.035, green: 0.012, blue: 0.120)
    static let panel = Color(red: 0.085, green: 0.024, blue: 0.250)
    static let raised = Color(red: 0.140, green: 0.038, blue: 0.390)
    static let pink = Color(red: 1.000, green: 0.310, blue: 0.847)
    static let cyan = Color(red: 0.208, green: 0.953, blue: 1.000)
    static let orange = Color(red: 1.000, green: 0.624, blue: 0.110)
    static let lime = Color(red: 0.616, green: 1.000, blue: 0.341)
    static let purpleGlow = Color(red: 0.760, green: 0.210, blue: 1.000)
    static let blue = Color(red: 0.240, green: 0.520, blue: 1.000)
    static let white = Color(red: 0.965, green: 0.965, blue: 1.000)
    static let muted = Color(red: 0.735, green: 0.700, blue: 0.900)

    static func named(_ name: String) -> Color {
        switch name {
        case "pink": pink
        case "cyan": cyan
        case "orange": orange
        case "lime": lime
        case "blue": blue
        default: purpleGlow
        }
    }
}

struct SpiritBackground: View {
    var aurora = true

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [SpiritColor.deepViolet, SpiritColor.midnightPurple, SpiritColor.ink],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if aurora {
                AuroraBands()
                    .opacity(0.72)
                    .ignoresSafeArea()
            }

            StarField()
                .opacity(0.65)
                .ignoresSafeArea()

            LinearGradient(colors: [.clear, .black.opacity(0.28)], startPoint: .center, endPoint: .bottom)
                .ignoresSafeArea()
        }
    }
}

struct AuroraBands: View {
    @State private var drift = false

    var body: some View {
        TimelineView(.animation) { timeline in
            let seconds = timeline.date.timeIntervalSinceReferenceDate
            Canvas { context, size in
                for index in 0..<5 {
                    var path = Path()
                    let yBase = size.height * (0.08 + CGFloat(index) * 0.055)
                    path.move(to: CGPoint(x: -80, y: yBase))
                    for step in 0...8 {
                        let x = CGFloat(step) / 8 * size.width
                        let wave = sin(seconds * 0.45 + Double(step + index) * 0.9) * 34
                        path.addQuadCurve(
                            to: CGPoint(x: x + 90, y: yBase + CGFloat(wave)),
                            control: CGPoint(x: x + 20, y: yBase - 60 + CGFloat(wave * 0.4))
                        )
                    }
                    context.stroke(
                        path,
                        with: .linearGradient(
                            Gradient(colors: [SpiritColor.cyan.opacity(0.04), SpiritColor.pink.opacity(0.35), SpiritColor.lime.opacity(0.15)]),
                            startPoint: CGPoint(x: 0, y: yBase),
                            endPoint: CGPoint(x: size.width, y: yBase + 80)
                        ),
                        style: StrokeStyle(lineWidth: CGFloat(22 + index * 4), lineCap: .round)
                    )
                }
            }
            .blur(radius: 8)
        }
    }
}

struct StarField: View {
    private let points: [CGPoint] = [
        CGPoint(x: 0.12, y: 0.12), CGPoint(x: 0.84, y: 0.10), CGPoint(x: 0.68, y: 0.18),
        CGPoint(x: 0.22, y: 0.28), CGPoint(x: 0.92, y: 0.34), CGPoint(x: 0.44, y: 0.08),
        CGPoint(x: 0.76, y: 0.48), CGPoint(x: 0.10, y: 0.56), CGPoint(x: 0.38, y: 0.42),
        CGPoint(x: 0.58, y: 0.66), CGPoint(x: 0.88, y: 0.70), CGPoint(x: 0.17, y: 0.78)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(points.indices, id: \.self) { index in
                Circle()
                    .fill(index.isMultiple(of: 3) ? SpiritColor.pink : SpiritColor.cyan)
                    .frame(width: index.isMultiple(of: 4) ? 4 : 2, height: index.isMultiple(of: 4) ? 4 : 2)
                    .position(x: points[index].x * proxy.size.width, y: points[index].y * proxy.size.height)
                    .shadow(color: SpiritColor.cyan, radius: 4)
            }
        }
    }
}

struct SpiritCardModifier: ViewModifier {
    var tint: Color = SpiritColor.cyan
    var glow: Double = 0.22

    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(SpiritColor.panel.opacity(0.86))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(tint.opacity(0.58), lineWidth: 1)
                    )
                    .shadow(color: tint.opacity(glow), radius: 16, x: 0, y: 0)
            )
    }
}

extension View {
    func spiritCard(tint: Color = SpiritColor.cyan, glow: Double = 0.22) -> some View {
        modifier(SpiritCardModifier(tint: tint, glow: glow))
    }
}
