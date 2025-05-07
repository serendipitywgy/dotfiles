-- 在你的 lua/plugins/markdown.lua 文件中
return {
    -- Markdown 预览
    {
        "iamcco/markdown-preview.nvim",
        cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
        keys = {
            {
                "<leader>mp",
                ft = "markdown",
                "<cmd>MarkdownPreviewToggle<cr>",
                desc = "Markdown Preview",
            },
        },
        config = function()
            vim.cmd([[do FileType]])
        end,
    },

    -- Markdown 渲染增强（可选）
    {
        "MeanderingProgrammer/render-markdown.nvim",
        opts = {
            code = {
                sign = false,
                width = "block",
                right_pad = 1,
            },
            heading = {
                sign = false,
                icons = {},
            },
            checkbox = {
                enabled = false,
            },
        },
        ft = { "markdown" },
        config = function(_, opts)
            require("render-markdown").setup(opts)
        end,
    },

    -- LSP 支持（如果你使用 lspconfig）
    -- {
    --     "neovim/nvim-lspconfig",
    --     opts = {
    --         servers = {
    --             marksman = {},
    --         },
    --     },
    -- },

    -- Mason 工具安装（如果你使用 mason.nvim）
    {
        "williamboman/mason.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "markdownlint-cli2", "markdown-toc" })
        end,
    },
}
