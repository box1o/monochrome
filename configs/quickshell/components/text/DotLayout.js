.pragma library

function width(characters, pitch, spacing, size, gap, padding) {
    if (!characters.length)
        return 0;
    return characters.reduce((total, rows) => total + rows[0].length * pitch + spacing, 0)
        - spacing - size * gap + 2 * padding;
}

function paint(ctx, characters, color, pitch, rowPitch, size, weight, spacing, padding) {
    ctx.reset();
    ctx.fillStyle = color;
    let offset = 0;
    for (const rows of characters) {
        for (let y = 0; y < rows.length; ++y) {
            for (let x = 0; x < rows[y].length; ++x) {
                if (rows[y][x] !== "1")
                    continue;
                ctx.beginPath();
                ctx.arc(padding + offset + x * pitch + size / 2,
                        padding + y * rowPitch + size / 2, size * weight / 2, 0, Math.PI * 2);
                ctx.fill();
            }
        }
        offset += rows[0].length * pitch + spacing;
    }
}
