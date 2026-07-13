PackUtils.load({
    name = "codecompanion.nvim",
    module = "codecompanion",
    deps = { "plenary.nvim", "codecompanion-history.nvim", "codecompanion-spinner.nvim" },
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
                            tools = true,
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
                        handlers = {
                            on_exit = function(_, data)
                                if not data.headers then return end
                                local parsed = {}
                                for _, h in ipairs(data.headers) do
                                    local k, v = h:match("([^:]+):%s*(.+)")
                                    if k then parsed[k] = v end
                                end
                                local mappings = {
                                    ["X-Ratelimit-Remaining"] = "daily_remain",
                                    ["X-Ratelimit-Reset"] = "reset",
                                }
                                local info = {}
                                for header, key in pairs(mappings) do
                                    if parsed[header] then info[key] = parsed[header] end
                                end
                                if next(info) then
                                    _G.CC_QUOTA = info
                                end
                            end,
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
                                default = "Big_Pickle",
                                choices = {
                                    ["Big_Pickle"] = {
                                        formatted_name = "Big Pickle",
                                    },
                                    ["deepseek-v4-pro"] = {
                                        formatted_name = "DeepSeek V4 Pro",
                                    },
                                },
                            },
                        },
                    })
                end,
            },
            acp = {
                opencode = function()
                    return require("codecompanion.adapters").extend("opencode", "acp", {
                        formatted_name = "OpenCode ACP",
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
                show_header_separator = true,
                separator = "━",
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

        extensions = {
            history = {
                enabled = true,
                opts = {
                    keymap = "gh",
                },
            },
            spinner = {},
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
            cli = {
                agent = "claude",
                agents = {
                    claude = {
                        cmd = "claude",
                        args = {},
                        description = "Claude Code CLI",
                        provider = "terminal",
                    },
                    opencode = {
                        cmd = "opencode",
                        args = {},
                        description = "OpenCode CLI",
                        provider = "terminal",
                    },
                },
            },
        },
    })

    vim.keymap.set("n", "<leader>cc", "<cmd>CodeCompanionChat Toggle<CR>",
        { desc = "AI Chat" })
    vim.keymap.set({ "n", "x" }, "<leader>ci", ":CodeCompanion ",
        { desc = "AI Inline" })
    vim.keymap.set("n", "<leader>ca", "<cmd>CodeCompanionActions<CR>",
        { desc = "AI Actions" })

    local function is_vertical_screen()
        return vim.o.columns < 120
    end

    local hooks = vim.api.nvim_create_augroup("CodeCompanionHooks", {})
    vim.api.nvim_create_autocmd("User", {
        pattern = "CodeCompanionChatOpened",
        group = hooks,
        callback = function()
            if is_vertical_screen() and vim.bo.filetype == "codecompanion" then
                vim.cmd("wincmd J")
            end
        end,
    })

    vim.keymap.set("n", "<LocalLeader>cc", function()
        require("codecompanion").toggle_cli()
    end, { desc = "CLI toggle" })
    vim.keymap.set({ "n", "v" }, "<LocalLeader>cp", function()
        require("codecompanion").cli({ prompt = true })
    end, { desc = "CLI prompt" })
    vim.keymap.set({ "n", "v" }, "<LocalLeader>ca", function()
        require("codecompanion").cli("#{this}", { focus = false })
    end, { desc = "CLI add context" })
    vim.keymap.set("n", "<LocalLeader>cd", function()
        require("codecompanion").cli("#{diagnostics} Can you fix these?", { focus = false, submit = true })
    end, { desc = "CLI diagnostics fix" })
    vim.keymap.set("n", "<LocalLeader>ct", function()
        require("codecompanion").cli("#{terminal} Sharing output. Can you fix it?", { focus = false, submit = true })
    end, { desc = "CLI terminal fix" })
    vim.keymap.set("n", "<leader>cq", function()
        if _G.CC_QUOTA then
            local parts = {}
            for k, v in pairs(_G.CC_QUOTA) do
                table.insert(parts, k .. ": " .. v)
            end
            vim.notify("API 额度: " .. table.concat(parts, ", "))
        else
            vim.notify("暂无额度信息", vim.log.levels.INFO)
        end
    end, { desc = "AI quota" })
end)
