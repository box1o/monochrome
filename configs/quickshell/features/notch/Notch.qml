import QtQuick
import Quickshell.Io
import Quickshell.Services.SystemTray
import Quickshell.Wayland
import "../launcher/models"
import "../wifi/models"
import "../bluetooth/models"
import "../../shell"
import "components"
import "state"
import "models"
import "../calendar/models"
import "../tray/models"
import "../session/models"
import "../sound/models"
import "../clipboard/models"
import "../snippets/models"
import "../vpn/models"

ShellWindow {
    id: notch

    required property QtObject snippets
    required property QtObject clipboard
    required property QtObject coffee
    required property QtObject phone
    required property QtObject session
    required property QtObject notifications
    required property QtObject power
    required property QtObject recording
    required property QtObject pomodoro
    required property QtObject media
    required property QtObject vpn
    required property QtObject profiles
    required property QtObject brightness
    required property QtObject audio
    required property QtObject wifi
    required property QtObject bluetooth
    required property QtObject applications
    required property QtObject tokens
    required property QtObject style
    required property QtObject month
    required property QtObject feedback
    required property QtObject clock
    readonly property bool expanded: state.expanded

    geometry: layout
    notchView: view
    menuOpen: state.expanded
    onDismissRequested: state.close("outside")

    IdleInhibitor {
        window: notch
        enabled: notch.coffee.enabled
    }

    function openMenu(page) {
        state.open();
        if (page === "launcher")
            launcherModel.reset();
        if (page === "snippets")
            snippetsModel.reset();
        if (page === "clipboard")
            clipboardModel.reset();
        navigationModel.page = page;
        notch.feedback.dismiss();
        notch.month.dismiss();
    }

    function openTray(item) {
        if (trayModel.open(item))
            openMenu("tray");
    }

    IpcHandler {
        target: "notch"

        function open(): void {
            notch.openMenu("overview");
        }

        function close(): void {
            state.close();
        }

        function toggle(): void {
            if (notch.expanded)
                state.close();
            else
                notch.openMenu("overview");
        }
    }

    IpcHandler {
        target: "launcher"
        function toggle(): void {
            if (notch.expanded && navigationModel.launcherOpen)
                state.close();
            else
                notch.openMenu("launcher");
        }

        function open(): void {
            notch.openMenu("launcher");
        }

        function close(): void {
            state.close();
        }
    }

    IpcHandler {
        target: "connectivity"
        function power(): void {
            notch.openMenu("power");
        }

        function vpn(): void {
            notch.openMenu("vpn");
        }

        function wifi(): void {
            notch.openMenu("wifi");
        }

        function sound(): void {
            notch.openMenu("sound");
        }

        function bluetooth(): void {
            notch.openMenu("bluetooth");
        }
    }

    IpcHandler {
        target: "quickactions"
        function tray(index: int): void {
            notch.openTray(SystemTray.items.values[index]);
        }
        function phone(): void {
            notch.openMenu("phone");
        }
        function power(): void {
            notch.openMenu("session");
        }
        function notifications(): void {
            notch.openMenu("notifications");
        }
        function clipboard(): void {
            notch.openMenu("clipboard");
        }
    }

    Connections {
        target: notch.feedback
        function onPresented(kind) {
            if (kind === "bluetooth" && state.expanded && navigationModel.bluetoothOpen)
                state.close("connection");
        }
    }

    SnippetsModel {
        id: snippetsModel
        source: notch.snippets
    }

    Connections {
        target: notch.snippets
        function onCopied() {
            state.close();
        }
        function onEditing() {
            state.close();
        }
    }

    IpcHandler {
        target: "snippets"
        function toggle(): void {
            if (notch.expanded && navigationModel.snippetsOpen)
                state.close();
            else
                notch.openMenu("snippets");
        }
        function open(): void {
            notch.openMenu("snippets");
        }
    }

    ClipboardModel {
        id: clipboardModel
        source: notch.clipboard
        active: state.expanded && navigationModel.clipboardOpen
    }

    Connections {
        target: notch.clipboard
        function onCopied() {
            state.close();
        }
    }

    IpcHandler {
        target: "clipboard"
        function toggle(): void {
            if (notch.expanded && navigationModel.clipboardOpen)
                state.close();
            else
                notch.openMenu("clipboard");
        }
        function open(): void {
            notch.openMenu("clipboard");
        }
    }

    WifiModel {
        id: wifiModel
        source: notch.wifi
        active: state.expanded && navigationModel.wifiOpen
    }

    BluetoothModel {
        id: bluetoothModel
        source: notch.bluetooth
        active: state.expanded && navigationModel.bluetoothOpen
    }

    LauncherModel {
        id: launcherModel
        applications: notch.applications
        onCloseRequested: state.close()
    }

    SessionModel {
        id: sessionModel
        source: notch.session
        active: state.expanded && navigationModel.sessionOpen
    }

    VpnModel {
        id: vpnModel
        source: notch.vpn
        active: state.expanded && navigationModel.vpnOpen
    }

    SoundModel {
        id: soundModel
        source: notch.audio
        profiles: notch.profiles
        active: state.expanded && navigationModel.soundOpen
    }

    TrayMenuModel {
        id: trayModel
        active: state.expanded && navigationModel.trayOpen
        onBackRequested: navigationModel.reset()
        onActionInvoked: state.close()
    }

    NotchNavigation {
        id: navigationModel
    }

    CalendarModel {
        id: calendarModel
        today: notch.clock.today
    }

    CompactPresentation {
        id: compactPresentation
        recording: notch.recording
        pomodoro: notch.pomodoro
        feedback: notch.feedback
        month: notch.month
        expanded: state.expanded
    }

    Connections {
        target: notch.pomodoro
        function onSessionChanged() {
            compactPresentation.activityDismissed = false;
        }
    }

    Connections {
        target: notch.recording
        function onActiveChanged() {
            compactPresentation.activityDismissed = false;
        }
    }

    NotchState {
        id: state
        closeDelay: notch.style.closeDelay
        hoverOpenEnabled: !notch.feedback.active
        pinned: expanded && navigationModel.detailsOpen
        onExpandedChanged: {
            if (expanded) {
                navigationModel.reset();
                calendarModel.reset();
                notch.month.dismiss();
            }
        }
        onDismissed: reason => {
            if (reason === "hover" && navigationModel.calendarOpen)
                notch.month.show();
        }
    }

    NotchMotion {
        id: layout
        style: notch.style
        tokens: notch.tokens
        preferredWidth: notch.style.expandedWidth * (navigationModel.snippetsOpen ? 1.5 : 1)
        availableWidth: notch.screen ? notch.screen.width : style.expandedWidth + 2 * style.shoulder
        availableHeight: notch.screen ? notch.screen.height : style.expandedHeight
        maximumHeight: navigationModel.snippetsOpen ? Math.max(600, style.expandedHeight) : Math.max(style.expandedHeight, view.overviewHeight)
        contentHeight: view.contentHeight
        contentWidth: view.feedbackWidth
        expanded: state.expanded
    }

    Binding {
        target: notch.phone
        property: "browsing"
        value: state.expanded && navigationModel.phoneOpen
        restoreMode: Binding.RestoreBindingOrValue
    }

    Binding {
        target: notch.brightness
        property: "browsing"
        value: state.expanded && (navigationModel.brightnessOpen || navigationModel.overviewOpen)
        restoreMode: Binding.RestoreBindingOrValue
    }

    Binding {
        target: notch.vpn
        property: "browsing"
        value: state.expanded && (navigationModel.vpnOpen || navigationModel.overviewOpen)
        restoreMode: Binding.RestoreBindingOrValue
    }

    NotchView {
        id: view
        anchors.fill: parent
        geometry: layout
        style: notch.style
        tokens: notch.tokens
        recording: notch.recording
        snippets: snippetsModel
        clipboard: clipboardModel
        coffee: notch.coffee
        phone: notch.phone
        session: sessionModel
        sound: soundModel
        notifications: notch.notifications
        power: notch.power
        pomodoro: notch.pomodoro
        media: notch.media
        vpn: vpnModel
        brightness: notch.brightness
        audio: notch.audio
        wifi: wifiModel
        bluetooth: bluetoothModel
        launcher: launcherModel
        trayMenu: trayModel
        calendar: calendarModel
        clock: notch.clock
        navigation: navigationModel
        feedback: notch.feedback
        month: notch.month
        presentation: compactPresentation
        expanded: state.expanded
        onHoverChanged: hovered => state.setHovered(hovered)
        onCloseRequested: state.close()
        onTrayRequested: item => notch.openTray(item)
        onPhoneRequested: notch.openMenu("phone")
        onSessionRequested: notch.openMenu("session")
        onNotificationsRequested: notch.openMenu("notifications")
        onPowerRequested: notch.openMenu("power")
        onVpnRequested: notch.openMenu("vpn")
        onBrightnessRequested: notch.openMenu("brightness")
        onSoundRequested: notch.openMenu("sound")
        onWifiRequested: notch.openMenu("wifi")
        onBluetoothRequested: notch.openMenu("bluetooth")
        onBackRequested: navigationModel.reset()
        onClockRequested: {
            compactPresentation.activityDismissed = true;
            notch.feedback.dismiss();
            notch.month.dismiss();
            state.close();
        }
    }
}
