import SwiftUI

struct SpiritPage<Content: View>: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    var maxWidth: CGFloat = 1180
    @ViewBuilder let content: () -> Content

    var body: some View {
        content()
            .frame(maxWidth: horizontalSizeClass == .regular ? maxWidth : .infinity)
            .frame(maxWidth: .infinity)
    }
}

struct BrandMark: View {
    let size: CGFloat

    var body: some View {
        Image("BrandLogo")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: SpiritColor.pink.opacity(0.42), radius: size * 0.16)
            .accessibilityLabel("WN SPRT mark")
    }
}

struct SpiritHeader: View {
    let title: String
    let subtitle: String
    var trailingIcon: String = "sparkles"

    var body: some View {
        HStack(spacing: 12) {
            BrandMark(size: 50)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title2.weight(.black))
                    .foregroundStyle(SpiritColor.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)
                Text(subtitle)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(SpiritColor.cyan)
            }
            Spacer()
            Image(systemName: trailingIcon)
                .foregroundStyle(SpiritColor.pink)
                .frame(width: 38, height: 38)
                .background(SpiritColor.raised.opacity(0.7), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.pink.opacity(0.45)))
        }
    }
}

struct NeonButton: View {
    let title: String
    let icon: String
    var tint: Color = SpiritColor.cyan
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.headline.weight(.bold))
                Spacer()
                Image(systemName: icon)
                    .font(.headline.weight(.bold))
            }
            .foregroundStyle(tint)
            .padding(.horizontal, 18)
            .padding(.vertical, 15)
            .background(SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint, lineWidth: 1.3))
            .shadow(color: tint.opacity(0.36), radius: 14)
        }
        .buttonStyle(.plain)
    }
}

struct MetricTile: View {
    let title: String
    let value: String
    let icon: String
    var tint: Color = SpiritColor.cyan

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
            Text(value)
                .font(.title3.weight(.black))
                .foregroundStyle(SpiritColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(SpiritColor.muted)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .spiritCard(tint: tint)
    }
}

struct SectionTitle: View {
    let title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.black))
                .foregroundStyle(SpiritColor.white)
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(SpiritColor.muted)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SpiritAssetImage: View {
    let name: String
    var fallbackSeed: Int = 1
    var height: CGFloat = 190

    var body: some View {
        Image(name)
            .resizable()
            .scaledToFill()
            .frame(height: height)
            .frame(maxWidth: .infinity)
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                LinearGradient(
                    colors: [.clear, SpiritColor.ink.opacity(0.24)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            )
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.cyan.opacity(0.30)))
            .shadow(color: SpiritColor.pink.opacity(0.20), radius: 16)
            .accessibilityHidden(true)
    }
}

struct NeonLandscape: View {
    var seed: Int = 1
    var showTent = true

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                LinearGradient(
                    colors: [SpiritColor.deepViolet, SpiritColor.midnightPurple, SpiritColor.ink],
                    startPoint: .top,
                    endPoint: .bottom
                )

                ForEach(0..<6, id: \.self) { index in
                    Circle()
                        .fill(index.isMultiple(of: 2) ? SpiritColor.cyan : SpiritColor.pink)
                        .frame(width: 3, height: 3)
                        .position(
                            x: proxy.size.width * CGFloat([0.16, 0.34, 0.58, 0.75, 0.88, 0.44][index]),
                            y: proxy.size.height * CGFloat([0.16, 0.28, 0.12, 0.22, 0.34, 0.42][index])
                        )
                        .shadow(color: SpiritColor.cyan, radius: 6)
                }

                MountainLayer(seed: seed)
                    .fill(LinearGradient(colors: [SpiritColor.blue.opacity(0.45), SpiritColor.purpleGlow.opacity(0.12)], startPoint: .top, endPoint: .bottom))
                    .overlay(MountainLayer(seed: seed).stroke(SpiritColor.cyan.opacity(0.9), lineWidth: 2))
                    .frame(height: proxy.size.height * 0.52)
                    .offset(y: -proxy.size.height * 0.12)

                ForestLine()
                    .stroke(SpiritColor.pink.opacity(0.9), lineWidth: 2)
                    .shadow(color: SpiritColor.pink, radius: 7)
                    .frame(height: proxy.size.height * 0.45)
                    .offset(y: -proxy.size.height * 0.02)

                PathLine()
                    .stroke(SpiritColor.cyan.opacity(0.8), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(height: proxy.size.height * 0.34)
                    .offset(y: proxy.size.height * 0.02)

                if showTent {
                    TentShape()
                        .fill(SpiritColor.orange.opacity(0.82))
                        .frame(width: 54, height: 42)
                        .overlay(TentShape().stroke(SpiritColor.pink, lineWidth: 2))
                        .shadow(color: SpiritColor.orange.opacity(0.65), radius: 16)
                        .offset(x: proxy.size.width * 0.23, y: -14)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.pink.opacity(0.42)))
    }
}

struct MountainLayer: Shape {
    let seed: Int

    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: rect.maxY))
        let peaks: [CGPoint] = [
            CGPoint(x: rect.width * 0.12, y: rect.height * 0.70),
            CGPoint(x: rect.width * 0.30, y: rect.height * CGFloat(seed % 2 == 0 ? 0.22 : 0.34)),
            CGPoint(x: rect.width * 0.48, y: rect.height * 0.64),
            CGPoint(x: rect.width * 0.64, y: rect.height * 0.18),
            CGPoint(x: rect.width * 0.88, y: rect.height * 0.76),
            CGPoint(x: rect.width, y: rect.maxY)
        ]
        peaks.forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}

struct ForestLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for index in 0..<9 {
            let x = rect.width * CGFloat(index) / 8
            let h = rect.height * CGFloat([0.45, 0.78, 0.58, 0.92, 0.55, 0.82, 0.50, 0.68, 0.44][index])
            path.move(to: CGPoint(x: x, y: rect.maxY))
            path.addLine(to: CGPoint(x: x, y: rect.maxY - h))
            path.move(to: CGPoint(x: x - 12, y: rect.maxY - h * 0.55))
            path.addLine(to: CGPoint(x: x, y: rect.maxY - h))
            path.addLine(to: CGPoint(x: x + 12, y: rect.maxY - h * 0.55))
            path.move(to: CGPoint(x: x - 16, y: rect.maxY - h * 0.30))
            path.addLine(to: CGPoint(x: x, y: rect.maxY - h * 0.58))
            path.addLine(to: CGPoint(x: x + 16, y: rect.maxY - h * 0.30))
        }
        return path
    }
}

struct PathLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.44, y: rect.minY))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.70, y: rect.maxY),
            control1: CGPoint(x: rect.width * 0.36, y: rect.height * 0.35),
            control2: CGPoint(x: rect.width * 0.72, y: rect.height * 0.56)
        )
        return path
    }
}

struct TentShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct BadgeHexagon: View {
    let badge: SpiritBadge
    let progress: Double

    var body: some View {
        let tint = SpiritColor.named(badge.tintName)
        VStack(spacing: 10) {
            ZStack {
                Hexagon()
                    .fill(SpiritColor.raised.opacity(0.58))
                    .overlay(Hexagon().stroke(tint, lineWidth: 2))
                    .shadow(color: tint.opacity(0.38), radius: 12)
                Image(systemName: badge.icon)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(progress >= 1 ? tint : tint.opacity(0.45))
            }
            .frame(width: 64, height: 58)
            Text(badge.title)
                .font(.caption.weight(.bold))
                .foregroundStyle(SpiritColor.white)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(height: 32)
        }
    }
}

struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let points = [
            CGPoint(x: rect.midX, y: rect.minY),
            CGPoint(x: rect.maxX, y: rect.height * 0.25),
            CGPoint(x: rect.maxX, y: rect.height * 0.75),
            CGPoint(x: rect.midX, y: rect.maxY),
            CGPoint(x: rect.minX, y: rect.height * 0.75),
            CGPoint(x: rect.minX, y: rect.height * 0.25)
        ]
        var path = Path()
        path.move(to: points[0])
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }
}
