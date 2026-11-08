.pragma library

function parse(text) {
    let value;
    try {
        value = JSON.parse(text);
    } catch (_) {
        return {};
    }
    if (!value || typeof value !== "object" || Array.isArray(value))
        return {};
    const entries = Object.create(null);
    for (const [id, entry] of Object.entries(value)) {
        if (entry && Number.isSafeInteger(entry.count) && entry.count > 0
                && Number.isFinite(entry.lastUsed) && entry.lastUsed >= 0)
            entries[id] = {count: entry.count, lastUsed: entry.lastUsed};
    }
    return entries;
}

function record(entries, id, now) {
    const count = entries[id]?.count || 0;
    const updated = Object.assign(Object.create(null), entries);
    updated[id] = {count: Math.min(Number.MAX_SAFE_INTEGER, count + 1), lastUsed: now};
    return updated;
}
