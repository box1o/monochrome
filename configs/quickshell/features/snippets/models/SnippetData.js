.pragma library
.import "../../../shared/search/FuzzyMatch.js" as Fuzzy

function validate(data) {
    if (!data || !Array.isArray(data.snippets))
        throw new Error("Expected a snippets list");
    const ids = new Set();
    for (const entry of data.snippets) {
        if (!entry || typeof entry.id !== "string" || !/^[A-Za-z0-9_.-]+$/.test(entry.id) || ids.has(entry.id)
                || typeof entry.title !== "string" || !entry.title || typeof entry.body !== "string"
                || (entry.language !== undefined && typeof entry.language !== "string"))
            throw new Error("Each snippet needs a unique id, title and text body");
        ids.add(entry.id);
    }
    return {snippets: data.snippets};
}

function index(entries) {
    return entries.map((entry, position) => ({
        entry: entry,
        position: position,
        candidate: Fuzzy.prepare(Fuzzy.normalize(entry.title + " " + (entry.language || "") + " " + entry.body))
    }));
}

function search(indexed, query) {
    const terms = Fuzzy.terms(query);
    if (!terms.length)
        return indexed.map(item => item.entry);
    const matches = [];
    for (const item of indexed) {
        let score = 0;
        let matched = true;
        for (const term of terms) {
            const value = Fuzzy.preparedScore(term, item.candidate);
            if (value < 0) {
                matched = false;
                break;
            }
            score += value;
        }
        if (matched)
            matches.push({item: item, score: score});
    }
    matches.sort((a, b) => b.score - a.score || a.item.position - b.item.position);
    return matches.map(match => match.item.entry);
}
