import QtQuick
import "../../clock"
import "../../overview"
import "../../launcher"
import "../../wifi"
import "../../bluetooth"
import "../../sound"
import "../../vpn"
import "../../brightness"
import "../../power"
import "../../tray"
import "../../phone"
import "../../session"
import "../../notifications"

Item {
    id: view

    required property QtObject coffee
    required property QtObject phone
    required property QtObject sound
    required property QtObject session
    required property QtObject notifications
    required property QtObject power
    required property QtObject pomodoro
    required property QtObject media
    required property QtObject vpn
    required property QtObject geometry
    required property QtObject style
    required property QtObject tokens
    required property QtObject brightness
    required property QtObject audio
    required property QtObject wifi
    required property QtObject bluetooth
    required property QtObject launcher
    required property QtObject trayMenu
    required property QtObject calendar
    required property QtObject clock
    required property QtObject feedback
    required property bool expanded
    required property QtObject month
    required property QtObject presentation
    required property QtObject navigation
    readonly property real contentHeight: overview.implicitHeight
    readonly property real feedbackWidth: compactFeedback.contentWidth
    readonly property real menuOpacity: Math.max(0, (geometry.progress - 0.35) / 0.65)
    readonly property real clockOpacity: {
        if (navigation.detailsOpen)
            return Math.max(0, 1 - geometry.progress * 3);

        return presentation.activityVisible ? geometry.progress : 1;
    }
    readonly property alias body: body
    readonly property alias leftShoulder: leftShoulder
    readonly property alias rightShoulder: rightShoulder

    signal hoverChanged(bool hovered)
    signal closeRequested()
    signal trayRequested(var item)
    signal phoneRequested()
    signal sessionRequested()
    signal notificationsRequested()
    signal powerRequested()
    signal vpnRequested()
    signal brightnessRequested()
    signal soundRequested()
    signal wifiRequested()
    signal bluetoothRequested()
    signal backRequested()
    signal clockRequested()

    OverviewMetrics {
        id: overviewMetrics

        fontSize: view.tokens.fontSize
    }

    NotchCorner {
        id: leftShoulder

        x: body.x - width
        radius: view.style.shoulder
        color: view.style.background
    }

    NotchCorner {
        id: rightShoulder

        x: body.x + body.width
        rightSide: true
        radius: view.style.shoulder
        color: view.style.background
    }

    Rectangle {
        id: body

        anchors.horizontalCenter: parent.horizontalCenter
        width: view.geometry.bodyWidth
        height: view.geometry.bodyHeight
        bottomLeftRadius: view.geometry.lowerRadius
        bottomRightRadius: view.geometry.lowerRadius
        color: view.style.background
        antialiasing: true
        clip: true

        HoverHandler {
            acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
            onHoveredChanged: view.hoverChanged(hovered)
        }

        TapHandler {
            acceptedButtons: Qt.RightButton
            onTapped: view.clockRequested()
        }

        CompactFeedback {
            id: compactFeedback

            anchors.fill: parent
            pomodoro: view.pomodoro
            presentation: view.presentation
            feedback: view.feedback
            month: view.month
            tokens: view.tokens
            style: view.style
            geometry: view.geometry
        }

        Overview {
            id: overview
            active: view.expanded && view.navigation.overviewOpen

            anchors.fill: parent
            visible: view.geometry.progress > 0 && !view.navigation.detailsOpen
            enabled: view.expanded && !view.navigation.detailsOpen
            opacity: view.menuOpacity
            focus: enabled
            coffee: view.coffee
            notifications: view.notifications
            power: view.power
            pomodoro: view.pomodoro
            media: view.media
            vpn: view.vpn
            brightness: view.brightness
            audio: view.audio
            wifi: view.wifi.source
            bluetooth: view.bluetooth.source
            clock: view.clock
            clockWidth: morphingClock.expandedWidth
            navigation: view.navigation
            calendar: view.calendar
            metrics: overviewMetrics
            tokens: view.tokens
            style: view.style
            onCloseRequested: view.closeRequested()
            onTrayRequested: item => view.trayRequested(item)
            onPhoneRequested: view.phoneRequested()
            onSessionRequested: view.sessionRequested()
            onNotificationsRequested: view.notificationsRequested()
            onPowerRequested: view.powerRequested()
            onVpnRequested: view.vpnRequested()
            onBrightnessRequested: view.brightnessRequested()
            onSoundRequested: view.soundRequested()
            onWifiRequested: view.wifiRequested()
            onBluetoothRequested: view.bluetoothRequested()
        }

        LauncherView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.launcher
            tokens: view.tokens
            active: view.navigation.launcherOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
        }

        WifiView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.wifi
            tokens: view.tokens
            active: view.navigation.wifiOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        BluetoothView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.bluetooth
            tokens: view.tokens
            active: view.navigation.bluetoothOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        TrayMenuView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.trayMenu
            tokens: view.tokens
            active: view.navigation.trayOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
        }

        PhoneView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            source: view.phone
            tokens: view.tokens
            active: view.navigation.phoneOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        SessionView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.session
            tokens: view.tokens
            active: view.navigation.sessionOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        NotificationsView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            source: view.notifications
            tokens: view.tokens
            active: view.navigation.notificationsOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        PowerView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            source: view.power
            tokens: view.tokens
            active: view.navigation.powerOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        VpnView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            source: view.vpn
            tokens: view.tokens
            active: view.navigation.vpnOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        BrightnessView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            source: view.brightness
            tokens: view.tokens
            active: view.navigation.brightnessOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        SoundView {
            anchors.fill: parent
            anchors.margins: overviewMetrics.padding
            model: view.sound
            tokens: view.tokens
            active: view.navigation.soundOpen && view.expanded
            opacity: view.menuOpacity
            onCloseRequested: view.closeRequested()
            onBackRequested: view.backRequested()
        }

        MorphingClock {
            id: morphingClock

            anchors.fill: parent
            visible: view.geometry.progress > 0 || !view.presentation.activityVisible
            opacity: view.clockOpacity
            clock: view.clock
            tokens: view.tokens
            style: view.style
            progress: view.geometry.progress
            metrics: overviewMetrics
        }
    }
}
