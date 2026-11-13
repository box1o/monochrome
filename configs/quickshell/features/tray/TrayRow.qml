import QtQuick
import Quickshell.Services.SystemTray

Flow {
    id: tray

    required property QtObject tokens

    signal menuRequested(var item)

    spacing: tokens.px(6)

    Text {
        width: implicitWidth + tokens.px(4)
        height: tokens.px(32)
        text: "TRAY"
        verticalAlignment: Text.AlignVCenter
        color: tray.tokens.muted
        font.family: tray.tokens.monoFamily
        font.pixelSize: tray.tokens.captionSize
        font.letterSpacing: tokens.px(1)
    }

    Repeater {
        model: SystemTray.items

        TrayButton {
            required property var modelData

            trayItem: modelData
            tokens: tray.tokens
            onMenuRequested: item => tray.menuRequested(item)
        }
    }
}
