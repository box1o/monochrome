import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import ".."

RowLayout {
    property var rootState

        id: idleCapsule
        anchors.centerIn: parent
        height: rootState.pillH
        spacing: 14
        visible: !rootState.themeNothing && (!rootState.expanded || (rootState.cfg.pillKeepVisible && !rootState.settingsMode)) && !rootState.osdActive && !rootState.toastActive && !rootState.btToastActive && !rootState.acToastActive
        opacity: rootState.pillSide ? 0 : (visible ? 1 : 0)
        Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

        RowLayout {
            id: mediaSeg
            spacing: 9
            visible: rootState.mediaActive
            opacity: visible ? 1 : 0
            Behavior on opacity { NumberAnimation { duration: rootState.animFast } }

            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                Layout.alignment: Qt.AlignVCenter
                radius: 6
                color: Qt.rgba(1, 1, 1, 0.08)
                Image {
                    id: capsuleArt
                    anchors.fill: parent
                    source: rootState.mediaArt
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: true
                    sourceSize.width: 56
                    visible: false
                    layer.enabled: true
                }
                Item {
                    id: capsuleArtMask
                    anchors.fill: parent
                    visible: false
                    layer.enabled: true
                    Rectangle { anchors.fill: parent; radius: 6; color: "#ffffff" }
                }
                MultiEffect {
                    anchors.fill: parent
                    source: capsuleArt
                    maskEnabled: true
                    maskSource: capsuleArtMask
                    visible: capsuleArt.status === Image.Ready
                }
                Text {
                    anchors.centerIn: parent
                    visible: capsuleArt.status !== Image.Ready
                    text: "󰝚"
                    color: rootState.colMuted
                    font { family: rootState.fontFam; pixelSize: 11 }
                }
            }

            Text {
                Layout.maximumWidth: 150
                Layout.alignment: Qt.AlignVCenter
                text: rootState.player ? rootState.player.trackTitle : ""
                color: rootState.colFg
                elide: Text.ElideRight
                font { family: rootState.fontFam; pixelSize: rootState.fontSize - 1; bold: true }
            }

            WaveBars {
                Layout.preferredWidth: 26
                Layout.preferredHeight: 14
                Layout.alignment: Qt.AlignVCenter
                barColor: rootState.colFg
                active: rootState.player ? rootState.player.isPlaying : false
            }

            Rectangle {
                Layout.preferredWidth: 1
                Layout.preferredHeight: 14
                Layout.alignment: Qt.AlignVCenter
                Layout.leftMargin: 2
                color: Qt.rgba(1, 1, 1, 0.14)
            }
        }

        Text {
            text: rootState.dayText
            color: rootState.colMuted
            font { family: rootState.fontFam; pixelSize: rootState.fontSize - 1; bold: true }
        }
        Text {
            text: rootState.timeText
            color: rootState.colFg
            Layout.preferredWidth: rootState.fontSize * 4.5
            horizontalAlignment: Text.AlignHCenter
            font { family: rootState.fontFam; pixelSize: rootState.fontSize; bold: true }
        }

        FlipText {
            value: String(rootState.wsId)
            textColor: rootState.colFg
            fontFam: rootState.fontFam
            pixelSize: rootState.fontSize - 1
            minWidth: rootState.fontSize * 1.5
            Layout.alignment: Qt.AlignVCenter
        }

        Item {
            visible: rootState.batteryPresent
            Layout.preferredWidth: rootState.batteryPresent
                                   ? rootState.iconSize + battPair.spacing + rootState.fontSize * 2.5 : 0
            Layout.preferredHeight: rootState.pillH
            Layout.alignment: Qt.AlignVCenter

            RowLayout {
                id: battPair
                anchors.centerIn: parent
                spacing: 4

                Text {
                    text: rootState.batteryIcon
                    color: rootState.batteryCharging || rootState.acOnline ? rootState.colOk
                         : rootState.batteryPct <= 15 ? rootState.colCrit
                         : rootState.colFg
                    font { family: rootState.fontFam; pixelSize: rootState.iconSize }
                    Behavior on color { ColorAnimation { duration: 200 } }
                }
                Text {
                    text: rootState.batteryPct + "%"
                    color: rootState.colMuted
                    font { family: rootState.fontFam; pixelSize: rootState.fontSize - 1; bold: true }
                }
            }
        }
    }
