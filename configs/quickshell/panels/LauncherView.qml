import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

import "../components"
FocusScope {
    id: view

    property var sys
    property string query: ""
    property int index: 0
    readonly property int maxRows: 6
    property var recent: []
    readonly property string recentFile: (Quickshell.env("XDG_CACHE_HOME") || (Quickshell.env("HOME") + "/.cache")) + "/mono/recent-apps"
    readonly property var builtins: []
    readonly property var extras: view.builtins
    readonly property var results: {
        var q = query.trim().toLowerCase();
        var all = DesktopEntries.applications ? DesktopEntries.applications.values : [];
        var starts = [], contains = [];
        var pinned = [];
        for (var b = 0; b < view.extras.length; b++) {
            var bi = view.extras[b];
            if (q.length === 0) {
                starts.push(bi);

            } else if (view.builtinMatches(bi, q)) {
                pinned.push(bi);
            }
        }
        for (var i = 0; i < all.length; i++) {
            var a = all[i];
            if (!a || a.noDisplay)
                continue;

            var n = String(a.name || "").toLowerCase();
            if (q.length === 0) {
                starts.push(a);
                continue;
            }
            var pos = n.indexOf(q);
            if (pos === 0)
                starts.push(a);
            else if (pos > 0)
                contains.push(a);
            else if (String(a.genericName || "").toLowerCase().indexOf(q) >= 0)
                contains.push(a);
        }
        var byName = function byName(x, y) {
            return String(x.name || "").localeCompare(String(y.name || ""));
        };
        if (q.length === 0) {
            starts.sort(function(x, y) {
                var d = view.recentRank(x) - view.recentRank(y);
                return d !== 0 ? d : byName(x, y);
            });
            return starts;
        }
        starts.sort(byName);
        contains.sort(byName);
        return pinned.concat(starts, contains);
    }
    readonly property bool isMath: {
        var q = query.trim();
        if (q.length < 3)
            return false;

        if (!/[+\-*/^%]/.test(q))
            return false;

        return /^[0-9\s+\-*/().,%^]+$/.test(q);
    }
    readonly property string mathResult: {
        if (!isMath)
            return "";

        try {
            var e = query.trim().replace(/,/g, ".").replace(/\^/g, "**");
            var r = Function('"use strict"; return (' + e + ')')();
            if (typeof r !== "number" || !isFinite(r))
                return "";

            return String(parseFloat(r.toFixed(10)));
        } catch (err) {
            return "";
        }
    }

    function rememberApp(app) {
        var id = String(app.id || app.name || "");
        if (!id.length)
            return ;

        var list = view.recent.filter((x) => {
            return x !== id;
        });
        list.unshift(id);
        if (list.length > 20)
            list = list.slice(0, 20);

        view.recent = list;
        pRecentWrite.command = ["sh", "-c", "mkdir -p \"$(dirname \"$1\")\"; printf '%s' \"$2\" > \"$1\"", "_", view.recentFile, list.join("\n")];
        pRecentWrite.running = true;
    }

    function recentRank(app) {
        var i = view.recent.indexOf(String(app.id || app.name || ""));
        return i < 0 ? 999 : i;
    }

    function builtinMatches(b, q) {
        if (q.length === 0)
            return false;

        if (String(b.name).toLowerCase().indexOf(q) >= 0)
            return true;

        return String(b.keys).toLowerCase().indexOf(q) >= 0;
    }

    function copyResult() {
        if (mathResult.length === 0)
            return ;

        pCopyCalc.command = ["sh", "-c", "printf '%s' \"$1\" | wl-copy", "_", mathResult];
        pCopyCalc.running = true;
        sys.closeLauncher();
    }

    function launch() {
        if (view.mathResult.length > 0) {
            copyResult();
            return ;
        }
        var app = results[index];
        if (!app)
            return ;

        rememberApp(app);
        app.execute();
        sys.closeLauncher();
    }

    function move(delta) {
        if (results.length === 0)
            return ;

        index = Math.max(0, Math.min(results.length - 1, index + delta));
        list.positionViewAtIndex(index, ListView.Contain);
    }

    implicitHeight: col.implicitHeight
    onQueryChanged: index = 0
    onResultsChanged: {
        if (index >= results.length)
            index = Math.max(0, results.length - 1);

    }

    Process {
        id: pRecentRead

        command: ["sh", "-c", "cat \"$1\" 2>/dev/null", "_", view.recentFile]
        running: true

        stdout: StdioCollector {
            onStreamFinished: view.recent = text.trim().split("\n").filter((x) => {
                return x.length;
            })
        }

    }

    Process {
        id: pRecentWrite
    }

    Process {
        id: pCopyCalc
    }

    FocusGrabber {
        target: input
    }

    ColumnLayout {
        id: col

        width: parent.width
        spacing: 10

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            radius: 13
            color: Qt.rgba(1, 1, 1, 0.06)
            border.color: input.activeFocus ? Qt.rgba(1, 1, 1, 0.22) : view.sys.colLine
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 13
                anchors.rightMargin: 13
                spacing: 9

                Text {
                    text: ""
                    color: view.sys.colMuted

                    font {
                        family: view.sys.fontFam
                        pixelSize: 14
                    }

                }

                TextField {
                    id: input

                    focus: true
                    Layout.fillWidth: true
                    placeholderText: view.sys.tr("Search apps…")
                    color: view.sys.colFg
                    placeholderTextColor: view.sys.colMuted
                    background: null
                    onTextChanged: view.query = text
                    Keys.onDownPressed: view.move(1)
                    Keys.onUpPressed: view.move(-1)
                    Keys.onReturnPressed: view.launch()
                    Keys.onEnterPressed: view.launch()
                    Keys.onEscapePressed: view.sys.closeLauncher()
                    Keys.onTabPressed: view.move(1)

                    font {
                        family: view.sys.fontFam
                        pixelSize: 13
                    }

                }

                Text {
                    visible: view.results.length > 0
                    text: view.results.length
                    color: view.sys.colMuted

                    font {
                        family: view.sys.fontFam
                        pixelSize: 11
                    }

                }

            }

            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }

            }

        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 52
            visible: view.mathResult.length > 0
            radius: 12
            color: Qt.rgba(view.sys.colOn.r, view.sys.colOn.g, view.sys.colOn.b, 0.14)
            border.color: Qt.rgba(view.sys.colOn.r, view.sys.colOn.g, view.sys.colOn.b, 0.4)
            border.width: 1

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 14
                anchors.rightMargin: 14
                spacing: 12

                Glyph {
                    Layout.preferredWidth: 22
                    Layout.preferredHeight: 22
                    glyph: String.fromCodePoint(983276)
                    color: view.sys.colOn
                    fontFam: view.sys.fontFam
                    size: view.sys.iconSize - 2
                }

                Text {
                    Layout.fillWidth: true
                    text: view.mathResult
                    color: view.sys.colFg
                    elide: Text.ElideRight

                    font {
                        family: view.sys.fontFam
                        pixelSize: view.sys.fontSize + 3
                        bold: true
                    }

                }

                Text {
                    text: "Enter"
                    color: view.sys.colMuted

                    font {
                        family: view.sys.fontFam
                        pixelSize: view.sys.fontSize - 5
                    }

                }

            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: view.copyResult()
            }

        }

        ListView {
            id: list

            Layout.fillWidth: true
            visible: view.mathResult.length === 0
            Layout.preferredHeight: view.mathResult.length > 0 ? 0 : Math.min(view.results.length, view.maxRows) * 46
            clip: true
            model: view.results
            currentIndex: view.index
            boundsBehavior: Flickable.OvershootBounds
            flickDeceleration: 2200
            spacing: 2

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 3

                contentItem: Rectangle {
                    radius: 2
                    color: Qt.rgba(1, 1, 1, 0.22)
                }

            }

            delegate: Rectangle {
                id: row

                required property var modelData
                required property int index

                width: list.width
                height: 44
                radius: 12
                color: index === view.index ? Qt.rgba(1, 1, 1, 0.11) : (rowMa.containsMouse ? Qt.rgba(1, 1, 1, 0.06) : "transparent")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 12
                    spacing: 11

                    Item {
                        Layout.preferredWidth: 26
                        Layout.preferredHeight: 26

                        Image {
                            id: appIcon

                            anchors.fill: parent
                            source: row.modelData.icon ? Quickshell.iconPath(row.modelData.icon, true) : ""
                            fillMode: Image.PreserveAspectFit
                            asynchronous: true
                            sourceSize.width: 52
                            sourceSize.height: 52
                            visible: status === Image.Ready
                        }

                        Rectangle {
                            anchors.fill: parent
                            visible: !appIcon.visible
                            radius: 7
                            color: Qt.rgba(1, 1, 1, 0.1)

                            Glyph {
                                anchors.centerIn: parent
                                visible: String(row.modelData.glyph || "").length > 0
                                glyph: row.modelData.glyph || ""
                                color: view.sys.colFg
                                fontFam: view.sys.fontFam
                                size: 15
                            }

                            Text {
                                anchors.centerIn: parent
                                visible: String(row.modelData.glyph || "").length === 0
                                text: String(row.modelData.name || "?").charAt(0).toUpperCase()
                                color: view.sys.colFg

                                font {
                                    family: view.sys.fontFam
                                    pixelSize: 12
                                    bold: true
                                }

                            }

                        }

                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.name || ""
                            color: view.sys.colFg
                            elide: Text.ElideRight

                            font {
                                family: view.sys.fontFam
                                pixelSize: 13
                                bold: row.index === view.index
                            }

                        }

                        Text {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: row.modelData.genericName || ""
                            color: view.sys.colMuted
                            elide: Text.ElideRight

                            font {
                                family: view.sys.fontFam
                                pixelSize: 10
                            }

                        }

                    }

                    Text {
                        visible: row.index === view.index
                        text: "󰌑"
                        color: view.sys.colMuted

                        font {
                            family: view.sys.fontFam
                            pixelSize: 12
                        }

                    }

                }

                MouseArea {
                    id: rowMa

                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onEntered: view.index = row.index
                    onClicked: view.launch()
                }

                Behavior on color {
                    ColorAnimation {
                        duration: 120
                    }

                }

            }

        }

        Text {
            Layout.fillWidth: true
            visible: view.results.length === 0 && view.mathResult.length === 0
            text: view.sys.tr("Nothing found")
            color: view.sys.colMuted
            horizontalAlignment: Text.AlignHCenter

            font {
                family: view.sys.fontFam
                pixelSize: 11
            }

        }

    }

}
