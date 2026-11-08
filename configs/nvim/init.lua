vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.have_nerd_font = true

for _, module in ipairs({ "options", "keymaps", "autocmds", "filetypes", "compat" }) do
    require("config." .. module)
end
require("config.theme").setup()
require("config.cpp_pairs").setup()

local lazy_path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazy_path) then
    local output = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        "https://github.com/folke/lazy.nvim.git",
        lazy_path,
    })
    if vim.v.shell_error ~= 0 then
        error("Could not install lazy.nvim:\n" .. output)
    end
end
vim.opt.rtp:prepend(lazy_path)

require("lazy").setup({
    { import = "plugins" },
    { import = "plugins.ui" },
    { import = "plugins.editor" },
    { import = "plugins.coding" },
    { import = "plugins.lsp" },
}, {
    install = { colorscheme = { "mono" } },
    checker = { enabled = false },
})
