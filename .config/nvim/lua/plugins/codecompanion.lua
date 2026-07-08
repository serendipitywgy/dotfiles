PackUtils.load({
    name = "codecompanion.nvim",
    module = "codecompanion",
    deps = { "plenary.nvim" },
}, function()
    require("codecompanion").setup({
        adapters = {
            http = {
                company = function()
                    return require("codecompanion.adapters").extend("anthropic", {
                        url = "https://navimaxx-cc.test.seewo.com/v1/messages",
                        formatted_name = "企业AI",
                        env = {
                            api_key = "ANTHROPIC_AUTH_TOKEN",
                        },
                        opts = {
                            compaction = false,
                            stream = true,
                            tools = false,
                            vision = false,
                        },
                        schema = {
                            model = {
                                default = "qwen3.7-max",
                                choices = {
                                    ["deepseek-v4-pro"] = {
                                        formatted_name = "DeepSeek V4 Pro",
                                        meta = { max_tokens = 64000 },
                                    },
                                    ["qwen3.7-max"] = {
                                        formatted_name = "Qwen 3.7 Max",
                                        meta = { max_tokens = 64000 },
                                    },
                                    ["glm-5.2"] = {
                                        formatted_name = "GLM 5.2",
                                        meta = { max_tokens = 32000 },
                                    },
                                },
                            },
                            extended_output = { default = false, enabled = false },
                            extended_thinking = { default = false, enabled = false },
                            thinking_budget = { default = 0, enabled = false },
                        },
                    })
                end,
                opencode = function()
                    local auth_path = vim.fn.expand("~/.local/share/opencode/auth.json")
                    local ok, data = pcall(function()
                        local f = io.open(auth_path, "r")
                        if not f then
                            return nil
                        end
                        local content = f:read("*a")
                        f:close()
                        return vim.json.decode(content)
                    end)
                    if ok and data and data.opencode then
                        vim.env.OPENCODE_API_KEY = data.opencode.key
                    end
                    return require("codecompanion.adapters").extend("openai_compatible", {
                        env = {
                            url = "https://api.opencode.ai",
                            api_key = "OPENCODE_API_KEY",
                        },
                        formatted_name = "OpenCode",
                        schema = {
                            model = {
                                default = "qwen3-coder-480b",
                                choices = {
                                    ["qwen3-coder-480b"] = {
                                        formatted_name = "Qwen3 Coder 480B",
                                    },
                                    ["deepseek-v4-pro"] = {
                                        formatted_name = "DeepSeek V4 Pro",
                                    },
                                    ["claude-sonnet-4-20250514"] = {
                                        formatted_name = "Claude Sonnet 4",
                                    },
                                    ["gpt-5-nano"] = {
                                        formatted_name = "GPT-5 Nano",
                                    },
                                },
                            },
                        },
                    })
                end,
            },
        },

        display = {
            action_palette = {
                provider = "snacks",
                opts = {
                    show_preset_prompts = true,
                },
            },
            chat = {
                window = {
                    layout = "vertical",
                    position = "right",
                    width = 0.45,
                    opts = {
                        wrap = true,
                        linebreak = true,
                    },
                },
                show_settings = false,
                show_token_count = true,
                show_reasoning = true,
                fold_reasoning = true,
                start_in_insert_mode = true,
                intro_message = "✨ CodeCompanion 已就绪，按 / 查看命令",
            },
            diff = {
                enabled = true,
                threshold_for_chat = 6,
            },
        },

        opts = {
            log_level = "WARN",
            language = "中文",
        },

        interactions = {
            chat = {
                adapter = "company",
                roles = {
                    llm = function(adapter)
                        return "CodeCompanion (" .. adapter.formatted_name .. ")"
                    end,
                    user = "我",
                },
                opts = {
                    context_management = {
                        enabled = true,
                        editing = { trigger = 0.65 },
                        compaction = { trigger = 0.85 },
                    },
                    system_prompt = function(ctx)
                        return ctx.default_system_prompt
                            .. "\n\n你必须用中文（简体中文）回答。所有解释、建议、非代码文字都必须使用中文。思考过程也使用中文。"
                    end,
                },
            },
            inline = {
                adapter = "company",
                opts = {
                    system_prompt = function(ctx)
                        return ctx.default_system_prompt
                            .. "\n\n你必须用中文（简体中文）回答。所有解释、建议、非代码文字都必须使用中文。思考过程也使用中文。"
                    end,
                },
            },
        },
    })

    vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>",
        { desc = "CodeCompanion Chat" })
    vim.keymap.set({ "n", "x" }, "<leader>ci", ":CodeCompanion ",
        { desc = "CodeCompanion Inline" })
    vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<CR>",
        { desc = "CodeCompanion Actions" })
end)
