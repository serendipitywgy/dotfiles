return {
    {
        "Kurama622/llm.nvim",
        dependencies = { 
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            -- "Exafunction/codeium.nvim"
        },
        lazy = false,
        cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
        config = function()
            local tools = require("llm.tools")

            require("llm").setup({
                -- [[ GLM ]]
                url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                -- model = "glm-4-flash",
                model = "glm-z1-flash",
                api_type = "zhipu",
                max_tokens = 8000,
                fetch_key = function()
                    return vim.env.GLM_TOKEN
                end,

                temperature = 0.3,
                top_p = 0.7,

                prompt = "You are a helpful chinese assistant.",

                spinner = {
                    text = {
                        "󰧞󰧞",
                        "󰧞󰧞",
                        "󰧞󰧞",
                        "󰧞󰧞",
                    },
                    hl = "Title",
                },

                prefix = {
                    -- 
                    user = { text = "😃 ", hl = "Title" },
                    assistant = { text = "  ", hl = "Added" },
                },

                display = {
                    diff = {
                        layout = "vertical",    -- vertical|horizontal split for default provider
                        opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
                        provider = "mini_diff", -- default|mini_diff
                    },
                },

                -- history_path = "/tmp/llm-history",
                save_session = true,
                max_history = 15,
                max_history_name_length = 20,

                -- stylua: ignore

                -- popup window options
                popwin_opts = {
                    relative = "cursor",
                    enter = true,
                    focusable = true,
                    zindex = 50,
                    position = { row = -7, col = 15, },
                    size = { height = 15, width = "50%", },
                    border = {
                        style = "single",
                        text = { top = " Explain ", top_align = "center" },
                    },
                    win_options = {
                        winblend = 0,
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                },
                keys = {
                    -- The keyboard mapping for the input window.
                    ["Input:Submit"]      = { mode = "n", key = "<cr>" },
                    ["Input:Cancel"]      = { mode = { "n", "i" }, key = "<C-c>" },
                    ["Input:Resend"]      = { mode = { "n", "i" }, key = "<C-r>" },

                    -- only works when "save_session = true"
                    ["Input:HistoryNext"] = { mode = { "n", "i" }, key = "<C-j>" },
                    ["Input:HistoryPrev"] = { mode = { "n", "i" }, key = "<C-k>" },

                    -- The keyboard mapping for the output window in "split" style.
                    ["Output:Ask"]        = { mode = "n", key = "i" },
                    ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
                    ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

                    -- The keyboard mapping for the output and input windows in "float" style.
                    ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
                    ["Session:Close"]     = { mode = "n", key = { "<esc>", "Q" } },

                    -- Scroll [default]
                    ["PageUp"]            = { mode = { "i", "n" }, key = "<C-b>" },
                    ["PageDown"]          = { mode = { "i", "n" }, key = "<C-f>" },
                    ["HalfPageUp"]        = { mode = { "i", "n" }, key = "<C-u>" },
                    ["HalfPageDown"]      = { mode = { "i", "n" }, key = "<C-d>" },
                    ["JumpToTop"]         = { mode = "n", key = "gg" },
                    ["JumpToBottom"]      = { mode = "n", key = "G" }
                },
                app_handler = {
                    OptimizeCode = {
                        handler = tools.side_by_side_handler,
                        opts = {
                            -- streaming_handler = local_llm_streaming_handler,
                            left = {
                                focusable = false,
                            },
                        },
                    },
                    TestCode = {
                        handler = tools.side_by_side_handler,
                        prompt = [[Write some test cases for the following code, only return the test cases.
            Give the code content directly, do not use code blocks or other tags to wrap it.]],
                        opts = {
                            right = {
                                title = " Test Cases ",
                            },
                        },
                    },
                    OptimCompare = {
                        handler = tools.action_handler,
                        opts = {
                            fetch_key = function()
                                return vim.env.GITHUB_TOKEN
                            end,
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",
                            language = "Chinese",
                        },
                    },
                    DocString = {
                        prompt =
                        [[You are an AI programming assistant. You need to write a really good docstring that follows a best practice for the given language.

Your core tasks include:
- parameter and return types (if applicable).
- any errors that might be raised or returned, depending on the language.

You must:
- Place the generated docstring before the start of the code.
- Follow the format of examples carefully if the examples are provided.
- Use Markdown formatting in your answers.
- Include the programming language name at the start of the Markdown code blocks.]],
                        handler = tools.action_handler,
                        opts = {
                            fetch_key = function()
                                return vim.env.GLM_TOKEN
                            end,
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",
                            only_display_diff = true,
                            templates = {
                                lua = [[- For the Lua language, you should use the LDoc style.
- Start all comment lines with "---".
]],
                            },
                        },
                    },
                    WordTranslate = {
                        handler = tools.flexi_handler,
                        prompt =
                        [[You are a translation expert. Your task is to translate all the text provided by the user into Chinese.

          NOTE:
          - All the text input by the user is part of the content to be translated, and you should ONLY FOCUS ON TRANSLATING THE TEXT without performing any other tasks.
          - RETURN ONLY THE TRANSLATED RESULT.]],
                        -- prompt = "Translate the following text to English, please only return the translation",
                        opts = {
                            fetch_key = function()
                                return vim.env.GLM_TOKEN
                            end,
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",
                            -- args = [=[return string.format([[curl %s -N -X POST -H "Content-Type: application/json" -H "Authorization: Bearer %s" -d '%s']], url, LLM_KEY, vim.fn.json_encode(body))]=],
                            exit_on_move = true,
                            enter_flexible_window = false,
                        },
                    },
                    Translate = {
                        handler = tools.qa_handler,
                        opts = {
                            fetch_key = function()
                                return vim.env.GLM_TOKEN
                            end,
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",

                            component_width = "60%",
                            component_height = "50%",
                            query = {
                                title = " 󰊿 Trans ",
                                hl = { link = "Define" },
                            },
                            input_box_opts = {
                                size = "15%",
                                win_options = {
                                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                                },
                            },
                            preview_box_opts = {
                                size = "85%",
                                win_options = {
                                    winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                                },
                            },
                        },
                    },
                    CodeExplain = {
                        handler = tools.flexi_handler,
                        prompt = "Explain the following code, please only return the explanation, and answer in Chinese",
                        opts = {
                            fetch_key = function()
                                return vim.env.GLM_TOKEN
                            end,
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",
                            enter_flexible_window = true,
                        },
                    },
                    Ask = {
                        handler = tools.disposable_ask_handler,
                        opts = {
                            position = {
                                row = 2,
                                col = 0,
                            },
                            title = " Ask ",
                            inline_assistant = true,
                            language = "Chinese",
                            url = "https://open.bigmodel.cn/api/paas/v4/chat/completions",
                            model = "glm-z1-flash",
                            api_type = "zhipu",
                            fetch_key = function()
                                return vim.env.GLM_TOKEN
                            end,
                            display = {
                                mapping = {
                                    mode = "n",
                                    keys = { "d" },
                                },
                                action = nil,
                            },
                            accept = {
                                mapping = {
                                    mode = "n",
                                    keys = { "Y", "y" },
                                },
                                action = nil,
                            },
                            reject = {
                                mapping = {
                                    mode = "n",
                                    keys = { "N", "n" },
                                },
                                action = nil,
                            },
                            close = {
                                mapping = {
                                    mode = "n",
                                    keys = { "<esc>" },
                                },
                                action = nil,
                            },
                        },
                    },
                    AttachToChat = {
                        handler = tools.attach_to_chat_handler,
                        opts = {
                            is_codeblock = true,
                            inline_assistant = true,
                            language = "Chinese",
                        },
                    },
                },
            })
        end,
        keys = {
            { "<leader>ac", mode = "n",          "<cmd>LLMSessionToggle<cr>",            desc = " Toggle LLM Chat" },
            { "<leader>ts", mode = "x",          "<cmd>LLMAppHandler WordTranslate<cr>", desc = " Word Translate" },
            { "<leader>ae", mode = "v",          "<cmd>LLMAppHandler CodeExplain<cr>",   desc = " Explain the Code" },
            { "<leader>at", mode = "n",          "<cmd>LLMAppHandler Translate<cr>",     desc = " AI Translator" },
            { "<leader>tc", mode = "x",          "<cmd>LLMAppHandler TestCode<cr>",      desc = " Generate Test Cases" },
            { "<leader>ao", mode = "x",          "<cmd>LLMAppHandler OptimCompare<cr>",  desc = " Optimize the Code" },
            { "<leader>au", mode = "n",          "<cmd>LLMAppHandler UserInfo<cr>",      desc = " Check Account Information" },
            { "<leader>ag", mode = "n",          "<cmd>LLMAppHandler CommitMsg<cr>",     desc = " Generate AI Commit Message" },
            { "<leader>ad", mode = "v",          "<cmd>LLMAppHandler DocString<cr>",     desc = " Generate a Docstring" },
            { "<leader>ak", mode = { "v", "n" }, "<cmd>LLMAppHandler Ask<cr>",           desc = " Ask LLM" },
            { "<leader>aa", mode = { "v", "n" }, "<cmd>LLMAppHandler AttachToChat<cr>",  desc = " Ask LLM (multi-turn)" },
            -- { "<leader>ae", mode = "v", "<cmd>LLMSelectedTextHandler 请解释下面这段代码<cr>" },
            -- { "<leader>ts", mode = "x", "<cmd>LLMSelectedTextHandler 英译汉<cr>" },
        },
    },
}
