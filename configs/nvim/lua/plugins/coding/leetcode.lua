local leet_arg = "leetcode.nvim"

return {
	{
		"kawre/leetcode.nvim",
		lazy = leet_arg ~= vim.fn.argv(0, -1),
		cmd = "Leet",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"MunifTanjim/nui.nvim",
			"nvim-telescope/telescope.nvim",
		},
		keys = {
			{ "<leader>lc", "<cmd>Leet<cr>", desc = "Open LeetCode" },
			{ "<leader>lr", "<cmd>Leet run<cr>", desc = "Run LeetCode tests" },
			{ "<leader>ls", "<cmd>Leet submit<cr>", desc = "Submit LeetCode solution" },
		},
		opts = {
			arg = leet_arg,
			lang = "cpp",
			picker = { provider = "telescope" },
			plugins = { non_standalone = true },
		},
	},
}
