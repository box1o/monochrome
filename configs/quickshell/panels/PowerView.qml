import QtQuick
import QtQuick.Layouts
import Quickshell.Io

import "../components"
Item {
    // md-lock_outline
    // md-logout
    // md-restart
    // md-power

    id: view

    property var sys
    property int armed: -1
    property int current: 0
    readonly property var actions: view.allActions
    readonly property var allActions: [{
        "id": "sleep",
        "icon": "",
        "label": view.sys.tr("Sleep"),
        "cmd": "systemctl suspend",
        "accent": view.sys.colFg
    }, {
        "id": "lock",
        "instant": true,
        "icon": String.fromCodePoint(983870),
        "label": view.sys.tr("Lock"),
        "cmd": view.sys.scriptDir + "/lock.sh",
        "accent": view.sys.colFg
    }, {
        "icon": String.fromCodePoint(983875),
        "label": view.sys.tr("Log out"),
        "cmd": "out=$(hyprctl dispatch 'hl.dsp.exit()' 2>&1); " + "case \"$out\" in ok*) ;; *) hyprctl dispatch exit ;; esac",
        "accent": view.sys.colWarn
    }, {
        "icon": String.fromCodePoint(984841),
        "label": view.sys.tr("Restart"),
        "cmd": "systemctl reboot",
        "accent": view.sys.colFg
    }, {
        "icon": String.fromCodePoint(984101),
        "label": view.sys.tr("Shut down"),
        "cmd": "systemctl poweroff",
        "accent": view.sys.colCrit
    }]

    function trigger(i) {
        if (i < 0 || i >= actions.length)
            return ;

        if (!actions[i].instant && view.armed !== i) {
            view.armed = i;
            view.current = i;
            disarm.restart();
            return ;
        }
        disarm.stop();
        view.sys.runDetached(actions[i].cmd);
        view.sys.collapse();
    }

    implicitHeight: col.implicitHeight
    focus: true
    Keys.onEscapePressed: view.sys.collapse()
    Keys.onReturnPressed: trigger(current)
    Keys.onLeftPressed: {
        if (current > 0) {
            current--;
            armed = -1;
        }
    }
    Keys.onRightPressed: {
        if (current < actions.length - 1) {
            current++;
            armed = -1;
        }
    }
    Component.onCompleted: forceActiveFocus()

    Timer {
        id: disarm

        interval: 2600
        onTriggered: view.armed = -1
    }

    ColumnLayout {
        id: col

        width: parent.width
        spacing: 14

        Text {
            Layout.fillWidth: true
            text: view.armed >= 0 ? view.sys.tr("Press again to confirm: ") + view.actions[view.armed].label : view.sys.tr("Power")
            color: view.armed >= 0 ? view.actions[view.armed].accent : view.sys.colFg

            font {
                family: view.sys.fontFam
                pixelSize: view.sys.fontSize
                bold: true
            }

            Behavior on color {
                ColorAnimation {
                    duration: 180
                }

            }

        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 11

            Repeater {
                model: view.actions

                Rectangle {
                    required property int index
                    required property var modelData
                    readonly property bool isArmed: view.armed === index
                    readonly property bool isCurrent: view.current === index

                    Layout.fillWidth: true
                    Layout.preferredHeight: 104
                    radius: 16
                    color: btnMa.containsMouse || isCurrent ? Qt.rgba(1, 1, 1, 0.1) : Qt.rgba(1, 1, 1, 0.05)
                    border.color: isArmed ? modelData.accent : isCurrent ? Qt.rgba(1, 1, 1, 0.22) : view.sys.colLine
                    border.width: 1
                    scale: btnMa.pressed ? 0.94 : (btnMa.containsMouse ? 1.03 : 1)

                    Rectangle {
                        anchors.fill: parent
                        radius: parent.radius
                        color: modelData.accent
                        opacity: parent.isArmed ? 0.22 : 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 180
                            }

                        }

                    }

                    ColumnLayout {
                        id: body

                        anchors.centerIn: parent
                        spacing: 9

                        Item {
                            readonly property color ink: modelData.accent

                            Layout.alignment: Qt.AlignHCenter
                            Layout.preferredWidth: 40
                            Layout.preferredHeight: 40

                            Item {
                                anchors.fill: parent
                                visible: modelData.id === "sleep"

                                Text {
                                    x: 1
                                    y: 15
                                    text: "Z"
                                    color: parent.parent.ink

                                    font {
                                        family: view.sys.fontBody
                                        pixelSize: 19
                                        bold: true
                                    }

                                }

                                Text {
                                    x: 17
                                    y: 1
                                    text: "z"
                                    color: parent.parent.ink

                                    font {
                                        family: view.sys.fontBody
                                        pixelSize: 10
                                        bold: true
                                    }

                                }

                                Text {
                                    x: 24
                                    y: 8
                                    text: "z"
                                    color: parent.parent.ink

                                    font {
                                        family: view.sys.fontBody
                                        pixelSize: 14
                                        bold: true
                                    }

                                }

                            }

                            Glyph {
                                anchors.fill: parent
                                visible: modelData.id !== "sleep"
                                glyph: modelData.icon
                                color: parent.ink
                                fontFam: view.sys.fontFam
                                size: view.sys.iconSize + 8
                            }

                        }

                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.label
                            color: body.parent.isArmed ? view.sys.colFg : view.sys.colMuted

                            font {
                                family: view.sys.fontFam
                                pixelSize: view.sys.fontSize - 4
                                bold: body.parent.isArmed
                            }

                            Behavior on color {
                                ColorAnimation {
                                    duration: 160
                                }

                            }

                        }

                    }

                    MouseArea {
                        id: btnMa

                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onEntered: {
                            view.current = index;
                            view.forceActiveFocus();
                        }
                        onClicked: view.trigger(index)
                    }

                    Behavior on color {
                        ColorAnimation {
                            duration: 160
                        }

                    }

                    Behavior on border.color {
                        ColorAnimation {
                            duration: 160
                        }

                    }

                    Behavior on scale {
                        NumberAnimation {
                            duration: 140
                            easing.type: Easing.OutBack
                        }

                    }

                }

            }

        }

    }

}
