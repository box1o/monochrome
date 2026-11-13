import QtQuick

FocusScope {
    id: page

    required property QtObject tokens
    required property Item contentItem
    property Item initialFocusItem: null
    property bool active: false
    property real reveal: active ? 1 : 0

    signal closeRequested()

    implicitHeight: contentItem ? contentItem.implicitHeight : 0
    onActiveChanged: {
        if (active && initialFocusItem)
            Qt.callLater(() => {
            if (page.active && page.initialFocusItem)
                page.initialFocusItem.forceActiveFocus();
        });
    }
    visible: active
    enabled: active
    focus: active
    Keys.onEscapePressed: closeRequested()

    transform: Translate {
        y: (1 - page.reveal) * -page.tokens.px(8)
    }

    Behavior on reveal {
        NumberAnimation {
            duration: page.tokens.motionEnabled ? page.tokens.normalDuration : 0
            easing.type: Easing.OutCubic
        }
    }
}
