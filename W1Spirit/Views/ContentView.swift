import SwiftUI

enum SpiritTab: Hashable {
    case today
    case trails
    case stories
    case collection
    case profile
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @State private var selectedTab: SpiritTab = .today

    var body: some View {
        ZStack {
            SpiritBackground()
            if horizontalSizeClass == .regular {
                HStack(spacing: 0) {
                    SpiritSidebar(selectedTab: $selectedTab)
                    selectedContent
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.leading, 28)
                        .padding(.trailing, 18)
                        .clipped()
                }
            } else {
                TabView(selection: $selectedTab) {
                    TodayView(selectedTab: $selectedTab)
                        .tabItem { Label("Today", systemImage: "house.fill") }
                        .tag(SpiritTab.today)
                    TrailsView()
                        .tabItem { Label("Trails", systemImage: "mountain.2.fill") }
                        .tag(SpiritTab.trails)
                    StoriesView()
                        .tabItem { Label("Stories", systemImage: "book.closed.fill") }
                        .tag(SpiritTab.stories)
                    CollectionView()
                        .tabItem { Label("Collection", systemImage: "hexagon.fill") }
                        .tag(SpiritTab.collection)
                    ProfileView()
                        .tabItem { Label("Profile", systemImage: "person.crop.circle.fill") }
                        .tag(SpiritTab.profile)
                }
                .tint(SpiritColor.pink)
            }
        }
    }

    @ViewBuilder
    private var selectedContent: some View {
        switch selectedTab {
        case .today:
            TodayView(selectedTab: $selectedTab)
        case .trails:
            TrailsView()
        case .stories:
            StoriesView()
        case .collection:
            CollectionView()
        case .profile:
            ProfileView()
        }
    }
}

private struct SpiritSidebar: View {
    @Binding var selectedTab: SpiritTab

    private let items: [(SpiritTab, String, String)] = [
        (.today, "Today", "house.fill"),
        (.trails, "Trails", "mountain.2.fill"),
        (.stories, "Stories", "book.closed.fill"),
        (.collection, "Collection", "hexagon.fill"),
        (.profile, "Profile", "person.crop.circle.fill")
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(spacing: 12) {
                BrandMark(size: 58)
                VStack(alignment: .leading, spacing: 2) {
                    Text("WN SPRT")
                        .font(.title3.weight(.black))
                        .foregroundStyle(SpiritColor.white)
                    Text("Forest Mood Trails")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(SpiritColor.cyan)
                }
            }
            .padding(.bottom, 10)

            ForEach(items, id: \.0) { tab, title, icon in
                Button {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.84)) {
                        selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: icon)
                            .frame(width: 28, height: 28)
                        Text(title)
                            .font(.headline.weight(.bold))
                        Spacer()
                    }
                    .foregroundStyle(selectedTab == tab ? SpiritColor.ink : SpiritColor.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 13)
                    .background(selectedTab == tab ? SpiritColor.cyan : SpiritColor.ink.opacity(0.45), in: RoundedRectangle(cornerRadius: 8))
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke((selectedTab == tab ? SpiritColor.cyan : SpiritColor.pink).opacity(0.45)))
                    .shadow(color: (selectedTab == tab ? SpiritColor.cyan : SpiritColor.pink).opacity(selectedTab == tab ? 0.28 : 0.10), radius: 14)
                }
                .buttonStyle(.plain)
            }

            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Label("Universal iPad", systemImage: "ipad.landscape")
                Label("Offline trails", systemImage: "wifi.slash")
            }
            .font(.caption.weight(.bold))
            .foregroundStyle(SpiritColor.muted)
        }
        .padding(18)
        .frame(width: 250)
        .frame(maxHeight: .infinity)
        .background(SpiritColor.ink.opacity(0.44))
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(SpiritColor.cyan.opacity(0.18))
                .frame(width: 1)
        }
    }
}
