import AppKit

extension SpiderView {
    // MARK: - Limbs on the web

    /// Short arms with a slight bend, gripping the strand.
    func drawArmsHoldingWeb(in context: CGContext, shoulderY: CGFloat, handY: CGFloat) {
        for dir: CGFloat in [-1, 1] {
            let shoulder = CGPoint(x: dir * 4.2, y: shoulderY)
            // Soft elbow out — not fully straight.
            let elbow = CGPoint(x: dir * 4.0, y: (shoulderY + handY) * 0.52 + 0.4)
            let wrist = CGPoint(x: dir * 1.5, y: handY)
            let base = limbTone(skin.body, lift: dir < 0 ? -0.06 : 0.04)

            drawLimbSegment(in: context, from: shoulder, to: elbow, width: 2.55, base: base, castShadow: true)
            drawLimbSegment(
                in: context,
                from: elbow,
                to: wrist,
                width: 2.35,
                base: limbTone(base, lift: 0.04),
                castShadow: false
            )
            drawJointOrb(in: context, center: elbow, radius: 1.25, base: limbTone(base, lift: 0.08))

            context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.28).cgColor)
            context.fillEllipse(in: CGRect(x: shoulder.x - 1.6, y: shoulder.y - 1.4, width: 3.2, height: 2.6))
        }
    }

    func drawHandsOnWeb(in context: CGContext, handY: CGFloat) {
        let glove = limbTone(skin.hasHoodie ? skin.secondary : skin.feet, lift: 0.05)

        for dir: CGFloat in [-1, 1] {
            let palm = CGPoint(x: dir * 1.4, y: handY)
            // Contact shadow on the silk under the hand.
            context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.22).cgColor)
            context.fillEllipse(in: CGRect(x: palm.x - 2.0, y: palm.y - 0.4, width: 4.0, height: 2.2))

            drawJointOrb(
                in: context,
                center: palm,
                radius: 1.85,
                base: glove
            )
            // Fingers curling over the strand — darker underside.
            context.setFillColor(limbTone(glove, lift: -0.18).cgColor)
            context.fillEllipse(in: CGRect(x: palm.x - 1.0, y: palm.y + 0.7, width: 2.0, height: 1.6))
            context.setFillColor(skin.accent.withAlphaComponent(0.9).cgColor)
            context.fillEllipse(in: CGRect(x: palm.x - 0.7, y: palm.y - 0.15, width: 1.4, height: 0.85))

            // Hard outline so hands don't melt into silk/arms.
            context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.55).cgColor)
            context.setLineWidth(0.85)
            context.strokeEllipse(in: CGRect(x: palm.x - 1.85, y: palm.y - 1.55, width: 3.7, height: 3.1))
        }
    }

    /// Strongly bent legs: knees kicked out wide, feet hooked on the silk tip.
    func drawLegsOnWeb(in context: CGContext, tipY: CGFloat, hipY: CGFloat) {
        for dir: CGFloat in [-1, 1] {
            let hip = CGPoint(x: dir * 2.0, y: hipY)
            let knee = CGPoint(x: dir * 6.2, y: tipY - 0.8)
            let ankle = CGPoint(x: dir * 1.3, y: tipY + 0.2)

            let thigh = limbTone(skin.body, lift: dir < 0 ? -0.08 : 0.02)
            let shin = limbTone(skin.feet, lift: dir < 0 ? -0.04 : 0.06)

            // Drop shadow under the whole bent leg.
            context.saveGState()
            context.setShadow(
                offset: CGSize(width: dir * 0.9, height: -1.1),
                blur: 2.4,
                color: NSColor(calibratedWhite: 0, alpha: 0.35).cgColor
            )
            context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.01).cgColor)
            context.setLineWidth(3.2)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            context.move(to: hip)
            context.addLine(to: knee)
            context.addLine(to: ankle)
            context.strokePath()
            context.restoreGState()

            drawLimbSegment(in: context, from: hip, to: knee, width: 3.0, base: thigh, castShadow: false)
            drawLimbSegment(in: context, from: knee, to: ankle, width: 2.55, base: shin, castShadow: false)

            // Knee cap — lighter blob so the bend reads.
            drawJointOrb(in: context, center: knee, radius: 1.7, base: limbTone(thigh, lift: 0.12))

            // Hip socket shade into torso.
            context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.30).cgColor)
            context.fillEllipse(in: CGRect(x: hip.x - 1.7, y: hip.y - 1.5, width: 3.4, height: 2.8))

            // Foot hooked on silk with clear rim + sole shade.
            let footCenter = CGPoint(x: ankle.x, y: tipY + 0.5)
            context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.25).cgColor)
            context.fillEllipse(in: CGRect(x: footCenter.x - 2.1, y: tipY - 0.8, width: 4.2, height: 2.0))
            drawJointOrb(in: context, center: footCenter, radius: 1.9, base: shin)
            context.setFillColor(skin.accent.cgColor)
            context.fillEllipse(in: CGRect(x: footCenter.x - 1.0, y: tipY + 0.7, width: 2.0, height: 1.1))
            context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.55).cgColor)
            context.setLineWidth(0.85)
            context.strokeEllipse(in: CGRect(x: footCenter.x - 1.95, y: tipY - 0.55, width: 3.9, height: 3.0))
        }
    }

    /// Capsule limb with dark outline, core fill, edge shade and highlight.
    func drawLimbSegment(
        in context: CGContext,
        from: CGPoint,
        to: CGPoint,
        width: CGFloat,
        base: NSColor,
        castShadow: Bool
    ) {
        let dx = to.x - from.x
        let dy = to.y - from.y
        let len = max(0.001, hypot(dx, dy))
        let nx = -dy / len
        let ny = dx / len

        let dark = limbTone(base, lift: -0.22)
        let mid = base
        let light = limbTone(base, lift: 0.16)
        let outline = NSColor(calibratedWhite: 0, alpha: 0.62)

        if castShadow {
            context.saveGState()
            context.setShadow(
                offset: CGSize(width: nx * 1.1 + 0.4, height: ny * 1.1 - 0.8),
                blur: 2.2,
                color: NSColor(calibratedWhite: 0, alpha: 0.32).cgColor
            )
            context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.01).cgColor)
            context.setLineCap(.round)
            context.setLineWidth(width)
            context.move(to: from)
            context.addLine(to: to)
            context.strokePath()
            context.restoreGState()
        }

        context.saveGState()
        context.setLineCap(.round)

        // Outer silhouette — keeps limbs from melting together.
        context.setStrokeColor(outline.cgColor)
        context.setLineWidth(width + 1.35)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()

        // Core body.
        context.setStrokeColor(mid.cgColor)
        context.setLineWidth(width)
        context.move(to: from)
        context.addLine(to: to)
        context.strokePath()

        // Underside shade band.
        context.setStrokeColor(dark.withAlphaComponent(0.75).cgColor)
        context.setLineWidth(width * 0.42)
        context.move(to: CGPoint(x: from.x - nx * width * 0.22, y: from.y - ny * width * 0.22))
        context.addLine(to: CGPoint(x: to.x - nx * width * 0.22, y: to.y - ny * width * 0.22))
        context.strokePath()

        // Top highlight.
        context.setStrokeColor(light.withAlphaComponent(0.70).cgColor)
        context.setLineWidth(width * 0.28)
        context.move(to: CGPoint(x: from.x + nx * width * 0.24, y: from.y + ny * width * 0.24))
        context.addLine(to: CGPoint(x: to.x + nx * width * 0.24, y: to.y + ny * width * 0.24))
        context.strokePath()

        context.restoreGState()
    }

    func drawJointOrb(in context: CGContext, center: CGPoint, radius: CGFloat, base: NSColor) {
        let dark = limbTone(base, lift: -0.2)
        let light = limbTone(base, lift: 0.18)

        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.45).cgColor)
        context.fillEllipse(in: CGRect(x: center.x - radius - 0.35, y: center.y - radius - 0.35, width: (radius + 0.35) * 2, height: (radius + 0.35) * 2))

        fillShadedOval(
            in: context,
            rect: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2),
            base: base,
            shade: dark,
            highlight: light
        )
    }

    /// Lift > 0 lightens, lift < 0 darkens — keeps left/right and limb parts distinct.
    func limbTone(_ color: NSColor, lift: CGFloat) -> NSColor {
        let rgb = color.usingColorSpace(.deviceRGB) ?? color
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        rgb.getRed(&r, green: &g, blue: &b, alpha: &a)
        if lift >= 0 {
            return NSColor(
                calibratedRed: min(1, r + (1 - r) * lift),
                green: min(1, g + (1 - g) * lift),
                blue: min(1, b + (1 - b) * lift),
                alpha: a
            )
        }
        let t = 1 + lift
        return NSColor(calibratedRed: max(0, r * t), green: max(0, g * t), blue: max(0, b * t), alpha: a)
    }


}
