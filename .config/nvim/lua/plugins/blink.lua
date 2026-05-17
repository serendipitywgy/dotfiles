local function blink_cmp2()
    require("blink.cmp").setup({
        completion = {
            documentation = {
                auto_show = true
            },
            ghost_text = {
                enabled = true,
                show_with_menu = false
            },
            menu = {
                draw = {
                    treesitter = { 'lsp', },
                    columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
                    components = {
                        item_idx = {
                            text = function(ctx)
                                return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or
                                    tostring(ctx.idx)
                            end,
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
            default = { "path", "snippets", "buffer", "lsp" },
            providers = {
                buffer = {
                    opts = {
                        max_async_buffer_size = 1000000,
                        max_total_buffer_size = 2000000,
                    },
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
                -- ghost_text = { enabled = true },
                -- menu的优先级比ghost_text高, 所以当menu显示时, ghost_text不会显示
                menu = {
                    auto_show = true
                }
            }
        }
    })
end

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
    once = true,
    callback = function()
        blink_cmp2()
    end,
})
