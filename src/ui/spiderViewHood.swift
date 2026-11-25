import AppKit

extension SpiderView {
    // MARK: - Hood

    func hoodFabricColor() -> NSColor {
        skin.hasHoodie ? skin.body : (skin.style == .crimson ? skin.head : skin.accent)
    }

    func hoodShadeColor() -> NSColor {
        skin.secondary.blended(withFraction: 0.35, of: .black) ?? skin.secondary
    }

    /// Big soft pouch behind the head (drawn first).
    func drawHoodBack(in context: CGContext, centerY y: CGFloat, radius: CGFloat) {
        let fabric = hoodFabricColor()
        let shade = hoodShadeColor()

        // Outer hood volume — wider than the skull.
        let outer = CGRect(x: -radius - 4.2, y: y - radius - 1.2, width: (radius + 4.2) * 2, height: radius * 2 + 5.5)
        fillShadedOval(in: context, rect: outer, base: fabric, shade: shade, highlight: .white)

        // Hood point / drape toward the feet (up, in hang space).
        let drape = CGRect(x: -6.5, y: y + radius - 1.5, width: 13, height: 7.5)
        fillShadedOval(in: context, rect: drape, base: fabric, shade: shade, highlight: .white)

        // Deep inner cavity shadow (opening where the mask sits).
        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.28).cgColor)
        context.fillEllipse(
            in: CGRect(x: -radius * 0.92, y: y - radius * 0.85, width: radius * 1.84, height: radius * 1.7)
        )

        // Fabric fold lines on the back pouch.
        context.setStrokeColor(shade.withAlphaComponent(0.55).cgColor)
        context.setLineWidth(0.7)
        context.setLineCap(.round)
        context.move(to: CGPoint(x: -7.5, y: y + 2))
        context.addQuadCurve(to: CGPoint(x: -3.5, y: y + radius + 3.5), control: CGPoint(x: -7.2, y: y + radius + 1))
        context.strokePath()
        context.move(to: CGPoint(x: 7.5, y: y + 2))
        context.addQuadCurve(to: CGPoint(x: 3.5, y: y + radius + 3.5), control: CGPoint(x: 7.2, y: y + radius + 1))
        context.strokePath()

        let outline = CGMutablePath()
        outline.addEllipse(in: outer)
        strokeOutline(in: context, path: outline)
    }

    /// Rim + side flaps in front of the mask.
    func drawHoodFront(in context: CGContext, centerY y: CGFloat, radius: CGFloat) {
        let fabric = hoodFabricColor()
        let shade = hoodShadeColor()

        // Left / right cheek flaps.
        for dir: CGFloat in [-1, 1] {
            let flap = CGMutablePath()
            let tip = CGPoint(x: dir * (radius + 1.2), y: y - 1.5)
            flap.move(to: CGPoint(x: dir * (radius - 1.5), y: y + radius * 0.55))
            flap.addQuadCurve(
                to: CGPoint(x: dir * (radius - 0.8), y: y - radius * 0.75),
                control: tip
            )
            flap.addQuadCurve(
                to: CGPoint(x: dir * (radius - 1.5), y: y + radius * 0.55),
                control: CGPoint(x: dir * (radius + 2.8), y: y)
            )
            flap.closeSubpath()

            context.addPath(flap)
            context.setFillColor(fabric.cgColor)
            context.fillPath()

            context.addPath(flap)
            context.setFillColor(shade.withAlphaComponent(0.35).cgColor)
            context.fillPath()

            context.addPath(flap)
            context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.4).cgColor)
            context.setLineWidth(0.7)
            context.strokePath()
        }

        // Soft rim around the face opening.
        context.setStrokeColor(fabric.cgColor)
        context.setLineWidth(2.4)
        context.strokeEllipse(
            in: CGRect(x: -radius - 0.2, y: y - radius - 0.2, width: radius * 2 + 0.4, height: radius * 2 + 0.4)
        )
        context.setStrokeColor(shade.withAlphaComponent(0.65).cgColor)
        context.setLineWidth(1.0)
        context.strokeEllipse(
            in: CGRect(x: -radius + 0.55, y: y - radius + 0.55, width: radius * 2 - 1.1, height: radius * 2 - 1.1)
        )

        // Chin / brow fold highlights.
        context.setStrokeColor(NSColor(calibratedWhite: 1, alpha: 0.12).cgColor)
        context.setLineWidth(1.0)
        context.addArc(
            center: CGPoint(x: 0, y: y),
            radius: radius + 0.1,
            startAngle: .pi * 0.15,
            endAngle: .pi * 0.85,
            clockwise: false
        )
        context.strokePath()
    }


}
