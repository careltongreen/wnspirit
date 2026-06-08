import Foundation
import SwiftUI

enum SpiritMood: String, CaseIterable, Identifiable, Codable {
    case calm = "Calm"
    case focused = "Focused"
    case adventurous = "Adventurous"
    case reflective = "Reflective"
    case social = "Social"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .calm: "water.waves"
        case .focused: "safari.fill"
        case .adventurous: "mountain.2.fill"
        case .reflective: "leaf.fill"
        case .social: "person.2.fill"
        }
    }

    var color: Color {
        switch self {
        case .calm: SpiritColor.cyan
        case .focused: SpiritColor.blue
        case .adventurous: SpiritColor.orange
        case .reflective: SpiritColor.purpleGlow
        case .social: SpiritColor.pink
        }
    }

    var prompt: String {
        switch self {
        case .calm: "Slow breath, soft steps, quiet details."
        case .focused: "A clear path for one small decision."
        case .adventurous: "Move toward the brightest unknown."
        case .reflective: "Notice what the forest is showing you."
        case .social: "Share the moment, even if it is tiny."
        }
    }
}

enum SpiritSound: String, CaseIterable, Identifiable, Codable {
    case cedarForest = "Cedar Forest"
    case mountainWind = "Mountain Wind"
    case lakeShore = "Lake Shore"
    case rainForest = "Rain Forest"
    case northernNight = "Northern Night"
    case campfire = "Campfire"

    var id: String { rawValue }

    var category: String {
        switch self {
        case .cedarForest: "Forest"
        case .mountainWind: "Wind"
        case .lakeShore: "Lake"
        case .rainForest: "Rain"
        case .northernNight: "Northern"
        case .campfire: "Campfire"
        }
    }

    var icon: String {
        switch self {
        case .cedarForest: "tree.fill"
        case .mountainWind: "wind"
        case .lakeShore: "drop.fill"
        case .rainForest: "cloud.rain.fill"
        case .northernNight: "moon.stars.fill"
        case .campfire: "flame.fill"
        }
    }
}

struct SpiritTrail: Identifiable, Codable, Hashable {
    let id: UUID
    let mood: SpiritMood
    let title: String
    let place: String
    let minutes: Int
    let sound: SpiritSound
    let challenge: String
    let storyTitle: String
    let province: String
    let paletteSeed: Int
    let imageName: String
    let difficulty: String
    let season: String
    let summary: String
    let routeSteps: [String]

    init(
        id: UUID = UUID(),
        mood: SpiritMood,
        title: String,
        place: String,
        minutes: Int,
        sound: SpiritSound,
        challenge: String,
        storyTitle: String,
        province: String,
        paletteSeed: Int,
        imageName: String = "TrailBanffCedar",
        difficulty: String = "Easy",
        season: String = "All season",
        summary: String = "A short mood-first route built for one focused outdoor reset.",
        routeSteps: [String] = []
    ) {
        self.id = id
        self.mood = mood
        self.title = title
        self.place = place
        self.minutes = minutes
        self.sound = sound
        self.challenge = challenge
        self.storyTitle = storyTitle
        self.province = province
        self.paletteSeed = paletteSeed
        self.imageName = imageName
        self.difficulty = difficulty
        self.season = season
        self.summary = summary
        self.routeSteps = routeSteps
    }
}

struct CanadaStory: Identifiable, Codable, Hashable {
    let id: UUID
    let category: String
    let title: String
    let region: String
    let readTime: String
    let audioTime: String
    let body: String
    let symbol: String
    let tintName: String
    let imageName: String
    let quote: String
    let paragraphs: [String]

    init(
        id: UUID = UUID(),
        category: String,
        title: String,
        region: String,
        readTime: String = "1 min read",
        audioTime: String = "30 sec audio",
        body: String,
        symbol: String,
        tintName: String,
        imageName: String = "StoryBanff",
        quote: String = "A place becomes memorable when you slow down enough to meet it.",
        paragraphs: [String] = []
    ) {
        self.id = id
        self.category = category
        self.title = title
        self.region = region
        self.readTime = readTime
        self.audioTime = audioTime
        self.body = body
        self.symbol = symbol
        self.tintName = tintName
        self.imageName = imageName
        self.quote = quote
        self.paragraphs = paragraphs.isEmpty ? [body] : paragraphs
    }
}

struct SpiritBadge: Identifiable, Codable, Hashable {
    let id: UUID
    let title: String
    let requirement: String
    let icon: String
    let tintName: String
    let threshold: Int

    init(id: UUID = UUID(), title: String, requirement: String, icon: String, tintName: String, threshold: Int) {
        self.id = id
        self.title = title
        self.requirement = requirement
        self.icon = icon
        self.tintName = tintName
        self.threshold = threshold
    }
}

struct SpiritProvince: Identifiable, Codable, Hashable {
    let id: UUID
    let name: String
    let unlockAt: Int
    let stories: [String]
    let symbol: String

    init(id: UUID = UUID(), name: String, unlockAt: Int, stories: [String], symbol: String) {
        self.id = id
        self.name = name
        self.unlockAt = unlockAt
        self.stories = stories
        self.symbol = symbol
    }
}

struct SpiritQuest: Codable, Hashable {
    let title: String
    let target: Int
    let reward: String
}
