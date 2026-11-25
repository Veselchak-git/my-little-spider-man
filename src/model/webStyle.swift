import AppKit

enum WebStyleID: String, CaseIterable, Identifiable {
    case classic
    case silk
    case twisted
    case glow
    case venom

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .classic: return "web.classic"
        case .silk: return "web.silk"
        case .twisted: return "web.twisted"
        case .glow: return "web.glow"
        case .venom: return "web.venom"
        }
    }

    var title: String { L10n.tr(titleKey) }
}

/// Drawing parameters for the hanging silk strand.
/// Geometry matches the Twisted look for every style; only colors differ.
struct WebStyle {
    var coreColor: NSColor
    var coreWidth: CGFloat
    var glowColor: NSColor
    var glowWidth: CGFloat
    var secondaryColor: NSColor
    var secondaryWidth: CGFloat
    var highlightColor: NSColor?
    var tipColor: NSColor
    var tipAccent: NSColor?
    var tipRadius: CGFloat
    var twistAmplitude: CGFloat
    var twistCycles: CGFloat

    /// Shared twisted-strand silhouette.
    private static let sharedAmplitude: CGFloat = 1.35
    private static let sharedCycles: CGFloat = 5
    private static let sharedCoreWidth: CGFloat = 1.35
    private static let sharedSecondaryWidth: CGFloat = 1.0
    private static let sharedGlowWidth: CGFloat = 3.6
    private static let sharedTipRadius: CGFloat = 2.4

    static func style(for id: WebStyleID) -> WebStyle {
        switch id {
        case .classic:
            // Soft white / cool-blue mist.
            return WebStyle(
                coreColor: NSColor(calibratedWhite: 0.96, alpha: 0.94),
                coreWidth: sharedCoreWidth,
                glowColor: NSColor(calibratedRed: 0.72, green: 0.86, blue: 1.0, alpha: 0.22),
                glowWidth: sharedGlowWidth,
                secondaryColor: NSColor(calibratedWhite: 0.88, alpha: 0.72),
                secondaryWidth: sharedSecondaryWidth,
                highlightColor: NSColor(calibratedWhite: 1, alpha: 0.45),
                tipColor: NSColor(calibratedWhite: 0.98, alpha: 0.96),
                tipAccent: nil,
                tipRadius: sharedTipRadius,
                twistAmplitude: sharedAmplitude,
                twistCycles: sharedCycles
            )

        case .silk:
            // Warm ivory with pearly sheen.
            return WebStyle(
                coreColor: NSColor(calibratedRed: 1.0, green: 0.97, blue: 0.90, alpha: 0.96),
                coreWidth: sharedCoreWidth,
                glowColor: NSColor(calibratedRed: 1.0, green: 0.92, blue: 0.75, alpha: 0.20),
                glowWidth: sharedGlowWidth,
                secondaryColor: NSColor(calibratedRed: 0.95, green: 0.88, blue: 0.72, alpha: 0.70),
                secondaryWidth: sharedSecondaryWidth,
                highlightColor: NSColor(calibratedWhite: 1, alpha: 0.55),
                tipColor: NSColor(calibratedRed: 1.0, green: 0.98, blue: 0.92, alpha: 0.98),
                tipAccent: nil,
                tipRadius: sharedTipRadius,
                twistAmplitude: sharedAmplitude,
                twistCycles: sharedCycles
            )

        case .twisted:
            // Neutral silver-grey (the reference look).
            return WebStyle(
                coreColor: NSColor(calibratedWhite: 0.94, alpha: 0.92),
                coreWidth: sharedCoreWidth,
                glowColor: NSColor(calibratedWhite: 0.75, alpha: 0.16),
                glowWidth: sharedGlowWidth,
                secondaryColor: NSColor(calibratedWhite: 0.82, alpha: 0.70),
                secondaryWidth: sharedSecondaryWidth,
                highlightColor: nil,
                tipColor: NSColor(calibratedWhite: 0.95, alpha: 0.95),
                tipAccent: nil,
                tipRadius: sharedTipRadius,
                twistAmplitude: sharedAmplitude,
                twistCycles: sharedCycles
            )

        case .glow:
            // Cyan / electric blue.
            return WebStyle(
                coreColor: NSColor(calibratedWhite: 1, alpha: 0.98),
                coreWidth: sharedCoreWidth,
                glowColor: NSColor(calibratedRed: 0.25, green: 0.85, blue: 1.0, alpha: 0.48),
                glowWidth: sharedGlowWidth + 1.4,
                secondaryColor: NSColor(calibratedRed: 0.45, green: 0.92, blue: 1.0, alpha: 0.65),
                secondaryWidth: sharedSecondaryWidth,
                highlightColor: NSColor(calibratedRed: 0.80, green: 0.98, blue: 1.0, alpha: 0.70),
                tipColor: NSColor(calibratedWhite: 1, alpha: 1),
                tipAccent: NSColor(calibratedRed: 0.40, green: 0.90, blue: 1.0, alpha: 0.85),
                tipRadius: sharedTipRadius,
                twistAmplitude: sharedAmplitude,
                twistCycles: sharedCycles
            )

        case .venom:
            // Black with crimson secondary.
            return WebStyle(
                coreColor: NSColor(calibratedRed: 0.12, green: 0.03, blue: 0.05, alpha: 0.96),
                coreWidth: sharedCoreWidth,
                glowColor: NSColor(calibratedRed: 0.50, green: 0.04, blue: 0.10, alpha: 0.38),
                glowWidth: sharedGlowWidth + 0.6,
                secondaryColor: NSColor(calibratedRed: 0.78, green: 0.08, blue: 0.14, alpha: 0.78),
                secondaryWidth: sharedSecondaryWidth,
                highlightColor: NSColor(calibratedRed: 0.95, green: 0.20, blue: 0.25, alpha: 0.40),
                tipColor: NSColor(calibratedRed: 0.16, green: 0.04, blue: 0.06, alpha: 0.98),
                tipAccent: NSColor(calibratedRed: 0.90, green: 0.12, blue: 0.16, alpha: 0.90),
                tipRadius: sharedTipRadius,
                twistAmplitude: sharedAmplitude,
                twistCycles: sharedCycles
            )
        }
    }
}
