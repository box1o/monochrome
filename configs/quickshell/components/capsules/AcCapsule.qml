import QtQuick
import QtQuick.Layouts

RowLayout {
    property var rootState

        id: acCapsule
        z: 110
        anchors.centerIn: parent
        spacing: 8
        visible: rootState.acToastActive
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

        Text {
            Layout.alignment: Qt.AlignVCenter
            text: String.fromCodePoint(0xF0241)
            color: rootState.colOk
            font { family: rootState.fontFam; pixelSize: rootState.iconSize + 3 }
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: rootState.tr("Charging")
            color: rootState.colFg
            font { family: rootState.fontFam; pixelSize: rootState.fontSize; bold: true }
        }
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: rootState.batteryPct + "%"
            color: rootState.colOk
            font { family: rootState.fontFam; pixelSize: rootState.fontSize; bold: true }
        }
    }
