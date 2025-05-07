return {
    {
        "olimorris/codecompanion.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            -- "nvim-treesitter/nvim-treesitter",
            "echasnovski/mini.diff",
            "j-hui/fidget.nvim",
        },

        -- stylua: ignore
        keys = {
            { "<leader>cca", "<CMD>CodeCompanionActions<CR>",     mode = { "n", "v" }, noremap = true, silent = true, desc = "CodeCompanion actions" },
            { "<leader>cci", "<CMD>CodeCompanion<CR>",            mode = { "n", "v" }, noremap = true, silent = true, desc = "CodeCompanion inline" },
            { "<leader>ccc", "<CMD>CodeCompanionChat Toggle<CR>", mode = { "n", "v" }, noremap = true, silent = true, desc = "CodeCompanion chat (toggle)" },
            { "<leader>ccp", "<CMD>CodeCompanionChat Add<CR>",    mode = { "v" },      noremap = true, silent = true, desc = "CodeCompanion chat add code" },
        },

        opts = {
            send_code = false,

            display = {
                chat = {
                    show_settings = false, -- If show settings, can not change adapter during the chat
                },
                diff = {
                    -- enabled = true,
                    layout = "vertical",    -- "vertical"|"horizontal" split for default provider
                    opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                    provider = "mini_diff", -- "default"|"mini_diff"
                },
            },

            adapters = {
                glm = function()
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        name = "glm",   -- 适配器名称
                        formatted_name = "GLM", -- 格式化名称
                        roles = {
                            llm = "assistant", -- LLM角色
                            user = "user", -- 用户角色
                        },
                        env = {
                            url = "https://open.bigmodel.cn/api/paas/v4", -- API基础URL
                            chat_url = "/chat/completions",       -- 聊天端点
                            api_key = vim.env.GLM_TOKEN,          -- 从环境变量获取API密钥
                        },
                        schema = {
                            model = {
                                default = "glm-z1-flash", -- 默认模型
                                desc = "ID of the model to use.",
                                choices = {
                                    "glm-z1-flash", -- 支持的模型列表
                                },
                            },
                            temperature = {
                                order = 2,
                                mapping = "parameters",
                                type = "number",
                                optional = true,
                                default = 0.8,
                                desc =
                                "What sampling temperature to use, between 0 and 2. Higher values like 0.8 will make the output more random, while lower values like 0.2 will make it more focused and deterministic.",
                                validate = function(n)
                                    return n >= 0 and n <= 2, "Must be between 0 and 2"
                                end,
                            },
                            max_tokens = {
                                order = 3,
                                mapping = "parameters",
                                type = "integer",
                                optional = true,
                                default = 8000,
                                desc = "An upper bound for the number of tokens that can be generated for a completion.",
                                validate = function(n)
                                    return n > 0, "Must be greater than 0"
                                end,
                            },
                        },
                    })
                end,
            },
            strategies = {
                chat = { adapter = "glm" },
                inline = { adapter = "glm" },
            },

            opts = {
                language = "Chinese", -- "English"|"Chinese"
            },

            prompt_library = {
                ["Essay - Stochastic Computing"] = {
                    strategy = "chat",
                    description = "Help spot mistakes and improve the quality of your essay",
                    prompts = {
                        {
                            role = "system",
                            content = [[
  Assume the role of a meticulous proofreader with a strong background in Stochastic Computing. Your task is to scrutinize an academic manuscript, focusing specifically on correcting grammatical errors and refining syntax to meet the highest standards of academic writing. Pay close attention to subject-verb agreement, tense consistency, and the proper use of academic tone and vocabulary. Examine complex sentences to ensure clarity and coherence, breaking down overly complicated structures if necessary. Your goal is to produce a polished, error-free document that communicates ideas clearly, concisely, and effectively, without detracting from the scholarly content and contributions of the work. Organize your changes in two lists, one list for grammatical errors and another list for syntax improvements. The content should be precise and concise, avoiding any unnecessary embellishments or alterations to the original meaning. The item in the list should have the following format:
```
- "The data was collected quick."
  - Issue: Adverb "quick" is used incorrectly instead of the adverbial form "quickly" to modify the verb "collected".
  - Change: `quick` -> `quickly`
```
              ]],
                        },
                        {
                            role = "user",
                            content = "",
                        },
                    },
                },
            },
        },
        init = function()
            require("plugins.utils.codecompanion_fidget_spinner"):init()
        end,
    },
}
