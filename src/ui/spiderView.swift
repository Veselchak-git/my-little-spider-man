import AppKit

/// Compact upside-down chibi with soft shadows, volume shading, and real fabric hoods.
final class SpiderView: NSView {
    var webAnchorInView: CGPoint = .zero
    var bodyPointInView: CGPoint = .zero
    var hangLength: CGFloat = 72
    var restHangLength: CGFloat = 72
    var ceilingPull: CGFloat = 0
    /// Silk strand length in points (fully extended).
    var silkLength: CGFloat = 56 {
        didSet { needsDisplay = true }
    }
    /// Chibi figure scale (1 = default).
    var figureScale: CGFloat = 1 {
        didSet { needsDisplay = true }
    }
    var skin: SpiderSkin = SpiderSkin.skin(for: .miles) {
        didSet { needsDisplay = true }
    }
    var webStyleID: WebStyleID = .classic {
        didSet { needsDisplay = true }
    }

    /// When false, eyes stay on the standard/neutral expression.
    var emotionsEnabled: Bool = true {
        didSet {
            if !emotionsEnabled {
                emotionFrom = .neutral
                emotionTo = .neutral
                emotionBlend = 1
                emotionCooldown = 0
                needsDisplay = true
            }
        }
    }

    /// Seconds between random emotion picks.
    var emotionInterval: CGFloat = 8

    var eyeOpenness: CGFloat = 1

    var blinkCooldown: CGFloat = CGFloat.random(in: 1.8...3.6)
    var blinkPhase: BlinkPhase = .idle
    var blinkTime: CGFloat = 0

    enum BlinkPhase {
        case idle, closing, closed, opening, doubleWait
    }

    enum EyeEmotion: CaseIterable {
        case neutral
        case surprise
        case anger
    }

    var emotionFrom: EyeEmotion = .neutral
    var emotionTo: EyeEmotion = .neutral
    var emotionBlend: CGFloat = 1
    var emotionCooldown: CGFloat = CGFloat.random(in: 2.0...5.0)
    let emotionTransitionDuration: CGFloat = 0.28
    /// For surprise: `true` = left eye opens wider (right squints); flips each beat.
    var surpriseLeftEyeOpens: Bool = Bool.random()

    override var isOpaque: Bool { false }
    override var wantsDefaultClipping: Bool { false }

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.backgroundColor = NSColor.clear.cgColor
        layer?.masksToBounds = false
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Distance from ceiling tip to head center when fully hung.
    var spriteHangLength: CGFloat {
        // Silk tip → wrapped feet → torso → head (head hangs lowest).
        silkLength + 26 * figureScale
    }

    override func draw(_ dirtyRect: NSRect) {
        guard let context = NSGraphicsContext.current?.cgContext else { return }
        context.clear(bounds)

        context.saveGState()
        context.translateBy(x: webAnchorInView.x, y: webAnchorInView.y + ceilingPull)

        let reveal = restHangLength > 1 ? max(0.05, min(1, hangLength / restHangLength)) : 1
        drawWebStrand(in: context, reveal: reveal)
        drawFigure(in: context, reveal: reveal)

        context.restoreGState()
    }


    private func drawFigure(in context: CGContext, reveal: CGFloat) {
        // Local space after translate: (0,0) = silk tip.
        // +Y = up the strand toward the ceiling; -Y = head hanging down.
        let tipY = -silkLength * reveal
        let headRadius: CGFloat = 9.8
        // Legs wrap the tip; torso hangs below; head lowest.
        // +Y = up the silk. Feet sit a bit above the hand grip.
        let footY: CGFloat = 6.0
        let handGripY: CGFloat = 2.8
        let hipY: CGFloat = -3.2
        let torsoCenterY: CGFloat = -8.2
        let headCenterY: CGFloat = -18.2

        context.saveGState()
        context.translateBy(x: 0, y: tipY)
        context.scaleBy(x: figureScale, y: figureScale)

        drawSpriteShadow(
            in: context,
            feetY: footY,
            torsoCenterY: torsoCenterY,
            headCenterY: headCenterY,
            headRadius: headRadius
        )

        // Back layer: legs wrap the silk above the hands.
        drawLegsOnWeb(in: context, tipY: footY, hipY: hipY)

        if skin.hasHood {
            drawHoodBack(in: context, centerY: headCenterY, radius: headRadius)
        }

        drawBody(in: context, torsoCenterY: torsoCenterY)
        drawHead(in: context, centerY: headCenterY, radius: headRadius)

        if skin.hasHood {
            drawHoodFront(in: context, centerY: headCenterY, radius: headRadius)
        }

        // Front layer: arms + hands below the feet on the strand.
        drawArmsHoldingWeb(in: context, shoulderY: torsoCenterY + 2.5, handY: handGripY)
        drawHandsOnWeb(in: context, handY: handGripY)

        context.restoreGState()
    }


}
