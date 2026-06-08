import Foundation
import SwiftUI
import AVFoundation
import FirebaseAnalytics

final class SpiritStore: ObservableObject {
    @AppStorage("w1.completedTrails") private var completedTrailCount = 7
    @AppStorage("w1.completedChallenges") private var completedChallengeCount = 4
    @AppStorage("w1.savedQuotes") private var savedQuoteCount = 2
    @AppStorage("w1.selectedMood") private var selectedMoodRaw = SpiritMood.reflective.rawValue
    @AppStorage("w1.lastTrailID") private var lastTrailID = ""

    @Published var selectedMood: SpiritMood = .reflective {
        didSet { selectedMoodRaw = selectedMood.rawValue }
    }
    @Published var activeTrail: SpiritTrail = SpiritSampleData.trails[0]
    @Published var selectedSound: SpiritSound = .cedarForest
    @Published var soundDuration = "10 min"
    @Published var isSoundPlaying = false
    @Published var playingSound: SpiritSound?

    private let natureAudio = NatureAudioEngine()

    let trails = SpiritSampleData.trails
    let stories = SpiritSampleData.stories
    let badges = SpiritSampleData.badges
    let provinces = SpiritSampleData.provinces
    let quest = SpiritSampleData.weeklyQuest

    init() {
        let mood = SpiritMood(rawValue: selectedMoodRaw) ?? .reflective
        selectedMood = mood
        activeTrail = SpiritSampleData.trails.first { $0.mood == mood } ?? SpiritSampleData.trails[0]
        selectedSound = activeTrail.sound
    }

    var completedTrails: Int { completedTrailCount }
    var completedChallenges: Int { completedChallengeCount }
    var savedQuotes: Int { savedQuoteCount }
    var streak: Int { min(21, max(1, completedTrailCount)) }
    var todaysTrail: SpiritTrail { activeTrail }

    var todaysStory: CanadaStory {
        stories.first { $0.title == activeTrail.storyTitle } ?? stories[0]
    }

    var todaysQuote: String {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return SpiritSampleData.quotes[day % SpiritSampleData.quotes.count]
    }

    func generateTrail() {
        let matching = trails.filter { $0.mood == selectedMood }
        activeTrail = matching.randomElement() ?? trails.randomElement() ?? activeTrail
        selectedSound = activeTrail.sound
        lastTrailID = activeTrail.id.uuidString
        Analytics.logEvent("trail_generated", parameters: [
            "mood": selectedMood.rawValue,
            "trail": activeTrail.place
        ])
    }

    func selectTrail(_ trail: SpiritTrail) {
        selectedMood = trail.mood
        activeTrail = trail
        selectedSound = trail.sound
        lastTrailID = trail.id.uuidString
        Analytics.logEvent("trail_selected", parameters: [
            "mood": trail.mood.rawValue,
            "trail": trail.place,
            "province": trail.province
        ])
    }

    func completeTrail() {
        completedTrailCount += 1
        completedChallengeCount += 1
        Analytics.logEvent("trail_completed", parameters: [
            "trail": activeTrail.place,
            "mood": activeTrail.mood.rawValue,
            "minutes": activeTrail.minutes
        ])
        generateTrail()
    }

    func saveQuote() {
        savedQuoteCount += 1
        Analytics.logEvent("aurora_quote_saved", parameters: [
            "saved_quotes": savedQuoteCount
        ])
    }

    func playSelectedSound() {
        playSound(selectedSound)
    }

    func playSound(_ sound: SpiritSound) {
        selectedSound = sound
        natureAudio.play(sound: sound)
        playingSound = sound
        isSoundPlaying = true
        Analytics.logEvent("nature_sound_played", parameters: [
            "sound": sound.rawValue,
            "duration": soundDuration
        ])
    }

    func stopSound() {
        natureAudio.stop()
        if let playingSound {
            Analytics.logEvent("nature_sound_stopped", parameters: [
                "sound": playingSound.rawValue
            ])
        }
        playingSound = nil
        isSoundPlaying = false
    }

    func toggleSound(_ sound: SpiritSound) {
        if isSoundPlaying, playingSound == sound {
            stopSound()
        } else {
            playSound(sound)
        }
    }

    func badgeProgress(for badge: SpiritBadge) -> Double {
        let current: Int
        if badge.title == "Wildlife Observer" {
            current = completedChallengeCount
        } else if badge.title == "Aurora Keeper" {
            current = savedQuoteCount
        } else if badge.title == "Story Listener" {
            current = min(stories.count, completedTrailCount + savedQuoteCount)
        } else {
            current = completedTrailCount
        }
        return min(1, Double(current) / Double(max(1, badge.threshold)))
    }

    func isUnlocked(_ province: SpiritProvince) -> Bool {
        completedTrailCount >= province.unlockAt
    }
}

private final class NatureAudioEngine {
    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private var isConfigured = false

    func play(sound: SpiritSound) {
        configureIfNeeded()
        player.stop()

        guard let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2),
              let buffer = makeBuffer(sound: sound, format: format) else {
            return
        }

        player.scheduleBuffer(buffer, at: nil, options: [.loops])
        do {
#if os(iOS)
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
#endif
            if !engine.isRunning {
                try engine.start()
            }
            player.play()
        } catch {
            player.stop()
        }
    }

    func stop() {
        player.stop()
    }

    private func configureIfNeeded() {
        guard !isConfigured else { return }
        engine.attach(player)
        let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.mainMixerNode.outputVolume = 0.72
        isConfigured = true
    }

    private func makeBuffer(sound: SpiritSound, format: AVAudioFormat) -> AVAudioPCMBuffer? {
        let sampleRate = format.sampleRate
        let duration = 6.0
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount),
              let channels = buffer.floatChannelData else {
            return nil
        }

        buffer.frameLength = frameCount
        var seed = UInt64(abs(sound.rawValue.hashValue) + 11)
        var lowPass: Float = 0
        var crackleHold: Float = 0

        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            let noise = nextNoise(seed: &seed)
            lowPass = lowPass * 0.985 + noise * 0.015
            let shimmer = Float(sin(2 * Double.pi * 0.08 * t))
            let sample = ambientSample(sound: sound, t: t, noise: noise, lowPass: lowPass, shimmer: shimmer, crackle: &crackleHold, seed: &seed)
            let left = clamp(sample * 0.90)
            let right = clamp(sample * (0.82 + 0.08 * Float(sin(2 * Double.pi * 0.19 * t))))
            channels[0][frame] = left
            channels[1][frame] = right
        }
        return buffer
    }

    private func ambientSample(
        sound: SpiritSound,
        t: Double,
        noise: Float,
        lowPass: Float,
        shimmer: Float,
        crackle: inout Float,
        seed: inout UInt64
    ) -> Float {
        switch sound {
        case .cedarForest:
            let wind = lowPass * 0.18
            let birds = chirp(t, every: 2.7, pitch: 1_660, offset: 0.35) * 0.055
            let leaves = noise * 0.018 * (0.6 + shimmer * 0.2)
            return wind + birds + leaves
        case .mountainWind:
            let gust = Float(sin(2 * Double.pi * 0.055 * t)) * 0.12 + lowPass * 0.36
            let air = noise * 0.028
            return gust + air
        case .lakeShore:
            let wave = Float(sin(2 * Double.pi * 0.42 * t) + sin(2 * Double.pi * 0.63 * t + 1.1)) * 0.065
            let foam = max(0, Float(sin(2 * Double.pi * 0.21 * t))) * noise * 0.045
            return wave + foam + lowPass * 0.08
        case .rainForest:
            let rain = noise * 0.11
            let canopy = lowPass * 0.22
            let drip = chirp(t, every: 0.83, pitch: 780, offset: 0.1) * 0.025
            return rain + canopy + drip
        case .northernNight:
            let drone = Float(sin(2 * Double.pi * 86 * t) + sin(2 * Double.pi * 129 * t)) * 0.045
            let aurora = Float(sin(2 * Double.pi * 0.07 * t)) * 0.07
            let sparkle = chirp(t, every: 3.4, pitch: 1_220, offset: 1.2) * 0.035
            return drone + aurora + sparkle + lowPass * 0.04
        case .campfire:
            if nextNoise(seed: &seed) > 0.985 {
                crackle = nextNoise(seed: &seed) * 0.25
            }
            crackle *= 0.82
            let flame = lowPass * 0.20 + noise * 0.045
            return flame + crackle
        }
    }

    private func chirp(_ t: Double, every: Double, pitch: Double, offset: Double) -> Float {
        let local = (t + offset).truncatingRemainder(dividingBy: every)
        guard local < 0.16 else { return 0 }
        let env = Float(1 - local / 0.16)
        return Float(sin(2 * Double.pi * pitch * t)) * env
    }

    private func nextNoise(seed: inout UInt64) -> Float {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1
        let value = Double((seed >> 33) & 0xFFFF) / 32_768.0 - 1.0
        return Float(value)
    }

    private func clamp(_ value: Float) -> Float {
        min(0.45, max(-0.45, value))
    }
}
