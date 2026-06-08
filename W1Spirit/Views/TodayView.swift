import SwiftUI

struct TodayView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    @Binding var selectedTab: SpiritTab

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var featureColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 18), count: isPadLayout ? 2 : 1)
    }
    private var metricColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: isPadLayout ? 4 : 2)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                SpiritPage {
                    VStack(spacing: 18) {
                        SpiritHeader(title: "WN SPRT", subtitle: "Forest Mood Trails", trailingIcon: "leaf.fill")

                        if isPadLayout {
                            HStack(alignment: .top, spacing: 18) {
                                heroPanel
                                spiritPanel
                            }
                        } else {
                            VStack(spacing: 18) {
                                heroPanel
                                spiritPanel
                            }
                        }

                        LazyVGrid(columns: metricColumns, spacing: 12) {
                            MetricTile(title: "Today's Weather Mood", value: "Sunny Reflection", icon: "sun.max.fill", tint: SpiritColor.orange)
                            MetricTile(title: "Spirit Streak", value: "\(store.streak) days", icon: "flame.fill", tint: SpiritColor.pink)
                            MetricTile(title: "Trail Time", value: "\(store.todaysTrail.minutes) min", icon: "clock.fill", tint: SpiritColor.cyan)
                            MetricTile(title: "Mood", value: store.todaysTrail.mood.rawValue, icon: store.todaysTrail.mood.icon, tint: store.todaysTrail.mood.color)
                        }

                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitle(title: "Northern Lights", subtitle: "Today's quote opens a quiet premium moment.")
                            Text(store.todaysQuote)
                                .font(.title3.weight(.bold))
                                .foregroundStyle(SpiritColor.white)
                                .padding(.vertical, 4)
                            NeonButton(title: "Open Aurora Mode", icon: "sparkles", tint: SpiritColor.lime) {
                                selectedTab = .profile
                            }
                        }
                        .spiritCard(tint: SpiritColor.lime)
                    }
                    .padding(18)
                    .padding(.bottom, isPadLayout ? 26 : 90)
                }
            }
            .background(SpiritBackground().ignoresSafeArea())
        }
        .navigationViewStyle(.stack)
    }

    private var heroPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Good Morning, Denys")
                .font(isPadLayout ? .largeTitle.weight(.black) : .title2.weight(.black))
                .foregroundStyle(SpiritColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text("Ready for your forest moment?")
                .font(.headline)
                .foregroundStyle(SpiritColor.muted)
            SpiritAssetImage(name: store.todaysTrail.imageName, fallbackSeed: store.todaysTrail.paletteSeed, height: isPadLayout ? 330 : 215)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var spiritPanel: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Spirit")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(store.todaysTrail.mood.color)
                    Text(store.todaysTrail.mood.rawValue)
                        .font(.system(size: isPadLayout ? 42 : 34, weight: .black, design: .rounded))
                        .foregroundStyle(SpiritColor.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text("Take a slow walk and reconnect with nature.")
                        .font(.subheadline)
                        .foregroundStyle(SpiritColor.muted)
                    Text(store.todaysTrail.place)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(SpiritColor.cyan)
                        .padding(.top, 4)
                }
                Spacer()
                Image(systemName: "star.fill")
                    .font(.title2)
                    .foregroundStyle(SpiritColor.orange)
                    .shadow(color: SpiritColor.orange, radius: 10)
            }
            NeonButton(title: "Start Today's Trail", icon: "arrow.right", tint: SpiritColor.cyan) {
                selectedTab = .trails
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .spiritCard(tint: store.todaysTrail.mood.color, glow: 0.33)
    }
}
