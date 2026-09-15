require("render-markdown").setup({
    render_modes = { "n", "c", "i", "v" },
    heading = {
        icons = { "   ", "   ", "   ", "   ", "   ", "   " },
    },
    code = {
        style = "full",
        width = "block",
    },
    win_options = {
        conceallevel = { default = vim.o.conceallevel, rendered = 2 },
    },
    file_types = { "markdown", "Avante" },
})

require("image").setup({
    backend = "kitty",
    integrations = {
        markdown = {
            enabled = true,
            clear_in_insert_mode = false,
            download_remote_images = true,
            only_render_image_at_cursor = false,
            filetypes = { "markdown", "vimwiki" },
        },
    },
    max_width = nil,
    max_height = nil,
    max_height_window_percentage = 80,
    max_width_window_percentage = 80,
    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
})

local M = {}

function M.attach()
    vim.keymap.set("n", "<leader>mc", function()
        local lang = vim.fn.input("Language: ")
        vim.api.nvim_put({ "```" .. lang, "", "```" }, "l", true, true)
        vim.cmd("normal! k")
        vim.cmd("startinsert")
    end, { desc = "插入 Markdown 代码块", buffer = true })
end

return M
