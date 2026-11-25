import AppKit

final class SpiderPanel: NSPanel {
    let spiderView = SpiderView(frame: .zero)

    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 160, height: 140),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        backgroundColor = .clear
        hasShadow = false
        level = .statusBar
        isFloatingPanel = true
        // Follow the active Space so a swipe naturally takes the spider with it;
        // AppDelegate then hides and reschedules an appear after the usual pause.
        collectionBehavior = [
            .moveToActiveSpace,
            .fullScreenAuxiliary,
            .ignoresCycle
        ]
        isMovableByWindowBackground = false
        hidesOnDeactivate = false
        becomesKeyOnlyIfNeeded = true
        ignoresMouseEvents = true
        animationBehavior = .none

        contentView = spiderView
    }

    override var canBecomeKey: Bool { false }
    override var canBecomeMain: Bool { false }

    /// Allow the panel to sit under / over the menu bar at the true top of the display.
    override func constrainFrameRect(_ frameRect: NSRect, to screen: NSScreen?) -> NSRect {
        frameRect
    }
}
