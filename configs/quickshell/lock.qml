//@ pragma UseQApplication
import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

//
//
ShellRoot {
    id: root

    property string password: ""
    property bool authMode: false
    property bool checking: false
    property string errorText: ""
    property int attempts: 0

    readonly property string user: Quickshell.env("USER") || "user"
    readonly property string nick:
        user.charAt(0).toUpperCase() + user.slice(1)

    readonly property string fontFam: "JetBrainsMono Nerd Font"

    FileView {
        id: cfgFile
        path: Quickshell.env("HOME") + "/.config/quickshell/settings.json"
        watchChanges: true
        onFileChanged: reload()
        adapter: JsonAdapter {
            property int  lockBlur: 32
            property string lockHint: ""
        }
    }
    readonly property var cfg: cfgFile.adapter

    readonly property bool testMode: Quickshell.env("MONO_LOCK_TEST") === "1"

    property string wallpaper: ""

    // Fixed black-and-white palette shared with the desktop shell.
    readonly property color accent: "#ffffff"
    readonly property color colFg:   "#ffffff"
    readonly property color colCrit: "#d71921"
    readonly property color colBg:   "#000000"
    function fgOn(c) {
        return (0.2126 * c.r + 0.7152 * c.g + 0.0722 * c.b) > 0.6
               ? root.colBg : "#ffffff";
    }

    function tr(k) { return k; }

    FileView {
        id: wallFile
        path: Quickshell.env("HOME") + "/.config/hypr/hyprpaper.conf"
        blockLoading: true
    }

    Component.onCompleted: {
        var cached = Quickshell.env("MONO_LOCK_BG") || "";
        if (cached.length) { root.wallpaper = cached; }

        var w = /^\s*path\s*=\s*(.+)$/m.exec(wallFile.text() || "");
        if (w && !cached.length) {
            var p = w[1].trim();
            if (p.indexOf("~") === 0) p = Quickshell.env("HOME") + p.slice(1);
            root.wallpaper = (p === "black" || p.length === 0) ? "" : p;
        }
    }

    property string timeText: "--:--"
    property string dateText: ""
    function tick() {
        var d = new Date();
        root.timeText = Qt.formatDateTime(d, "HH:mm");
        root.dateText = Qt.formatDateTime(d, "dddd, d MMMM");
    }
    Timer {
        interval: 1000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: root.tick()
    }

    // ------------------------------------------------------------------- PAM
    PamContext {
        id: pam
        config: "swaylock"
        user: root.user

        onPamMessage: {
            if (responseRequired) respond(root.password);
        }
        onCompleted: result => {
            root.checking = false;
            if (result === PamResult.Success) {
                root.password = "";
                lock.locked = false;
                quitTimer.start();
            } else {
                root.attempts++;
                root.errorText = result === PamResult.MaxTries
                                 ? root.tr("Too many attempts")
                                 : root.tr("Wrong password");
                root.password = "";
            }
        }
        onError: {
            root.checking = false;
            root.errorText = root.tr("Verification error");
            root.password = "";
        }
    }

    Timer { id: quitTimer; interval: 220; onTriggered: Qt.quit() }

    function submit() {
        if (root.checking) return;
        if (!root.password.length) return;
        root.errorText = "";
        root.checking = true;
        if (!pam.start()) {
            root.checking = false;
            root.errorText = root.tr("PAM unavailable");
        }
    }

    IpcHandler {
        target: "lock"
        function unlock(): void {
            if (!root.testMode) return;
            lock.locked = false;
            quitTimer.start();
        }
        function auth(): void {
            if (!root.testMode) return;
            root.authMode = true;
        }
    }

    WlSessionLock {
        id: lock
        locked: true

        WlSessionLockSurface {
            id: surface
            color: "#000000"

            Item {
                anchors.fill: parent

                Image {
                    id: bg
                    anchors.fill: parent
                    source: root.wallpaper.length ? "file://" + root.wallpaper : ""
                    fillMode: Image.PreserveAspectCrop
                    cache: true
                    asynchronous: false
                    sourceSize: Qt.size(surface.width * 2, surface.height * 2)
                    layer.enabled: true
                    layer.smooth: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: bg
                    visible: bg.status === Image.Ready
                    blurEnabled: true
                    blurMax: root.cfg ? root.cfg.lockBlur : 32
                    blurMultiplier: 0.85
                    blur: root.authMode ? 1.0 : 0.0
                    Behavior on blur {
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "#000000"
                    opacity: root.authMode ? 0.55 : 0.35
                    Behavior on opacity { NumberAnimation { duration: 420 } }
                }

                Column {
                    id: idleBlock
                    anchors.centerIn: parent
                    spacing: 18
                    y: parent.height / 2 - height / 2 - (root.authMode ? 60 : 0)
                    Behavior on y {
                        NumberAnimation { duration: 420; easing.type: Easing.OutCubic }
                    }

                    Rectangle {
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: 96; height: 96; radius: 48
                        color: Qt.rgba(1, 1, 1, 0.08)
                        border.color: Qt.rgba(1, 1, 1, 0.16)
                        border.width: 1
                        opacity: root.authMode ? 0 : 1
                        scale: root.authMode ? 0.9 : 1
                        visible: opacity > 0.01
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        Behavior on scale { NumberAnimation { duration: 300 } }

                        Text {
                            anchors.centerIn: parent
                            text: String.fromCodePoint(0xF033E)
                            color: "#ffffff"
                            font { family: root.fontFam; pixelSize: 40 }
                        }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.timeText
                        color: "#ffffff"
                        font { family: root.fontFam; pixelSize: 84; bold: true }
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.dateText
                        color: Qt.rgba(1, 1, 1, 0.55)
                        font { family: root.fontFam; pixelSize: 17 }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: text.length > 0
                        text: root.cfg ? root.cfg.lockHint : ""
                        color: Qt.rgba(1, 1, 1, 0.50)
                        font { family: root.fontFam; pixelSize: 14 }
                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: root.tr("Press Enter")
                        color: Qt.rgba(1, 1, 1, 0.40)
                        opacity: root.authMode ? 0 : 1
                        visible: opacity > 0.01
                        font { family: root.fontFam; pixelSize: 13; letterSpacing: 1 }
                        Behavior on opacity { NumberAnimation { duration: 300 } }
                        SequentialAnimation on scale {
                            running: !root.authMode
                            loops: Animation.Infinite
                            NumberAnimation { to: 1.04; duration: 1100; easing.type: Easing.InOutSine }
                            NumberAnimation { to: 1.00; duration: 1100; easing.type: Easing.InOutSine }
                        }
                    }
                }

                Item {
                    id: island
                    width: root.authMode ? 420 : 150
                    height: 62
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: parent.height / 2 + 130
                    opacity: root.authMode ? 1 : 0
                    visible: opacity > 0.01
                    scale: root.authMode ? 1 : 0.92

                    Behavior on width {
                        NumberAnimation { duration: 380; easing.type: Easing.OutBack }
                    }
                    Behavior on opacity { NumberAnimation { duration: 260 } }
                    Behavior on scale {
                        NumberAnimation { duration: 380; easing.type: Easing.OutBack }
                    }

                    transform: Translate { id: shakeT }
                    SequentialAnimation {
                        id: shake
                        loops: 2
                        NumberAnimation { target: shakeT; property: "x"; to: -9; duration: 55 }
                        NumberAnimation { target: shakeT; property: "x"; to:  9; duration: 55 }
                        NumberAnimation { target: shakeT; property: "x"; to:  0; duration: 55 }
                    }
                    Connections {
                        target: root
                        function onErrorTextChanged() {
                            if (root.errorText.length) shake.restart();
                        }
                    }

                    Rectangle {
                        id: capsule
                        anchors.fill: parent
                        radius: height / 2
                        color: Qt.rgba(0.04, 0.04, 0.05, 0.92)
                        border.width: 1
                        border.color: root.errorText.length
                                      ? Qt.rgba(0.94, 0.27, 0.27, 0.75)
                                      : Qt.rgba(1, 1, 1, 0.14)
                        Behavior on border.color { ColorAnimation { duration: 200 } }

                        Row {
                            anchors.centerIn: parent
                            spacing: 14

                            Item {
                                width: 26; height: 26
                                anchors.verticalCenter: parent.verticalCenter

                                Text {
                                    anchors.centerIn: parent
                                    visible: !root.checking
                                    text: String.fromCodePoint(0xF033E)
                                    color: root.errorText.length ? root.colCrit : root.accent
                                    font { family: root.fontFam; pixelSize: 19 }
                                    Behavior on color { ColorAnimation { duration: 200 } }
                                }
                                Text {
                                    id: spinner
                                    anchors.centerIn: parent
                                    visible: root.checking
                                    text: String.fromCodePoint(0xF0772)
                                    color: root.accent
                                    font { family: root.fontFam; pixelSize: 19 }
                                    RotationAnimator on rotation {
                                        running: spinner.visible
                                        loops: Animation.Infinite
                                        from: 0; to: 360; duration: 900
                                    }
                                }
                            }

                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 7
                                Repeater {
                                    model: Math.min(root.password.length, 16)
                                    Rectangle {
                                        width: 9; height: 9; radius: 5
                                        color: "#ffffff"
                                        opacity: 0.9
                                        scale: 0
                                        Component.onCompleted: scale = 1
                                        Behavior on scale {
                                            NumberAnimation {
                                                duration: 180; easing.type: Easing.OutBack
                                            }
                                        }
                                    }
                                }
                                Text {
                                    visible: root.password.length === 0
                                    text: root.errorText.length ? root.errorText : root.tr("Password")
                                    color: root.errorText.length
                                           ? root.colCrit : Qt.rgba(1, 1, 1, 0.35)
                                    font { family: root.fontFam; pixelSize: 14 }
                                }
                            }
                        }
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: island.y + island.height + 16
                    text: root.nick
                    color: Qt.rgba(1, 1, 1, 0.55)
                    opacity: root.authMode ? 1 : 0
                    visible: opacity > 0.01
                    font { family: root.fontFam; pixelSize: 14; letterSpacing: 1 }
                    Behavior on opacity { NumberAnimation { duration: 300 } }
                }

                TextInput {
                    id: pwInput
                    focus: true
                    width: 1; height: 1
                    opacity: 0
                    echoMode: TextInput.Password
                    activeFocusOnPress: false

                    Component.onCompleted: forceActiveFocus()
                    onTextChanged: {
                        root.password = text;
                        if (text.length) root.errorText = "";
                    }
                    onAccepted: root.submit()

                    Connections {
                        target: root
                        function onPasswordChanged() {
                            if (root.password === "" && pwInput.text !== "") pwInput.text = "";
                        }
                    }

                    Keys.onEscapePressed: {
                        if (root.authMode && !root.checking) {
                            pwInput.text = "";
                            root.errorText = "";
                            root.authMode = false;
                        }
                    }
                    Keys.onPressed: event => {
                        if (root.checking) { event.accepted = true; return; }
                        if (!root.authMode) {
                            root.authMode = true;
                            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter
                                || event.key === Qt.Key_Space)
                                event.accepted = true;
                        }
                    }
                }

                Timer {
                    interval: 400; running: true; repeat: true
                    onTriggered: if (!pwInput.activeFocus) pwInput.forceActiveFocus()
                }
            }
        }
    }
}
