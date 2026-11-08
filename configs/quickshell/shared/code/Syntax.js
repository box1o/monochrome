.pragma library
.import "vendor/Highlight.js" as Highlight

const cache = new Map();
const cacheLimit = 64;

function remember(key, value) {
    if (cache.size >= cacheLimit)
        cache.delete(cache.keys().next().value);
    cache.set(key, value);
    return value;
}

const languages = ["cpp", "python", "go", "typescript", "javascript", "bash", "json", "yaml", "css", "xml", "sql"];

function detect(body, language) {
    if (language && !["auto", "text", "plaintext"].includes(language.toLowerCase()))
        return Highlight.engine().getLanguage(language) ? language : "text";
    const sample = body.slice(0, 4000);
    const key = "detect:" + sample;
    if (cache.has(key))
        return cache.get(key);
    if (/^#!.*(?:bash|sh)|^\s*(?:gw |docker |export |sudo |git |npm |pacman )/m.test(sample))
        return "bash";
    if (/^\s*#include\s*[<"]|\bstd::/.test(sample))
        return "cpp";
    if (/^\s*(?:async\s+)?def\s+\w+\s*\(|^\s*from\s+\S+\s+import\s/m.test(sample))
        return "python";
    if (/^\s*package\s+\w+|^\s*func\s+/m.test(sample))
        return "go";
    if (/^\s*(?:export\s+)?(?:interface|type)\s+\w+|\b(?:const|let)\s+\w+\s*:/m.test(sample))
        return "typescript";
    try {
        return remember(key, Highlight.engine().highlightAuto(sample, languages).language || "text");
    } catch (error) {
        return "text";
    }
}

function escape(text) {
    return text.replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
}

function format(body, language, colors) {
    const preview = body.length > 12000 ? body.slice(0, 12000) + "\n…" : body;
    const key = "code:" + language + ":" + preview;
    let html = cache.get(key);
    if (html === undefined) {
        html = escape(preview);
        try {
            if (Highlight.engine().getLanguage(language))
                html = Highlight.engine().highlight(preview, {language: language, ignoreIllegals: true}).value;
        } catch (error) {
            // Unsupported grammar constructs retain a readable plain-text preview.
        }
        remember(key, html);
    }
    // Qt rich text has no external stylesheet; translate the highlighter's spans.
    return html.replace(/<span class="([^"]+)">/g, (_, names) => {
        const name = names.split(" ")[0].replace("hljs-", "");
        const color = /comment|quote/.test(name) ? colors.muted
            : /keyword|selector|meta/.test(name) ? colors.accent
            : /string|regexp|attr/.test(name) ? colors.blue
            : colors.foreground;
        return '<font color="' + color + '">';
    }).replace(/<\/span>/g, "</font>").replace(/\n/g, "<br>").replace(/ {2}/g, " &nbsp;");
}
