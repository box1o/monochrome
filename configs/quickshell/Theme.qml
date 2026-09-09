import QtQuick

QtObject {
    property var cfg

    readonly property color background: "#000000"
    readonly property color foreground: "#ffffff"
    readonly property color muted: Qt.rgba(foreground.r, foreground.g, foreground.b,
                                           cfg ? cfg.mutedAlpha : 0.45)
    readonly property color line: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.10)
    readonly property color hover: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.10)
    readonly property color active: "#ffffff"
    readonly property color success: "#ffffff"
    readonly property color critical: "#d71921"
}
