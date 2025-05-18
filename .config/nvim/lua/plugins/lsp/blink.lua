return {
    "saghen/blink.cmp",
    version = "*",
    dependencies = {
        "rafamadriz/friendly-snippets"
    },
    event = "VeryLazy",
    -- event = {'BufReadPost', 'BufNewFile'},
    opts = {
        completion = {
            documentation = {
                auto_show = true
            }
        },
        keymap = {
            -- preset = "super-tab",
            preset = "super-tab",

            -- 默认键- '<C-f>' '<C-b>'
            -- ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            -- ['<C-b>'] = { 'scroll_documentation_down', 'fallback' },
        },
        signature = {
            enabled = true
        },
        sources = {
            default = { "lazydev", "path", "snippets", "buffer", "lsp" },
            providers = {
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    -- score_offset = 100,
                },
            },
        },
        cmdline = {
            sources    = function()
                local cmd_type = vim.fn.getcmdtype()
                if cmd_type == "/" then
                    return { "buffer" }
                end
                if cmd_type == ":" then
                    return { "cmdline" }
                end
                return {}
            end,
            keymap     = {
                preset = "super-tab",
            },
            completion = {
                menu = {
                    auto_show = true
                }
            }
        }
    },
}
