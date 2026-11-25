import AppKit

extension SpiderView {
    func drawWebStrand(in context: CGContext, reveal: CGFloat) {
        let length = silkLength * reveal
        drawProceduralSilk(in: context, length: length, style: WebStyle.style(for: webStyleID))
    }

    func drawProceduralSilk(in context: CGContext, length: CGFloat, style: WebStyle) {
        guard length > 0.5 else { return }
        context.saveGState()
        context.setLineCap(.round)
        context.setLineJoin(.round)

        let amp = style.twistAmplitude
        let cycles = style.twistCycles

        // Soft outer glow along the twist.
        context.setShadow(offset: .zero, blur: style.glowWidth * 0.55, color: style.glowColor.cgColor)
        context.setStrokeColor(style.glowColor.cgColor)
        context.setLineWidth(style.glowWidth)
        strokeSilkPath(in: context, length: length, amplitude: amp * 0.35, cycles: cycles)
        context.setShadow(offset: .zero, blur: 0, color: nil)

        // Opposite-phase secondary strand (the twist).
        context.setStrokeColor(style.secondaryColor.cgColor)
        context.setLineWidth(style.secondaryWidth)
        strokeSilkPath(in: context, length: length, amplitude: amp, cycles: cycles, phase: .pi)

        // Core strand.
        context.setStrokeColor(style.coreColor.cgColor)
        context.setLineWidth(style.coreWidth)
        strokeSilkPath(in: context, length: length, amplitude: amp, cycles: cycles)

        // Optional highlight following the core twist.
        if let highlight = style.highlightColor {
            context.setStrokeColor(highlight.cgColor)
            context.setLineWidth(max(0.3, style.coreWidth * 0.35))
            strokeSilkPath(in: context, length: length, amplitude: amp, cycles: cycles, xOffset: -0.35)
        }

        let tip = style.tipRadius
        context.setFillColor(style.tipColor.cgColor)
        context.fillEllipse(in: CGRect(x: -tip, y: -tip, width: tip * 2, height: tip * 2))
        if let accent = style.tipAccent {
            context.setFillColor(accent.cgColor)
            context.fillEllipse(in: CGRect(x: -tip * 0.45, y: -tip * 0.45, width: tip * 0.9, height: tip * 0.9))
        }

        context.restoreGState()
    }

    func strokeSilkPath(
        in context: CGContext,
        length: CGFloat,
        amplitude: CGFloat,
        cycles: CGFloat,
        phase: CGFloat = 0,
        xOffset: CGFloat = 0
    ) {
        let steps = max(8, Int(length / 3))
        context.beginPath()
        for i in 0...steps {
            let t = CGFloat(i) / CGFloat(steps)
            let y = -length * t
            let x: CGFloat
            if amplitude > 0.01, cycles > 0 {
                x = xOffset + sin(t * cycles * .pi * 2 + phase) * amplitude * (0.35 + 0.65 * t)
            } else {
                x = xOffset
            }
            let point = CGPoint(x: x, y: y)
            if i == 0 {
                context.move(to: point)
            } else {
                context.addLine(to: point)
            }
        }
        context.strokePath()
    }

}
