import QtQuick
import QtQuick.Layouts
import "../../components/controls"

RowLayout {
    id: row

    required property QtObject recording
    required property QtObject coffee
    required property QtObject notifications
    required property QtObject tokens

    signal phoneRequested()
    signal sessionRequested()
    signal notificationsRequested()

    spacing: row.tokens.spacing

    CoffeeButton {
        Layout.fillWidth: true
        source: row.coffee
        tokens: row.tokens
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + tokens.px(6)
        tokens: row.tokens
        iconName: "smartphone"
        description: "ADB · scrcpy"
        onClicked: row.phoneRequested()
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + tokens.px(6)
        tokens: row.tokens
        iconName: "video"
        description: row.recording.error || (row.recording.active ? "Stop recording" : "Start recording")
        active: row.recording.active
        color: active ? row.tokens.red : row.tokens.muted
        enabled: !row.recording.busy
        onClicked: row.recording.toggle()

        Behavior on color {
            ColorAnimation {
                duration: row.tokens.motionEnabled ? row.tokens.fastDuration : 0
            }
        }
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + tokens.px(6)
        tokens: row.tokens
        iconName: "power"
        description: "Power"
        onClicked: row.sessionRequested()
    }

    QuickActionButton {
        cornerRadius: row.tokens.radius_small + tokens.px(6)
        tokens: row.tokens
        iconName: "bell"
        description: row.notifications.count > 0 ? row.notifications.count + " notifications" : "Notifications"
        active: row.notifications.count > 0
        onClicked: row.notificationsRequested()
    }
}
