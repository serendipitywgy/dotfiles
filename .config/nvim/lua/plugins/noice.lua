vim.pack.add({
    { src = "https://github.com/folke/noice.nvim" },
    { src = "https://github.com/MunifTanjim/nui.nvim" },
})
-- require("nui").setup()
-- nui只是noice依赖的插件，所以不需要setup
require("noice").setup({
    lsp = {
        override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
        },
    },
    routes = {
        {
            filter = {
                event = "msg_show",
                any = {
                    { find = "%d+L, %d+B" },
                    { find = "; after #%d+" },
                    { find = "; before #%d+" },
                },
            },
            view = "mini",
        },
    },
    presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
    },
})
