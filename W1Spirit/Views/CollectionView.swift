import SwiftUI

struct CollectionView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var badgeColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 16), count: isPadLayout ? 5 : 3)
    }
    private var lowerColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 18), count: isPadLayout ? 2 : 1)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                SpiritPage(maxWidth: 1160) {
                    VStack(spacing: 18) {
                        SpiritHeader(title: "My Collection", subtitle: "Your moments in nature.", trailingIcon: "slider.horizontal.3")

                        VStack(alignment: .leading, spacing: 14) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Spirit Badges")
                                        .font(.title.weight(.black))
                                        .foregroundStyle(SpiritColor.white)
                                    Text("\(store.completedTrails) / 30 trails completed")
                                        .font(.headline)
                                        .foregroundStyle(SpiritColor.muted)
                                }
                                Spacer()
                                Image(systemName: "star.fill")
                                    .font(.largeTitle)
                                    .foregroundStyle(SpiritColor.orange)
                                    .shadow(color: SpiritColor.orange, radius: 12)
                            }

                            LazyVGrid(columns: badgeColumns, spacing: 16) {
                                ForEach(store.badges) { badge in
                                    BadgeHexagon(badge: badge, progress: store.badgeProgress(for: badge))
                                }
                            }
                        }
                        .spiritCard(tint: SpiritColor.pink, glow: 0.34)

                        LazyVGrid(columns: lowerColumns, spacing: 18) {
                            WeeklyQuestCard()
                            SpiritMapCard(mapHeight: isPadLayout ? 285 : 220)
                        }
                    }
                    .padding(18)
                    .padding(.bottom, isPadLayout ? 26 : 90)
                }
            }
            .background(SpiritBackground().ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
    }
}

private struct WeeklyQuestCard: View {
    @EnvironmentObject private var store: SpiritStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Spirit Quest", subtitle: "Weekly reward track")
            Text(store.quest.title)
                .font(.title3.weight(.black))
                .foregroundStyle(SpiritColor.white)
            ProgressView(value: min(1, Double(store.completedTrails % (store.quest.target + 1)) / Double(store.quest.target)))
                .tint(SpiritColor.lime)
            HStack {
                Label(store.quest.reward, systemImage: "gift.fill")
                Spacer()
                Text("\(min(store.quest.target, store.completedTrails % (store.quest.target + 1))) / \(store.quest.target)")
            }
            .font(.subheadline.weight(.bold))
            .foregroundStyle(SpiritColor.lime)
        }
        .spiritCard(tint: SpiritColor.lime)
    }
}

private struct SpiritMapCard: View {
    @EnvironmentObject private var store: SpiritStore
    var mapHeight: CGFloat = 220

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Spirit Map", subtitle: "No GPS. Just your Canadian progress.")
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(SpiritColor.ink.opacity(0.50))
                CanadaMapShape()
                    .stroke(SpiritColor.cyan.opacity(0.75), style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                    .shadow(color: SpiritColor.cyan.opacity(0.5), radius: 10)
                    .padding(20)
                ProvincePins()
            }
            .frame(height: mapHeight)

            VStack(spacing: 10) {
                ForEach(store.provinces) { province in
                    HStack {
                        Image(systemName: province.symbol)
                            .foregroundStyle(store.isUnlocked(province) ? SpiritColor.cyan : SpiritColor.muted)
                            .frame(width: 26)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(province.name)
                                .font(.headline)
                                .foregroundStyle(SpiritColor.white)
                            Text(province.stories.joined(separator: " + "))
                                .font(.caption)
                                .foregroundStyle(SpiritColor.muted)
                                .lineLimit(1)
                        }
                        Spacer()
                        Text(store.isUnlocked(province) ? "Open" : "\(province.unlockAt) trails")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(store.isUnlocked(province) ? SpiritColor.lime : SpiritColor.muted)
                    }
                }
            }
        }
        .spiritCard(tint: SpiritColor.cyan)
    }
}

private struct CanadaMapShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.08, y: rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.width * 0.18, y: rect.height * 0.42))
        path.addLine(to: CGPoint(x: rect.width * 0.30, y: rect.height * 0.48))
        path.addLine(to: CGPoint(x: rect.width * 0.40, y: rect.height * 0.30))
        path.addLine(to: CGPoint(x: rect.width * 0.54, y: rect.height * 0.38))
        path.addLine(to: CGPoint(x: rect.width * 0.64, y: rect.height * 0.22))
        path.addLine(to: CGPoint(x: rect.width * 0.78, y: rect.height * 0.40))
        path.addLine(to: CGPoint(x: rect.width * 0.94, y: rect.height * 0.45))
        path.addLine(to: CGPoint(x: rect.width * 0.82, y: rect.height * 0.58))
        path.addLine(to: CGPoint(x: rect.width * 0.70, y: rect.height * 0.54))
        path.addLine(to: CGPoint(x: rect.width * 0.58, y: rect.height * 0.68))
        path.addLine(to: CGPoint(x: rect.width * 0.40, y: rect.height * 0.62))
        path.addLine(to: CGPoint(x: rect.width * 0.28, y: rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.width * 0.12, y: rect.height * 0.70))
        path.closeSubpath()
        return path
    }
}

private struct ProvincePins: View {
    private let pins: [(CGFloat, CGFloat, Color)] = [
        (0.27, 0.59, SpiritColor.pink),
        (0.37, 0.48, SpiritColor.cyan),
        (0.29, 0.34, SpiritColor.lime),
        (0.18, 0.60, SpiritColor.orange),
        (0.84, 0.48, SpiritColor.pink)
    ]

    var body: some View {
        GeometryReader { proxy in
            ForEach(pins.indices, id: \.self) { index in
                Circle()
                    .fill(pins[index].2)
                    .frame(width: 10, height: 10)
                    .shadow(color: pins[index].2, radius: 10)
                    .position(x: proxy.size.width * pins[index].0, y: proxy.size.height * pins[index].1)
            }
        }
    }
}
