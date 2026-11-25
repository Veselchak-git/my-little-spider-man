import AppKit

extension SpiderView {
    // MARK: - Body

    func drawBody(in context: CGContext, torsoCenterY: CGFloat) {
        let torso = CGRect(x: -5.2, y: torsoCenterY - 5.1, width: 10.4, height: 9.4)

        if skin.hasHoodie {
            drawHoodieShell(in: context, torso: torso, torsoCenterY: torsoCenterY)
        } else {
            let torsoPath = torsoPath(for: skin.style, torso: torso)
            context.saveGState()
            context.addPath(torsoPath)
            context.clip()

            context.setFillColor(skin.body.cgColor)
            context.fill(torso.insetBy(dx: -2, dy: -2))

            context.setFillColor(skin.secondary.withAlphaComponent(0.38).cgColor)
            context.fill(CGRect(x: torso.minX, y: torso.minY - 0.5, width: torso.width, height: torso.height * 0.48))
            context.setFillColor(NSColor(calibratedWhite: 1, alpha: 0.10).cgColor)
            context.fill(CGRect(x: torso.minX + 1.5, y: torso.midY, width: torso.width * 0.55, height: torso.height * 0.4))

            drawSuitPanels(in: context, torso: torso, torsoCenterY: torsoCenterY)
            drawSuitWebbing(in: context, torso: torso, torsoCenterY: torsoCenterY)
            context.restoreGState()

            strokeOutline(in: context, path: torsoPath)
        }

        if skin.style != .hoodie {
            drawChestSpider(in: context, center: CGPoint(x: 0, y: torsoCenterY - 0.15))
        }
    }

    func torsoPath(for style: SpiderSkin.Style, torso: CGRect) -> CGMutablePath {
        let path = CGMutablePath()
        switch style {
        case .future:
            // Tapered armor torso with hard edges.
            path.move(to: CGPoint(x: 0, y: torso.maxY + 1.0))
            path.addLine(to: CGPoint(x: torso.maxX + 0.8, y: torso.maxY - 1.5))
            path.addLine(to: CGPoint(x: torso.maxX + 0.2, y: torso.minY))
            path.addLine(to: CGPoint(x: 0, y: torso.minY - 0.8))
            path.addLine(to: CGPoint(x: torso.minX - 0.2, y: torso.minY))
            path.addLine(to: CGPoint(x: torso.minX - 0.8, y: torso.maxY - 1.5))
            path.closeSubpath()
        case .programmable:
            path.move(to: CGPoint(x: 0, y: torso.maxY + 0.8))
            path.addLine(to: CGPoint(x: torso.maxX + 1.2, y: torso.midY + 2))
            path.addLine(to: CGPoint(x: torso.maxX + 0.4, y: torso.minY - 0.4))
            path.addLine(to: CGPoint(x: 0, y: torso.minY - 1.2))
            path.addLine(to: CGPoint(x: torso.minX - 0.4, y: torso.minY - 0.4))
            path.addLine(to: CGPoint(x: torso.minX - 1.2, y: torso.midY + 2))
            path.closeSubpath()
        case .prowler:
            path.addRoundedRect(in: torso.insetBy(dx: -0.5, dy: -0.3), cornerWidth: 2.0, cornerHeight: 2.0)
        case .tech:
            path.addRoundedRect(in: torso.insetBy(dx: -0.2, dy: 0), cornerWidth: 1.6, cornerHeight: 1.6)
        default:
            path.addRoundedRect(in: torso, cornerWidth: 3.6, cornerHeight: 3.6)
        }
        return path
    }

    func drawHoodieShell(in context: CGContext, torso: CGRect, torsoCenterY: CGFloat) {
        let shell = CGRect(x: -6.4, y: torso.minY - 0.6, width: 12.8, height: torso.height + 2.0)
        let path = CGMutablePath()
        path.addRoundedRect(in: shell, cornerWidth: 4.4, cornerHeight: 4.4)

        fillShadedRoundedRect(in: context, rect: shell, corner: 4.4, base: skin.body, shade: hoodShadeColor())

        // Pocket / hem shadow.
        context.setFillColor(NSColor(calibratedWhite: 0, alpha: 0.18).cgColor)
        context.fill(CGRect(x: shell.minX + 1.2, y: shell.minY + 0.6, width: shell.width - 2.4, height: 2.2))

        // Zipper.
        context.setStrokeColor(skin.secondary.cgColor)
        context.setLineWidth(1.1)
        context.move(to: CGPoint(x: 0, y: shell.maxY - 0.8))
        context.addLine(to: CGPoint(x: 0, y: shell.minY + 1.0))
        context.strokePath()
        context.setFillColor(skin.accent.cgColor)
        context.fillEllipse(in: CGRect(x: -1.1, y: shell.maxY - 2.6, width: 2.2, height: 2.2))

        // Black graffiti spider on the hoodie.
        drawChestSpider(in: context, center: CGPoint(x: 0, y: torsoCenterY - 0.4))
        strokeOutline(in: context, path: path)
    }

    func fillShadedRoundedRect(
        in context: CGContext,
        rect: CGRect,
        corner: CGFloat,
        base: NSColor,
        shade: NSColor
    ) {
        let path = CGMutablePath()
        path.addRoundedRect(in: rect, cornerWidth: corner, cornerHeight: corner)
        context.addPath(path)
        context.setFillColor(base.cgColor)
        context.fillPath()

        context.saveGState()
        context.addPath(path)
        context.clip()
        context.setFillColor(shade.withAlphaComponent(0.40).cgColor)
        context.fill(CGRect(x: rect.minX, y: rect.minY, width: rect.width, height: rect.height * 0.45))
        context.setFillColor(NSColor(calibratedWhite: 1, alpha: 0.12).cgColor)
        context.fill(CGRect(x: rect.minX + 1.5, y: rect.midY, width: rect.width * 0.55, height: rect.height * 0.38))
        context.restoreGState()
    }

    func drawSuitPanels(in context: CGContext, torso: CGRect, torsoCenterY: CGFloat) {
        switch skin.style {
        case .miles:
            // Red raised side ribs only.
            context.setFillColor(skin.accent.cgColor)
            context.fill(CGRect(x: -5.2, y: torso.minY + 0.7, width: 1.7, height: torso.height - 1.2))
            context.fill(CGRect(x: 3.5, y: torso.minY + 0.7, width: 1.7, height: torso.height - 1.2))

        case .advanced:
            // Shoulder pipes that flow into chest — no classic side bars.
            context.setStrokeColor(skin.accent.cgColor)
            context.setLineWidth(1.8)
            context.setLineCap(.round)
            context.move(to: CGPoint(x: -5.0, y: torso.maxY - 0.4))
            context.addQuadCurve(to: CGPoint(x: -1.2, y: torsoCenterY), control: CGPoint(x: -4.2, y: torsoCenterY + 2))
            context.move(to: CGPoint(x: 5.0, y: torso.maxY - 0.4))
            context.addQuadCurve(to: CGPoint(x: 1.2, y: torsoCenterY), control: CGPoint(x: 4.2, y: torsoCenterY + 2))
            context.strokePath()

        case .prowler:
            // Violet side panels + lime claw marks.
            context.setFillColor(skin.secondary.cgColor)
            context.fill(CGRect(x: -5.6, y: torso.minY + 0.4, width: 2.0, height: torso.height - 0.8))
            context.fill(CGRect(x: 3.6, y: torso.minY + 0.4, width: 2.0, height: torso.height - 0.8))
            context.setStrokeColor(skin.accent.cgColor)
            context.setLineWidth(1.4)
            context.setLineCap(.round)
            for dy: CGFloat in [-2.4, -0.2, 2.0] {
                context.move(to: CGPoint(x: -4.6, y: torsoCenterY + dy + 1.4))
                context.addLine(to: CGPoint(x: -0.6, y: torsoCenterY + dy - 0.8))
                context.move(to: CGPoint(x: 4.6, y: torsoCenterY + dy + 1.4))
                context.addLine(to: CGPoint(x: 0.6, y: torsoCenterY + dy - 0.8))
                context.strokePath()
            }
            // Belt glow.
            context.setFillColor(skin.accent.withAlphaComponent(0.7).cgColor)
            context.fill(CGRect(x: -3.5, y: torso.minY + 0.5, width: 7.0, height: 1.1))

        case .tech:
            // 2020 Integrated: angular side plates + glowing crimson circuit Y.
            context.setFillColor(skin.secondary.cgColor)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 2.8, y: torso.maxY - 0.2))
                context.addLine(to: CGPoint(x: dir * 5.8, y: torso.maxY - 2.0))
                context.addLine(to: CGPoint(x: dir * 5.6, y: torso.minY + 0.6))
                context.addLine(to: CGPoint(x: dir * 3.0, y: torso.minY + 1.2))
                context.closePath()
                context.fillPath()
            }
            context.setStrokeColor(skin.accent.cgColor)
            context.setLineWidth(1.25)
            context.setLineCap(.round)
            context.setLineJoin(.round)
            // Circuit Y from shoulders into sternum.
            context.move(to: CGPoint(x: -4.2, y: torso.maxY - 0.4))
            context.addLine(to: CGPoint(x: 0, y: torsoCenterY + 1.2))
            context.addLine(to: CGPoint(x: 4.2, y: torso.maxY - 0.4))
            context.move(to: CGPoint(x: 0, y: torsoCenterY + 1.2))
            context.addLine(to: CGPoint(x: 0, y: torso.minY + 0.8))
            context.strokePath()
            // Status nodes.
            context.setFillColor(skin.accent.cgColor)
            context.fillEllipse(in: CGRect(x: -0.55, y: torsoCenterY + 0.7, width: 1.1, height: 1.1))
            context.fillEllipse(in: CGRect(x: -0.45, y: torso.minY + 1.0, width: 0.9, height: 0.9))

        case .crimson:
            // Plain black suit under the cowl — almost no red on torso.
            context.setFillColor(skin.secondary.withAlphaComponent(0.45).cgColor)
            context.fill(CGRect(x: -1.0, y: torso.minY + 0.8, width: 2.0, height: torso.height - 1.4))

        case .uptown:
            // Gold shoulder medals / diamonds, not red pipes.
            context.setFillColor(skin.accent.cgColor)
            fillDiamond(in: context, center: CGPoint(x: -4.0, y: torsoCenterY + 1.5), size: 2.2)
            fillDiamond(in: context, center: CGPoint(x: 4.0, y: torsoCenterY + 1.5), size: 2.2)
            fillDiamond(in: context, center: CGPoint(x: -4.0, y: torsoCenterY - 1.8), size: 1.6)
            fillDiamond(in: context, center: CGPoint(x: 4.0, y: torsoCenterY - 1.8), size: 1.6)

        case .programmable:
            context.setFillColor(skin.secondary.cgColor)
            for rect in [
                CGRect(x: -4.8, y: torsoCenterY + 1.0, width: 3.6, height: 2.8),
                CGRect(x: 1.2, y: torsoCenterY + 0.2, width: 3.4, height: 3.0),
                CGRect(x: -3.6, y: torsoCenterY - 3.2, width: 3.2, height: 2.6),
                CGRect(x: 0.4, y: torsoCenterY - 3.4, width: 3.6, height: 2.7)
            ] {
                context.fill(rect)
                context.setStrokeColor(skin.accent.withAlphaComponent(0.7).cgColor)
                context.setLineWidth(0.7)
                context.stroke(rect)
            }

        case .future:
            // 2099: high pointed collar + geometric scarlet armor fins.
            context.setFillColor(skin.accent.cgColor)
            // Tall collar spike (Miguel silhouette).
            context.move(to: CGPoint(x: -2.6, y: torso.maxY - 0.6))
            context.addLine(to: CGPoint(x: 0, y: torso.maxY + 3.0))
            context.addLine(to: CGPoint(x: 2.6, y: torso.maxY - 0.6))
            context.addLine(to: CGPoint(x: 1.4, y: torso.maxY - 2.4))
            context.addLine(to: CGPoint(x: -1.4, y: torso.maxY - 2.4))
            context.closePath()
            context.fillPath()
            // Angular side armor fins.
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 2.4, y: torso.maxY - 1.8))
                context.addLine(to: CGPoint(x: dir * 6.8, y: torsoCenterY + 2.2))
                context.addLine(to: CGPoint(x: dir * 6.0, y: torsoCenterY - 0.8))
                context.addLine(to: CGPoint(x: dir * 5.4, y: torso.minY + 0.4))
                context.addLine(to: CGPoint(x: dir * 2.8, y: torso.minY + 1.4))
                context.addLine(to: CGPoint(x: dir * 2.6, y: torsoCenterY - 0.6))
                context.closePath()
                context.fillPath()
            }
            // Black abdomen plate.
            context.setFillColor(skin.secondary.cgColor)
            context.move(to: CGPoint(x: -2.4, y: torsoCenterY - 0.4))
            context.addLine(to: CGPoint(x: 2.4, y: torsoCenterY - 0.4))
            context.addLine(to: CGPoint(x: 1.8, y: torso.minY + 0.2))
            context.addLine(to: CGPoint(x: -1.8, y: torso.minY + 0.2))
            context.closePath()
            context.fillPath()

        case .hoodie:
            break

        case .classic:
            context.setFillColor(skin.accent.cgColor)
            context.fill(CGRect(x: -5.2, y: torso.minY + 0.5, width: 2.3, height: torso.height - 1.0))
            context.fill(CGRect(x: 2.9, y: torso.minY + 0.5, width: 2.3, height: torso.height - 1.0))
            context.setFillColor(skin.secondary.cgColor)
            context.fill(CGRect(x: -4.3, y: torso.minY + 0.55, width: 8.6, height: 1.35))
        }
    }

    func fillDiamond(in context: CGContext, center: CGPoint, size: CGFloat) {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: center.x, y: center.y + size))
        path.addLine(to: CGPoint(x: center.x + size * 0.7, y: center.y))
        path.addLine(to: CGPoint(x: center.x, y: center.y - size))
        path.addLine(to: CGPoint(x: center.x - size * 0.7, y: center.y))
        path.closeSubpath()
        context.addPath(path)
        context.fillPath()
    }

    func drawSuitWebbing(in context: CGContext, torso: CGRect, torsoCenterY: CGFloat) {
        context.setStrokeColor(skin.webLine.cgColor)
        context.setLineWidth(skin.webLineWidth * 0.8)
        context.setLineCap(.round)
        context.setLineJoin(.round)

        switch skin.style {
        case .miles:
            // Classic raised lattice on torso.
            context.move(to: CGPoint(x: 0, y: torso.maxY - 0.3))
            context.addLine(to: CGPoint(x: 0, y: torso.minY + 0.5))
            context.strokePath()
            for dy: CGFloat in [-2.4, -0.6, 1.2] {
                let y = torsoCenterY + dy
                context.move(to: CGPoint(x: -4.2, y: y))
                context.addQuadCurve(to: CGPoint(x: 4.2, y: y), control: CGPoint(x: 0, y: y + 1.3))
                context.strokePath()
            }

        case .classic:
            context.move(to: CGPoint(x: 0, y: torso.maxY - 0.3))
            context.addLine(to: CGPoint(x: 0, y: torso.minY + 0.5))
            context.strokePath()
            for dy: CGFloat in [-2.6, -1.0, 0.6, 2.0] {
                let y = torsoCenterY + dy
                context.move(to: CGPoint(x: -4.0, y: y))
                context.addQuadCurve(to: CGPoint(x: 4.0, y: y), control: CGPoint(x: 0, y: y + 1.2))
                context.strokePath()
            }

        case .uptown:
            // Sparse ornate gold arcs — not dense Miles lattice.
            context.setLineWidth(skin.webLineWidth)
            for dy: CGFloat in [-1.8, 1.0] {
                let y = torsoCenterY + dy
                context.move(to: CGPoint(x: -3.8, y: y))
                context.addQuadCurve(to: CGPoint(x: 3.8, y: y), control: CGPoint(x: 0, y: y + 2.0))
                context.strokePath()
            }

        case .advanced:
            // Smooth suit — only faint contour, no lattice.
            context.setStrokeColor(skin.webLine.withAlphaComponent(0.35).cgColor)
            context.setLineWidth(0.6)
            context.strokeEllipse(in: CGRect(x: -3.2, y: torsoCenterY - 2.8, width: 6.4, height: 5.2))

        case .crimson, .hoodie, .prowler:
            break

        case .programmable:
            context.setLineWidth(skin.webLineWidth)
            context.move(to: CGPoint(x: -4.2, y: torso.maxY - 0.8))
            context.addLine(to: CGPoint(x: 0, y: torso.minY + 0.6))
            context.addLine(to: CGPoint(x: 4.2, y: torso.maxY - 0.8))
            context.strokePath()

        case .tech:
            // Horizontal bus lines across the circuit Y.
            context.setLineWidth(0.65)
            context.move(to: CGPoint(x: -3.2, y: torsoCenterY - 0.6))
            context.addLine(to: CGPoint(x: 3.2, y: torsoCenterY - 0.6))
            context.move(to: CGPoint(x: -2.4, y: torsoCenterY - 2.2))
            context.addLine(to: CGPoint(x: 2.4, y: torsoCenterY - 2.2))
            context.strokePath()

        case .future:
            // Sharp scarlet V seam under the collar.
            context.setLineWidth(1.05)
            context.move(to: CGPoint(x: -2.2, y: torso.maxY - 2.6))
            context.addLine(to: CGPoint(x: 0, y: torsoCenterY - 0.2))
            context.addLine(to: CGPoint(x: 2.2, y: torso.maxY - 2.6))
            context.strokePath()
        }
    }

    func drawChestSpider(in context: CGContext, center: CGPoint) {
        if skin.style == .crimson { return }

        let scale: CGFloat
        switch skin.style {
        case .advanced, .tech: scale = 1.3
        case .future: scale = 1.2
        case .classic: scale = 0.72
        case .hoodie: scale = 1.25
        case .prowler: scale = 1.15
        default: scale = skin.largeEmblem ? 1.12 : 0.82
        }

        context.saveGState()
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: scale, y: scale)
        context.setShadow(offset: CGSize(width: 0.4, height: -0.6), blur: 1.2, color: NSColor.black.withAlphaComponent(0.35).cgColor)
        context.setFillColor(skin.emblem.cgColor)
        context.setStrokeColor(skin.emblem.cgColor)
        context.setLineCap(.round)
        context.setLineWidth(skin.largeEmblem ? 0.65 : 0.5)

        switch skin.style {
        case .advanced:
            let mark = CGMutablePath()
            mark.move(to: CGPoint(x: 0, y: 2.4))
            mark.addLine(to: CGPoint(x: 2.4, y: 0.3))
            mark.addLine(to: CGPoint(x: 1.0, y: -2.2))
            mark.addLine(to: CGPoint(x: -1.0, y: -2.2))
            mark.addLine(to: CGPoint(x: -2.4, y: 0.3))
            mark.closeSubpath()
            context.addPath(mark)
            context.fillPath()

        case .tech:
            // Glowing crimson circuit spider (2020).
            context.setShadow(offset: .zero, blur: 2.4, color: skin.accent.withAlphaComponent(0.55).cgColor)
            context.fillEllipse(in: CGRect(x: -1.4, y: -0.2, width: 2.8, height: 2.4))
            context.fillEllipse(in: CGRect(x: -0.95, y: -1.6, width: 1.9, height: 1.6))
            context.setLineWidth(0.85)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: dir * 0.9, y: 0.9))
                context.addLine(to: CGPoint(x: dir * 2.8, y: 1.8))
                context.move(to: CGPoint(x: dir * 1.0, y: 0.2))
                context.addLine(to: CGPoint(x: dir * 3.0, y: 0.1))
                context.move(to: CGPoint(x: dir * 0.9, y: -0.5))
                context.addLine(to: CGPoint(x: dir * 2.6, y: -1.4))
                context.strokePath()
            }

        case .future:
            // Angular 2099 spider glyph.
            let mark = CGMutablePath()
            mark.move(to: CGPoint(x: 0, y: 2.8))
            mark.addLine(to: CGPoint(x: 1.4, y: 1.0))
            mark.addLine(to: CGPoint(x: 2.8, y: 0.2))
            mark.addLine(to: CGPoint(x: 1.2, y: 0.0))
            mark.addLine(to: CGPoint(x: 0.9, y: -2.6))
            mark.addLine(to: CGPoint(x: -0.9, y: -2.6))
            mark.addLine(to: CGPoint(x: -1.2, y: 0.0))
            mark.addLine(to: CGPoint(x: -2.8, y: 0.2))
            mark.addLine(to: CGPoint(x: -1.4, y: 1.0))
            mark.closeSubpath()
            context.addPath(mark)
        context.fillPath()

        case .programmable:
            strokeHex(in: context, center: .zero, radius: 2.4)
            context.setLineWidth(1.0)
            context.move(to: CGPoint(x: 0, y: 2.4))
            context.addLine(to: CGPoint(x: 0, y: -2.4))
            context.strokePath()

        case .prowler:
            // Keep claw emblem, denser.
            context.setLineWidth(1.2)
            for dir: CGFloat in [-1, 1] {
                context.move(to: CGPoint(x: 0, y: 1.8))
                context.addLine(to: CGPoint(x: dir * 3.4, y: 2.6))
                context.move(to: CGPoint(x: 0, y: 0.3))
                context.addLine(to: CGPoint(x: dir * 3.6, y: 0.3))
                context.move(to: CGPoint(x: 0, y: -1.1))
                context.addLine(to: CGPoint(x: dir * 3.0, y: -2.5))
                context.strokePath()
            }
            context.fillEllipse(in: CGRect(x: -1.3, y: -1.5, width: 2.6, height: 3.0))

        case .uptown:
            fillDiamond(in: context, center: .zero, size: 2.6)
            context.setFillColor(skin.secondary.cgColor)
            fillDiamond(in: context, center: .zero, size: 1.2)

        default:
            context.fillEllipse(in: CGRect(x: -1.55, y: -0.35, width: 3.1, height: 2.7))
            context.fillEllipse(in: CGRect(x: -1.05, y: -1.85, width: 2.1, height: 1.85))
            let legs: [(CGFloat, CGFloat, CGFloat, CGFloat)] = [
                (-1.2, 0.7, -3.35, 2.05), (-1.35, 0.15, -3.55, 0.25),
                (-1.25, -0.45, -3.25, -1.55), (-0.9, -1.15, -2.35, -2.45),
                (1.2, 0.7, 3.35, 2.05), (1.35, 0.15, 3.55, 0.25),
                (1.25, -0.45, 3.25, -1.55), (0.9, -1.15, 2.35, -2.45)
            ]
            for (x0, y0, x1, y1) in legs {
                context.move(to: CGPoint(x: x0, y: y0))
                context.addQuadCurve(
                    to: CGPoint(x: x1, y: y1),
                    control: CGPoint(x: (x0 + x1) * 0.55, y: (y0 + y1) * 0.5 + (x1 > 0 ? 0.55 : -0.55))
                )
                context.strokePath()
            }
        }
        context.restoreGState()
    }



}
