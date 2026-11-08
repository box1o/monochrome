.pragma library

function parse(text) {
    const cards = JSON.parse(text);
    if (!Array.isArray(cards))
        throw new Error("Expected an audio card list");
    return cards.filter(card => card.properties?.["device.api"] === "bluez5").map(card => ({
        name: card.name,
        title: card.properties["device.description"] || card.name,
        current: card.active_profile,
        profiles: Object.entries(card.profiles || {})
            .filter(([name, value]) => name !== "off" && value.available !== false && value.sinks > 0)
            .sort((a, b) => b[1].priority - a[1].priority)
            .map(([name, value]) => {
                const description = String(value.description || name);
                return {
                    name: name,
                    title: description.match(/codec ([^)]+)/)?.[1] || description,
                    stereo: name.startsWith("a2dp-"),
                    description: name.startsWith("a2dp-") ? "Stereo playback" : "Headset · microphone available"
                };
            })
    }));
}

function codecId(text, title) {
    const codecs = JSON.parse(text);
    if (!Array.isArray(codecs))
        throw new Error("Expected a codec list");
    const match = codecs.find(codec => typeof codec.description === "string"
        && codec.description.toLowerCase() === title.toLowerCase());
    return match && typeof match.name === "string" ? match.name : null;
}
