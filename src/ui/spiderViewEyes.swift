import AppKit

extension SpiderView {
    /// Returns `true` when blink/emotion changed the drawable eye state.
    @discardableResult
    func tickEyes(dt: CGFloat) -> Bool {
        let blinkDirty = tickBlink(dt: dt)
        let emotionDirty = tickEmotion(dt: dt)
        return blinkDirty || emotionDirty
    }

    /// Eyes are mid-animation (blink or emotion transition) — keep a higher tick rate.
    var eyesNeedHighFPS: Bool {
        blinkPhase != .idle || emotionBlend < 1
    }

    func tickBlink(dt: CGFloat) -> Bool {
        switch blinkPhase {
        case .idle:
            blinkCooldown -= dt
            if blinkCooldown <= 0 {
                blinkPhase = .closing
                blinkTime = 0
                return true
            }
            return false
        case .closing:
            blinkTime += dt
            let t = min(1, blinkTime / 0.045)
            eyeOpenness = 1 - t
            if t >= 1 { blinkPhase = .closed; blinkTime = 0 }
            return true
        case .closed:
            blinkTime += dt
            eyeOpenness = 0.06
            if blinkTime >= 0.05 { blinkPhase = .opening; blinkTime = 0 }
            return true
        case .opening:
            blinkTime += dt
            let t = min(1, blinkTime / 0.07)
            eyeOpenness = 0.06 + 0.94 * t
            if t >= 1 {
                eyeOpenness = 1
                if Int.random(in: 0...3) == 0 {
                    blinkPhase = .doubleWait
                    blinkTime = 0
                } else {
                    blinkPhase = .idle
                    blinkCooldown = CGFloat.random(in: 2.2...5.5)
                }
            }
            return true
        case .doubleWait:
            blinkTime += dt
            eyeOpenness = 1
            if blinkTime >= 0.12 { blinkPhase = .closing; blinkTime = 0 }
            return true
        }
    }

    func tickEmotion(dt: CGFloat) -> Bool {
        guard emotionsEnabled else {
            if emotionTo != .neutral || emotionFrom != .neutral {
                emotionFrom = .neutral
                emotionTo = .neutral
                emotionBlend = 1
                return true
            }
            return false
        }

        var dirty = false
        if emotionBlend < 1 {
            emotionBlend = min(1, emotionBlend + dt / emotionTransitionDuration)
            dirty = true
        }

        emotionCooldown -= dt
        if emotionCooldown <= 0 {
            pickNextEmotion()
            dirty = true
        }
        return dirty
    }

    func pickNextEmotion() {
        let next: EyeEmotion
        if emotionTo == .neutral {
            next = Bool.random() ? .surprise : .anger
        } else {
            next = Int.random(in: 0...2) == 0 ? (Bool.random() ? .surprise : .anger) : .neutral
        }

        emotionFrom = emotionTo
        emotionTo = next
        emotionBlend = 0
        if next == .surprise {
            surpriseLeftEyeOpens = Bool.random()
        }

        let base = max(3, emotionInterval)
        let jitter = base * CGFloat.random(in: 0.75...1.25)
        emotionCooldown = next == .neutral ? jitter : max(1.2, jitter * 0.55)
    }

    struct EmotionPose {
        var widthMul: CGFloat
        var heightMul: CGFloat
        var tiltAdd: CGFloat
        var anger: CGFloat
        var surprise: CGFloat
    }

    func pose(for emotion: EyeEmotion) -> EmotionPose {
        switch emotion {
        case .neutral:
            return EmotionPose(widthMul: 1, heightMul: 1, tiltAdd: 0, anger: 0, surprise: 0)
        case .surprise:
            // Asymmetry (open vs squint) applied per-eye in drawLens.
            return EmotionPose(widthMul: 1.02, heightMul: 1.0, tiltAdd: -0.02, anger: 0, surprise: 1)
        case .anger:
            return EmotionPose(widthMul: 1.06, heightMul: 0.46, tiltAdd: 0.20, anger: 1, surprise: 0)
        }
    }

    func currentEmotionPose() -> EmotionPose {
        let a = pose(for: emotionFrom)
        let b = pose(for: emotionTo)
        let t = emotionBlend
        return EmotionPose(
            widthMul: a.widthMul + (b.widthMul - a.widthMul) * t,
            heightMul: a.heightMul + (b.heightMul - a.heightMul) * t,
            tiltAdd: a.tiltAdd + (b.tiltAdd - a.tiltAdd) * t,
            anger: a.anger + (b.anger - a.anger) * t,
            surprise: a.surprise + (b.surprise - a.surprise) * t
        )
    }

    /// Surprise: one eye opens a bit, the other squints a bit.
    func surpriseHeightMul(facingLeft: Bool, surprise: CGFloat) -> CGFloat {
        guard surprise > 0.001 else { return 1 }
        let thisOpens = facingLeft ? surpriseLeftEyeOpens : !surpriseLeftEyeOpens
        let open: CGFloat = 1.38
        let squint: CGFloat = 0.58
        let target = thisOpens ? open : squint
        return 1 + (target - 1) * surprise
    }


    func drawLens(in context: CGContext, center: CGPoint, facingLeft: Bool) {
        let openness = max(0.08, eyeOpenness)
        let dir: CGFloat = facingLeft ? -1 : 1
        let emotion = currentEmotionPose()
        let surpriseH = surpriseHeightMul(facingLeft: facingLeft, surprise: emotion.surprise)
        var spec = lensSpec(for: skin.lensStyle, openness: openness)
        spec.width *= emotion.widthMul
        spec.height *= emotion.heightMul * surpriseH
        spec.tilt += emotion.tiltAdd
        // Squinting eye tilts a little; open eye stays flatter.
        if emotion.surprise > 0.001 {
            let thisOpens = facingLeft ? surpriseLeftEyeOpens : !surpriseLeftEyeOpens
            spec.tilt += thisOpens ? -0.03 * emotion.surprise : 0.06 * emotion.surprise
        }

        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: 1, y: -1)
        context.rotate(by: dir * spec.tilt)

        if let glow = skin.lensGlow {
            context.setShadow(offset: .zero, blur: spec.glowBlur, color: glow.cgColor)
        } else {
            context.setShadow(
                offset: CGSize(width: 0, height: -0.35),
                blur: 0.75,
                color: NSColor.black.withAlphaComponent(0.38).cgColor
            )
        }

        let rimW = spec.width + spec.rimPad
        let rimH = spec.height + spec.rimPad * 0.85
        context.addPath(lensPath(style: skin.lensStyle, width: rimW, height: rimH, dir: dir))
        context.setFillColor(skin.lensRim.cgColor)
        context.fillPath()

        context.setShadow(offset: .zero, blur: 0, color: nil)

        context.addPath(lensPath(style: skin.lensStyle, width: spec.width, height: spec.height, dir: dir))
        context.setFillColor(skin.lensFill.cgColor)
        context.fillPath()

        switch skin.lensStyle {
        case .led:
            drawLEDScan(in: context, width: spec.width, height: spec.height, dir: dir)
        case .crystal:
            drawProgrammableWeb(in: context, width: spec.width, height: spec.height, dir: dir)
        case .advanced:
            context.setStrokeColor(NSColor(calibratedWhite: 0.55, alpha: 0.30).cgColor)
            context.setLineWidth(0.5)
            context.addPath(lensPath(style: .advanced, width: spec.width * 0.78, height: spec.height * 0.62, dir: dir))
            context.strokePath()
        default:
            break
        }

        if eyeOpenness > 0.35 {
            drawLensHighlight(in: context, style: skin.lensStyle, width: spec.width, height: spec.height, dir: dir)
        }

        // Angry brow slash above the lens.
        if emotion.anger > 0.08 {
            context.setStrokeColor(skin.lensRim.withAlphaComponent(0.55 + 0.35 * emotion.anger).cgColor)
            context.setLineWidth(1.0 + 0.4 * emotion.anger)
            context.setLineCap(.round)
            let y = spec.height * 0.55 + 1.2
            context.move(to: CGPoint(x: -dir * spec.width * 0.35, y: y + 0.8 * emotion.anger))
            context.addLine(to: CGPoint(x: dir * spec.width * 0.40, y: y - 1.4 * emotion.anger))
            context.strokePath()
        }

        context.restoreGState()
    }

    struct LensSpec {
        var width: CGFloat
        var height: CGFloat
        var rimPad: CGFloat
        var tilt: CGFloat
        var glowBlur: CGFloat
    }

    func lensSpec(for style: SpiderSkin.LensStyle, openness: CGFloat) -> LensSpec {
        switch style {
        case .miles, .hoodie, .comic:
            // Original soft-almond Miles/Classic lenses.
            return LensSpec(width: 6.8, height: 5.25 * openness, rimPad: 1.30, tilt: 0.10, glowBlur: 0)
        case .advanced:
            return LensSpec(width: 6.4, height: 4.2 * openness, rimPad: 0.95, tilt: 0.07, glowBlur: 0)
        case .prowler:
            return LensSpec(width: 4.4, height: 3.6 * openness, rimPad: 1.00, tilt: 0.08, glowBlur: 2.8)
        case .led:
            return LensSpec(width: 6.4, height: 4.8 * openness, rimPad: 1.10, tilt: 0.09, glowBlur: 3.4)
        case .crimson:
            return LensSpec(width: 6.2, height: 5.0 * openness, rimPad: 1.20, tilt: 0.10, glowBlur: 0)
        case .gold:
            return LensSpec(width: 6.8, height: 5.2 * openness, rimPad: 2.20, tilt: 0.12, glowBlur: 1.6)
        case .crystal:
            return LensSpec(width: 6.2, height: 4.8 * openness, rimPad: 1.10, tilt: 0.14, glowBlur: 2.6)
        case .slit2099:
            return LensSpec(width: 9.6, height: 3.6 * openness, rimPad: 1.20, tilt: 0.26, glowBlur: 0)
        }
    }

    func drawLensHighlight(
        in context: CGContext,
        style: SpiderSkin.LensStyle,
        width: CGFloat,
        height: CGFloat,
        dir: CGFloat
    ) {
        let alpha: CGFloat
        switch style {
        case .led: alpha = 0.60
        case .prowler: alpha = 0.40
        case .crystal: alpha = 0.35
        default: alpha = 0.42
        }

        context.setFillColor(NSColor(calibratedWhite: 1, alpha: alpha).cgColor)
        switch style {
        case .slit2099:
            context.fillEllipse(in: CGRect(x: dir * width * 0.05 - 1.5, y: height * 0.02, width: 2.8, height: 1.0))
        case .led:
            context.fillEllipse(in: CGRect(x: -width * 0.10, y: height * 0.08, width: width * 0.28, height: height * 0.22))
        case .prowler:
            context.setFillColor(NSColor(calibratedRed: 0.80, green: 1.0, blue: 0.60, alpha: 0.40).cgColor)
            context.fillEllipse(in: CGRect(x: -0.7, y: height * 0.06, width: 1.4, height: 0.95))
        default:
            context.fillEllipse(in: CGRect(x: dir * width * 0.02 - 1.15, y: height * 0.08, width: 2.3, height: 1.35))
        }
    }

    /// Fine scanlines on the classic eye silhouette (2020 helmet LED).
    func drawLEDScan(in context: CGContext, width: CGFloat, height: CGFloat, dir: CGFloat) {
        context.saveGState()
        context.addPath(lensPath(style: .led, width: width, height: height, dir: dir))
        context.clip()
        context.setStrokeColor(NSColor(calibratedRed: 0.45, green: 0.75, blue: 1.0, alpha: 0.40).cgColor)
        context.setLineWidth(0.35)
        var y = -height * 0.42
        while y < height * 0.42 {
            context.move(to: CGPoint(x: -width * 0.45, y: y))
            context.addLine(to: CGPoint(x: width * 0.45, y: y))
            context.strokePath()
            y += 0.85
        }
        context.restoreGState()
    }

    func drawProgrammableWeb(in context: CGContext, width: CGFloat, height: CGFloat, dir: CGFloat) {
        context.saveGState()
        context.addPath(lensPath(style: .crystal, width: width, height: height, dir: dir))
        context.clip()
        context.setStrokeColor(NSColor(calibratedWhite: 1, alpha: 0.50).cgColor)
        context.setLineWidth(0.5)
        context.move(to: CGPoint(x: 0, y: height * 0.42))
        context.addLine(to: CGPoint(x: 0, y: -height * 0.42))
        context.move(to: CGPoint(x: -width * 0.32, y: height * 0.18))
        context.addLine(to: CGPoint(x: width * 0.32, y: -height * 0.18))
        context.move(to: CGPoint(x: width * 0.32, y: height * 0.18))
        context.addLine(to: CGPoint(x: -width * 0.32, y: -height * 0.18))
        context.strokePath()
        context.restoreGState()
    }

    /// Real Spidey lens silhouettes — each suit has its own proportions and corner language.
    func lensPath(style: SpiderSkin.LensStyle, width: CGFloat, height: CGFloat, dir: CGFloat) -> CGMutablePath {
        let path = CGMutablePath()

        switch style {
        case .miles, .hoodie, .comic:
            // Original soft almond (pre-redesign Miles/Classic).
            classicSoftAlmond(path: path, width: width, height: height, dir: dir)

        case .gold:
            pointedSpideyEye(path: path, width: width, height: height, dir: dir, tipSharpness: 0.85)

        case .advanced:
            pointedSpideyEye(path: path, width: width, height: height, dir: dir, tipSharpness: 0.55, flatness: 0.22)

        case .prowler:
            pointedSpideyEye(path: path, width: width, height: height, dir: dir, tipSharpness: 0.45, flatness: 0.10)

        case .led:
            pointedSpideyEye(path: path, width: width, height: height, dir: dir, tipSharpness: 0.80)

        case .crimson:
            pointedSpideyEye(path: path, width: width, height: height, dir: dir, tipSharpness: 0.70)

        case .crystal:
            path.move(to: CGPoint(x: dir * width * 0.52, y: height * 0.02))
            path.addLine(to: CGPoint(x: dir * width * 0.10, y: height * 0.48))
            path.addLine(to: CGPoint(x: -dir * width * 0.20, y: height * 0.36))
            path.addLine(to: CGPoint(x: -dir * width * 0.46, y: 0))
            path.addLine(to: CGPoint(x: -dir * width * 0.10, y: -height * 0.48))
            path.addLine(to: CGPoint(x: dir * width * 0.18, y: -height * 0.34))
            path.closeSubpath()

        case .slit2099:
            path.move(to: CGPoint(x: dir * width * 0.56, y: height * 0.04))
            path.addLine(to: CGPoint(x: dir * width * 0.16, y: height * 0.48))
            path.addQuadCurve(
                to: CGPoint(x: -dir * width * 0.28, y: height * 0.20),
                control: CGPoint(x: -dir * width * 0.02, y: height * 0.46)
            )
            path.addLine(to: CGPoint(x: -dir * width * 0.48, y: 0))
            path.addQuadCurve(
                to: CGPoint(x: -dir * width * 0.06, y: -height * 0.48),
                control: CGPoint(x: -dir * width * 0.36, y: -height * 0.40)
            )
            path.addLine(to: CGPoint(x: dir * width * 0.26, y: -height * 0.26))
            path.closeSubpath()
        }

        return path
    }

    func classicSoftAlmond(path: CGMutablePath, width: CGFloat, height: CGFloat, dir: CGFloat) {
        let outer = CGPoint(x: dir * width * 0.48, y: height * 0.05)
        let top = CGPoint(x: -dir * width * 0.05, y: height * 0.48)
        let inner = CGPoint(x: -dir * width * 0.42, y: -height * 0.05)
        let bottom = CGPoint(x: dir * width * 0.08, y: -height * 0.48)
        path.move(to: outer)
        path.addQuadCurve(to: top, control: CGPoint(x: dir * width * 0.55, y: height * 0.55))
        path.addQuadCurve(to: inner, control: CGPoint(x: -dir * width * 0.55, y: height * 0.25))
        path.addQuadCurve(to: bottom, control: CGPoint(x: -dir * width * 0.35, y: -height * 0.55))
        path.addQuadCurve(to: outer, control: CGPoint(x: dir * width * 0.45, y: -height * 0.45))
        path.closeSubpath()
    }

    func pointedSpideyEye(
        path: CGMutablePath,
        width: CGFloat,
        height: CGFloat,
        dir: CGFloat,
        tipSharpness: CGFloat,
        flatness: CGFloat = 0
    ) {
        let tipX = 0.42 + 0.16 * tipSharpness
        let tipY = 0.08 + 0.10 * tipSharpness
        let topH = max(0.36, 0.50 - flatness)
        let botH = max(0.36, 0.48 - flatness * 0.6)
        let innerX = 0.40 + 0.04 * (1 - tipSharpness)

        let tip = CGPoint(x: dir * width * tipX, y: height * tipY)
        let top = CGPoint(x: -dir * width * 0.02, y: height * topH)
        let inn = CGPoint(x: -dir * width * innerX, y: -height * 0.02)
        let bot = CGPoint(x: dir * width * 0.06, y: -height * botH)

        path.move(to: tip)
        path.addQuadCurve(
            to: top,
            control: CGPoint(x: dir * width * (tipX + 0.02), y: height * (topH + 0.08 * tipSharpness))
        )
        path.addQuadCurve(
            to: inn,
            control: CGPoint(x: -dir * width * 0.52, y: height * 0.30)
        )
        path.addQuadCurve(
            to: bot,
            control: CGPoint(x: -dir * width * 0.30, y: -height * (botH + 0.06))
        )
        path.addQuadCurve(
            to: tip,
            control: CGPoint(x: dir * width * (tipX * 0.75), y: -height * 0.22)
        )
        path.closeSubpath()
    }

}
