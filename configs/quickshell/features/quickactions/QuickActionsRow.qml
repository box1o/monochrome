import QtQuick
import QtQuick.Layouts
import "../../components/controls"

RowLayout {
    id: row

    required property QtObject coffee
    required property QtObject notifications
    required property QtObject tokens

    signal phoneRequested()
    signal sessionRequested()
    signal notificationsRequested()

    spacing: 8

    CoffeeButton {
        Layout.fillWidth: true
        source: row.coffee
        tokens: row.tokens
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + 6
        tokens: row.tokens
        iconName: "smartphone"
        description: "ADB · scrcpy"
        onClicked: row.phoneRequested()
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + 6
        tokens: row.tokens
        iconName: "power"
        description: "Power"
        onClicked: row.sessionRequested()
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + 6
        tokens: row.tokens
        iconName: "bell"
        description: row.notifications.count > 0 ? row.notifications.count + " notifications" : "Notifications"
        active: row.notifications.count > 0
        onClicked: row.notificationsRequested()
    }
}
