import QtQuick
import "../../shared/code/Syntax.js" as Syntax

Item {
    id: preview

    required property QtObject tokens
    required property string text
    property string languageHint: "auto"
    readonly property string previewText: text.length > 1800 ? text.slice(0, 1800) + "\n…" : text
    readonly property string language: Syntax.detect(previewText, languageHint)

    signal clicked()

    clip: true

    TapHandler {
        onTapped: preview.clicked()
    }

    Text {
        id: code

        width: preview.width
        text: Syntax.format(preview.previewText, preview.language, preview.tokens)
        textFormat: Text.RichText
        color: preview.tokens.foreground
        font.family: preview.tokens.monoFamily
        font.pixelSize: preview.tokens.captionSize
        wrapMode: Text.WrapAnywhere
    }
}
