// Generated from themes/mono.yaml. Do not edit.
import QtQuick

QtObject {
    readonly property color background: "#{{colors.background}}"
    readonly property color surface: "#{{colors.surface}}"
    readonly property color surface_bright: "#{{colors.surface_bright}}"
    readonly property color foreground: "#{{colors.foreground}}"
    readonly property color muted: "#{{colors.muted}}"
    readonly property color border: "#{{colors.border}}"
    readonly property color accent: "#{{colors.accent}}"
    readonly property color on_accent: "#{{colors.on_accent}}"
    readonly property color red: "#{{colors.red}}"
    readonly property color green: "#{{colors.green}}"
    readonly property color yellow: "#{{colors.yellow}}"
    readonly property color blue: "#{{colors.blue}}"
    readonly property color magenta: "#{{colors.magenta}}"
    readonly property color cyan: "#{{colors.cyan}}"
    readonly property color white: "#{{colors.white}}"
    readonly property color black: "#{{colors.black}}"
    readonly property real radius: {{geometry.radius}}
    readonly property real radius_small: {{geometry.radius_small}}
    readonly property real border_width: {{geometry.border_width}}
    readonly property real gap_inner: {{geometry.gap_inner}}
    readonly property real gap_outer: {{geometry.gap_outer}}
    readonly property real padding: {{geometry.padding}}
    readonly property string fontFamily: "{{fonts.family}}"
    readonly property string monoFamily: "{{fonts.mono_family}}"
    readonly property real fontSize: {{fonts.shell_size}}
    readonly property real iconSize: {{fonts.icon_size}}
    readonly property real fastDuration: {{duration.fast_ms}}
    readonly property real normalDuration: {{duration.normal_ms}}
    readonly property real slowDuration: {{duration.slow_ms}}
    readonly property bool motionEnabled: {{motion.enabled}}
    readonly property real motionScale: {{motion.scale}}
    readonly property var curve: [{{motion.curve.0}}, {{motion.curve.1}}, {{motion.curve.2}}, {{motion.curve.3}}, 1, 1]
    readonly property real opacity: {{appearance.opacity}}

    // Shared presentation roles keep feature views on the system palette.
    readonly property color cardBackground: "#{{notch.background}}"
    readonly property color cardBorder: alpha(border, 0.22)
    readonly property color controlBackground: background
    readonly property color hoverBackground: alpha(foreground, 0.045)
    readonly property color pressedBackground: alpha(foreground, 0.14)
    readonly property color selectionBackground: alpha(blue, 0.13)
    readonly property color focusColor: blue
    readonly property color onFill: foregroundOn(foreground)
    readonly property real spacing: padding + gap_inner
    readonly property real sectionSpacing: padding * 2
    readonly property real cardInset: spacing
    readonly property real cardRadius: radius + 5
    readonly property real controlRadius: radius + 2
    readonly property real cardHeight: 54
    readonly property real buttonSize: 30
    readonly property real rowHeight: 44
    readonly property real fieldHeight: 36
    readonly property real bodySize: Math.max(12, fontSize - 2)
    readonly property real labelSize: Math.max(11, fontSize - 3)
    readonly property real detailSize: Math.max(10, fontSize - 4)
    readonly property real captionSize: Math.max(10, fontSize - 5)

    function alpha(color, opacity) { return Qt.rgba(color.r, color.g, color.b, opacity); }
    function duration(milliseconds) { return motionEnabled ? Math.round(milliseconds * normalDuration / 160) : 0; }

    function luminance(color) {
        function linear(channel) {
            return channel <= 0.04045 ? channel / 12.92 : Math.pow((channel + 0.055) / 1.055, 2.4);
        }
        return 0.2126 * linear(color.r) + 0.7152 * linear(color.g) + 0.0722 * linear(color.b);
    }
    function foregroundOn(color) {
        const value = luminance(color);
        function contrast(candidate) {
            const other = luminance(candidate);
            return (Math.max(value, other) + 0.05) / (Math.min(value, other) + 0.05);
        }
        return contrast(foreground) >= contrast(on_accent) ? foreground : on_accent;
    }
}
