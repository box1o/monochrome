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

    implicitHeight: 44
    padding: 8
    rightPadding: 18
    hoverEnabled: true
    Accessible.name: title

    background: Rectangle {
        radius: row.tokens.radius + 2
        color: row.tokens.alpha(row.tokens.foreground, row.down ? 0.09 : row.selected ? 0.055 : row.hovered ? 0.03 : 0)

        Behavior on color {
            ColorAnimation {
                duration: row.tokens.motionEnabled ? row.tokens.fastDuration : 0
            }
        }
    }

    contentItem: RowLayout {
        spacing: 10

        Item {
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24

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
                width: 20
                height: 20
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
            spacing: 2

            Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                text: row.title
                color: row.tokens.foreground
                font.family: row.tokens.fontFamily
                font.pixelSize: row.tokens.fontSize - 2
                elide: Text.ElideRight
            }

            Text {
                textFormat: Text.PlainText
                Layout.fillWidth: true
                visible: text.length > 0
                text: row.subtitle
                color: row.tokens.muted
                font.family: row.tokens.fontFamily
                font.pixelSize: row.tokens.fontSize - 4
                elide: Text.ElideRight
            }
        }

        AssetIcon {
            Layout.preferredWidth: 16
            Layout.preferredHeight: 16
            Layout.leftMargin: 12
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
