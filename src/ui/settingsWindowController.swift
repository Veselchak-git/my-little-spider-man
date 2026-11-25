import AppKit

@MainActor
final class SettingsWindowController: NSWindowController, NSTextFieldDelegate {
    private let hangStepper = NSStepper()
    private let delayStepper = NSStepper()
    private let webStepper = NSStepper()
    private let scaleStepper = NSStepper()
    private let emotionIntervalStepper = NSStepper()

    private let hangField = NSTextField(string: "")
    private let delayField = NSTextField(string: "")
    private let webField = NSTextField(string: "")
    private let scaleField = NSTextField(string: "")
    private let emotionIntervalField = NSTextField(string: "")

    private let skinPopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let webStylePopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let languagePopUp = NSPopUpButton(frame: .zero, pullsDown: false)
    private let emotionsCheckbox = NSButton(checkboxWithTitle: "", target: nil, action: nil)

    private let hangLabel = NSTextField(labelWithString: "")
    private let delayLabel = NSTextField(labelWithString: "")
    private let webLabel = NSTextField(labelWithString: "")
    private let scaleLabel = NSTextField(labelWithString: "")
    private let emotionIntervalLabel = NSTextField(labelWithString: "")
    private let skinLabel = NSTextField(labelWithString: "")
    private let webStyleLabel = NSTextField(labelWithString: "")
    private let languageLabel = NSTextField(labelWithString: "")

    private var onChange: (() -> Void)?

    convenience init(onChange: @escaping () -> Void) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 440, height: 470),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.isReleasedWhenClosed = false
        window.center()
        self.init(window: window)
        self.onChange = onChange
        window.contentView = makeContent()
        reloadFromSettings()
    }

    private func makeContent() -> NSView {
        let root = NSView(frame: NSRect(x: 0, y: 0, width: 440, height: 470))

        for label in [hangLabel, delayLabel, webLabel, scaleLabel, emotionIntervalLabel, skinLabel, webStyleLabel, languageLabel] {
            label.font = .systemFont(ofSize: 13)
        }

        configureStepper(
            hangStepper,
            min: AppSettings.Range.hangDuration.lowerBound,
            max: AppSettings.Range.hangDuration.upperBound,
            increment: 1,
            action: #selector(hangStepperChanged)
        )
        configureStepper(
            delayStepper,
            min: AppSettings.Range.appearDelay.lowerBound,
            max: AppSettings.Range.appearDelay.upperBound,
            increment: 1,
            action: #selector(delayStepperChanged)
        )
        configureStepper(
            webStepper,
            min: AppSettings.Range.webLength.lowerBound,
            max: AppSettings.Range.webLength.upperBound,
            increment: 2,
            action: #selector(webStepperChanged)
        )
        configureStepper(
            scaleStepper,
            min: AppSettings.Range.spiderScale.lowerBound * 100,
            max: AppSettings.Range.spiderScale.upperBound * 100,
            increment: 5,
            action: #selector(scaleStepperChanged)
        )
        configureStepper(
            emotionIntervalStepper,
            min: AppSettings.Range.emotionInterval.lowerBound,
            max: AppSettings.Range.emotionInterval.upperBound,
            increment: 1,
            action: #selector(emotionIntervalStepperChanged)
        )

        configureNumberField(
            hangField,
            min: AppSettings.Range.hangDuration.lowerBound,
            max: AppSettings.Range.hangDuration.upperBound,
            action: #selector(hangFieldChanged)
        )
        configureNumberField(
            delayField,
            min: AppSettings.Range.appearDelay.lowerBound,
            max: AppSettings.Range.appearDelay.upperBound,
            action: #selector(delayFieldChanged)
        )
        configureNumberField(
            webField,
            min: AppSettings.Range.webLength.lowerBound,
            max: AppSettings.Range.webLength.upperBound,
            action: #selector(webFieldChanged)
        )
        configureNumberField(
            scaleField,
            min: AppSettings.Range.spiderScale.lowerBound * 100,
            max: AppSettings.Range.spiderScale.upperBound * 100,
            action: #selector(scaleFieldChanged)
        )
        configureNumberField(
            emotionIntervalField,
            min: AppSettings.Range.emotionInterval.lowerBound,
            max: AppSettings.Range.emotionInterval.upperBound,
            action: #selector(emotionIntervalFieldChanged)
        )

        emotionsCheckbox.target = self
        emotionsCheckbox.action = #selector(emotionsCheckboxChanged)
        emotionsCheckbox.font = .systemFont(ofSize: 13)

        skinPopUp.target = self
        skinPopUp.action = #selector(skinChanged)
        webStylePopUp.target = self
        webStylePopUp.action = #selector(webStyleChanged)
        languagePopUp.target = self
        languagePopUp.action = #selector(languageChanged)

        let hangRow = row(
            label: hangLabel,
            value: hangField,
            stepper: hangStepper,
            min: AppSettings.Range.hangDuration.lowerBound,
            max: AppSettings.Range.hangDuration.upperBound
        )
        let delayRow = row(
            label: delayLabel,
            value: delayField,
            stepper: delayStepper,
            min: AppSettings.Range.appearDelay.lowerBound,
            max: AppSettings.Range.appearDelay.upperBound
        )
        let webRow = row(
            label: webLabel,
            value: webField,
            stepper: webStepper,
            min: AppSettings.Range.webLength.lowerBound,
            max: AppSettings.Range.webLength.upperBound
        )
        let scaleRow = row(
            label: scaleLabel,
            value: scaleField,
            stepper: scaleStepper,
            min: AppSettings.Range.spiderScale.lowerBound * 100,
            max: AppSettings.Range.spiderScale.upperBound * 100
        )
        let emotionIntervalRow = row(
            label: emotionIntervalLabel,
            value: emotionIntervalField,
            stepper: emotionIntervalStepper,
            min: AppSettings.Range.emotionInterval.lowerBound,
            max: AppSettings.Range.emotionInterval.upperBound
        )

        for view in [
            hangRow, delayRow, webRow, scaleRow,
            emotionsCheckbox, emotionIntervalRow,
            skinLabel, skinPopUp, webStyleLabel, webStylePopUp, languageLabel, languagePopUp
        ] {
            view.translatesAutoresizingMaskIntoConstraints = false
            root.addSubview(view)
        }

        NSLayoutConstraint.activate([
            hangRow.topAnchor.constraint(equalTo: root.topAnchor, constant: 22),
            hangRow.leadingAnchor.constraint(equalTo: root.leadingAnchor, constant: 20),
            hangRow.trailingAnchor.constraint(equalTo: root.trailingAnchor, constant: -20),

            delayRow.topAnchor.constraint(equalTo: hangRow.bottomAnchor, constant: 14),
            delayRow.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),
            delayRow.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            webRow.topAnchor.constraint(equalTo: delayRow.bottomAnchor, constant: 14),
            webRow.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),
            webRow.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            scaleRow.topAnchor.constraint(equalTo: webRow.bottomAnchor, constant: 14),
            scaleRow.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),
            scaleRow.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            emotionsCheckbox.topAnchor.constraint(equalTo: scaleRow.bottomAnchor, constant: 18),
            emotionsCheckbox.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),
            emotionsCheckbox.trailingAnchor.constraint(lessThanOrEqualTo: hangRow.trailingAnchor),

            emotionIntervalRow.topAnchor.constraint(equalTo: emotionsCheckbox.bottomAnchor, constant: 12),
            emotionIntervalRow.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),
            emotionIntervalRow.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            skinLabel.topAnchor.constraint(equalTo: emotionIntervalRow.bottomAnchor, constant: 18),
            skinLabel.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),

            skinPopUp.centerYAnchor.constraint(equalTo: skinLabel.centerYAnchor),
            skinPopUp.leadingAnchor.constraint(equalTo: root.centerXAnchor, constant: -28),
            skinPopUp.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            webStyleLabel.topAnchor.constraint(equalTo: skinLabel.bottomAnchor, constant: 16),
            webStyleLabel.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),

            webStylePopUp.centerYAnchor.constraint(equalTo: webStyleLabel.centerYAnchor),
            webStylePopUp.leadingAnchor.constraint(equalTo: skinPopUp.leadingAnchor),
            webStylePopUp.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor),

            languageLabel.topAnchor.constraint(equalTo: webStyleLabel.bottomAnchor, constant: 16),
            languageLabel.leadingAnchor.constraint(equalTo: hangRow.leadingAnchor),

            languagePopUp.centerYAnchor.constraint(equalTo: languageLabel.centerYAnchor),
            languagePopUp.leadingAnchor.constraint(equalTo: skinPopUp.leadingAnchor),
            languagePopUp.trailingAnchor.constraint(equalTo: hangRow.trailingAnchor)
        ])

        return root
    }

    private func configureStepper(
        _ stepper: NSStepper,
        min: Double,
        max: Double,
        increment: Double,
        action: Selector
    ) {
        stepper.minValue = min
        stepper.maxValue = max
        stepper.increment = increment
        stepper.valueWraps = false
        stepper.target = self
        stepper.action = action
    }

    private func configureNumberField(_ field: NSTextField, min: Double, max: Double, action: Selector) {
        field.font = .monospacedDigitSystemFont(ofSize: 13, weight: .regular)
        field.alignment = .right
        field.isEditable = true
        field.isSelectable = true
        field.isBezeled = true
        field.bezelStyle = .roundedBezel
        field.focusRingType = .default
        field.delegate = self
        field.target = self
        field.action = action
        field.formatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .none
            formatter.minimum = NSNumber(value: min)
            formatter.maximum = NSNumber(value: max)
            formatter.allowsFloats = false
            return formatter
        }()
    }

    private func row(
        label: NSTextField,
        value: NSTextField,
        stepper: NSStepper,
        min: Double,
        max: Double
    ) -> NSView {
        let box = NSView()
        let rangeHint = NSTextField(labelWithString: rangeText(min: min, max: max))
        rangeHint.font = .monospacedDigitSystemFont(ofSize: 11, weight: .regular)
        rangeHint.textColor = .secondaryLabelColor
        rangeHint.alignment = .right
        rangeHint.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        rangeHint.setContentCompressionResistancePriority(.required, for: .horizontal)

        label.translatesAutoresizingMaskIntoConstraints = false
        rangeHint.translatesAutoresizingMaskIntoConstraints = false
        value.translatesAutoresizingMaskIntoConstraints = false
        stepper.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(label)
        box.addSubview(rangeHint)
        box.addSubview(value)
        box.addSubview(stepper)

        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: box.leadingAnchor),
            label.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: rangeHint.leadingAnchor, constant: -8),

            stepper.trailingAnchor.constraint(equalTo: box.trailingAnchor),
            stepper.centerYAnchor.constraint(equalTo: box.centerYAnchor),

            value.trailingAnchor.constraint(equalTo: stepper.leadingAnchor, constant: -8),
            value.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            value.widthAnchor.constraint(equalToConstant: 58),

            rangeHint.trailingAnchor.constraint(equalTo: value.leadingAnchor, constant: -8),
            rangeHint.centerYAnchor.constraint(equalTo: box.centerYAnchor),

            box.heightAnchor.constraint(equalToConstant: 28)
        ])
        return box
    }

    private func rangeText(min: Double, max: Double) -> String {
        "\(Int(min.rounded()))–\(Int(max.rounded()))"
    }

    func reloadFromSettings() {
        applyLocalizedLabels()
        rebuildPopUps()

        let settings = AppSettings.shared
        setHang(settings.hangDuration)
        setDelay(settings.appearDelay)
        setWeb(Double(settings.webLength))
        setScalePercent(settings.spiderScalePercent)
        setEmotionInterval(settings.emotionInterval)
        emotionsCheckbox.state = settings.emotionsEnabled ? .on : .off
        updateEmotionIntervalEnabled()

        if let index = SpiderSkinID.allCases.firstIndex(of: settings.skinID) {
            skinPopUp.selectItem(at: index)
        }
        if let index = WebStyleID.allCases.firstIndex(of: settings.webStyleID) {
            webStylePopUp.selectItem(at: index)
        }
        if let index = AppLanguage.allCases.firstIndex(of: settings.language) {
            languagePopUp.selectItem(at: index)
        }
    }

    private func applyLocalizedLabels() {
        window?.title = L10n.tr("settings.title")
        hangLabel.stringValue = L10n.tr("settings.hang_duration")
        delayLabel.stringValue = L10n.tr("settings.appear_delay")
        webLabel.stringValue = L10n.tr("settings.web_length")
        scaleLabel.stringValue = L10n.tr("settings.spider_scale")
        emotionsCheckbox.title = L10n.tr("settings.emotions_enabled")
        emotionIntervalLabel.stringValue = L10n.tr("settings.emotion_interval")
        skinLabel.stringValue = L10n.tr("settings.skin")
        webStyleLabel.stringValue = L10n.tr("settings.web_style")
        languageLabel.stringValue = L10n.tr("settings.language")
    }

    private func rebuildPopUps() {
        let selectedSkin = AppSettings.shared.skinID
        let selectedWebStyle = AppSettings.shared.webStyleID
        let selectedLanguage = AppSettings.shared.language

        skinPopUp.removeAllItems()
        for skin in SpiderSkinID.allCases {
            skinPopUp.addItem(withTitle: skin.title)
            skinPopUp.lastItem?.representedObject = skin.rawValue
        }
        if let index = SpiderSkinID.allCases.firstIndex(of: selectedSkin) {
            skinPopUp.selectItem(at: index)
        }

        webStylePopUp.removeAllItems()
        for style in WebStyleID.allCases {
            webStylePopUp.addItem(withTitle: style.title)
            webStylePopUp.lastItem?.representedObject = style.rawValue
        }
        if let index = WebStyleID.allCases.firstIndex(of: selectedWebStyle) {
            webStylePopUp.selectItem(at: index)
        }

        languagePopUp.removeAllItems()
        for language in AppLanguage.allCases {
            languagePopUp.addItem(withTitle: language.title)
            languagePopUp.lastItem?.representedObject = language.rawValue
        }
        if let index = AppLanguage.allCases.firstIndex(of: selectedLanguage) {
            languagePopUp.selectItem(at: index)
        }
    }

    private func setHang(_ value: Double) {
        let clamped = min(AppSettings.Range.hangDuration.upperBound, max(AppSettings.Range.hangDuration.lowerBound, value.rounded()))
        hangStepper.doubleValue = clamped
        hangField.integerValue = Int(clamped)
    }

    private func setDelay(_ value: Double) {
        let clamped = min(AppSettings.Range.appearDelay.upperBound, max(AppSettings.Range.appearDelay.lowerBound, value.rounded()))
        delayStepper.doubleValue = clamped
        delayField.integerValue = Int(clamped)
    }

    private func setWeb(_ value: Double) {
        let clamped = min(AppSettings.Range.webLength.upperBound, max(AppSettings.Range.webLength.lowerBound, value.rounded()))
        webStepper.doubleValue = clamped
        webField.integerValue = Int(clamped)
    }

    private func setScalePercent(_ value: Int) {
        let minP = Int(AppSettings.Range.spiderScale.lowerBound * 100)
        let maxP = Int(AppSettings.Range.spiderScale.upperBound * 100)
        let clamped = min(maxP, max(minP, value))
        scaleStepper.doubleValue = Double(clamped)
        scaleField.integerValue = clamped
    }

    private func setEmotionInterval(_ value: Double) {
        let clamped = min(
            AppSettings.Range.emotionInterval.upperBound,
            max(AppSettings.Range.emotionInterval.lowerBound, value.rounded())
        )
        emotionIntervalStepper.doubleValue = clamped
        emotionIntervalField.integerValue = Int(clamped)
    }

    private func updateEmotionIntervalEnabled() {
        let on = emotionsCheckbox.state == .on
        emotionIntervalField.isEnabled = on
        emotionIntervalStepper.isEnabled = on
        emotionIntervalLabel.alphaValue = on ? 1 : 0.45
    }

    private func commitHang(_ value: Double) {
        setHang(value)
        AppSettings.shared.hangDuration = hangStepper.doubleValue
        onChange?()
    }

    private func commitDelay(_ value: Double) {
        setDelay(value)
        AppSettings.shared.appearDelay = delayStepper.doubleValue
        onChange?()
    }

    private func commitWeb(_ value: Double) {
        setWeb(value)
        AppSettings.shared.webLength = CGFloat(webStepper.doubleValue)
        onChange?()
    }

    private func commitScale(_ percent: Int) {
        setScalePercent(percent)
        AppSettings.shared.spiderScalePercent = Int(scaleStepper.doubleValue)
        onChange?()
    }

    private func commitEmotionInterval(_ value: Double) {
        setEmotionInterval(value)
        AppSettings.shared.emotionInterval = emotionIntervalStepper.doubleValue
        onChange?()
    }

    @objc private func hangStepperChanged() { commitHang(hangStepper.doubleValue) }
    @objc private func delayStepperChanged() { commitDelay(delayStepper.doubleValue) }
    @objc private func webStepperChanged() { commitWeb(webStepper.doubleValue) }
    @objc private func scaleStepperChanged() { commitScale(Int(scaleStepper.doubleValue)) }
    @objc private func emotionIntervalStepperChanged() { commitEmotionInterval(emotionIntervalStepper.doubleValue) }

    @objc private func hangFieldChanged() { commitHang(Double(hangField.integerValue)) }
    @objc private func delayFieldChanged() { commitDelay(Double(delayField.integerValue)) }
    @objc private func webFieldChanged() { commitWeb(Double(webField.integerValue)) }
    @objc private func scaleFieldChanged() { commitScale(scaleField.integerValue) }
    @objc private func emotionIntervalFieldChanged() { commitEmotionInterval(Double(emotionIntervalField.integerValue)) }

    @objc private func emotionsCheckboxChanged() {
        AppSettings.shared.emotionsEnabled = emotionsCheckbox.state == .on
        updateEmotionIntervalEnabled()
        onChange?()
    }

    func controlTextDidEndEditing(_ obj: Notification) {
        guard let field = obj.object as? NSTextField else { return }
        switch field {
        case hangField: hangFieldChanged()
        case delayField: delayFieldChanged()
        case webField: webFieldChanged()
        case scaleField: scaleFieldChanged()
        case emotionIntervalField: emotionIntervalFieldChanged()
        default: break
        }
    }

    @objc private func skinChanged() {
        guard let raw = skinPopUp.selectedItem?.representedObject as? String,
              let skin = SpiderSkinID(rawValue: raw)
        else { return }
        AppSettings.shared.skinID = skin
        onChange?()
    }

    @objc private func webStyleChanged() {
        guard let raw = webStylePopUp.selectedItem?.representedObject as? String,
              let style = WebStyleID(rawValue: raw)
        else { return }
        AppSettings.shared.webStyleID = style
        onChange?()
    }

    @objc private func languageChanged() {
        guard let raw = languagePopUp.selectedItem?.representedObject as? String,
              let language = AppLanguage(rawValue: raw)
        else { return }
        AppSettings.shared.language = language
        reloadFromSettings()
        onChange?()
    }
}
