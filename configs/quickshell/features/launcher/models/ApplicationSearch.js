.pragma library
.import "FuzzyMatch.js" as FuzzyMatch

function normalize(value) {
    return String(value || "").normalize("NFKD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase();
}

function matchScore(entry, terms) {
    const name = normalize(entry.name);
    const words = name.split(/[\s._:+\/()\-]+/).filter(Boolean);
    const initials = words.map(word => word[0]).join("");
    const metadata = normalize([entry.genericName, entry.comment, ...(entry.keywords || [])].join(" "));
    let score = 0;

    for (const term of terms) {
        const nameMatch = FuzzyMatch.score(term, name);
        let best = nameMatch < 0 ? -1 : nameMatch + 50;
        for (const word of words) {
            const wordMatch = FuzzyMatch.score(term, word);
            if (wordMatch >= 0)
                best = Math.max(best, wordMatch - 50);
        }
        if (term.length >= 2 && initials.startsWith(term))
            best = Math.max(best, 800);
        if (metadata.includes(term))
            best = Math.max(best, 200);
        if (best < 0)
            return -1;
        score += best;
    }
    return score;
}

function search(entries, query, usage = {}) {
    const terms = normalize(query).trim().split(/\s+/).filter(Boolean);
    const matches = [];

    for (const entry of entries) {
        if (entry.noDisplay || !entry.name)
            continue;
        const score = matchScore(entry, terms);
        if (score >= 0)
            matches.push({entry: entry, score: score, usage: usage[entry.id] || {count: 0, lastUsed: 0}});
    }
    matches.sort((a, b) => b.score - a.score
        || b.usage.count - a.usage.count
        || b.usage.lastUsed - a.usage.lastUsed
        || a.entry.name.localeCompare(b.entry.name)
        || a.entry.id.localeCompare(b.entry.id));
    return matches.map(match => match.entry);
}
