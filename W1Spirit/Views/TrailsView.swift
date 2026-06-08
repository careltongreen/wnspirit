import SwiftUI

struct TrailsView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    @State private var filter: SpiritMood? = nil

    private var filteredTrails: [SpiritTrail] {
        guard let filter else { return store.trails }
        return store.trails.filter { $0.mood == filter }
    }

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    var body: some View {
        NavigationView {
            ScrollView(showsIndicators: false) {
                SpiritPage(maxWidth: 1240) {
                    VStack(spacing: 18) {
                        SpiritHeader(title: "Trails", subtitle: "Choose your next forest moment.", trailingIcon: "wand.and.stars")
                        TrailStatsBand(filteredCount: filteredTrails.count, totalCount: store.trails.count)
                        MoodPickerPanel()
                        TrailCard(trail: store.activeTrail)
                        TrailCatalog(filter: $filter, trails: filteredTrails)
                        NatureSoundsPanel()
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

private struct MoodPickerPanel: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: isPadLayout ? 5 : 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .lastTextBaseline) {
                SectionTitle(title: "Mood", subtitle: isPadLayout ? "Choose the tone, then generate a route." : "Pick a mood, then generate or choose a route manually.")
                if isPadLayout {
                    Button {
                        store.generateTrail()
                    } label: {
                        Label("Generate", systemImage: "shuffle")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(store.selectedMood.color)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 11)
                            .background(SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(store.selectedMood.color, lineWidth: 1.2))
                    }
                    .buttonStyle(.plain)
                }
            }

            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(SpiritMood.allCases) { mood in
                    Button {
                        withAnimation(.spring(response: 0.36, dampingFraction: 0.82)) {
                            store.selectedMood = mood
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: mood.icon)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mood.rawValue)
                                    .font(isPadLayout ? .subheadline.weight(.black) : .headline.weight(.bold))
                                if !isPadLayout {
                                    Text(mood.prompt)
                                        .font(.caption)
                                        .foregroundStyle(SpiritColor.muted)
                                        .lineLimit(1)
                                }
                            }
                            Spacer()
                            if store.selectedMood == mood {
                                Image(systemName: "checkmark.circle.fill")
                            }
                        }
                        .foregroundStyle(mood.color)
                        .padding(14)
                        .background(SpiritColor.ink.opacity(store.selectedMood == mood ? 0.72 : 0.42), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(mood.color.opacity(store.selectedMood == mood ? 1 : 0.45), lineWidth: 1))
                        .shadow(color: mood.color.opacity(store.selectedMood == mood ? 0.42 : 0.08), radius: 12)
                    }
                    .buttonStyle(.plain)
                }
            }

            if !isPadLayout {
                NeonButton(title: "Generate My Trail", icon: "shuffle", tint: store.selectedMood.color) {
                    store.generateTrail()
                }
            }
        }
        .spiritCard(tint: store.selectedMood.color)
    }
}

private struct TrailStatsBand: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    let filteredCount: Int
    let totalCount: Int

    private var columns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: horizontalSizeClass == .regular ? 4 : 2)
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            MetricTile(title: "All Trails", value: "\(totalCount)", icon: "map.fill", tint: SpiritColor.cyan)
            MetricTile(title: "Visible", value: "\(filteredCount)", icon: "square.grid.2x2.fill", tint: SpiritColor.pink)
            MetricTile(title: "Selected Mood", value: store.selectedMood.rawValue, icon: store.selectedMood.icon, tint: store.selectedMood.color)
            MetricTile(title: "Today", value: "\(store.activeTrail.minutes) min", icon: "clock.fill", tint: SpiritColor.orange)
        }
    }
}

private struct TrailCatalog: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    @Binding var filter: SpiritMood?
    let trails: [SpiritTrail]

    private var catalogColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 12), count: horizontalSizeClass == .regular ? 2 : 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Choose a Trail", subtitle: "\(trails.count) routes available offline")

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    FilterChip(title: "All", icon: "square.grid.2x2.fill", tint: SpiritColor.cyan, isSelected: filter == nil) {
                        filter = nil
                    }
                    ForEach(SpiritMood.allCases) { mood in
                        FilterChip(title: mood.rawValue, icon: mood.icon, tint: mood.color, isSelected: filter == mood) {
                            filter = mood
                        }
                    }
                }
                .padding(.vertical, 2)
            }

            LazyVGrid(columns: catalogColumns, spacing: 12) {
                ForEach(trails) { trail in
                    NavigationLink(destination: TrailDetailView(trail: trail)) {
                        HStack(spacing: 12) {
                            Image(trail.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 88, height: 78)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(trail.mood.color.opacity(0.45)))
                            VStack(alignment: .leading, spacing: 5) {
                                HStack {
                                    Label("\(trail.minutes) min", systemImage: "clock.fill")
                                    Text(trail.difficulty)
                                }
                                .font(.caption.weight(.bold))
                                .foregroundStyle(trail.mood.color)
                                Text(trail.place)
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(SpiritColor.white)
                                    .lineLimit(2)
                                Text(trail.summary)
                                    .font(.caption)
                                    .foregroundStyle(SpiritColor.muted)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: store.todaysTrail.id == trail.id ? "checkmark.circle.fill" : "chevron.right")
                                .foregroundStyle(store.todaysTrail.id == trail.id ? SpiritColor.lime : SpiritColor.muted)
                        }
                        .padding(10)
                        .background(SpiritColor.ink.opacity(0.50), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(trail.mood.color.opacity(0.28)))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .spiritCard(tint: filter?.color ?? SpiritColor.cyan)
    }
}

private struct FilterChip: View {
    let title: String
    let icon: String
    let tint: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(.caption.weight(.bold))
                .foregroundStyle(isSelected ? SpiritColor.ink : tint)
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .background(isSelected ? tint : SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.55)))
        }
        .buttonStyle(.plain)
    }
}

private struct TrailCard: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    let trail: SpiritTrail

    private var isPadLayout: Bool { horizontalSizeClass == .regular }

    var body: some View {
        Group {
            if isPadLayout {
                HStack(alignment: .top, spacing: 18) {
                    SpiritAssetImage(name: trail.imageName, fallbackSeed: trail.paletteSeed, height: 290)
                        .frame(maxWidth: 470)
                    trailSummary
                }
            } else {
                VStack(alignment: .leading, spacing: 15) {
                    trailSummaryHeader
                    SpiritAssetImage(name: trail.imageName, fallbackSeed: trail.paletteSeed, height: 205)
                    trailSummaryBody
                }
            }
        }
        .spiritCard(tint: trail.mood.color, glow: 0.36)
    }

    private var trailSummary: some View {
        VStack(alignment: .leading, spacing: 15) {
            trailSummaryHeader
            trailSummaryBody
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var trailSummaryHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: trail.mood.icon)
                    .foregroundStyle(trail.mood.color)
                Text("Today's Selected Trail")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(trail.mood.color)
                Spacer()
                Image(systemName: "heart")
                    .foregroundStyle(SpiritColor.white)
            }
            Text(trail.title)
                .font(isPadLayout ? .largeTitle.weight(.black) : .title.weight(.black))
                .foregroundStyle(SpiritColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text(trail.place)
                .font(.title3.weight(.bold))
                .foregroundStyle(SpiritColor.cyan)
        }
    }

    private var trailSummaryBody: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                MiniSpec(value: "\(trail.minutes) min", title: "Walking", icon: "clock.fill", tint: SpiritColor.orange)
                MiniSpec(value: trail.season, title: "Best mood", icon: "sun.max.fill", tint: SpiritColor.lime)
            }

            TrailStep(icon: trail.sound.icon, title: "Listen", detail: "\(trail.sound.rawValue) sound", tint: SpiritColor.cyan)
            SoundControlButton(sound: trail.sound, tint: SpiritColor.cyan)
            TrailStep(icon: "sparkle.magnifyingglass", title: "Discovery Challenge", detail: trail.challenge, tint: SpiritColor.lime)
            TrailStep(icon: "book.closed.fill", title: "Canada Story", detail: "\(trail.storyTitle) - read in Stories", tint: SpiritColor.pink)

            HStack(spacing: 10) {
                NavigationLink(destination: TrailDetailView(trail: trail)) {
                    Label("Open Trail", systemImage: "map.fill")
                        .font(.headline.weight(.bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .foregroundStyle(SpiritColor.ink)
                        .background(trail.mood.color, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)

                Button {
                    withAnimation(.spring(response: 0.38, dampingFraction: 0.8)) {
                        store.completeTrail()
                    }
                } label: {
                    Image(systemName: "checkmark")
                        .font(.headline.weight(.bold))
                        .frame(width: 52, height: 48)
                        .foregroundStyle(SpiritColor.lime)
                        .background(SpiritColor.ink.opacity(0.60), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(SpiritColor.lime))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TrailDetailView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    let trail: SpiritTrail

    private var isPadLayout: Bool { horizontalSizeClass == .regular }
    private var detailColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 18), count: isPadLayout ? 2 : 1)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            SpiritPage(maxWidth: 1120) {
                VStack(alignment: .leading, spacing: 18) {
                    SpiritAssetImage(name: trail.imageName, fallbackSeed: trail.paletteSeed, height: isPadLayout ? 390 : 280)
                    .overlay(alignment: .bottomLeading) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(trail.mood.rawValue.uppercased())
                                .font(.caption.weight(.black))
                                .foregroundStyle(trail.mood.color)
                            Text(trail.place)
                                .font(.largeTitle.weight(.black))
                                .foregroundStyle(SpiritColor.white)
                                .lineLimit(3)
                                .minimumScaleFactor(0.72)
                        }
                        .padding(16)
                    }

                Text(trail.summary)
                    .font(.headline)
                    .foregroundStyle(SpiritColor.muted)

                HStack(spacing: 10) {
                    MiniSpec(value: "\(trail.minutes)", title: "minutes", icon: "clock.fill", tint: SpiritColor.orange)
                    MiniSpec(value: trail.difficulty, title: "difficulty", icon: "figure.walk", tint: trail.mood.color)
                    MiniSpec(value: trail.sound.category, title: "sound", icon: trail.sound.icon, tint: SpiritColor.cyan)
                }

                    LazyVGrid(columns: detailColumns, spacing: 18) {
                        AudioRoutePanel(sound: trail.sound, tint: trail.mood.color)
                        RouteMapPanel(trail: trail)
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        SectionTitle(title: "Route Steps", subtitle: "A guided 5-15 minute micro-adventure")
                        ForEach(Array(trail.routeSteps.enumerated()), id: \.offset) { index, step in
                            HStack(alignment: .top, spacing: 12) {
                                Text("\(index + 1)")
                                    .font(.headline.weight(.black))
                                    .foregroundStyle(SpiritColor.ink)
                                    .frame(width: 30, height: 30)
                                    .background(trail.mood.color, in: Circle())
                                Text(step)
                                    .font(.subheadline)
                                    .foregroundStyle(SpiritColor.white)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                            }
                        }
                    }
                    .spiritCard(tint: trail.mood.color)

                VStack(alignment: .leading, spacing: 10) {
                    SectionTitle(title: "Discovery Challenge")
                    Text(trail.challenge)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(SpiritColor.white)
                    Text("Keep it simple: observe, photograph if you want, and leave the place exactly as you found it.")
                        .font(.subheadline)
                        .foregroundStyle(SpiritColor.muted)
                }
                .spiritCard(tint: SpiritColor.lime)

                    NeonButton(title: "Use This Trail Today", icon: "checkmark.circle.fill", tint: trail.mood.color) {
                        store.selectTrail(trail)
                    }
                }
                .padding(18)
                .padding(.bottom, 40)
            }
        }
        .background(SpiritBackground().ignoresSafeArea())
        .navigationTitle("Trail")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct RouteMapPanel: View {
    let trail: SpiritTrail

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Route Map", subtitle: "\(trail.routeSteps.count) checkpoints from start to finish")
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(SpiritColor.ink.opacity(0.55))
                RoutePath()
                    .stroke(trail.mood.color.opacity(0.88), style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                    .shadow(color: trail.mood.color.opacity(0.65), radius: 10)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 24)
                CheckpointLayer(count: trail.routeSteps.count, tint: trail.mood.color)
            }
            .frame(height: 160)
            HStack {
                Label("Start", systemImage: "location.fill")
                    .foregroundStyle(SpiritColor.lime)
                Spacer()
                Label("Finish", systemImage: "flag.checkered")
                    .foregroundStyle(trail.mood.color)
            }
            .font(.caption.weight(.bold))
        }
        .spiritCard(tint: trail.mood.color)
    }
}

private struct AudioRoutePanel: View {
    let sound: SpiritSound
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(title: "Trail Audio", subtitle: "Procedural offline ambient loop")
            SoundControlButton(sound: sound, tint: tint)
        }
        .spiritCard(tint: tint)
    }
}

private struct SoundControlButton: View {
    @EnvironmentObject private var store: SpiritStore
    let sound: SpiritSound
    let tint: Color

    private var isPlaying: Bool {
        store.isSoundPlaying && store.playingSound == sound
    }

    var body: some View {
        Button {
            store.toggleSound(sound)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isPlaying ? "stop.fill" : "play.fill")
                    .font(.headline.weight(.black))
                    .frame(width: 38, height: 38)
                    .foregroundStyle(SpiritColor.ink)
                    .background(isPlaying ? SpiritColor.orange : tint, in: RoundedRectangle(cornerRadius: 8))
                VStack(alignment: .leading, spacing: 2) {
                    Text(isPlaying ? "Stop \(sound.rawValue)" : "Play \(sound.rawValue)")
                        .font(.headline.weight(.black))
                        .foregroundStyle(SpiritColor.white)
                    Text(isPlaying ? "Audio is playing locally" : "Offline generated nature sound")
                        .font(.caption)
                        .foregroundStyle(SpiritColor.muted)
                }
                Spacer()
                if isPlaying {
                    Image(systemName: "waveform")
                        .foregroundStyle(tint)
                }
            }
            .padding(12)
            .background(SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke((isPlaying ? SpiritColor.orange : tint).opacity(0.65)))
        }
        .buttonStyle(.plain)
    }
}

private struct RoutePath: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.height * 0.72))
        path.addCurve(
            to: CGPoint(x: rect.width * 0.32, y: rect.height * 0.28),
            control1: CGPoint(x: rect.width * 0.10, y: rect.height * 0.86),
            control2: CGPoint(x: rect.width * 0.20, y: rect.height * 0.16)
        )
        path.addCurve(
            to: CGPoint(x: rect.width * 0.62, y: rect.height * 0.58),
            control1: CGPoint(x: rect.width * 0.42, y: rect.height * 0.42),
            control2: CGPoint(x: rect.width * 0.47, y: rect.height * 0.72)
        )
        path.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.height * 0.22),
            control1: CGPoint(x: rect.width * 0.74, y: rect.height * 0.42),
            control2: CGPoint(x: rect.width * 0.85, y: rect.height * 0.18)
        )
        return path
    }
}

private struct CheckpointLayer: View {
    let count: Int
    let tint: Color

    private var points: [CGPoint] {
        [
            CGPoint(x: 0.12, y: 0.72),
            CGPoint(x: 0.34, y: 0.28),
            CGPoint(x: 0.55, y: 0.58),
            CGPoint(x: 0.75, y: 0.36),
            CGPoint(x: 0.88, y: 0.22)
        ]
    }

    var body: some View {
        GeometryReader { proxy in
            ForEach(0..<min(max(count, 2), points.count), id: \.self) { index in
                let point = points[index]
                ZStack {
                    Circle()
                        .fill(index == 0 ? SpiritColor.lime : tint)
                        .frame(width: index == 0 ? 18 : 15, height: index == 0 ? 18 : 15)
                        .shadow(color: index == 0 ? SpiritColor.lime : tint, radius: 9)
                    Text(index == 0 ? "" : "\(index)")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(SpiritColor.ink)
                }
                .position(x: proxy.size.width * point.x, y: proxy.size.height * point.y)
            }
        }
    }
}

private struct MiniSpec: View {
    let value: String
    let title: String
    let icon: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Image(systemName: icon)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline.weight(.black))
                .foregroundStyle(SpiritColor.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
            Text(title)
                .font(.caption)
                .foregroundStyle(SpiritColor.muted)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(SpiritColor.ink.opacity(0.50), in: RoundedRectangle(cornerRadius: 8))
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(tint.opacity(0.35)))
    }
}

private struct TrailStep: View {
    let icon: String
    let title: String
    let detail: String
    let tint: Color

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(tint)
                .frame(width: 28, height: 28)
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

private struct NatureSoundsPanel: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @EnvironmentObject private var store: SpiritStore
    private let durations = ["5 min", "10 min", "Loop"]

    private var soundColumns: [GridItem] {
        Array(repeating: GridItem(.flexible(), spacing: 10), count: horizontalSizeClass == .regular ? 3 : 2)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            SectionTitle(title: "Nature Sounds", subtitle: "Forest, lake, rain, wind, northern night, and campfire.")
            LazyVGrid(columns: soundColumns, spacing: 10) {
                ForEach(SpiritSound.allCases) { sound in
                    Button {
                        store.selectedSound = sound
                    } label: {
                        VStack(alignment: .leading, spacing: 8) {
                            Image(systemName: sound.icon)
                            Text(sound.category)
                                .font(.caption)
                                .foregroundStyle(SpiritColor.muted)
                            Text(sound.rawValue)
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(SpiritColor.white)
                                .lineLimit(1)
                                .minimumScaleFactor(0.72)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(SpiritColor.ink.opacity(0.55), in: RoundedRectangle(cornerRadius: 8))
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(store.selectedSound == sound ? SpiritColor.cyan : SpiritColor.cyan.opacity(0.22)))
                    }
                    .buttonStyle(.plain)
                }
            }

            Picker("Duration", selection: $store.soundDuration) {
                ForEach(durations, id: \.self) { duration in
                    Text(duration).tag(duration)
                }
            }
            .pickerStyle(.segmented)

            NeonButton(
                title: store.isSoundPlaying && store.playingSound == store.selectedSound ? "Stop \(store.selectedSound.rawValue)" : "Play \(store.selectedSound.rawValue)",
                icon: store.isSoundPlaying && store.playingSound == store.selectedSound ? "stop.fill" : "play.fill",
                tint: store.isSoundPlaying && store.playingSound == store.selectedSound ? SpiritColor.orange : SpiritColor.cyan
            ) {
                store.toggleSound(store.selectedSound)
            }
        }
        .spiritCard(tint: SpiritColor.cyan)
    }
}
