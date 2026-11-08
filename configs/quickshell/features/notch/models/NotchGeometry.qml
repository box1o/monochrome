import QtQml

QtObject {
    required property QtObject style
    property real availableWidth: style.expandedWidth + 2 * style.shoulder
    property real availableHeight: style.expandedHeight
    property real progress: 0
    property real contentWidth: 0
    property real contentHeight: 0
    property real maximumHeight: style.expandedHeight
    readonly property real widthLimit: Math.max(0, availableWidth - 2 * style.shoulder)
    property real preferredWidth: style.expandedWidth
    readonly property real expandedWidth: Math.min(preferredWidth, widthLimit)
    readonly property real targetHeight: Math.min(Math.max(style.compactHeight, contentHeight), maximumHeight, Math.max(0, availableHeight))
    property real expandedHeight: targetHeight
    readonly property real compactHeight: Math.min(style.compactHeight, expandedHeight)
    property real compactWidth: Math.min(expandedWidth, Math.max(style.compactWidth, contentWidth))
    // Clamp animated values as well as targets: the width spring can overshoot.
    readonly property real bodyWidth: Math.max(0, Math.min(expandedWidth, compactWidth + (expandedWidth - compactWidth) * progress))
    readonly property real bodyHeight: compactHeight + (expandedHeight - compactHeight) * progress
    readonly property real lowerRadius: Math.min(bodyWidth / 2, bodyHeight / 2, style.compactRadius + (style.expandedRadius - style.compactRadius) * progress)
    readonly property real surfaceWidth: Math.min(availableWidth, expandedWidth + 2 * style.shoulder)
    // Native surface allocation stays fixed while the visible body animates.
    readonly property real surfaceHeight: Math.min(maximumHeight, Math.max(0, availableHeight))
}
