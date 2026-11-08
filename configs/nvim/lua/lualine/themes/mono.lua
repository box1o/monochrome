local p = require("mono.palette")
local function mode(color)
    return {
        a = { fg = p.background, bg = color, gui = "bold" },
        b = { fg = p.foreground, bg = p.surface_bright },
        c = { fg = p.foreground, bg = p.surface },
    }
end

return {
    normal = mode(p.accent),
    insert = mode(p.green),
    visual = mode(p.magenta),
    replace = mode(p.red),
    command = mode(p.yellow),
    terminal = mode(p.cyan),
    inactive = {
        a = { fg = p.muted, bg = p.background },
        b = { fg = p.muted, bg = p.background },
        c = { fg = p.muted, bg = p.background },
    },
}
