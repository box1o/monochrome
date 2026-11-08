function parse(text) {
    const states = ["device", "offline", "unauthorized", "recovery", "sideload", "bootloader"];
    return text.split("\n").map(line => {
        const fields = line.trim().split(/\s+/);
        const model = fields.find(field => field.startsWith("model:"));
        return {
            serial: fields[0],
            state: fields[1],
            name: model ? model.slice(6).replace(/_/g, " ") : fields[0]
        };
    }).filter(device => device.serial && states.includes(device.state));
}
