.pragma library

// Preserve the original two-wave charging effect and phase cadence.
function paint(ctx, width, height, radius, tint, level, phase) {
    ctx.reset();
    if (width <= 0 || height <= 0)
        return;
    const r = Math.min(radius, width / 2, height / 2);
    ctx.beginPath();
    ctx.moveTo(0, 0);
    ctx.lineTo(width, 0);
    ctx.lineTo(width, height - r);
    ctx.arcTo(width, height, width - r, height, r);
    ctx.lineTo(r, height);
    ctx.arcTo(0, height, 0, height - r, r);
    ctx.closePath();
    ctx.clip();
    const base = height * (1 - Math.max(0.12, Math.min(0.92, level)));
    for (let wave = 0; wave < 2; ++wave) {
        const offset = wave === 0 ? 0 : Math.PI * 0.7;
        const frequency = wave === 0 ? 0.055 : 0.041;
        ctx.beginPath();
        ctx.moveTo(0, height);
        for (let x = 0; x <= width; x += 3) {
            const y = base + 3.2 * Math.sin(frequency * x + phase + offset)
                + 1.6 * Math.sin(frequency * 1.9 * x - phase * 0.7);
            ctx.lineTo(x, y);
        }
        ctx.lineTo(width, height);
        ctx.closePath();
        ctx.fillStyle = Qt.rgba(tint.r, tint.g, tint.b, wave === 0 ? 0.16 : 0.11);
        ctx.fill();
    }
}
