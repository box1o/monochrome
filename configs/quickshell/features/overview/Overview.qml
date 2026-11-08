import QtQuick
import QtQuick.Layouts
import "../clock"
import "../calendar"
import "../connectivity"
import "components"
import "../quickactions"
import "../tray"
import "models"

FocusScope {
    id: overview

    property bool active: false

    required property QtObject coffee
    required property QtObject notifications
    required property QtObject power
    required property QtObject pomodoro
    required property QtObject media
    required property QtObject vpn
    required property QtObject brightness
    required property QtObject audio
    required property QtObject wifi
    required property QtObject bluetooth
    required property QtObject calendar
    required property QtObject navigation
    required property QtObject clock
    required property QtObject metrics
    required property real clockWidth
    required property QtObject tokens
    required property QtObject style

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
    signal closeRequested()

    implicitHeight: metrics.padding * 2 + metrics.headerHeight + 8 + overviewContent.implicitHeight
    Keys.onEscapePressed: closeRequested()
    Keys.onLeftPressed: {
        if (overview.navigation.calendarOpen)
            calendar.shiftMonth(-1);
    }
    Keys.onRightPressed: {
        if (overview.navigation.calendarOpen)
            calendar.shiftMonth(1);
    }

    ActivityDeckModel {
        id: deckModel
        media: overview.media
        active: overview.active
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: overview.metrics.padding
        spacing: 8

        ClockHeader {
            Layout.fillWidth: true
            clock: overview.clock
            tokens: overview.tokens
            style: overview.style
            calendarOpen: overview.navigation.calendarOpen
            clockWidth: overview.clockWidth
            metrics: overview.metrics
            onClicked: overview.navigation.toggleCalendar()
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            Flickable {
                anchors.fill: parent
                visible: !overview.navigation.calendarOpen
                contentWidth: width
                contentHeight: overviewContent.height
                flickableDirection: Flickable.VerticalFlick
                interactive: contentHeight > height
                clip: true
                boundsBehavior: Flickable.StopAtBounds

                Column {
                    id: overviewContent

                    width: parent.width
                    spacing: 8

                    ConnectivityTiles {
                        id: connectivity

                        width: parent.width
                        tokens: overview.tokens
                        audio: overview.audio
                        wifi: overview.wifi
                        bluetooth: overview.bluetooth
                        onSoundRequested: overview.soundRequested()
                        onWifiRequested: overview.wifiRequested()
                        onBluetoothRequested: overview.bluetoothRequested()
                    }

                    SystemControlsRow {
                        cardHeight: connectivity.height
                        width: parent.width
                        vpn: overview.vpn
                        onVpnRequested: overview.vpnRequested()
                        brightness: overview.brightness
                        tokens: overview.tokens
                        onBrightnessRequested: overview.brightnessRequested()
                    }

                    ActivityDeck {
                        width: parent.width
                        model: deckModel
                        power: overview.power
                        pomodoro: overview.pomodoro
                        tokens: overview.tokens
                        onPowerRequested: overview.powerRequested()
                    }

                    QuickActionsRow {
                        width: parent.width
                        coffee: overview.coffee
                        notifications: overview.notifications
                        tokens: overview.tokens
                        onPhoneRequested: overview.phoneRequested()
                        onSessionRequested: overview.sessionRequested()
                        onNotificationsRequested: overview.notificationsRequested()
                    }

                    TrayRow {
                        onMenuRequested: item => overview.trayRequested(item)
                        width: parent.width
                        tokens: overview.tokens
                    }
                }
            }

            CalendarPage {
                anchors.fill: parent
                active: overview.navigation.calendarOpen
                model: calendar
                tokens: overview.tokens
                onPreviousRequested: calendar.shiftMonth(-1)
                onNextRequested: calendar.shiftMonth(1)
                onTodayRequested: calendar.reset()
            }
        }
    }
}
