-- 定义 catppuccin 配置
local catppuccin_config = {
    transparent_background = false, -- 启用透明背景
    custom_highlights = function(colors)
        local u = require("catppuccin.utils.colors")
        return {
            -- 自定义 CursorLineNr 高亮组，使其在透明背景下更为显眼
            CursorLineNr = { bg = u.blend(colors.overlay0, colors.base, 0.9), style = { "bold" } },
            -- 自定义 CursorLine 高亮组，使其在透明背景下更为显眼
            CursorLine = { bg = u.blend(colors.overlay0, colors.base, 0.6) },
            -- 使用更亮的颜色来突出 LspReferenceText、LspReferenceWrite 和 LspReferenceRead
            LspReferenceText = { bg = u.blend(colors.surface2, colors.base, 0.8) },
            LspReferenceWrite = { bg = u.blend(colors.surface2, colors.base, 0.8) },
            LspReferenceRead = { bg = u.blend(colors.surface2, colors.base, 0.8) },
            -- 自定义 Visual 模式的高亮，使其在透明背景下更为显眼
            Visual = { bg = u.blend(colors.blue, colors.base, 0.5) },
            -- 自定义 LineNr 高亮组，使行号更加明显
            LineNr = { fg = colors.overlay1 },
        }
    end,
    integrations = {
        aerial = true,                     -- 启用 aerial 插件的集成
        alpha = true,                      -- 启用 alpha 插件的集成
        cmp = true,                        -- 启用 cmp 插件的集成
        dashboard = true,                  -- 启用 dashboard 插件的集成
        flash = true,                      -- 启用 flash 插件的集成
        fzf = true,                        -- 启用 fzf 插件的集成
        grug_far = true,                   -- 启用 grug_far 插件的集成
        gitsigns = true,                   -- 启用 gitsigns 插件的集成
        headlines = true,                  -- 启用 headlines 插件的集成
        illuminate = true,                 -- 启用 illuminate 插件的集成
        indent_blankline = { enabled = true }, -- 启用 indent_blankline 插件的集成
        leap = true,                       -- 启用 leap 插件的集成
        lsp_trouble = true,                -- 启用 lsp_trouble 插件的集成
        mason = true,                      -- 启用 mason 插件的集成
        markdown = true,                   -- 启用 markdown 插件的集成
        mini = true,                       -- 启用 mini 插件的集成
        native_lsp = {
            enabled = true,                -- 启用 native LSP 的集成
            underlines = {
                errors = { "undercurl" },  -- 使用下划线表示错误
                hints = { "undercurl" },   -- 使用下划线表示提示
                warnings = { "undercurl" }, -- 使用下划线表示警告
                information = { "undercurl" }, -- 使用下划线表示信息
            },
        },
        navic = { enabled = true, custom_bg = "lualine" }, -- 启用 navic 插件的集成，并设置自定义背景为 lualine
        neotest = true,                                -- 启用 neotest 插件的集成
        neotree = true,                                -- 启用 neotree 插件的集成
        noice = true,                                  -- 启用 noice 插件的集成
        notify = true,                                 -- 启用 notify 插件的集成
        semantic_tokens = true,                        -- 启用 semantic tokens 的集成
        snacks = true,                                 -- 启用 snacks 插件的集成
        telescope = true,                              -- 启用 telescope 插件的集成
        treesitter = true,                             -- 启用 treesitter 插件的集成
        treesitter_context = true,                     -- 启用 treesitter_context 插件的集成
        which_key = true,                              -- 启用 which_key 插件的集成
    },
}
return {
    -- {
    --   "folke/tokyonight.nvim",
    --   lazy = false,  -- 确保主题立即加载
    --   priority = 1000,  -- 给主题高优先级
    --   opts = {
    --     transparent = true,
    --     styles = {
    --       sidebars = "transparent",
    --       floats = "transparent",
    --     },
    --   },
    --   config = function(_, opts)
    --     require("tokyonight").setup(opts)  -- 确保将opts传递给setup
    --     vim.cmd.colorscheme("tokyonight")
    --   end,
    -- },
    {
      "catppuccin/nvim",
      name = "catppuccin",
      lazy = false, -- 确保插件立即加载
      config = function()
        require("catppuccin").setup(catppuccin_config) -- 传递自定义配置
        vim.cmd.colorscheme("catppuccin") -- 在插件加载完成后应用颜色方案
      end,
    },
    -- "rose-pine/neovim",
    -- name = "rose-pine",
    -- config = function()
    --     vim.cmd("colorscheme rose-pine-dawn")
    -- end
}
