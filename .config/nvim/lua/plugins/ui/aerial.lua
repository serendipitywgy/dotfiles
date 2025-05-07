return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons"
    },
    event = "BufRead",  -- 在打开文件时加载
    config = function()
        require("aerial").setup({
            -- 优先使用 LSP，其次使用 Treesitter
            backends = { "lsp", "treesitter", "markdown", "man" },

            -- 布局选项
            layout = {
                -- 默认宽度
                default_direction = "right",
                -- 宽度
                width = 30,
                -- 最小宽度
                min_width = 20,
            },

            -- 显示导航箭头
            show_guides = true,

            -- 在打开文件时自动打开 aerial
            -- 设为 false 可以手动控制
            open_automatic = false,

            -- 自动关闭没有符号的缓冲区
            close_automatic_events = { "unsupported" },

            -- 高亮当前项目
            highlight_on_hover = true,

            -- 自动聚焦到当前位置
            autojump = true,

            -- 过滤显示的符号
            filter_kind = {
                "Class",
                "Constructor",
                "Enum",
                "Function",
                "Interface",
                "Method",
                "Struct",
                "Namespace",
            },

            -- 图标设置
            icons = {
                Class = "󰠱 ",
                Constructor = " ",
                Enum = " ",
                Function = "󰊕 ",
                Interface = " ",
                Method = "󰆧 ",
                Struct = "󰙅 ",
                Namespace = "󰌗 ",
            },

            -- 自定义 LSP 优先级
            lsp = {
                -- 优先使用 clangd 作为 C++ 的 LSP
                priority = {
                    "clangd",
                    "pyright",
                    "lua_ls",
                },
            },

            -- 键位绑定
            keymaps = {
                ["<CR>"] = "actions.jump",
                ["<C-v>"] = "actions.jump_vsplit",
                ["<C-s>"] = "actions.jump_split",
                ["p"] = "actions.scroll",
                ["<C-j>"] = "actions.down_and_scroll",
                ["<C-k>"] = "actions.up_and_scroll",
            },
        })

        -- 设置命令
        vim.keymap.set("n", "<leader>cs", "<cmd>AerialToggle!<CR>", { desc = "打开/关闭代码大纲" })

        -- 可选：在启动时自动打开 aerial
        -- vim.cmd("autocmd FileType * AerialOpen")
    end,
}
