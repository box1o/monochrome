import QtQml

QtObject {
    required property real fontSize
    property real contentPadding: 12
    property real sectionSpacing: 8
    readonly property real padding: contentPadding
    readonly property real headerHeight: 36
    readonly property real clockSize: fontSize + 7
    readonly property real clockY: padding + (headerHeight - clockSize) / 2
}
