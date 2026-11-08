import QtQuick

CalendarView {
    id: page

    property bool active: false
    property real offset: active ? 0 : 24

    enabled: active
    opacity: active ? 1 : 0
    Accessible.ignored: !active

    transform: Translate {
        x: page.offset
    }

    Behavior on offset {
        NumberAnimation {
            duration: page.tokens.motionEnabled ? page.tokens.normalDuration : 0
            easing.type: Easing.BezierSpline
            easing.bezierCurve: page.tokens.curve
        }
    }

    Behavior on opacity {
        NumberAnimation {
            duration: page.tokens.motionEnabled ? page.tokens.fastDuration : 0
        }
    }
}
