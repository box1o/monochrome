.pragma library
.import "../../../shared/search/FuzzyMatch.js" as FuzzyMatch

function search(entries, query) {
    const terms = FuzzyMatch.terms(query);
    if (terms.length === 0)
        return entries;

    const matches = [];
    entries.forEach((entry, index) => {
        const text = FuzzyMatch.normalize(entry.image ? "Image " + entry.preview : entry.preview);
        let score = 0;
        for (const term of terms) {
            const match = FuzzyMatch.textScore(term, text);
            if (match < 0)
                return;
            score += match;
        }
        matches.push({entry: entry, score: score, index: index});
    });
    matches.sort((a, b) => b.score - a.score || a.index - b.index);
    return matches.map(match => match.entry);
}
