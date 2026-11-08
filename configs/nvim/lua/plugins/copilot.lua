-- GitHub Copilot Integration
return {

    { "github/copilot.vim" },

    {
        "CopilotC-Nvim/CopilotChat.nvim",
        dependencies = {
            { "github/copilot.vim" },
            { "nvim-lua/plenary.nvim" },
        },
        cmd = {
            "CopilotChat",
            "CopilotChatToggle",
            "CopilotChatOpen",
            "CopilotChatClose",
            "CopilotChatRestart",
            "CopilotChatReset",
            "CopilotChatFix",
            "CopilotChatOptimize",
            "CopilotChatExplain",
            "CopilotChatTests",
            "CopilotChatDocs",
            "CopilotChatCommit",
            "CopilotChatReview",
        },
        keys = {
            { "<leader>cc", "<cmd>CopilotChatToggle<cr>", desc = "[C]opilot [C]hat toggle" },
            { "<leader>ce", "<cmd>CopilotChatExplain<cr>", desc = "[C]opilot [E]xplain code" },
            { "<leader>cF", "<cmd>CopilotChatFix<cr>", desc = "[C]opilot [F]ix code" },
            { "<leader>cO", "<cmd>CopilotChatOptimize<cr>", desc = "[C]opilot [O]ptimize code" },
            { "<leader>ct", "<cmd>CopilotChatTests<cr>", desc = "[C]opilot generate [T]ests" },
            { "<leader>cd", "<cmd>CopilotChatDocs<cr>", desc = "[C]opilot generate [D]ocs" },
            { "<leader>cr", "<cmd>CopilotChatReview<cr>", desc = "[C]opilot [R]eview code" },
            {
                "<leader>c/",
                function()
                    require("CopilotChat").ask()
                end,
                desc = "[C]opilot ask question",
            },

            -- Visual mode mappings
            { "<leader>ce", ":<C-u>CopilotChatExplain<cr>", mode = "x", desc = "[C]opilot [E]xplain selection" },
            { "<leader>cF", ":<C-u>CopilotChatFix<cr>", mode = "x", desc = "[C]opilot [F]ix selection" },
            { "<leader>cO", ":<C-u>CopilotChatOptimize<cr>", mode = "x", desc = "[C]opilot [O]ptimize selection" },
            {
                "<leader>ct",
                ":<C-u>CopilotChatTests<cr>",
                mode = "x",
                desc = "[C]opilot generate [T]ests for selection",
            },
            { "<leader>cd", ":<C-u>CopilotChatDocs<cr>", mode = "x", desc = "[C]opilot generate [D]ocs for selection" },
            { "<leader>cr", ":<C-u>CopilotChatReview<cr>", mode = "x", desc = "[C]opilot [R]eview selection" },
        },
        build = function()
            -- Build tiktoken only on Linux and macOS
            if vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1 then
                return "make tiktoken"
            end
            return nil
        end,
        config = function()
            require("CopilotChat").setup({
                -- Select a model
                model = "claude-3.7-sonnet",

                -- Customize prompts
                prompts = {
                    -- Default prompts
                    Explain = {
                        prompt = "Explain this code in detail, focusing on why certain decisions were made.",
                        system_prompt = "You are an expert coding tutor who specializes in explaining code clearly and concisely.",
                    },

                    -- Custom prompt for architecture suggestions
                    Architecture = {
                        prompt = "Analyze this code's architecture and suggest improvements in design patterns, separation of concerns, and overall structure.",
                        system_prompt = "You are a software architect with expertise in clean code and design patterns. Focus on high-level improvements.",
                        mapping = "<leader>ci",
                        description = "Suggest architectural improvements",
                    },

                    -- New custom prompt example
                    Security = {
                        prompt = "Analyze this code for security vulnerabilities and suggest improvements.",
                        system_prompt = "You are a security expert specializing in code security audits. Focus on finding and fixing vulnerabilities.",
                        mapping = "<leader>cs",
                        description = "Security audit",
                    },
                },

                -- UI options
                window = {
                    border = "rounded",
                    width = 0.4,
                    height = 0.7,
                    title = "Copilot Chat",
                    footer = " 󱙺  Use <C-y> to accept diffs, <C-s> to submit, q to close",
                    zindex = 50,
                },

                highlight_headers = true,
                highlight_selection = true,
                auto_follow_cursor = true,
                show_help = true,

                -- Custom settings for better UX
                selection = require("CopilotChat.select").visual, -- Use visual selection by default
                auto_insert_mode = true, -- Enter insert mode when opening chat
                clear_chat_on_new_prompt = false,

                -- Use icons for context and keywords
                question_header = "# 󰧑 User ",
                answer_header = "# 󰚩 Copilot ",
                error_header = "# 󰅚 Error ",
            })
        end,
    },
}
