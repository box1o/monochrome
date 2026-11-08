import QtQuick
import QtQuick.Controls
import "../../components/controls"

LabeledSlider {
    id: slider

    required property QtObject source
    property bool inverted: false

    description: "Display brightness"
    displayIconName: "brightness"
    enabled: source.available
    from: 0.05
    stepSize: 0.05
    snapMode: Slider.SnapOnRelease
    focusOutline: !inverted
    trackColor: inverted ? tokens.alpha(tokens.background, 0.9) : tokens.alpha(tokens.foreground, 0.08)
    fillColor: inverted ? tokens.background : tokens.foreground
    readoutColor: tokens.foreground
    filledReadoutColor: inverted ? tokens.foreground : tokens.background
    label: enabled ? Math.round(value * 20) * 5 + "%" : "—"
    onMoved: source.setPercentage(value * 100)

    // Backend reads must not pull an active drag back to an older hardware value.
    Binding {
        target: slider
        property: "value"
        value: Math.max(slider.from, slider.source.percentage / 100)
        when: !slider.pressed && !slider.source.busy
        restoreMode: Binding.RestoreNone
    }
}
