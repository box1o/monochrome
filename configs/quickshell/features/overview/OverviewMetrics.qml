import QtQml

QtObject {
    required property real fontSize
    readonly property real padding: 12
    readonly property real headerHeight: 36
    readonly property real clockSize: fontSize + 7
    readonly property real clockY: padding + (headerHeight - clockSize) / 2
}
