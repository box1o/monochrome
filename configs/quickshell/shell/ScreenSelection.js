.pragma library

function topmost(screens) {
    let selected = null;
    for (const screen of screens) {
        if (!selected || screen.y < selected.y
                || (screen.y === selected.y && screen.x < selected.x))
            selected = screen;
    }
    return selected;
}
