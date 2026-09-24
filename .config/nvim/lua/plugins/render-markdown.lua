local M = {}

local render_markdown_config = {
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
    file_types = { "markdown" },
}

local function load_plugins()
    if vim.g.loaded_render_markdown then return end

    vim.cmd.packadd("image.nvim")
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

    vim.cmd.packadd("diagram.nvim")
    require("diagram").setup({
        integrations = {
            require("diagram.integrations.markdown"),
        },
        renderer_options = {
            plantuml = {
                charset = "utf-8",
            },
            mermaid = {
                cli_args = { "--puppeteerConfigFile", vim.fn.stdpath("config") .. "/puppeteer.json" },
            },
        },
    })

    -- The plugin entrypoint reads this before attaching the current buffer.
    vim.g.render_markdown_config = render_markdown_config
    local ok, err = pcall(vim.cmd.packadd, "render-markdown.nvim")
    vim.g.render_markdown_config = nil
    if not ok then error(err) end
end

local function attach_markdown_keymaps(buf)
    if vim.bo[buf].filetype ~= "markdown" then return end

    vim.keymap.set("n", "<leader>mc", function()
        local lang = vim.fn.input("Language: ")
        vim.api.nvim_put({ "```" .. lang, "", "```" }, "l", true, true)
        vim.cmd("normal! k")
        vim.cmd("startinsert")
    end, { desc = "插入 Markdown 代码块", buffer = buf })

    vim.keymap.set("n", "K", function()
        require("diagram").show_diagram_hover()
    end, { desc = "预览图表 (PlantUML/Mermaid/D2)", buffer = buf })
end

function M.load(buf)
    local ok, err = pcall(load_plugins)
    if not ok then
        vim.notify("Failed to load Markdown plugins: " .. tostring(err), vim.log.levels.ERROR)
        return
    end
    attach_markdown_keymaps(buf)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("MarkdownPluginsLazyLoad", { clear = true }),
    pattern = { "markdown", "vimwiki" },
    callback = function(event)
        M.load(event.buf)
    end,
})

return M
