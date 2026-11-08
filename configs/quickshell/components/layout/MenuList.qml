import QtQuick

ListView {
    implicitHeight: Math.max(36, contentHeight)
    clip: true
    boundsBehavior: Flickable.StopAtBounds
}
