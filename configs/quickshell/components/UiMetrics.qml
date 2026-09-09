import QtQuick

QtObject {
    property int fontSize: 15
    property int iconSize: 17
    property int dotSmall: 12

    property int notchHeight: 28
    readonly property int notchClockSize: Math.max(10, fontSize - 3)
    readonly property int notchIconSize: Math.max(11, iconSize - 3)
    readonly property int notchDigitSize: Math.max(8, dotSmall - 2)
    readonly property int notchWorkspaceGap: 6
    readonly property int notchSideGap: 7
    readonly property int notchBatteryGap: 4
}
