.pragma library

function parse(text) {
    const entries = [];
    const seen = {};
    for (const line of text.split("\n")) {
        const tab = line.indexOf("\t");
        const id = line.slice(0, tab);
        if (tab < 1 || !/^\d+$/.test(id) || seen[id])
            continue;
        const preview = line.slice(tab + 1).trim();
        if (!preview)
            continue;
        seen[id] = true;
        entries.push({id: id, preview: preview, image: /^\[\[\s*binary data/.test(preview)});
    }
    return entries;
}
