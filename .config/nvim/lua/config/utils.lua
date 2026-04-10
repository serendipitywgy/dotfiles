local M = {}

M.is_lsp_attached = function()
    local clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
    return next(clients) ~= nil
end

M.is_mac = function()
    local uname = vim.uv.os_uname()
    return uname.sysname == "Darwin"
end

M.func_on_window = function(window_name, myfunc)
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == window_name then
            myfunc()
            break
        end
    end
end

---@param items snacks.picker.Item[]
M.open_grep_results = function(items)
    if #items == 0 then
        Snacks.notify("No results to display")
        return
    end

    -- build lines and line-to-item mapping
    local lines = {}
    local line_items = {} ---@type table<integer, snacks.picker.Item>
    local current_file = nil
    local file_count = 0

    for _, item in ipairs(items) do
        local filepath = Snacks.picker.util.path(item)
        if filepath ~= current_file then
            current_file = filepath
            file_count = file_count + 1
            table.insert(lines, filepath .. ":")
        end
        local lnum = item.pos and item.pos[1] or 1
        local content = item.line or item.text or ""
        table.insert(lines, string.format("  %4d │ %s", lnum, content))
        line_items[#lines] = item
    end

    -- header
    local header = string.format("Search Results: %d matches in %d files", #items, file_count)
    table.insert(lines, 1, header)
    table.insert(lines, 2, string.rep("─", #header))
    -- offset the mapping by 2 for the header
    local header_offset = 2

    -- create buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].buftype = "nofile"
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].filetype = "snacks_grep_results"
    vim.bo[buf].modifiable = false

    -- highlight file path lines and header
    local ns = vim.api.nvim_create_namespace("snacks_grep_results")
    vim.api.nvim_buf_add_highlight(buf, ns, "Title", 0, 0, -1)
    vim.api.nvim_buf_add_highlight(buf, ns, "SnacksPickerDir", 1, 0, -1)
    for i = 3, #lines do
        if line_items[i - header_offset] then
            local item = line_items[i - header_offset]
            local filepath = Snacks.picker.util.path(item)
            if lines[i]:find(filepath .. ":", 1, true) then
                vim.api.nvim_buf_add_highlight(buf, ns, "SnacksPickerDir", i - 1, 0, -1)
            end
        end
    end

    -- open in current window (bufferline will show it as a new buffer)
    vim.api.nvim_win_set_buf(0, buf)

    -- keymaps
    vim.keymap.set("n", "<CR>", function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local item = line_items[row - header_offset]
        if not item then
            return
        end
        local filepath = Snacks.picker.util.path(item)
        local lnum = item.pos and item.pos[1] or 1
        local col = item.pos and (item.pos[2] + 1) or 1
        -- open file in a new tab, keeping result tab intact
        vim.cmd.edit(filepath)
        vim.api.nvim_win_set_cursor(0, { lnum, col })
    end, { buffer = buf, desc = "Jump to result" })

    vim.keymap.set("n", "q", function()
        vim.cmd("close")
    end, { buffer = buf, desc = "Close results" })
end

M.reset_overseerlist_width = function()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_get_option_value("filetype", { buf = buf })
        if ft == "OverseerList" then
            local target_width = math.floor(vim.o.columns * 0.2)
            vim.api.nvim_win_set_width(win, target_width)
            break
        end
    end
end

return M
