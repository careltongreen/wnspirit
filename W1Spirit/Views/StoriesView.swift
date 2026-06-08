import SwiftUI

struct StoriesView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    @State private var selectedCategory = "National Parks"

    private var categories: [String] {
        Array(Set(store.stories.map(\.category))).sorted()
    }

    private var filteredStories: [CanadaStory] {
        store.stories.filter { $0.category == selectedCategory }
    }

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var storyColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: isPadLayout ? 2 : 1)
    }

    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                SpiritPage(maxWidth: 1160) {
                    VStack(spacing: 18) {
                        SpiritHeader(title: "Canada Stories", subtitle: "Read short Canadian nature articles.", trailingIcon: "book.pages.fill")

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        selectedCategory = category
                                    } label: {
                                        Text(category)
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(selectedCategory == category ? SpiritColor.ink : SpiritColor.cyan)
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 9)
                                            .background(selectedCategory == category ? SpiritColor.cyan : SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.cyan.opacity(0.55)))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        FeaturedStory(story: store.todaysStory, heroHeight: isPadLayout ? 340 : 220)

                        VStack(alignment: .leading, spacing: 14) {
                            SectionTitle(title: selectedCategory, subtitle: "\(filteredStories.count) expanded articles")
                            LazyVGrid(columns: storyColumns, spacing: 12) {
                                ForEach(filteredStories) { story in
                                    NavigationLink(destination: StoryDetailView(story: story)) {
                                        StoryRow(story: story)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .spiritCard(tint: SpiritColor.pink)
                    }
                    .padding(18)
                    .padding(.bottom, isPadLayout ? 26 : 90)
                }
            }
            .background(SpiritBackground().ignoresSafeArea())
            .onAppear {
                if !categories.contains(selectedCategory), let first = categories.first {
                    selectedCategory = first
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}

private struct FeaturedStory: View {
    let story: CanadaStory
    var heroHeight: CGFloat = 220

    var body: some View {
        let tint = SpiritColor.named(story.tintName)
        NavigationLink(destination: StoryDetailView(story: story)) {
            VStack(alignment: .leading, spacing: 13) {
                SpiritAssetImage(name: story.imageName, height: heroHeight)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("TODAY'S STORY")
                                .font(.caption.weight(.black))
                                .foregroundStyle(tint)
                            Text(story.title)
                                .font(.title.weight(.black))
                                .foregroundStyle(SpiritColor.white)
                        }
                        .padding(14)
                    }
                Text(story.body)
                    .font(.subheadline)
                    .foregroundStyle(SpiritColor.muted)
                    .lineLimit(3)
                HStack {
                    Label(story.readTime, systemImage: "text.alignleft")
                    Label(story.audioTime, systemImage: "waveform")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
            }
            .spiritCard(tint: tint)
        }
        .buttonStyle(.plain)
    }
}

private struct StoryRow: View {
    let story: CanadaStory

    var body: some View {
        let tint = SpiritColor.named(story.tintName)
        HStack(spacing: 12) {
            Image(story.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 86, height: 78)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.45)))
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Label(story.readTime, systemImage: story.symbol)
                    Text(story.region)
                }
                .font(.caption.weight(.bold))
                .foregroundStyle(tint)
                Text(story.title)
                    .font(.headline.weight(.black))
                    .foregroundStyle(SpiritColor.white)
                    .lineLimit(2)
                Text(story.body)
                    .font(.caption)
                    .foregroundStyle(SpiritColor.muted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(SpiritColor.muted)
        }
        .padding(10)
        .background(SpiritColor.ink.opacity(0.50), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.25)))
    }
}

private struct StoryDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    let story: CanadaStory

    private var isPadLayout: Bool { horizontalSizeClass == .regular }

    var body: some View {
        let tint = SpiritColor.named(story.tintName)
        ScrollView(showsIndicators: false) {
            SpiritPage(maxWidth: 980) {
                VStack(alignment: .leading, spacing: 18) {
                    SpiritAssetImage(name: story.imageName, height: isPadLayout ? 420 : 300)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(story.category.uppercased())
                                .font(.caption.weight(.black))
                                .foregroundStyle(tint)
                            Text(story.title)
                                .font(.largeTitle.weight(.black))
                                .foregroundStyle(SpiritColor.white)
                                .lineLimit(3)
                                .minimumScaleFactor(0.72)
                            Text(story.region)
                                .font(.headline)
                                .foregroundStyle(SpiritColor.muted)
                        }
                        .padding(16)
                    }

                    HStack(spacing: 10) {
                        StorySpec(value: story.readTime, icon: "text.alignleft", tint: tint)
                        StorySpec(value: story.audioTime, icon: "waveform", tint: SpiritColor.cyan)
                    }

                    VStack(alignment: .leading, spacing: 10) {
                        Image(systemName: "quote.opening")
                            .foregroundStyle(tint)
                        Text(story.quote)
                            .font(.title2.weight(.black))
                            .foregroundStyle(SpiritColor.white)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .spiritCard(tint: tint)

                    VStack(alignment: .leading, spacing: 16) {
                        ForEach(Array(story.paragraphs.enumerated()), id: \.offset) { index, paragraph in
                            Text(paragraph)
                                .font(index == 0 ? .headline : .body)
                                .foregroundStyle(index == 0 ? SpiritColor.white : SpiritColor.muted)
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .spiritCard(tint: SpiritColor.cyan, glow: 0.12)

                    VStack(alignment: .leading, spacing: 10) {
                        SectionTitle(title: "Trail Prompt")
                        Text("After reading, choose one detail from the story and look for its echo nearby: a line, a color, a sound, a texture, or a boundary.")
                            .font(.subheadline)
                            .foregroundStyle(SpiritColor.muted)
                    }
                    .spiritCard(tint: SpiritColor.lime)
                }
                .padding(18)
                .padding(.bottom, 40)
            }
        }
        .background(SpiritBackground().ignoresSafeArea())
        .navigationTitle("Story")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct StorySpec: View {
    let value: String
    let icon: String
    let tint: Color

    var body: some View {
        Label(value, systemImage: icon)
            .font(.caption.weight(.bold))
            .foregroundStyle(tint)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.35)))
    }
}
