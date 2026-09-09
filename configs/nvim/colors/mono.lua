local p = require("mono.palette")

vim.cmd("highlight clear")
if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

vim.o.background = "dark"
vim.g.colors_name = "mono"

local groups = {
    Normal = { fg = p.foreground, bg = p.background },
    NormalFloat = { fg = p.foreground, bg = p.surface },
    FloatBorder = { fg = p.surface_bright, bg = p.surface },
    CursorLine = { bg = p.surface },
    CursorLineNr = { fg = p.accent, bold = true },
    LineNr = { fg = p.muted },
    Visual = { fg = p.background, bg = p.accent },
    Search = { fg = p.background, bg = p.yellow },
    IncSearch = { fg = p.background, bg = p.accent },
    MatchParen = { fg = p.accent, bold = true },
    Pmenu = { fg = p.foreground, bg = p.surface },
    PmenuSel = { fg = p.background, bg = p.accent },
    StatusLine = { fg = p.foreground, bg = p.surface_bright },
    StatusLineNC = { fg = p.muted, bg = p.surface },
    WinSeparator = { fg = p.surface_bright },
    Comment = { fg = p.muted, italic = true },
    Constant = { fg = p.yellow },
    String = { fg = p.green },
    Character = { fg = p.green },
    Number = { fg = p.yellow },
    Boolean = { fg = p.yellow, bold = true },
    Identifier = { fg = p.foreground },
    Function = { fg = p.blue },
    Statement = { fg = p.accent, bold = true },
    Keyword = { fg = p.accent, italic = true },
    Operator = { fg = p.cyan },
    PreProc = { fg = p.magenta },
    Type = { fg = p.cyan },
    Special = { fg = p.magenta },
    Underlined = { fg = p.blue, underline = true },
    Error = { fg = p.red },
    Todo = { fg = p.background, bg = p.yellow, bold = true },
    DiagnosticError = { fg = p.red },
    DiagnosticWarn = { fg = p.yellow },
    DiagnosticInfo = { fg = p.blue },
    DiagnosticHint = { fg = p.cyan },
    GitSignsAdd = { fg = p.green },
    GitSignsChange = { fg = p.yellow },
    GitSignsDelete = { fg = p.red },
    TelescopeBorder = { fg = p.surface_bright },
    TelescopeSelection = { fg = p.foreground, bg = p.surface_bright },
    TelescopeMatching = { fg = p.accent, bold = true },
}

for name, options in pairs(groups) do
    vim.api.nvim_set_hl(0, name, options)
end

vim.g.terminal_color_0 = p.black
vim.g.terminal_color_1 = p.red
vim.g.terminal_color_2 = p.green
vim.g.terminal_color_3 = p.yellow
vim.g.terminal_color_4 = p.blue
vim.g.terminal_color_5 = p.magenta
vim.g.terminal_color_6 = p.cyan
vim.g.terminal_color_7 = p.white
vim.g.terminal_color_8 = p.muted
vim.g.terminal_color_9 = p.red
vim.g.terminal_color_10 = p.green
vim.g.terminal_color_11 = p.yellow
vim.g.terminal_color_12 = p.blue
vim.g.terminal_color_13 = p.magenta
vim.g.terminal_color_14 = p.cyan
vim.g.terminal_color_15 = p.foreground
