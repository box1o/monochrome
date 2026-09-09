import QtQuick
import QtQuick.Layouts

Item {
    id: nothingCapsule
    property var rootState
    property var metrics

    readonly property real compactFont: metrics.notchClockSize
    readonly property real compactIcon: metrics.notchIconSize
    readonly property real compactDots: metrics.notchDigitSize
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.verticalCenter: parent.verticalCenter
    anchors.leftMargin: 12
    anchors.rightMargin: 12
    height: metrics.notchHeight
    visible: rootState.themeNothing && !rootState.expanded && !rootState.btToastActive && !rootState.acToastActive
             && !rootState.osdActive && !rootState.toastActive
    opacity: rootState.pillSide ? 0 : (visible ? 1 : 0)
    Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

    readonly property real armGap: 13
    readonly property int wsSlots: 5
    readonly property real wsReserve: nothingCapsule.wsSlots * 5 + (nothingCapsule.wsSlots - 1) * nLeft.spacing + 10
    readonly property real arm: Math.max(nLeft.implicitWidth, nRight.implicitWidth)
    implicitWidth: nClock.implicitWidth + 2 * (nothingCapsule.arm + nothingCapsule.armGap)

    RowLayout {
        id: nLeft
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: metrics.notchWorkspaceGap
        Item {
            Layout.preferredWidth: Math.max(wsRow.implicitWidth, nothingCapsule.wsReserve)
            Layout.preferredHeight: 6
            RowLayout {
                id: wsRow
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                spacing: nLeft.spacing
                Repeater {
                    model: rootState.wsList
                    Rectangle {
                        required property var modelData
                        readonly property bool here: modelData === rootState.wsId
                        property real len: here ? 15 : 5
                        property bool settled: false
                        Component.onCompleted: settled = true
                        Layout.preferredWidth: len
                        Layout.preferredHeight: 5
                        radius: 2.5
                        color: rootState.colFg
                        opacity: here ? 1 : 0.3
                        Behavior on len { enabled: settled; NumberAnimation { duration: rootState.animMs; easing.type: Easing.OutCubic } }
                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -5
                            onClicked: rootState.gotoWorkspace(modelData)
                        }
                    }
                }
            }
        }
    }

    DotText {
        id: nClock
        anchors.centerIn: parent
        value: rootState.timeText
        size: nothingCapsule.compactFont
        //
        gapRatio: 0.1
        color: rootState.colFg
    }

    RowLayout {
        id: nRight
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        spacing: metrics.notchSideGap

        Rectangle {
            visible: rootState.srcAudio !== null && !rootState.srcAudio.muted
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            radius: 3
            color: "#22c55e"
        }

        RowLayout {
            spacing: metrics.notchBatteryGap
            visible: rootState.batteryPresent
            Text {
                text: rootState.batteryIcon
                color: rootState.batteryPct <= 15 && !rootState.acOnline ? rootState.colCrit : rootState.colFg
                font { family: rootState.fontFam; pixelSize: nothingCapsule.compactIcon - 2 }
            }
            DotText {
                value: String(rootState.batteryPct)
                size: nothingCapsule.compactDots
                color: rootState.batteryPct <= 15 && !rootState.acOnline ? rootState.colCrit : rootState.colFg
            }
        }
    }
}
