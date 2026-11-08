import QtQuick
import QtQuick.Effects
import Quickshell

Item {
    id: icon

    required property string name
    required property color color
    property real inset: ["wifi", "wifi-off", "bluetooth", "bluetooth-off"].includes(name) ? 0 : 1

    implicitWidth: 16
    implicitHeight: 16

    Image {
        id: image

        anchors.fill: parent
        anchors.margins: icon.inset
        source: icon.name ? "file://" + Quickshell.env("HOME") + "/.local/share/mono/icons/lucide/" + icon.name + ".svg" : ""
        sourceSize.width: width
        sourceSize.height: height
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    MultiEffect {
        anchors.fill: image
        anchors.margins: icon.inset
        source: image
        colorization: 1
        colorizationColor: icon.color
    }
}
