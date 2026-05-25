-- IME auto-switch for fcitx5 on Linux
-- InsertLeave: save state and deactivate; InsertEnter: restore previous state
local prev_active = false

local ime_augroup = vim.api.nvim_create_augroup("ImeAutoSwitch", { clear = true })

vim.api.nvim_create_autocmd("InsertLeave", {
    group = ime_augroup,
    callback = function()
        local state = vim.fn.system("fcitx5-remote")
        prev_active = vim.trim(state) == "2"
        if prev_active then
            vim.fn.jobstart({ "fcitx5-remote", "-c" })
        end
    end,
})

vim.api.nvim_create_autocmd("InsertEnter", {
    group = ime_augroup,
    callback = function()
        if prev_active then
            vim.fn.jobstart({ "fcitx5-remote", "-o" })
        end
    end,
})
