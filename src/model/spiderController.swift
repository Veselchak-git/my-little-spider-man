import AppKit

enum SpiderMode {
    case hidden
    case entering
    case hanging
    case leaving
}

final class SpiderController {
    private(set) var mode: SpiderMode = .hidden
    private(set) var anchor: CGPoint = .zero

    /// Distance from ceiling tip down to the head center while fully hung.
    private(set) var hangLength: CGFloat = 72
    /// Extra lift that slides the whole figure up past the top of the screen.
    private(set) var ceilingPull: CGFloat = 0
    private(set) var restLength: CGFloat = 72

    /// How long the spider stays fully visible while hanging.
    var hangDuration: CFTimeInterval = 10
    /// Pause after leaving / space-switch before the next appear.
    var appearDelay: CFTimeInterval = 5

    private var hangEndsAt: CFTimeInterval = 0
    private var nextAppearAt: CFTimeInterval = 0

    private var offscreenPull: CGFloat {
        restLength + 36
    }

    /// Head position in global AppKit coords.
    var bodyPoint: CGPoint {
        CGPoint(
            x: anchor.x,
            y: anchor.y - hangLength + ceilingPull
        )
    }

    var isVisible: Bool {
        mode == .entering || mode == .hanging || mode == .leaving
    }

    /// Pose is changing (slide in/out) — needs continuous redraw.
    var isPoseAnimating: Bool {
        mode == .entering || mode == .leaving
    }

    /// Screen whose top edge currently owns the web tip.
    var currentScreen: NSScreen? {
        Self.screenCovering(x: anchor.x) ?? NSScreen.main
    }

    func configure(hangLength: CGFloat) {
        restLength = hangLength
        self.hangLength = hangLength
    }

    func applyTiming(hangDuration: CFTimeInterval, appearDelay: CFTimeInterval) {
        self.hangDuration = hangDuration
        self.appearDelay = appearDelay
        if mode == .hanging {
            hangEndsAt = CFAbsoluteTimeGetCurrent() + hangDuration
        }
    }

    /// First (or forced) appearance somewhere on a random display.
    func appearNow() {
        beginEntering(at: Self.randomCeilingPoint())
    }

    func updateAfterDisplayChange() {
        guard isVisible else { return }
        if let screen = currentScreen {
            anchor.y = screen.frame.maxY
            let frame = screen.frame
            let margin: CGFloat = 40
            anchor.x = min(max(anchor.x, frame.minX + margin), frame.maxX - margin)
        } else if let fallback = NSScreen.screens.first {
            anchor = Self.randomCeilingPoint(on: fallback)
        }
        if mode == .hanging {
            hangLength = restLength
            ceilingPull = 0
        }
    }

    func tick(dt: CGFloat) {
        let now = CFAbsoluteTimeGetCurrent()

        if isVisible, mode != .leaving, let screen = currentScreen {
            anchor.y = screen.frame.maxY
        }

        switch mode {
        case .hidden:
            if now >= nextAppearAt {
                appearNow()
            }

        case .entering:
            tickEntering(dt: dt, now: now)

        case .hanging:
            if now >= hangEndsAt {
                beginLeaving()
            }

        case .leaving:
            tickLeaving(dt: dt, now: now)
        }
    }

    /// Menu: stay put and restart the hang timer.
    func freezeInPlace() {
        guard isVisible else {
            appearNow()
            return
        }
        hangLength = restLength
        ceilingPull = 0
        mode = .hanging
        hangEndsAt = CFAbsoluteTimeGetCurrent() + hangDuration
        if let screen = currentScreen {
            anchor.y = screen.frame.maxY
        }
    }

    /// Menu: leave immediately.
    func leaveNow() {
        if mode == .hidden {
            appearNow()
            return
        }
        beginLeaving()
    }

    /// Space swipe: vanish immediately, then come back after appearDelay.
    func hideForStandardPause() {
        mode = .hidden
        hangLength = restLength
        ceilingPull = 0
        nextAppearAt = CFAbsoluteTimeGetCurrent() + appearDelay
    }

    private func beginEntering(at point: CGPoint) {
        anchor = point
        hangLength = 4
        ceilingPull = offscreenPull
        mode = .entering
        hangEndsAt = .greatestFiniteMagnitude
    }

    private func tickEntering(dt: CGFloat, now: CFTimeInterval) {
        if ceilingPull > 0 {
            ceilingPull = max(0, ceilingPull - 130 * dt)
            return
        }

        ceilingPull = 0
        hangLength = min(restLength, hangLength + 100 * dt)
        guard hangLength >= restLength else { return }

        hangLength = restLength
        mode = .hanging
        hangEndsAt = now + hangDuration
    }

    private func beginLeaving() {
        guard mode == .hanging || mode == .entering || mode == .leaving else { return }
        mode = .leaving
    }

    private func tickLeaving(dt: CGFloat, now: CFTimeInterval) {
        if hangLength > 4 {
            hangLength = max(4, hangLength - 110 * dt)
            return
        }

        hangLength = 4
        ceilingPull = min(offscreenPull, ceilingPull + 130 * dt)
        guard ceilingPull >= offscreenPull else { return }

        ceilingPull = offscreenPull
        mode = .hidden
        nextAppearAt = now + appearDelay
    }

    // MARK: - Screen helpers

    static func screenCovering(x: CGFloat) -> NSScreen? {
        let matches = NSScreen.screens.filter { screen in
            x >= screen.frame.minX && x <= screen.frame.maxX
        }
        if matches.count <= 1 {
            return matches.first
        }
        return matches.min { abs($0.frame.midX - x) < abs($1.frame.midX - x) }
    }

    static func randomCeilingPoint(on screen: NSScreen? = nil) -> CGPoint {
        let screens = NSScreen.screens
        guard !screens.isEmpty else {
            return .zero
        }

        let chosen = screen ?? screens.randomElement()!
        let margin: CGFloat = 48
        let minX = chosen.frame.minX + margin
        let maxX = chosen.frame.maxX - margin
        let x: CGFloat
        if maxX > minX {
            x = CGFloat.random(in: minX...maxX)
        } else {
            x = chosen.frame.midX
        }
        return CGPoint(x: x, y: chosen.frame.maxY)
    }
}
