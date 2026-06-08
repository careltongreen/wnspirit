import AppKit

let root = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("W1Spirit/Assets.xcassets")

struct SceneSpec {
    let name: String
    let seed: Int
    let mood: Int
}

let specs: [SceneSpec] = [
    SceneSpec(name: "TrailBanffCedar", seed: 1, mood: 0),
    SceneSpec(name: "TrailLakeLouise", seed: 2, mood: 1),
    SceneSpec(name: "TrailJasperCompass", seed: 3, mood: 2),
    SceneSpec(name: "TrailYukonAurora", seed: 4, mood: 3),
    SceneSpec(name: "TrailNovaTide", seed: 5, mood: 4),
    SceneSpec(name: "TrailBCRainforest", seed: 6, mood: 5),
    SceneSpec(name: "TrailKettleRail", seed: 7, mood: 6),
    SceneSpec(name: "TrailYohoStone", seed: 8, mood: 0),
    SceneSpec(name: "TrailRemoteLake", seed: 9, mood: 1),
    SceneSpec(name: "TrailCampfireCircle", seed: 10, mood: 4),
    SceneSpec(name: "TrailPrairieSky", seed: 11, mood: 2),
    SceneSpec(name: "TrailMapleShadow", seed: 12, mood: 5),
    SceneSpec(name: "TrailFundyRock", seed: 13, mood: 4),
    SceneSpec(name: "TrailArcticSignal", seed: 14, mood: 3),
    SceneSpec(name: "TrailMistyHemlock", seed: 15, mood: 5),
    SceneSpec(name: "TrailMontrealLantern", seed: 16, mood: 6),
    SceneSpec(name: "TrailPolarQuiet", seed: 17, mood: 3),
    SceneSpec(name: "TrailGhostTown", seed: 18, mood: 6),
    SceneSpec(name: "TrailBeaverDam", seed: 19, mood: 1),
    SceneSpec(name: "TrailNorthernWindow", seed: 20, mood: 3),
    SceneSpec(name: "TrailGlacierLine", seed: 37, mood: 3),
    SceneSpec(name: "TrailHopewellStacks", seed: 38, mood: 4),
    SceneSpec(name: "TrailRedSand", seed: 39, mood: 4),
    SceneSpec(name: "TrailHalifaxHarbour", seed: 40, mood: 6),
    SceneSpec(name: "TrailMoraineBlue", seed: 41, mood: 1),
    SceneSpec(name: "TrailMaligneCanyon", seed: 42, mood: 2),
    SceneSpec(name: "TrailLighthouseWind", seed: 43, mood: 4),
    SceneSpec(name: "TrailOldGrowthCircle", seed: 44, mood: 5),
    SceneSpec(name: "TrailSnowLantern", seed: 45, mood: 3),
    SceneSpec(name: "TrailTorontoRavine", seed: 46, mood: 5),
    SceneSpec(name: "TrailTundraMarker", seed: 47, mood: 3),
    SceneSpec(name: "TrailCanoePortage", seed: 48, mood: 5),
    SceneSpec(name: "TrailWhitePassRail", seed: 49, mood: 6),
    SceneSpec(name: "TrailTofinoRain", seed: 50, mood: 5),
    SceneSpec(name: "TrailWinnipegLights", seed: 51, mood: 6),
    SceneSpec(name: "TrailRavenRidge", seed: 52, mood: 5),
    SceneSpec(name: "TrailBadlandsDrop", seed: 53, mood: 0),
    SceneSpec(name: "TrailOkanaganOrchard", seed: 54, mood: 4),
    SceneSpec(name: "TrailFogBell", seed: 55, mood: 3),
    SceneSpec(name: "TrailNatureSwap", seed: 56, mood: 5),
    SceneSpec(name: "StoryBanff", seed: 21, mood: 0),
    SceneSpec(name: "StoryLakeLouise", seed: 22, mood: 1),
    SceneSpec(name: "StoryJasper", seed: 23, mood: 2),
    SceneSpec(name: "StoryYoho", seed: 24, mood: 0),
    SceneSpec(name: "StoryCreeStars", seed: 25, mood: 2),
    SceneSpec(name: "StoryInuitRoutes", seed: 26, mood: 3),
    SceneSpec(name: "StoryMetisRiver", seed: 27, mood: 1),
    SceneSpec(name: "StoryMoose", seed: 28, mood: 5),
    SceneSpec(name: "StoryBeaver", seed: 29, mood: 1),
    SceneSpec(name: "StoryPolar", seed: 30, mood: 3),
    SceneSpec(name: "StoryGhostTown", seed: 31, mood: 6),
    SceneSpec(name: "StoryRemoteLake", seed: 32, mood: 1),
    SceneSpec(name: "StoryRailways", seed: 33, mood: 6),
    SceneSpec(name: "StoryAtlanticTide", seed: 34, mood: 4),
    SceneSpec(name: "StoryMontreal", seed: 35, mood: 6),
    SceneSpec(name: "StoryWindow", seed: 36, mood: 3)
]

func color(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
    NSColor(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
}

func palette(_ mood: Int) -> (NSColor, NSColor, NSColor) {
    switch mood {
    case 1: return (color(53, 243, 255), color(42, 5, 106), color(157, 255, 87))
    case 2: return (color(80, 130, 255), color(26, 2, 74), color(53, 243, 255))
    case 3: return (color(157, 255, 87), color(26, 2, 74), color(255, 79, 216))
    case 4: return (color(255, 159, 28), color(42, 5, 106), color(255, 79, 216))
    case 5: return (color(157, 255, 87), color(12, 42, 60), color(53, 243, 255))
    case 6: return (color(255, 79, 216), color(30, 8, 82), color(255, 159, 28))
    default: return (color(255, 79, 216), color(42, 5, 106), color(53, 243, 255))
    }
}

func drawTree(x: CGFloat, y: CGFloat, h: CGFloat, tint: NSColor) {
    tint.withAlphaComponent(0.86).setStroke()
    let path = NSBezierPath()
    path.move(to: CGPoint(x: x, y: y))
    path.line(to: CGPoint(x: x, y: y + h))
    for layer in 0..<4 {
        let yy = y + h * CGFloat(0.25 + Double(layer) * 0.18)
        let span = h * CGFloat(0.28 - Double(layer) * 0.035)
        path.move(to: CGPoint(x: x - span, y: yy))
        path.line(to: CGPoint(x: x, y: yy + h * 0.18))
        path.line(to: CGPoint(x: x + span, y: yy))
    }
    path.lineWidth = max(2, h * 0.025)
    path.stroke()
}

func drawScene(_ spec: SceneSpec, size: CGSize) -> NSImage {
    let image = NSImage(size: size)
    image.lockFocus()
    let rect = CGRect(origin: .zero, size: size)
    let (accent, base, secondary) = palette(spec.mood)

    NSGradient(colors: [base, color(26, 2, 74), color(5, 3, 22)])?.draw(in: rect, angle: -65)

    for index in 0..<18 {
        let x = CGFloat((index * 83 + spec.seed * 37) % 1000) / 1000 * size.width
        let y = size.height * (0.12 + CGFloat((index * 41 + spec.seed * 11) % 380) / 1000)
        let star = NSBezierPath(ovalIn: CGRect(x: x, y: y, width: 2.5, height: 2.5))
        (index.isMultiple(of: 3) ? accent : secondary).withAlphaComponent(0.75).setFill()
        star.fill()
    }

    for band in 0..<4 {
        let path = NSBezierPath()
        let y = size.height * CGFloat(0.70 - Double(band) * 0.07)
        path.move(to: CGPoint(x: -60, y: y))
        path.curve(
            to: CGPoint(x: size.width + 60, y: y - CGFloat(28 + band * 6)),
            controlPoint1: CGPoint(x: size.width * 0.25, y: y + CGFloat(70 - band * 8)),
            controlPoint2: CGPoint(x: size.width * 0.62, y: y - CGFloat(80 - band * 4))
        )
        (band.isMultiple(of: 2) ? accent : secondary).withAlphaComponent(0.22).setStroke()
        path.lineWidth = CGFloat(16 + band * 5)
        path.stroke()
    }

    let mountain = NSBezierPath()
    mountain.move(to: CGPoint(x: 0, y: size.height * 0.32))
    let peaks: [CGPoint] = [
        CGPoint(x: size.width * 0.12, y: size.height * 0.48),
        CGPoint(x: size.width * 0.27, y: size.height * CGFloat(spec.seed.isMultiple(of: 2) ? 0.73 : 0.64)),
        CGPoint(x: size.width * 0.43, y: size.height * 0.45),
        CGPoint(x: size.width * 0.60, y: size.height * CGFloat(spec.seed.isMultiple(of: 3) ? 0.78 : 0.68)),
        CGPoint(x: size.width * 0.82, y: size.height * 0.43),
        CGPoint(x: size.width, y: size.height * 0.36),
        CGPoint(x: size.width, y: 0),
        CGPoint(x: 0, y: 0)
    ]
    peaks.forEach { mountain.line(to: $0) }
    mountain.close()
    color(24, 9, 72, 0.90).setFill()
    mountain.fill()
    accent.withAlphaComponent(0.78).setStroke()
    mountain.lineWidth = 3
    mountain.stroke()

    if [1, 4].contains(spec.mood) {
        let water = NSBezierPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height * 0.28))
        color(6, 22, 55, 0.75).setFill()
        water.fill()
        for index in 0..<8 {
            let line = NSBezierPath()
            let y = size.height * CGFloat(0.06 + Double(index) * 0.025)
            line.move(to: CGPoint(x: size.width * 0.10, y: y))
            line.curve(to: CGPoint(x: size.width * 0.90, y: y + 3), controlPoint1: CGPoint(x: size.width * 0.35, y: y + 12), controlPoint2: CGPoint(x: size.width * 0.60, y: y - 10))
            secondary.withAlphaComponent(0.45).setStroke()
            line.lineWidth = 2
            line.stroke()
        }
    }

    if spec.mood == 6 {
        for index in 0..<5 {
            let w = size.width * 0.07
            let x = size.width * CGFloat(0.12 + Double(index) * 0.15)
            let h = size.height * CGFloat(0.16 + Double((index + spec.seed) % 4) * 0.035)
            let building = NSBezierPath(rect: CGRect(x: x, y: size.height * 0.20, width: w, height: h))
            color(12, 6, 36, 0.88).setFill()
            building.fill()
            accent.withAlphaComponent(0.55).setStroke()
            building.lineWidth = 2
            building.stroke()
        }
    }

    if spec.mood == 4 {
        let tent = NSBezierPath()
        tent.move(to: CGPoint(x: size.width * 0.64, y: size.height * 0.20))
        tent.line(to: CGPoint(x: size.width * 0.73, y: size.height * 0.38))
        tent.line(to: CGPoint(x: size.width * 0.83, y: size.height * 0.20))
        tent.close()
        color(255, 159, 28, 0.78).setFill()
        tent.fill()
        color(255, 79, 216, 0.92).setStroke()
        tent.lineWidth = 3
        tent.stroke()
    }

    for index in 0..<10 {
        let x = size.width * CGFloat(index) / 9
        let h = size.height * CGFloat(0.20 + Double((index * 7 + spec.seed) % 6) * 0.035)
        drawTree(x: x + CGFloat((spec.seed % 3) * 6), y: size.height * 0.16, h: h, tint: index.isMultiple(of: 2) ? secondary : accent)
    }

    let glow = NSBezierPath(ovalIn: CGRect(x: size.width * 0.08, y: size.height * 0.10, width: size.width * 0.22, height: size.height * 0.14))
    accent.withAlphaComponent(0.08).setFill()
    glow.fill()

    image.unlockFocus()
    return image
}

func savePNG(_ image: NSImage, to url: URL) throws {
    guard let tiff = image.tiffRepresentation,
          let bitmap = NSBitmapImageRep(data: tiff),
          let data = bitmap.representation(using: .png, properties: [:]) else {
        return
    }
    try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    try data.write(to: url)
}

func writeContents(for name: String, in dir: URL) throws {
    let json = """
    {
      "images" : [
        {
          "filename" : "\(name).png",
          "idiom" : "universal",
          "scale" : "1x"
        }
      ],
      "info" : {
        "author" : "xcode",
        "version" : 1
      }
    }
    """
    try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
    try json.data(using: .utf8)?.write(to: dir.appendingPathComponent("Contents.json"))
}

for spec in specs {
    let dir = root.appendingPathComponent("\(spec.name).imageset")
    try writeContents(for: spec.name, in: dir)
    try savePNG(drawScene(spec, size: CGSize(width: 1200, height: 900)), to: dir.appendingPathComponent("\(spec.name).png"))
}
