import QtQuick

ListView {
    id: list

    property bool motionEnabled: true

    implicitHeight: Math.max(36, contentHeight)
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    ScrollMotion {
        motionEnabled: list.motionEnabled
    }
}
