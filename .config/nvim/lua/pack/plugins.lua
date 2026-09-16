-- ==============================================================
-- 插件花名册（集中管理所有插件的下载地址）
-- ==============================================================
return {
    -- 主题
    { src = "https://github.com/catppuccin/nvim" },
    { src = "https://github.com/folke/tokyonight.nvim" },
    { src = "https://github.com/ellisonleao/gruvbox.nvim" },
    { src = "https://github.com/rebelot/kanagawa.nvim" },
    { src = "https://github.com/rose-pine/neovim" },
    { src = "https://github.com/sainnhe/everforest" },
    { src = "https://github.com/EdenEast/nightfox.nvim" },
    { src = "https://github.com/savq/melange-nvim" },
    { src = "https://github.com/glepnir/zephyr-nvim" },
    { src = "https://github.com/NLKNguyen/papercolor-theme" },
    { src = "https://github.com/kepano/flexoki-Neovim" },
    { src = "https://github.com/nvim-tree/nvim-web-devicons" },

    -- 状态栏
    { src = "https://github.com/linrongbin16/lsp-progress.nvim" },
    { src = "https://github.com/rebelot/heirline.nvim" },

    -- mini 系列
    { src = "https://github.com/nvim-mini/mini.ai" },
    { src = "https://github.com/nvim-mini/mini.surround" },

    -- tmux 导航（条件加载，此处统一下载）
    "https://github.com/christoomey/vim-tmux-navigator",

    -- snacks（多功能：picker、indent、notifier 等）
    { src = "https://github.com/folke/snacks.nvim" },

    -- LSP
    { src = "https://github.com/folke/lazydev.nvim" },
    { src = "https://github.com/mason-org/mason.nvim" },
    { src = "https://github.com/mason-org/mason-lspconfig.nvim" },
    { src = "https://github.com/neovim/nvim-lspconfig" },  -- 服务器定义注册表(0.12 只内置了 API,定义仍需插件)

    -- 补全
    { src = "https://github.com/rafamadriz/friendly-snippets" },
    { src = "https://github.com/archie-judd/blink-cmp-words" },
    { src = "https://github.com/saghen/blink.cmp", version = "v1.10.2" },

    -- 快速跳转
    { src = "https://github.com/folke/flash.nvim" },

    -- Treesitter
    { src = "https://github.com/nvim-treesitter/nvim-treesitter",          version = "main" },
    { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },

    -- noice（仅命令框，通知由 Snacks 接管）
    { src = "https://github.com/folke/noice.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },

    -- which-key
    { src = "https://github.com/folke/which-key.nvim" },
    { src = "https://github.com/folke/trouble.nvim" },

    -- autopairs / surround
    { src = "https://github.com/windwp/nvim-autopairs" },


    -- bufferline
    { src = "https://github.com/akinsho/bufferline.nvim" },

    -- 文件管理
    { src = "https://github.com/stevearc/oil.nvim" },

    -- 调试
    { src = "https://github.com/mfussenegger/nvim-dap" },
    { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
    { src = "https://github.com/nvim-neotest/nvim-nio" },
    { src = "https://github.com/rcarriga/nvim-dap-ui" },
    { src = "https://github.com/mfussenegger/nvim-dap-python" },

    -- git
    { src = "https://github.com/lewis6991/gitsigns.nvim" },


    -- Markdown 渲染
    { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
    { src = "https://github.com/3rd/image.nvim" },
    { src = "https://github.com/3rd/diagram.nvim" },

    -- 会话管理
    { src = "https://github.com/rmagatti/auto-session" },

    -- CMake
    { src = "https://github.com/nvim-lua/plenary.nvim" },
    { src = "https://github.com/Civitasv/cmake-tools.nvim" },

    -- 任务管理
    { src = "https://github.com/stevearc/overseer.nvim" },

    -- AI 补全 / Sidekick
    { src = "https://github.com/Exafunction/windsurf.vim" },
    { src = "https://github.com/folke/sidekick.nvim" },


    -- 重命名增量预览
    { src = "https://github.com/smjonas/inc-rename.nvim" },

    -- 格式化
    { src = "https://github.com/stevearc/conform.nvim" },

    -- 翻译
    { src = "https://github.com/uga-rosa/translate.nvim" },
}
