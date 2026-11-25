import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let panel = SpiderPanel()
    private let controller = SpiderController()
    private var statusItem: NSStatusItem?
    private var tickTimer: Timer?
    private var lastTick: CFTimeInterval = 0
    private var lastPanelFrame: NSRect = .zero
    private var settingsWindow: SettingsWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupStatusItem()
        applySettingsToRuntime()
        startSpider()
        startTickTimer()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screensChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(settingsChanged),
            name: AppSettings.didChangeNotification,
            object: nil
        )

        NSWorkspace.shared.notificationCenter.addObserver(
            self,
            selector: #selector(activeSpaceChanged),
            name: NSWorkspace.activeSpaceDidChangeNotification,
            object: nil
        )
    }

    func applicationWillTerminate(_ notification: Notification) {
        tickTimer?.invalidate()
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }

    private func setupStatusItem() {
        let item = statusItem ?? NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = item.button {
            button.image = Self.makeStatusIcon()
            button.image?.isTemplate = true
            button.toolTip = L10n.tr("status.tooltip")
        }
        item.menu = makeStatusMenu()
        statusItem = item
    }

    private func makeStatusMenu() -> NSMenu {
        let menu = NSMenu()
        menu.addItem(withTitle: L10n.tr("menu.appear_now"), action: #selector(appearNow), keyEquivalent: "m")
        menu.addItem(withTitle: L10n.tr("menu.hang_still"), action: #selector(hangStill), keyEquivalent: "h")
        menu.addItem(.separator())
        menu.addItem(withTitle: L10n.tr("menu.settings"), action: #selector(openSettings), keyEquivalent: ",")
        menu.addItem(.separator())
        menu.addItem(withTitle: L10n.tr("menu.quit"), action: #selector(quitApp), keyEquivalent: "q")
        return menu
    }

    private func rebuildLocalizedChrome() {
        statusItem?.button?.toolTip = L10n.tr("status.tooltip")
        statusItem?.menu = makeStatusMenu()
        settingsWindow?.reloadFromSettings()
    }

    private static func makeStatusIcon() -> NSImage {
        let size = NSSize(width: 16, height: 16)
        let image = NSImage(size: size, flipped: false) { rect in
            NSColor.black.setStroke()
            NSColor.black.setFill()

            let web = NSBezierPath()
            web.move(to: NSPoint(x: rect.midX, y: rect.maxY - 0.5))
            web.line(to: NSPoint(x: rect.midX, y: rect.midY + 3))
            web.lineWidth = 1
            web.stroke()

            let torso = NSBezierPath(
                roundedRect: NSRect(x: rect.midX - 2.5, y: rect.midY - 1, width: 5, height: 5),
                xRadius: 1.5,
                yRadius: 1.5
            )
            torso.fill()

            let head = NSBezierPath(
                ovalIn: NSRect(x: rect.midX - 2, y: rect.minY + 1.5, width: 4, height: 3.5)
            )
            head.fill()
            return true
        }
        image.isTemplate = true
        return image
    }

    private func startSpider() {
        controller.configure(hangLength: panel.spiderView.spriteHangLength)
        controller.appearNow()
        syncPanelFrame(forceOrderFront: true)
    }

    private func applySettingsToRuntime() {
        let settings = AppSettings.shared
        controller.applyTiming(
            hangDuration: settings.hangDuration,
            appearDelay: settings.appearDelay
        )
        panel.spiderView.skin = SpiderSkin.skin(for: settings.skinID)
        panel.spiderView.webStyleID = settings.webStyleID
        panel.spiderView.silkLength = settings.webLength
        panel.spiderView.figureScale = settings.spiderScale
        panel.spiderView.emotionsEnabled = settings.emotionsEnabled
        panel.spiderView.emotionInterval = CGFloat(settings.emotionInterval)
        controller.configure(hangLength: panel.spiderView.spriteHangLength)
    }

    private func startTickTimer() {
        tickTimer?.invalidate()
        lastTick = CFAbsoluteTimeGetCurrent()
        // Base cadence 30 Hz; idle hanging skips most redraws (see handleTick).
        let timer = Timer(timeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            MainActor.assumeIsolated {
                self?.handleTick()
            }
        }
        RunLoop.main.add(timer, forMode: .common)
        tickTimer = timer
    }

    private func handleTick() {
        let now = CFAbsoluteTimeGetCurrent()
        let dt = CGFloat(min(now - lastTick, 1.0 / 15.0))
        lastTick = now

        let wasVisible = controller.isVisible
        let previousMode = controller.mode
        controller.tick(dt: dt)

        if controller.isVisible {
            let eyesDirty = panel.spiderView.tickEyes(dt: dt)
            let poseDirty = controller.isPoseAnimating || previousMode != controller.mode
            syncPanelFrame(
                forceOrderFront: !wasVisible,
                needsRedraw: eyesDirty || poseDirty || !wasVisible
            )
        } else if wasVisible {
            hidePanel()
        }
    }

    private func hidePanel() {
        panel.orderOut(nil)
        lastPanelFrame = .zero
    }

    private func syncPanelFrame(forceOrderFront: Bool = false, needsRedraw: Bool = true) {
        guard controller.isVisible else { return }

        let scale = max(1, panel.spiderView.figureScale)
        let sidePadding: CGFloat = 42 * scale
        let belowHead: CGFloat = 28 * scale
        let body = controller.bodyPoint
        let tip = CGPoint(x: controller.anchor.x, y: controller.anchor.y + controller.ceilingPull)

        var minY = min(tip.y, body.y) - belowHead
        var maxY = max(tip.y, body.y) + 2

        if let screen = controller.currentScreen ?? NSScreen.main {
            let ceiling = screen.frame.maxY
            maxY = max(maxY, ceiling)
            minY = min(minY, ceiling - 2)
        }

        let frame = NSRect(
            x: tip.x - sidePadding,
            y: minY,
            width: sidePadding * 2,
            height: max(maxY - minY, 48)
        )

        let frameMoved = !framesEqual(frame, lastPanelFrame)
        if frameMoved {
            panel.setFrame(frame, display: false)
            lastPanelFrame = frame
        }

        if forceOrderFront {
            panel.orderFrontRegardless()
        }

        let view = panel.spiderView
        let newAnchor = CGPoint(x: tip.x - frame.origin.x, y: tip.y - frame.origin.y)
        let newBody = CGPoint(x: body.x - frame.origin.x, y: body.y - frame.origin.y)
        let poseChanged =
            abs(view.webAnchorInView.x - newAnchor.x) > 0.25
            || abs(view.webAnchorInView.y - newAnchor.y) > 0.25
            || abs(view.hangLength - controller.hangLength) > 0.25
            || abs(view.restHangLength - controller.restLength) > 0.25

        view.webAnchorInView = newAnchor
        view.bodyPointInView = newBody
        view.hangLength = controller.hangLength
        view.restHangLength = controller.restLength
        view.ceilingPull = 0

        if needsRedraw || frameMoved || poseChanged {
            view.needsDisplay = true
        }
    }

    private func framesEqual(_ a: NSRect, _ b: NSRect) -> Bool {
        abs(a.origin.x - b.origin.x) < 0.5
            && abs(a.origin.y - b.origin.y) < 0.5
            && abs(a.size.width - b.size.width) < 0.5
            && abs(a.size.height - b.size.height) < 0.5
    }

    @objc private func appearNow() {
        controller.appearNow()
        syncPanelFrame(forceOrderFront: true)
    }

    @objc private func hangStill() {
        controller.freezeInPlace()
        syncPanelFrame(forceOrderFront: true)
    }

    @objc private func openSettings() {
        if settingsWindow == nil {
            settingsWindow = SettingsWindowController { [weak self] in
                self?.applySettingsToRuntime()
                self?.rebuildLocalizedChrome()
            }
        }
        settingsWindow?.reloadFromSettings()
        settingsWindow?.showWindow(nil)
        settingsWindow?.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func settingsChanged() {
        applySettingsToRuntime()
        rebuildLocalizedChrome()
    }

    @objc private func quitApp() {
        NSApp.terminate(nil)
    }

    @objc private func screensChanged() {
        controller.updateAfterDisplayChange()
        if controller.isVisible {
            syncPanelFrame(forceOrderFront: true)
        }
    }

    @objc private func activeSpaceChanged() {
        controller.hideForStandardPause()
        hidePanel()
    }
}
