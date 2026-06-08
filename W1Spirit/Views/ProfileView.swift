import SwiftUI

struct ProfileView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var topColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 18), count: isPadLayout ? 2 : 1)
    }
    private var metricColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: isPadLayout ? 2 : 2)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                SpiritPage(maxWidth: 1120) {
                    VStack(spacing: 18) {
                        SpiritHeader(title: "Profile", subtitle: "Offline friendly. No sign up.", trailingIcon: "person.crop.circle.fill")

                        LazyVGrid(columns: topColumns, spacing: 18) {
                            NorthernLightsMode(height: isPadLayout ? 460 : 340)

                            VStack(alignment: .leading, spacing: 12) {
                                SectionTitle(title: "WN SPRT", subtitle: "Premium Canadian Nature Experience for iPhone and iPad")
                                LazyVGrid(columns: metricColumns, spacing: 12) {
                                    MetricTile(title: "Trails Completed", value: "\(store.completedTrails)", icon: "checkmark.seal.fill", tint: SpiritColor.lime)
                                    MetricTile(title: "Challenges", value: "\(store.completedChallenges)", icon: "sparkle.magnifyingglass", tint: SpiritColor.orange)
                                }
                                ProfileRow(icon: "person.slash.fill", title: "No Sign Up", detail: "Open the app and start your forest moment.")
                                ProfileRow(icon: "wifi.slash", title: "Offline Friendly", detail: "Sounds, stories, trails, and challenges are local.")
                                ProfileRow(icon: "heart.fill", title: "Simple & Beautiful", detail: "Focus on what actually restores your mood.")
                            }
                            .spiritCard(tint: SpiritColor.pink)
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

private struct NorthernLightsMode: View {
    @EnvironmentObject private var store: SpiritStore
    var height: CGFloat = 340

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            SpiritBackground(aurora: true)
            VStack(alignment: .leading, spacing: 16) {
                Spacer(minLength: 100)
                Text("Northern Lights Mode")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(SpiritColor.cyan)
                Text(store.todaysQuote)
                    .font(.system(size: 29, weight: .black, design: .rounded))
                    .foregroundStyle(SpiritColor.white)
                    .lineSpacing(3)
                    .minimumScaleFactor(0.78)
                NeonButton(title: "Save to Collection", icon: "bookmark.fill", tint: SpiritColor.lime) {
                    store.saveQuote()
                }
            }
            .padding(18)
        }
        .frame(height: height)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.lime.opacity(0.55)))
        .shadow(color: SpiritColor.cyan.opacity(0.28), radius: 24)
    }
}

private struct ProfileRow: View {
    let icon: String
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(SpiritColor.cyan)
                .frame(width: 30, height: 30)
                .background(SpiritColor.ink.opacity(0.6), in: RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(SpiritColor.white)
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(SpiritColor.muted)
            }
            Spacer()
        }
    }
}
