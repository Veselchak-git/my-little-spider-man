import AppKit

extension SpiderView {
    // MARK: - Head

    func drawHead(in context: CGContext, centerY y: CGFloat, radius: CGFloat) {
        let headRect = CGRect(x: -radius, y: y - radius, width: radius * 2, height: radius * 2)
        let shade = (skin.head.blended(withFraction: 0.35, of: .black) ?? skin.head)

        switch skin.style {
        case .programmable:
            let hex = CGMutablePath()
            for i in 0..<6 {
                let angle = CGFloat(i) / 6 * .pi * 2 - .pi / 2
                let p = CGPoint(x: cos(angle) * (radius + 0.8), y: y + sin(angle) * (radius + 0.8))
                if i == 0 { hex.move(to: p) } else { hex.addLine(to: p) }
            }
            hex.closeSubpath()
            context.addPath(hex)
            context.setFillColor(skin.head.cgColor)
            context.fillPath()
            strokeOutline(in: context, path: hex)

        case .prowler:
            fillShadedOval(in: context, rect: headRect, base: skin.head, shade: shade, highlight: .white)
            context.setFillColor(skin.head.cgColor)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * (radius - 1.5), y: y + radius * 0.2))
                context.addLine(to: CGPoint(x: dir * (radius + 3.0), y: y + radius * 0.9))
                context.addLine(to: CGPoint(x: dir * (radius - 0.2), y: y + radius * 0.55))
                context.closePath()
                context.fillPath()
            }
            // Lime rim around face.
            context.setStrokeColor(skin.accent.withAlphaComponent(0.7).cgColor)
            context.setLineWidth(1.3)
            context.strokeEllipse(in: headRect.insetBy(dx: -0.6, dy: -0.6))
            let outline = CGMutablePath()
            outline.addEllipse(in: headRect)
            strokeOutline(in: context, path: outline)

        case .tech:
            // 2020 steel helmet — matte plates around the LED eye display.
            fillShadedOval(in: context, rect: headRect, base: skin.head, shade: shade, highlight: .white)
            context.setFillColor(skin.secondary.cgColor)
            context.fill(CGRect(x: -radius + 1.0, y: y + 1.6, width: radius * 2 - 2.0, height: 2.6))
            // Dark brow ridge above the LED eyes (not a red bar).
            context.setFillColor(NSColor(calibratedWhite: 0.04, alpha: 1).cgColor)
            context.fill(CGRect(x: -radius + 1.6, y: y + 3.2, width: radius * 2 - 3.2, height: 1.0))
            // Side headphone cups (Rahzzah 2020 helmet).
            context.setFillColor(skin.secondary.cgColor)
            for dir: CGFloat in [-1, 1] {
                context.fillEllipse(in: CGRect(x: dir * (radius - 0.2) - 1.4, y: y - 1.6, width: 2.8, height: 3.4))
            }
            let outline = CGMutablePath()
            outline.addEllipse(in: headRect)
            strokeOutline(in: context, path: outline)

        case .future:
            fillShadedOval(in: context, rect: headRect, base: skin.head, shade: shade, highlight: .white)
            // Iconic 2099 ear horns.
            context.setFillColor(skin.accent.cgColor)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * (radius - 2.0), y: y + radius * 0.15))
                context.addLine(to: CGPoint(x: dir * (radius + 3.4), y: y + radius * 0.95))
                context.addLine(to: CGPoint(x: dir * (radius + 0.6), y: y + radius * 0.35))
                context.addLine(to: CGPoint(x: dir * (radius - 0.8), y: y + radius * 0.05))
                context.closePath()
                context.fillPath()
            }
            // Scarlet wraparound eye sockets.
            context.setFillColor(skin.accent.withAlphaComponent(0.55).cgColor)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 1.2, y: y + 1.8))
                context.addLine(to: CGPoint(x: dir * (radius - 0.4), y: y + 2.4))
                context.addLine(to: CGPoint(x: dir * (radius + 0.2), y: y - 0.8))
                context.addLine(to: CGPoint(x: dir * 1.6, y: y - 2.2))
                context.closePath()
                context.fillPath()
            }
            let outline = CGMutablePath()
            outline.addEllipse(in: headRect)
            strokeOutline(in: context, path: outline)

        default:
            fillShadedOval(in: context, rect: headRect, base: skin.head, shade: shade, highlight: .white)
            let outline = CGMutablePath()
            outline.addEllipse(in: headRect)
            strokeOutline(in: context, path: outline)
        }

        drawMaskPattern(in: context, centerY: y, radius: radius, headRect: headRect)

        let placement = lensPlacement(for: skin.lensStyle, headY: y)
        drawLens(in: context, center: CGPoint(x: -placement.x, y: placement.y), facingLeft: true)
        drawLens(in: context, center: CGPoint(x: placement.x, y: placement.y), facingLeft: false)
    }

    func lensPlacement(for style: SpiderSkin.LensStyle, headY y: CGFloat) -> CGPoint {
        // x = distance from face center to lens center — must leave a clear gap between eyes.
        switch style {
        case .miles, .hoodie, .comic:
            // Original Miles/Classic placement.
            return CGPoint(x: 3.65, y: y - 0.55)
        case .advanced:  return CGPoint(x: 4.15, y: y - 0.20)
        case .prowler:   return CGPoint(x: 3.55, y: y - 0.10)
        case .led:       return CGPoint(x: 4.10, y: y + 0.05)
        case .crimson:   return CGPoint(x: 4.20, y: y - 0.40)
        case .gold:      return CGPoint(x: 4.35, y: y - 0.30)
        case .crystal:   return CGPoint(x: 4.15, y: y - 0.20)
        case .slit2099:  return CGPoint(x: 5.10, y: y + 0.05)
        }
    }

    func drawMaskPattern(in context: CGContext, centerY y: CGFloat, radius: CGFloat, headRect: CGRect) {
        context.saveGState()
        context.addEllipse(in: headRect.insetBy(dx: 0.2, dy: 0.2))
        context.clip()

        let origin = CGPoint(x: 0, y: y + 0.35)
        context.setStrokeColor(skin.webLine.cgColor)
        context.setLineWidth(skin.webLineWidth)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        switch skin.style {
        case .miles:
            drawTraditionalWebbing(in: context, center: origin, radius: radius, spokes: 12, rings: 5)
            context.setLineWidth(skin.webLineWidth * 1.3)
            context.move(to: CGPoint(x: 0, y: y - radius + 1))
            context.addLine(to: CGPoint(x: 0, y: y + radius - 1))
            context.strokePath()

        case .classic:
            drawTraditionalWebbing(in: context, center: origin, radius: radius, spokes: 14, rings: 6)

        case .uptown:
            // Sparse gold lattice.
            drawTraditionalWebbing(in: context, center: origin, radius: radius, spokes: 8, rings: 3)

        case .advanced:
            // Clean mask: thin contour rings only.
            context.setStrokeColor(skin.accent.withAlphaComponent(0.55).cgColor)
            context.setLineWidth(0.7)
            for t: CGFloat in [0.55, 0.85] {
                let r = radius * t
                context.strokeEllipse(in: CGRect(x: -r, y: y - r, width: r * 2, height: r * 2))
            }

        case .prowler:
            context.setStrokeColor(skin.accent.cgColor)
            context.setLineWidth(1.25)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 1.8, y: y + radius - 1.2))
                context.addLine(to: CGPoint(x: dir * (radius - 0.8), y: y - 1.5))
                context.move(to: CGPoint(x: dir * 1.2, y: y + 2))
                context.addLine(to: CGPoint(x: dir * (radius - 1.5), y: y - 4))
                context.strokePath()
            }

        case .tech:
            // Angular HUD seams + cheek rails.
            context.setLineWidth(0.75)
            context.move(to: CGPoint(x: -radius + 1.2, y: y + 2.5))
            context.addLine(to: CGPoint(x: -2.0, y: y - 4.5))
            context.move(to: CGPoint(x: radius - 1.2, y: y + 2.5))
            context.addLine(to: CGPoint(x: 2.0, y: y - 4.5))
            context.move(to: CGPoint(x: -3.5, y: y - 1.5))
            context.addLine(to: CGPoint(x: 3.5, y: y - 1.5))
            context.strokePath()

        case .future:
            // Clean 2099: center ridge + cheek seams into the horns.
            context.setLineWidth(1.05)
            context.move(to: CGPoint(x: 0, y: y - radius + 1.2))
            context.addLine(to: CGPoint(x: 0, y: y + radius - 1.5))
            context.strokePath()
            context.setLineWidth(0.8)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 1.5, y: y + 3.5))
                context.addLine(to: CGPoint(x: dir * (radius - 1.0), y: y - 1.0))
                context.strokePath()
            }

        case .programmable:
            for t: CGFloat in [0.35, 0.58, 0.82] { strokeHex(in: context, center: origin, radius: radius * t) }
            for i in 0..<6 {
                let angle = CGFloat(i) / 6 * .pi * 2 - .pi / 2
                context.move(to: origin)
                context.addLine(to: CGPoint(x: origin.x + cos(angle) * radius, y: origin.y + sin(angle) * radius))
                context.strokePath()
            }

        case .crimson, .hoodie:
            // Mask mostly covered by hood — faint seams only.
            context.setStrokeColor(skin.webLine.withAlphaComponent(0.35).cgColor)
            context.setLineWidth(0.55)
            context.move(to: CGPoint(x: 0, y: y - 3))
            context.addLine(to: CGPoint(x: 0, y: y + 4))
            context.strokePath()
        }

        context.restoreGState()
    }

    func drawTraditionalWebbing(
        in context: CGContext,
        center: CGPoint,
        radius: CGFloat,
        spokes: Int,
        rings: Int
    ) {
        for i in 0..<spokes {
            let angle = (CGFloat(i) / CGFloat(spokes)) * .pi * 2 - .pi / 2
            context.move(to: center)
            context.addLine(to: CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius))
            context.strokePath()
        }
        for i in 1...rings {
            let t = CGFloat(i) / CGFloat(rings + 1) + 0.12
            let r = radius * min(0.95, t)
            context.strokeEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
        }
    }

    func strokeHex(in context: CGContext, center: CGPoint, radius: CGFloat) {
        let path = CGMutablePath()
        for i in 0..<6 {
            let angle = CGFloat(i) / 6 * .pi * 2 - .pi / 2
            let p = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
        }
        path.closeSubpath()
        context.addPath(path)
        context.strokePath()
    }


}
