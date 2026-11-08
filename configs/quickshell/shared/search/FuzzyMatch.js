.pragma library

function normalize(value) {
    return String(value || "").normalize("NFKD").replace(/[\u0300-\u036f]/g, "").toLocaleLowerCase();
}

function terms(query) {
    return normalize(query).trim().split(/\s+/).filter(Boolean);
}

// Optimal string alignment also treats adjacent swapped letters as one edit.
function editDistance(query, candidate) {
    let previous = Array.from({length: candidate.length + 1}, (_, i) => i);
    let beforePrevious = previous;

    for (let i = 1; i <= query.length; i++) {
        const current = [i];
        for (let j = 1; j <= candidate.length; j++) {
            current[j] = Math.min(current[j - 1] + 1, previous[j] + 1,
                previous[j - 1] + (query[i - 1] === candidate[j - 1] ? 0 : 1));
            if (i > 1 && j > 1 && query[i - 1] === candidate[j - 2] && query[i - 2] === candidate[j - 1])
                current[j] = Math.min(current[j], beforePrevious[j - 2] + 1);
        }
        beforePrevious = previous;
        previous = current;
    }
    return previous[candidate.length];
}

function subsequenceScore(query, candidate) {
    let position = 0;
    let gaps = 0;
    for (const letter of query) {
        const next = candidate.indexOf(letter, position);
        if (next < 0)
            return -1;
        gaps += next - position;
        position = next + 1;
    }
    return 600 - Math.min(100, gaps * 3);
}

function score(query, candidate) {
    if (candidate === query)
        return 1000;
    if (candidate.startsWith(query))
        return 900;
    if (candidate.includes(query))
        return 700;
    if (query.length >= 3) {
        const subsequence = subsequenceScore(query, candidate);
        if (subsequence >= 0)
            return subsequence;
    }
    // Short queries are too ambiguous to correct reliably.
    if (query.length < 4)
        return -1;
    const limit = query.length >= 8 ? 2 : 1;
    if (query.length > candidate.length + limit)
        return -1;
    let distance = editDistance(query, candidate.slice(0, query.length));
    if (distance > limit && candidate.length > query.length)
        distance = Math.min(distance, editDistance(query, candidate.slice(0, query.length + limit)));
    return distance <= limit ? 450 - distance * 60 : -1;
}

// Normalize once in the feature's adapter, then prepare reusable word data.
function prepare(text) {
    const words = text.split(/[\s._:+\/()\-]+/).filter(Boolean);
    return {text: text, words: words, initials: words.map(word => word[0]).join("")};
}

function preparedScore(term, candidate) {
    const fullMatch = score(term, candidate.text);
    let best = fullMatch < 0 ? -1 : fullMatch + 50;
    for (const word of candidate.words) {
        const wordMatch = score(term, word);
        if (wordMatch >= 0)
            best = Math.max(best, wordMatch - 50);
    }
    if (term.length >= 2 && candidate.initials.startsWith(term))
        best = Math.max(best, 800);
    return best;
}

function textScore(term, text) {
    return preparedScore(term, prepare(text));
}
