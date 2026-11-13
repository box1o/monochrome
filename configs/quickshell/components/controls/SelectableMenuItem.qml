import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../icons"

AbstractButton {
    id: row

    required property string title
    property string subtitle: ""
    property url iconSource: ""
    property string iconName: ""
    required property QtObject tokens
    property bool selected: false
    property color iconColor: tokens.muted

    implicitHeight: tokens.rowHeight
    padding: tokens.px(8)
    rightPadding: tokens.px(18)
    hoverEnabled: true
    Accessible.name: title

    background: Rectangle {
        radius: row.tokens.controlRadius
        color: row.down ? row.tokens.pressedBackground : row.selected ? row.tokens.selectionBackground : row.hovered ? row.tokens.hoverBackground : "transparent"
        border.width: row.visualFocus ? 1 : 0
        border.color: row.tokens.focusColor

        Behavior on color {
            ColorAnimation {
                duration: row.tokens.motionEnabled ? row.tokens.fastDuration : 0
            }
        }
    }

    contentItem: RowLayout {
        spacing: tokens.px(10)

        Item {
            Layout.preferredWidth: tokens.px(24)
            Layout.preferredHeight: tokens.px(24)

            Image {
                id: icon

                anchors.fill: parent
                visible: row.iconName.length === 0
                source: row.iconSource
                sourceSize.width: 24
                sourceSize.height: 24
                fillMode: Image.PreserveAspectFit
            }

            AssetIcon {
                anchors.centerIn: parent
                width: tokens.px(20)
                height: tokens.px(20)
                name: row.iconName
                visible: row.iconName.length > 0
                color: row.iconColor
            }

            Text {
                textFormat: Text.PlainText
                anchors.centerIn: parent
                visible: row.iconName.length === 0 && (icon.source.toString() === "" || icon.status === Image.Error)
                text: row.title.charAt(0).toUpperCase()
                font.family: row.tokens.fontFamily
                font.pixelSize: row.tokens.fontSize
                color: row.tokens.foreground
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: tokens.px(2)

            Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                text: row.title
                color: row.tokens.foreground
                font.family: row.tokens.fontFamily
                font.pixelSize: row.tokens.bodySize
                elide: Text.ElideRight
            }

            Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                visible: text.length > 0
                text: row.subtitle
                color: row.tokens.muted
                font.family: row.tokens.fontFamily
                font.pixelSize: row.tokens.detailSize
                elide: Text.ElideRight
            }
        }

        AssetIcon {
            Layout.preferredWidth: tokens.px(16)
            Layout.preferredHeight: tokens.px(16)
            Layout.leftMargin: tokens.px(12)
            Layout.alignment: Qt.AlignVCenter
            name: "arrow-up-right"
            color: row.tokens.muted
            opacity: row.selected || row.hovered ? 1 : 0

            Behavior on opacity {
                NumberAnimation {
                    duration: row.tokens.motionEnabled ? row.tokens.fastDuration : 0
                }
            }
        }
    }
}
