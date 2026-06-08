import AppKit

let root = URL(fileURLWithPath: #filePath)
    .deletingLastPathComponent()
    .deletingLastPathComponent()
    .appendingPathComponent("W1Spirit/Assets.xcassets")

func color(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1) -> NSColor {
    NSColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
}

func drawMark(size: CGFloat, includeBackground: Bool) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    let rect = NSRect(x: 0, y: 0, width: size, height: size)

    if includeBackground {
        NSGradient(colors: [
            color(42, 5, 106),
            color(26, 2, 74),
            color(6, 2, 24)
        ])?.draw(in: rect, angle: -60)

        for index in 0..<8 {
            let band = NSBezierPath()
            band.move(to: CGPoint(x: -size * 0.1, y: size * (0.75 - CGFloat(index) * 0.045)))
            band.curve(
                to: CGPoint(x: size * 1.1, y: size * (0.68 - CGFloat(index) * 0.035)),
                controlPoint1: CGPoint(x: size * 0.28, y: size * (0.98 - CGFloat(index) * 0.03)),
                controlPoint2: CGPoint(x: size * 0.64, y: size * (0.42 - CGFloat(index) * 0.02))
            )
            color(index.isMultiple(of: 2) ? 53 : 255, index.isMultiple(of: 2) ? 243 : 79, index.isMultiple(of: 2) ? 255 : 216, 0.18).setStroke()
            band.lineWidth = size * 0.026
            band.stroke()
        }
    }

    let scriptFont = NSFontManager.shared.convert(NSFont.systemFont(ofSize: size * 0.30, weight: .black), toHaveTrait: .italicFontMask)
    let text = "W1" as NSString
    let shadow = NSShadow()
    shadow.shadowBlurRadius = size * 0.035
    shadow.shadowColor = color(255, 79, 216, 0.9)
    shadow.shadowOffset = .zero
    text.draw(
        at: CGPoint(x: size * 0.15, y: size * 0.46),
        withAttributes: [
            .font: scriptFont,
            .foregroundColor: color(255, 245, 255),
            .strokeColor: color(255, 79, 216),
            .strokeWidth: -3,
            .shadow: shadow
        ]
    )

    let spiritFont = NSFont.systemFont(ofSize: size * 0.105, weight: .black)
    ("SPIRIT" as NSString).draw(
        at: CGPoint(x: size * 0.48, y: size * 0.54),
        withAttributes: [.font: spiritFont, .foregroundColor: color(246, 244, 255)]
    )

    let subFont = NSFont.systemFont(ofSize: size * 0.045, weight: .bold)
    ("FOREST MOOD TRAILS" as NSString).draw(
        at: CGPoint(x: size * 0.49, y: size * 0.46),
        withAttributes: [.font: subFont, .foregroundColor: color(53, 243, 255)]
    )

    let leaf = NSBezierPath()
    let center = CGPoint(x: size * 0.53, y: size * 0.35)
    for index in 0..<8 {
        let angle = CGFloat(index) * .pi / 4
        let radius = index.isMultiple(of: 2) ? size * 0.09 : size * 0.038
        let point = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
        index == 0 ? leaf.move(to: point) : leaf.line(to: point)
    }
    leaf.close()
    color(255, 79, 216, 0.9).setFill()
    leaf.fill()

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

try savePNG(drawMark(size: 1024, includeBackground: true), to: root.appendingPathComponent("AppIcon.appiconset/W1SpiritIcon.png"))
try savePNG(drawMark(size: 256, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo.png"))
try savePNG(drawMark(size: 512, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo@2x.png"))
try savePNG(drawMark(size: 768, includeBackground: false), to: root.appendingPathComponent("BrandLogo.imageset/BrandLogo@3x.png"))
