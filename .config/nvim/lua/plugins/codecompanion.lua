vim.pack.add({
    {
        src = "https://github.com/olimorris/codecompanion.nvim",
        version = vim.version.range('v17.33.0'),
    },
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/zbirenbaum/copilot.lua" },
})

require("copilot").setup({
    suggestion = {
        enabled = true,                -- 启用建议功能
        auto_trigger = false,          -- 自动触发建议
        hide_during_completion = true, -- 在完成时隐藏建议
        debounce = 75,                 -- 建议的防抖时间（毫秒）
        trigger_on_accept = true,      -- 在接受建议时触发新的建议
        keymap = {
            -- accept = "<Tab>",          -- 按 Tab 键接受建议
            next = "<C-j>",    -- 下一个建议
            prev = "<C-k>",    -- 上一个建议
            dismiss = "<C-]>", -- 关闭建议
            --
        },
    },
    filetypes = {
        ["*"] = true, -- 所有文件类型都启用 Copilot
    },
})
require("codecompanion").setup({
    opts = {
        log_level = "DEBUG",
        language = "Chinese",
    },
    prompt_library = {
        ["Explain"] = {
            strategy = "chat",
            description = "解释选中代码",
            opts = {
                short_name = "explain",
            },
            prompts = {
                {
                    role = "system",
                    content = "你是一个经验丰富的程序员，请用简明中文説明代码。",
                },
                {
                    role = "user",
                    content = "解释选中的代码",
                },
            },
        },
        ["Review"] = {
            strategy = "chat",
            description = "审查选中代码",
            opts = {
                short_name = "review",
            },
            prompts = {
                {
                    role = "system",
                    content = "你是代码审查专家，请用中文详细分析下面代码的优缺点。",
                },
                {
                    role = "user",
                    content = "审查选中的代码",
                },
            },
        },
        ["Fix"] = {
            strategy = "chat",
            description = "修复代码 bug",
            opts = {
                short_name = "fix",
            },
            prompts = {
                {
                    role = "user",
                    content = "这段代码中存在一个问题，请重写这段代码以修复 bug。",
                },
            },
        },
        ["Optimize"] = {
            strategy = "chat",
            description = "优化选中代码",
            opts = {
                short_name = "optimize",
            },
            prompts = {
                {
                    role = "user",
                    content = "请优化选中的代码。",
                },
            },
        },
        ["Docs"] = {
            strategy = "chat",
            description = "生成中文 Doxygen 注释",
            opts = {
                short_name = "docs",
            },
            prompts = {
                {
                    role = "user",
                    content = "请以 Doxygen 格式为我的代码生成面向开发者的文档，注释以中文编写。",
                },
            },
        },
        ["Tests"] = {
            strategy = "chat",
            description = "生成测试代码",
            opts = {
                short_name = "tests",
            },
            prompts = {
                {
                    role = "user",
                    content = "请为我的代码生成测试。",
                },
            },
        },
        ["FixDiagnostic"] = {
            strategy = "chat",
            description = "修复诊断问题",
            opts = {
                short_name = "diagnostic",
            },
            prompts = {
                {
                    role = "user",
                    content = "请帮助解决以下文件中的诊断问题：",
                },
            },
        },
        ["Commit"] = {
            strategy = "chat",
            description = "生成规范 Commit 信息",
            opts = {
                short_name = "commit",
            },
            prompts = {
                {
                    role = "user",
                    content = [[
请写一个符合 commitizen 约定的提交信息。确保标题最多 50 个字符，消息在 72 个字符处换行。将整个消息用 gitcommit 语言包装在代码块中。
]],
                },
            },
        },
        ["CommitStaged"] = {
            strategy = "chat",
            description = "针对已暂存生成规范 Commit 信息",
            opts = {
                short_name = "commit_staged",
            },
            prompts = {
                {
                    role = "user",
                    content = [[
请写一个符合 commitizen 约定的提交信息。确保标题最多 50 个字符，消息在 72 个字符处换行。将整个消息用 gitcommit 语言包装在代码块中。
]],
                },
            },
        },
    }
})
