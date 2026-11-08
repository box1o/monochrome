local M = {}
local palette_path = vim.fn.stdpath("config") .. "/lua/mono/palette.lua"
local signature

function M.reload(force)
    local stat = vim.uv.fs_stat(palette_path)
    if not stat then
        vim.notify("Mono palette is missing; run the Mono theme generator", vim.log.levels.ERROR)
        return
    end
    local next_signature = table.concat({ stat.ino, stat.size, stat.mtime.sec, stat.mtime.nsec }, ":")
    if not force and signature == next_signature then
        return
    end
    package.loaded["mono.palette"] = nil
    package.loaded["lualine.themes.mono"] = nil
    vim.cmd.colorscheme("mono")
    signature = next_signature
end

function M.setup()
    M.reload(true)
    vim.api.nvim_create_autocmd({ "FocusGained", "UIEnter" }, {
        group = vim.api.nvim_create_augroup("MonoTheme", { clear = true }),
        callback = function()
            M.reload()
        end,
    })
    vim.api.nvim_create_user_command("MonoThemeReload", function()
        M.reload(true)
    end, {
        desc = "Reload the generated system palette",
    })
    vim.keymap.set("n", "<leader>ut", "<cmd>MonoThemeReload<cr>", { desc = "Reload system theme" })
end

return M
