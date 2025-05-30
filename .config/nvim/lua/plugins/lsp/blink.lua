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
            },
            menu = {
                draw = {
                    treesitter = {'lsp',},
                    columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
                    components = {
                        item_idx = {
                            text = function(ctx) return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or
                                tostring(ctx.idx) end,
                            highlight = 'BlinkCmpItemIdx' -- optional, only if you want to change its color
                        }
                    }
                },
            },
        },
        keymap = {
            -- preset = "super-tab",
            preset = "super-tab",
            ['<A-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
            ['<A-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
            ['<A-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
            ['<A-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
            ['<A-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
            ['<A-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
            ['<A-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
            ['<A-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
            ['<A-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
            ['<A-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
            -- 默认键- '<C-f>' '<C-b>'
            -- ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
            -- ['<C-b>'] = { 'scroll_documentation_down', 'fallback' },
        },
        signature = {
            enabled = true
        },
        sources = {
            default = { "path", "snippets", "buffer", "lsp", "lazydev"},
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
