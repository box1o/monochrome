import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Effects
import "../../../components"
import Quickshell
import Quickshell.Services.Pipewire

import QtQuick.Controls
import "../../controls"
import "../../../components"

Rectangle {
    id: mediaCard
    property var view


                readonly property var p: mediaCard.view.sys.player

                objectName: "cc-media"
                Layout.row: mediaCard.view.ccRow("media")
                Layout.column: 0
                visible: mediaCard.view.sys.mediaActive
                Layout.fillWidth: true
                Layout.preferredHeight: 124
                radius: 16
                color: Qt.rgba(1, 1, 1, 0.05)
                border.color: mediaCard.view.sys.colLine
                border.width: 1

                ColumnLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 11
                    anchors.rightMargin: 12
                    anchors.topMargin: 10
                    anchors.bottomMargin: 10
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 11

                        Rectangle {
                            Layout.preferredWidth: 42
                            Layout.preferredHeight: 42
                            radius: 10
                            color: Qt.rgba(1, 1, 1, 0.07)

                            Image {
                                id: cardArt

                                anchors.fill: parent
                                source: mediaCard.view.sys.mediaArt
                                fillMode: Image.PreserveAspectCrop
                                asynchronous: true
                                sourceSize.width: 120
                                visible: false
                                layer.enabled: true
                            }

                            Item {
                                id: cardArtMask

                                anchors.fill: parent
                                visible: false
                                layer.enabled: true

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 10
                                    color: "#ffffff"
                                }

                            }

                            MultiEffect {
                                anchors.fill: parent
                                source: cardArt
                                maskEnabled: true
                                maskSource: cardArtMask
                                visible: cardArt.status === Image.Ready
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: cardArt.status !== Image.Ready
                                text: "󰝚"
                                color: mediaCard.view.sys.colMuted

                                font {
                                    family: mediaCard.view.sys.fontFam
                                    pixelSize: 18
                                }

                            }

                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (mediaCard.p)
                                        mediaCard.p.togglePlaying();

                                }
                            }

                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 2

                            Text {
                                Layout.fillWidth: true
                                text: mediaCard.p ? mediaCard.p.trackTitle : ""
                                color: mediaCard.view.sys.colFg
                                elide: Text.ElideRight

                                font {
                                    family: mediaCard.view.sys.fontFam
                                    pixelSize: 13
                                    bold: true
                                }

                            }

                            Text {
                                Layout.fillWidth: true
                                text: mediaCard.p ? mediaCard.p.trackArtist : ""
                                color: mediaCard.view.sys.colMuted
                                elide: Text.ElideRight

                                font {
                                    family: mediaCard.view.sys.fontFam
                                    pixelSize: 11
                                }

                            }

                        }

                        MediaBtn {


                            view: mediaCard.view
                            icon: "󰒮"
                            enabledAction: mediaCard.p ? mediaCard.p.canGoPrevious : false
                            onAct: {
                                if (mediaCard.p)
                                    mediaCard.p.previous();

                            }
                        }

                        MediaBtn {


                            view: mediaCard.view
                            icon: mediaCard.p && mediaCard.p.isPlaying ? "󰏤" : "󰐊"
                            primary: true
                            enabledAction: mediaCard.p ? mediaCard.p.canTogglePlaying : false
                            onAct: {
                                if (mediaCard.p)
                                    mediaCard.p.togglePlaying();

                            }
                        }

                        MediaBtn {


                            view: mediaCard.view
                            icon: "󰒭"
                            enabledAction: mediaCard.p ? mediaCard.p.canGoNext : false
                            onAct: {
                                if (mediaCard.p)
                                    mediaCard.p.next();

                            }
                        }

                    }

                    Item {
                        id: seek

                        readonly property var p: mediaCard.p
                        readonly property real dur: seek.p ? Math.max(0, seek.p.length) : 0
                        readonly property bool usable: seek.p !== null && seek.dur > 0 && seek.p.positionSupported && seek.p.canSeek
                        readonly property real frac: seek.dur > 0 ? Math.max(0, Math.min(1, seek.pos / seek.dur)) : 0
                        property real pos: 0
                        property bool dragging: false
                        property bool primed: false

                        function fracOf(x) {
                            return Math.max(0, Math.min(1, x / Math.max(1, seek.width)));
                        }

                        Layout.fillWidth: true
                        Layout.preferredHeight: 34
                        visible: seek.p !== null
                        Component.onDestruction: seek.primed = false

                        Timer {
                            interval: 500
                            repeat: true
                            running: seek.visible && seek.p !== null
                            triggeredOnStart: true
                            onTriggered: {
                                if (seek.p === null)
                                    return ;

                                seek.p.positionChanged();
                                if (seek.dragging)
                                    return ;

                                seek.pos = seek.p.position;
                                seek.primed = true;
                            }
                        }

                        Connections {
                            function onTrackTitleChanged() {
                                seek.dragging = false;
                                seek.primed = false;
                                seek.pos = 0;
                            }

                            target: mediaCard.p
                            ignoreUnknownSignals: true
                        }

                        WaveBars {
                            id: barsRest

                            anchors.fill: parent
                            barCount: 46
                            gap: 3
                            barColor: Qt.rgba(1, 1, 1, 0.22)
                            active: seek.p ? seek.p.isPlaying : false
                        }

                        Item {
                            width: seek.width * seek.frac
                            height: seek.height
                            clip: true

                            WaveBars {
                                width: seek.width
                                height: seek.height
                                barCount: 46
                                gap: 3
                                barColor: mediaCard.view.sys.colOn
                                active: seek.p ? seek.p.isPlaying : false
                            }

                        }

                        Rectangle {
                            visible: !mediaCard.view.sys.themeNothing
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            height: 2
                            radius: 1
                            color: Qt.rgba(1, 1, 1, 0.12)

                            Rectangle {
                                width: parent.width * seek.frac
                                height: parent.height
                                radius: 1
                                color: mediaCard.view.sys.colOn
                            }

                        }

                        Rectangle {
                            x: seek.width * seek.frac - width / 2
                            width: seekMa.pressed ? 3 : 2
                            height: parent.height
                            radius: 1.5
                            color: "#ffffff"
                            opacity: !seek.usable ? 0 : (seekMa.containsMouse || seekMa.pressed) ? 1 : 0

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 140
                                }

                            }

                            Behavior on width {
                                NumberAnimation {
                                    duration: 120
                                }

                            }

                        }

                        MouseArea {
                            id: seekMa

                            anchors.fill: parent
                            anchors.margins: -3
                            hoverEnabled: true
                            preventStealing: true
                            enabled: seek.usable
                            cursorShape: seek.usable ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onPressed: (mouse) => {
                                seek.dragging = true;
                                seek.pos = seek.fracOf(mouse.x) * seek.dur;
                            }
                            onPositionChanged: (mouse) => {
                                if (!pressed)
                                    return ;

                                seek.pos = seek.fracOf(mouse.x) * seek.dur;
                            }
                            onReleased: (mouse) => {
                                if (seek.usable)
                                    seek.p.position = seek.pos;

                                seek.dragging = false;
                            }
                            onCanceled: seek.dragging = false
                        }

                        Behavior on pos {
                            enabled: seek.primed && !seek.dragging

                            NumberAnimation {
                                duration: 520
                                easing.type: Easing.Linear
                            }

                        }

                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.topMargin: -6
                        visible: seek.visible && seek.dur > 0

                        Text {
                            visible: !mediaCard.view.sys.themeNothing
                            text: mediaCard.view.fmtTime(seek.pos)
                            color: mediaCard.view.sys.colMuted

                            font {
                                family: mediaCard.view.sys.fontFam
                                pixelSize: 10
                            }

                        }

                        DotText {
                            visible: mediaCard.view.sys.themeNothing
                            value: mediaCard.view.fmtTime(seek.pos)
                            size: mediaCard.view.sys.dotHSmall
                            color: mediaCard.view.sys.colMuted
                        }

                        Item {
                            Layout.fillWidth: true
                        }

                        Text {
                            visible: !mediaCard.view.sys.themeNothing
                            text: mediaCard.view.fmtTime(seek.dur)
                            color: Qt.rgba(1, 1, 1, 0.28)

                            font {
                                family: mediaCard.view.sys.fontFam
                                pixelSize: 10
                            }

                        }

                        DotText {
                            visible: mediaCard.view.sys.themeNothing
                            value: mediaCard.view.fmtTime(seek.dur)
                            size: mediaCard.view.sys.dotHSmall
                            color: Qt.rgba(1, 1, 1, 0.28)
                        }

                    }

                }

            }
