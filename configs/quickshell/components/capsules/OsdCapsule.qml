import QtQuick
import QtQuick.Layouts

RowLayout {
    property var rootState

        id: osdCapsule
        anchors.centerIn: parent
        height: rootState.pillH
        spacing: 12
        visible: rootState.osdActive && !rootState.toastActive && !rootState.btToastActive && !rootState.acToastActive
        opacity: visible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

        Text {
            text: rootState.osdIcon
            color: rootState.osdMuted ? rootState.colMuted : rootState.colFg
            Layout.preferredWidth: rootState.iconSize + 4
            horizontalAlignment: Text.AlignHCenter
            font { family: rootState.fontFam; pixelSize: rootState.iconSize }
            Behavior on color { ColorAnimation { duration: 160 } }
        }

        Rectangle {
            Layout.preferredWidth: 150
            Layout.preferredHeight: 5
            Layout.alignment: Qt.AlignVCenter
            radius: 3
            color: Qt.rgba(1, 1, 1, 0.16)

            Rectangle {
                width: parent.width * (rootState.osdMuted ? 0 : rootState.osdValue)
                height: parent.height
                radius: 3
                color: rootState.osdKind === "bright" ? rootState.colWarn : rootState.colOn
                Behavior on width {
                    NumberAnimation { duration: 120; easing.type: Easing.OutCubic }
                }
                Behavior on color { ColorAnimation { duration: 160 } }
            }
        }

        Text {
            Layout.preferredWidth: rootState.fontSize * 2.5
            horizontalAlignment: Text.AlignRight
            text: rootState.osdMuted ? "—" : Math.round(rootState.osdValue * 100) + "%"
            color: rootState.colMuted
            font { family: rootState.fontFam; pixelSize: rootState.fontSize - 1; bold: true }
        }
}
