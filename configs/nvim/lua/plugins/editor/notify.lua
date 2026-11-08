return {
    {
        "rcarriga/nvim-notify",
        event = "VeryLazy",
        opts = {
            background_colour = function()
                return require("mono.palette").surface
            end,
            render = "compact",
            stages = "fade",
            timeout = 3000,
            max_height = function()
                return math.floor(vim.o.lines * 0.75)
            end,
            max_width = function()
                return math.floor(vim.o.columns * 0.75)
            end,
            on_open = function(win)
                vim.api.nvim_win_set_config(win, { border = "rounded" })
            end,
        },
        config = function(_, opts)
            require("notify").setup(opts)
        end,
    },
}
