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
import "../../clipboard"
import "../../snippets"

Item {
    id: view

    required property QtObject recording
    required property QtObject snippets
    required property QtObject clipboard
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
    readonly property real overviewHeight: overview.overviewHeight
    readonly property Item currentPage: {
        switch (navigation.page) {
        case "launcher":
            return launcherPage;
        case "wifi":
            return wifiPage;
        case "bluetooth":
            return bluetoothPage;
        case "tray":
            return trayPage;
        case "phone":
            return phonePage;
        case "session":
            return sessionPage;
        case "notifications":
            return notificationsPage;
        case "power":
            return powerPage;
        case "vpn":
            return vpnPage;
        case "brightness":
            return brightnessPage;
        case "sound":
            return soundPage;
        case "snippets":
            return snippetsPage;
        case "clipboard":
            return clipboardPage;
        default:
            return null;
        }
    }
    readonly property real contentHeight: currentPage ? currentPage.implicitHeight + 2 * overviewMetrics.padding : overview.implicitHeight
    readonly property real feedbackWidth: compactFeedback.contentWidth
    readonly property real menuOpacity: Math.max(0, (geometry.progress - 0.7) / 0.3)
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
        contentPadding: view.tokens.sectionSpacing
        sectionSpacing: view.tokens.spacing
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
            enabled: !view.navigation.snippetsOpen
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

        Item {
            id: menuViewport

            anchors.horizontalCenter: parent.horizontalCenter
            width: view.geometry.expandedWidth
            height: view.geometry.targetHeight

            Overview {
                id: overview

                active: view.expanded && view.navigation.overviewOpen
                anchors.fill: parent
                visible: view.geometry.progress > 0 && !view.navigation.detailsOpen
                enabled: view.expanded && !view.navigation.detailsOpen
                opacity: view.menuOpacity
                focus: enabled
                recording: view.recording
                coffee: view.coffee
                notifications: view.notifications
                power: view.power
                pomodoro: view.pomodoro
                media: view.media
                vpn: view.vpn.source
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

            SnippetsView {
                id: snippetsPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.snippets
                tokens: view.tokens
                active: view.navigation.snippetsOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
                onBackRequested: view.backRequested()
            }

            ClipboardView {
                id: clipboardPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.clipboard
                tokens: view.tokens
                active: view.navigation.clipboardOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
                onBackRequested: view.backRequested()
            }

            LauncherView {
                id: launcherPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.launcher
                tokens: view.tokens
                active: view.navigation.launcherOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
            }

            WifiView {
                id: wifiPage

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
                id: bluetoothPage

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
                id: trayPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.trayMenu
                tokens: view.tokens
                active: view.navigation.trayOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
            }

            PhoneView {
                id: phonePage

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
                id: sessionPage

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
                id: notificationsPage

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
                id: powerPage

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
                id: vpnPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.vpn
                tokens: view.tokens
                active: view.navigation.vpnOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
                onBackRequested: view.backRequested()
            }

            BrightnessView {
                id: brightnessPage

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
                id: soundPage

                anchors.fill: parent
                anchors.margins: overviewMetrics.padding
                model: view.sound
                tokens: view.tokens
                active: view.navigation.soundOpen && view.expanded
                opacity: view.menuOpacity
                onCloseRequested: view.closeRequested()
                onBackRequested: view.backRequested()
            }
        }

        Rectangle {
            anchors.bottom: parent.bottom
            x: view.geometry.lowerRadius
            width: Math.max(0, parent.width - 2 * x)
            height: Math.min(24, parent.height)
            opacity: view.geometry.transitioning ? view.menuOpacity : 0
            visible: opacity > 0

            gradient: Gradient {
                GradientStop {
                    position: 0
                    color: "transparent"
                }

                GradientStop {
                    position: 1
                    color: view.style.background
                }
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: view.tokens.motionEnabled ? 80 : 0
                }
            }
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
