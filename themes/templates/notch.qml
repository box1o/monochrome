// Generated from themes/mono.yaml. Do not edit.
import QtQuick

QtObject {
    required property QtObject tokens

    readonly property real compactWidth: tokens.px({{notch.compact_width}})
    readonly property real compactHeight: tokens.px({{notch.compact_height}})
    readonly property real expandedWidth: tokens.px({{notch.expanded_width}})
    readonly property real expandedHeight: tokens.px({{notch.expanded_height}})
    readonly property real compactRadius: Math.min(tokens.px({{notch.compact_radius}}), Math.floor(compactHeight / 4) * 2)
    readonly property real expandedRadius: tokens.px({{notch.expanded_radius}})
    readonly property real shoulder: tokens.px({{notch.shoulder}})
    readonly property real closeDelay: {{notch.close_delay}}
    readonly property color background: "#{{notch.background}}"
    readonly property color foreground: "#{{notch.foreground}}"
    readonly property real clockSpacing: tokens.px({{notch.clock_spacing}})
    readonly property real clockDotSpacing: {{notch.clock_dot_spacing}}
    readonly property real clockRowSpacing: {{notch.clock_row_spacing}}
    readonly property real clockWeight: {{notch.clock_weight}}
    readonly property real clockSizeOffset: tokens.px({{notch.clock_size_offset}})
    readonly property color activityColor: "#{{notch.activity_color}}"
}
