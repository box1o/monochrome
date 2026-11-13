import QtQml

QtObject {
    required property QtObject tokens
    property real contentPadding: tokens.sectionSpacing
    property real sectionSpacing: tokens.spacing
    readonly property real padding: contentPadding
    readonly property real headerHeight: tokens.px(36)
    readonly property real clockSize: tokens.largeClockSize
    readonly property real clockY: padding + (headerHeight - clockSize) / 2
}
