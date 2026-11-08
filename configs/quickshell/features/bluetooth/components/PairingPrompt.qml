import QtQuick
import QtQuick.Layouts
import "../../../components/controls"

ColumnLayout {
    id: prompt

    required property QtObject source
    required property QtObject tokens
    readonly property string deviceName: source.pending?.name || "the device"
    readonly property string kind: source.prompt.kind || ""
    readonly property bool needsInput: kind === "pin" || kind === "passkey"
    readonly property bool valid: kind === "pin" ? input.text.length >= 1 && input.text.length <= 16 : kind === "passkey" ? /^\d{1,6}$/.test(input.text) : true
    visible: kind.length > 0
    spacing: 6
    onKindChanged: input.clear()

    StatusLabel {
        Layout.fillWidth: true
        tokens: prompt.tokens
        text: prompt.kind === "display" ? "Enter " + prompt.source.prompt.value + " on " + prompt.deviceName : prompt.kind === "confirm" ? "Confirm pairing with " + prompt.deviceName + (prompt.source.prompt.value ? ": " + prompt.source.prompt.value : "") : "Enter " + (prompt.kind === "pin" ? "PIN" : "passkey") + " for " + prompt.deviceName
    }

    InputField {
        id: input
        Layout.fillWidth: true
        visible: prompt.needsInput
        tokens: prompt.tokens
        placeholderText: prompt.kind === "pin" ? "PIN" : "Passkey"
        maximumLength: prompt.kind === "pin" ? 16 : 6
        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
        onAccepted: {
            if (prompt.valid) {
                prompt.source.reply(true, text);
                clear();
            }
        }
    }

    RowLayout {
        Layout.fillWidth: true
        TextButton {
            tokens: prompt.tokens
            text: "Confirm"
            visible: prompt.kind !== "display"
            enabled: prompt.valid
            onClicked: {
                prompt.source.reply(true, input.text);
                input.clear();
            }
        }

        TextButton {
            tokens: prompt.tokens
            text: "Cancel pairing"
            onClicked: prompt.source.cancel()
        }
    }
}
