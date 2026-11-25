import AppKit

struct SpiderSkin {
    enum Style {
        case miles
        case advanced
        case prowler
        case tech
        case crimson
        case uptown
        case programmable
        case future
        case hoodie
        case classic
    }

    /// Per-suit eye / lens silhouette matching the real costume.
    enum LensStyle {
        case miles       // Miles Classic: large pointed bug-eye almonds
        case advanced    // Advanced Suit: sleeker raised mechanical lenses
        case prowler     // Purple Reign: small rounded lenses, lime glow
        case led         // 2020 Suit: LED-matrix classic eye shape on helmet
        case crimson     // Crimson Cowl: large soft whites under the hood
        case gold        // Uptown Pride: large whites with thick gold rim
        case crystal     // Programmable Matter: red polygonal glowing lenses
        case slit2099    // Spider-Man 2099: long angular wraparound whites
        case hoodie      // Street Hoodie: Miles almonds under the hood
        case comic       // Classic Peter: biggest round comic-book lenses
    }

    var style: Style
    var lensStyle: LensStyle
    var head: NSColor
    var body: NSColor
    var accent: NSColor
    var secondary: NSColor
    var feet: NSColor
    var emblem: NSColor
    var lensFill: NSColor
    var lensRim: NSColor
    var lensGlow: NSColor?
    var headStroke: NSColor
    var webLine: NSColor
    var webLineWidth: CGFloat
    var largeEmblem: Bool
    var hasHood: Bool
    var hasHoodie: Bool

    static func skin(for id: SpiderSkinID) -> SpiderSkin {
        switch id {
        case .miles:
            return SpiderSkin(
                style: .miles,
                lensStyle: .miles,
                head: c(0.04, 0.04, 0.06),
                body: c(0.05, 0.05, 0.07),
                accent: c(0.62, 0.04, 0.10),
                secondary: c(0.16, 0.16, 0.20),
                feet: c(0.04, 0.04, 0.06),
                emblem: c(0.68, 0.05, 0.11),
                lensFill: w(0.97),
                lensRim: c(0.02, 0.02, 0.03),
                lensGlow: nil,
                headStroke: c(0.62, 0.04, 0.10, 0.30),
                webLine: c(0.58, 0.04, 0.10, 0.95),
                webLineWidth: 0.72,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .advanced:
            return SpiderSkin(
                style: .advanced,
                lensStyle: .advanced,
                head: c(0.16, 0.17, 0.20),
                body: c(0.20, 0.21, 0.24),
                accent: c(0.95, 0.12, 0.18),
                secondary: c(0.38, 0.40, 0.44),
                feet: c(0.14, 0.15, 0.18),
                emblem: c(0.95, 0.12, 0.18),
                lensFill: w(0.98),
                lensRim: c(0.08, 0.08, 0.10),
                lensGlow: nil,
                headStroke: c(0.95, 0.12, 0.18, 0.25),
                webLine: c(0.55, 0.56, 0.58, 0.45),
                webLineWidth: 0.55,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .prowler:
            // Purple Reign: small white lenses with lime glow (not big Miles eyes).
            return SpiderSkin(
                style: .prowler,
                lensStyle: .prowler,
                head: c(0.12, 0.04, 0.22),
                body: c(0.08, 0.03, 0.14),
                accent: c(0.55, 1.0, 0.22),
                secondary: c(0.42, 0.14, 0.62),
                feet: c(0.10, 0.03, 0.18),
                emblem: c(0.55, 1.0, 0.22),
                lensFill: c(0.85, 1.0, 0.75),
                lensRim: c(0.25, 0.55, 0.10),
                lensGlow: c(0.55, 1.0, 0.22, 0.55),
                headStroke: c(0.55, 1.0, 0.22, 0.50),
                webLine: c(0.55, 1.0, 0.22, 0.80),
                webLineWidth: 0.70,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .tech:
            // 2020 Rahzzah: helmet LED display of classic Spidey eyes (white pixels).
            return SpiderSkin(
                style: .tech,
                lensStyle: .led,
                head: c(0.07, 0.07, 0.09),
                body: c(0.10, 0.10, 0.12),
                accent: c(0.90, 0.10, 0.16),
                secondary: c(0.22, 0.22, 0.26),
                feet: c(0.06, 0.06, 0.08),
                emblem: c(0.95, 0.14, 0.18),
                lensFill: c(0.92, 0.96, 1.0),
                lensRim: c(0.04, 0.05, 0.07),
                lensGlow: c(0.55, 0.85, 1.0, 0.55),
                headStroke: c(0.90, 0.10, 0.16, 0.35),
                webLine: c(0.90, 0.10, 0.16, 0.75),
                webLineWidth: 0.62,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .crimson:
            return SpiderSkin(
                style: .crimson,
                lensStyle: .crimson,
                head: c(0.42, 0.05, 0.08),
                body: c(0.08, 0.05, 0.07),
                accent: c(0.72, 0.08, 0.12),
                secondary: c(0.28, 0.04, 0.06),
                feet: c(0.08, 0.05, 0.07),
                emblem: c(0.85, 0.12, 0.14),
                lensFill: w(0.96),
                lensRim: c(0.18, 0.03, 0.05),
                lensGlow: nil,
                headStroke: c(0.72, 0.08, 0.12, 0.50),
                webLine: c(0.55, 0.06, 0.10, 0.75),
                webLineWidth: 0.58,
                largeEmblem: true,
                hasHood: true,
                hasHoodie: false
            )

        case .uptown:
            return SpiderSkin(
                style: .uptown,
                lensStyle: .gold,
                head: c(0.05, 0.05, 0.06),
                body: c(0.06, 0.06, 0.07),
                accent: c(0.92, 0.72, 0.18),
                secondary: c(0.55, 0.38, 0.08),
                feet: c(0.05, 0.05, 0.06),
                emblem: c(0.95, 0.78, 0.22),
                lensFill: w(0.97),
                lensRim: c(0.78, 0.58, 0.12),
                lensGlow: c(0.95, 0.80, 0.25, 0.25),
                headStroke: c(0.92, 0.72, 0.18, 0.40),
                webLine: c(0.92, 0.72, 0.18, 0.92),
                webLineWidth: 0.70,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .programmable:
            // Programmable Matter: red-glow polygonal lenses with web lines.
            return SpiderSkin(
                style: .programmable,
                lensStyle: .crystal,
                head: c(0.04, 0.04, 0.05),
                body: c(0.06, 0.06, 0.08),
                accent: c(0.98, 0.14, 0.18),
                secondary: c(0.16, 0.16, 0.20),
                feet: c(0.04, 0.04, 0.05),
                emblem: c(0.98, 0.14, 0.18),
                lensFill: c(1.0, 0.45, 0.42),
                lensRim: c(0.40, 0.04, 0.06),
                lensGlow: c(1.0, 0.22, 0.18, 0.60),
                headStroke: c(0.98, 0.14, 0.18, 0.35),
                webLine: c(0.98, 0.14, 0.18, 0.90),
                webLineWidth: 0.70,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .future:
            // 2099: black suit, sharp scarlet armor fins, white wraparound lenses.
            return SpiderSkin(
                style: .future,
                lensStyle: .slit2099,
                head: c(0.05, 0.05, 0.06),
                body: c(0.04, 0.04, 0.05),
                accent: c(0.88, 0.07, 0.12),
                secondary: c(0.14, 0.03, 0.05),
                feet: c(0.05, 0.05, 0.06),
                emblem: c(0.92, 0.10, 0.14),
                lensFill: w(0.98),
                lensRim: c(0.88, 0.07, 0.12),
                lensGlow: nil,
                headStroke: c(0.88, 0.07, 0.12, 0.40),
                webLine: c(0.88, 0.07, 0.12, 0.70),
                webLineWidth: 0.65,
                largeEmblem: true,
                hasHood: false,
                hasHoodie: false
            )

        case .hoodie:
            return SpiderSkin(
                style: .hoodie,
                lensStyle: .hoodie,
                head: c(0.04, 0.04, 0.06),
                body: c(0.72, 0.08, 0.12),
                accent: c(0.92, 0.10, 0.16),
                secondary: c(0.08, 0.08, 0.10),
                feet: c(0.04, 0.04, 0.06),
                emblem: c(0.05, 0.05, 0.07),
                lensFill: w(0.97),
                lensRim: c(0.02, 0.02, 0.03),
                lensGlow: nil,
                headStroke: c(0.92, 0.10, 0.16, 0.30),
                webLine: c(0.92, 0.10, 0.16, 0.90),
                webLineWidth: 0.68,
                largeEmblem: true,
                hasHood: true,
                hasHoodie: true
            )

        case .classic:
            return SpiderSkin(
                style: .classic,
                lensStyle: .comic,
                head: c(0.88, 0.12, 0.14),
                body: c(0.12, 0.28, 0.72),
                accent: c(0.88, 0.12, 0.14),
                secondary: c(0.06, 0.14, 0.42),
                feet: c(0.88, 0.12, 0.14),
                emblem: c(0.04, 0.04, 0.06),
                lensFill: w(0.99),
                lensRim: c(0.05, 0.05, 0.07),
                lensGlow: nil,
                headStroke: c(0.40, 0.04, 0.06, 0.40),
                webLine: c(0.05, 0.04, 0.06, 0.82),
                webLineWidth: 0.52,
                largeEmblem: false,
                hasHood: false,
                hasHoodie: false
            )
        }
    }

    private static func c(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat, _ a: CGFloat = 1) -> NSColor {
        NSColor(calibratedRed: r, green: g, blue: b, alpha: a)
    }

    private static func w(_ v: CGFloat, _ a: CGFloat = 1) -> NSColor {
        NSColor(calibratedWhite: v, alpha: a)
    }
}
