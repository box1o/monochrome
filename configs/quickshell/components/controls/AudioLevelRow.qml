import QtQuick
import QtQuick.Layouts

ColumnLayout {
    id: row

    required property QtObject tokens
    required property string title
    property string detail: ""
    property string iconName: "volume-2-bold"
    property string mutedIconName: "volume-x-bold"
    property bool titleInside: false
    property bool showPercentage: true
    property real volume: 0
    property bool muted: false
    property bool available: true
    signal volumeRequested(real value)
    signal muteRequested

    spacing: 4
    RowLayout {
        Layout.fillWidth: true
        visible: !row.titleInside
        spacing: 10

        Text {
            Layout.fillWidth: row.detail.length === 0
            elide: Text.ElideRight
            text: row.title
            textFormat: Text.PlainText
            color: row.tokens.foreground
            font.family: row.tokens.fontFamily
            font.pixelSize: row.tokens.fontSize - 3
        }

        Text {
            Layout.fillWidth: true
            visible: row.detail.length > 0
            horizontalAlignment: Text.AlignRight
            text: row.detail
            textFormat: Text.PlainText
            elide: Text.ElideRight
            color: row.tokens.muted
            font.family: row.tokens.fontFamily
            font.pixelSize: row.tokens.fontSize - 4
        }
    }

    AudioSlider {
        Layout.fillWidth: true
        tokens: row.tokens
        iconName: row.iconName
        mutedIconName: row.mutedIconName
        showPercentage: row.showPercentage
        title: row.titleInside ? row.title : ""
        description: row.title
        value: row.volume
        muted: row.muted
        enabled: row.available
        onMoved: row.volumeRequested(value)
        onMuteRequested: row.muteRequested()
    }
}
