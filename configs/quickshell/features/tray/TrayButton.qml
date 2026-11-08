import QtQuick
import QtQuick.Controls
import Quickshell.Services.SystemTray
import "../../components/controls"

AbstractButton {
    id: button

    required property SystemTrayItem trayItem
    required property QtObject tokens
    readonly property string title: trayItem.tooltipTitle || trayItem.title || trayItem.id

    signal menuRequested(var item)

    function showMenu() {
        if (trayItem.hasMenu)
            menuRequested(trayItem);
    }

    width: 32
    height: 32
    padding: 7
    hoverEnabled: true
    Accessible.name: title
    onClicked: {
        if (trayItem.onlyMenu)
            showMenu();
        else
            trayItem.activate();
    }

    TapHandler {
        acceptedButtons: Qt.RightButton
        onTapped: button.showMenu()
    }

    TapHandler {
        acceptedButtons: Qt.MiddleButton
        onTapped: button.trayItem.secondaryActivate()
    }

    WheelHandler {
        onWheel: (event) => {
            const horizontal = event.angleDelta.y === 0;
            button.trayItem.scroll(horizontal ? event.angleDelta.x : event.angleDelta.y, horizontal);
            event.accepted = true;
        }
    }

    ButtonTooltip {
        parent: button
        tokens: button.tokens
        text: button.title
        visible: button.hovered && button.visible && !button.down
    }

    background: Rectangle {
        radius: button.tokens.radius_small + 3
        color: button.tokens.alpha(button.tokens.foreground, button.down ? 0.12 : button.hovered ? 0.09 : 0.035)
        border.width: button.visualFocus ? 1 : 0
        border.color: button.tokens.muted
    }

    contentItem: Item {
        Image {
            id: icon

            anchors.fill: parent
            source: button.trayItem.icon
            sourceSize.width: 36
            sourceSize.height: 36
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            anchors.centerIn: parent
            visible: icon.status !== Image.Ready
            text: button.title.charAt(0).toUpperCase()
            color: button.tokens.foreground
            font.family: button.tokens.fontFamily
            font.pixelSize: button.tokens.fontSize - 2
        }
    }
}
