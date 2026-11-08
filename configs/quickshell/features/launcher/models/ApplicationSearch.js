.pragma library
.import "../../../shared/search/FuzzyMatch.js" as FuzzyMatch

function matchScore(entry, terms) {
    const name = FuzzyMatch.normalize(entry.name);
    const metadata = FuzzyMatch.normalize([entry.genericName, entry.comment, ...(entry.keywords || [])].join(" "));
    let score = 0;

    for (const term of terms) {
        let best = FuzzyMatch.textScore(term, name);
        if (metadata.includes(term))
            best = Math.max(best, 200);
        if (best < 0)
            return -1;
        score += best;
    }
    return score;
}

function search(entries, query, usage = {}) {
    const terms = FuzzyMatch.terms(query);
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
