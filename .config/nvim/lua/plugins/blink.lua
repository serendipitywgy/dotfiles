-- 自动检测并下载 blink.cmp 预编译二进制
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
            list = {
                selection = {
                    auto_insert = true,
                    preselect = true,
                },
            },
            accept = {
                auto_brackets = { enabled = true },
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
            preset = "super-tab",
            ['<Tab>'] = {
                "snippet_forward",
                function()
                    return require("sidekick").nes_jump_or_apply()
                end,
                "select_and_accept",
                "fallback",
            },
            ['<C-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
            ['<C-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
            ['<C-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
            ['<C-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
            ['<C-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
            ['<C-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
            ['<C-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
            ['<C-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
            ['<C-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
            ['<C-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
        },
        signature = {
            enabled = true
        },

        fuzzy = {
            frecency = { enabled = true },
        },

        sources = {
            default = { "lazydev", "path", "snippets", "buffer", "lsp" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
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
