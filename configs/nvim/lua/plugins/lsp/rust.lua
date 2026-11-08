return {
    {
        "mrcjkb/rustaceanvim",
        version = "^6",
        cond = function()
            return vim.fn.executable("rustc") == 1
        end,
        lazy = false,
        init = function()
            vim.g.rustaceanvim = {
                server = { default_settings = { ["rust-analyzer"] = { check = { command = "clippy" } } } },
            }
        end,
    },
}
