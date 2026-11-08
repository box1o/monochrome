return {
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons", "ThePrimeagen/harpoon" },
        priority = 900,
        opts = function()
            local parts = require("config.statusline")
            return {
                options = {
                    theme = "mono",
                    globalstatus = true,
                    disabled_filetypes = { statusline = { "dashboard", "alpha" } },
                    section_separators = { left = "", right = "" },
                    component_separators = { left = "│", right = "│" },
                },
                sections = {
                    lualine_a = { "mode" },
                    lualine_b = {
                        { "branch", fmt = parts.branch, icon = "󰘬" },
                        parts.harpoon,
                        { "diff", symbols = { added = " ", modified = " ", removed = " " } },
                        { "diagnostics", sources = { "nvim_diagnostic" } },
                        parts.micropython,
                    },
                    lualine_c = {
                        { "filetype", icon_only = true },
                        {
                            "filename",
                            path = 1,
                            symbols = { modified = "●", unnamed = "[No Name]", newfile = "[New]" },
                        },
                        vim.lsp.status,
                    },
                    lualine_x = {
                        parts.file_size,
                        "encoding",
                        { "fileformat", symbols = { unix = "󰌽 ", dos = "󰘿 ", mac = "󰘵 " } },
                    },
                    lualine_y = { "filetype" },
                    lualine_z = { "location", "progress" },
                },
                inactive_sections = { lualine_c = { { "filename", path = 1 } }, lualine_x = { "location" } },
                extensions = { "oil", "toggleterm", "lazy", "trouble", "nvim-tree", "quickfix", "fugitive" },
            }
        end,
    },
}
