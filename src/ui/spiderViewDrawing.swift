import AppKit

extension SpiderView {
    // MARK: - Shadows

    func drawSpriteShadow(
        in context: CGContext,
        feetY: CGFloat,
        torsoCenterY: CGFloat,
        headCenterY: CGFloat,
        headRadius: CGFloat
    ) {
        context.saveGState()
        context.setShadow(
            offset: CGSize(width: 1.2, height: -1.6),
            blur: 4.5,
            color: NSColor(calibratedWhite: 0, alpha: 0.28).cgColor
        )

        // Invisible silhouette that only casts the shadow.
        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.01).cgColor)
        context.fillEllipse(
            in: CGRect(
                x: -headRadius - 1.5,
                y: headCenterY - headRadius - 1.5,
                width: (headRadius + 1.5) * 2,
                height: (headRadius + 1.5) * 2
            )
        )
        context.fillEllipse(in: CGRect(x: -6.5, y: torsoCenterY - 5.5, width: 13, height: 11))
        context.fillEllipse(in: CGRect(x: -5.0, y: feetY - 1.0, width: 10, height: 5))
        // Arms reaching up the silk.
        context.fillEllipse(in: CGRect(x: -5.5, y: feetY + 2, width: 4, height: 10))
        context.fillEllipse(in: CGRect(x: 1.5, y: feetY + 2, width: 4, height: 10))
        context.restoreGState()

        // Soft contact shade where limbs meet the strand.
        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.16).cgColor)
        context.fillEllipse(in: CGRect(x: -3.2, y: feetY - 0.6, width: 6.4, height: 2.2))
        context.fillEllipse(in: CGRect(x: -2.6, y: feetY + 6.2, width: 5.2, height: 2.0))
    }

    func fillShadedOval(
        in context: CGContext,
        rect: CGRect,
        base: NSColor,
        shade: NSColor,
        highlight: NSColor
    ) {
        context.setFillColor(base.cgColor)
        context.fillEllipse(in: rect)

        context.saveGState()
        context.addEllipse(in: rect)
        context.clip()

        // Bottom / side shade.
        context.setFillColor(shade.withAlphaComponent(0.42).cgColor)
        context.fillEllipse(
            in: CGRect(
                x: rect.minX - rect.width * 0.05,
                y: rect.minY - rect.height * 0.08,
                width: rect.width * 1.05,
                height: rect.height * 0.62
            )
        )

        // Soft highlight.
        context.setFillColor(highlight.withAlphaComponent(0.18).cgColor)
        context.fillEllipse(
            in: CGRect(
                x: rect.minX + rect.width * 0.18,
                y: rect.midY + rect.height * 0.02,
                width: rect.width * 0.58,
                height: rect.height * 0.42
            )
        )
        context.restoreGState()
    }

    func strokeOutline(in context: CGContext, path: CGPath) {
        context.addPath(path)
        context.setStrokeColor(NSColor(calibratedWhite: 0, alpha: 0.55).cgColor)
        context.setLineWidth(1.15)
        context.strokePath()
    }


}
