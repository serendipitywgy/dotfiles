local trouble_ok, trouble

local function ensure_setup()
    if trouble_ok == nil then
        trouble_ok, trouble = pcall(require, "trouble")
        if trouble_ok then
            trouble.setup({})
        end
    end
    return trouble_ok
end

vim.keymap.set("n", "<leader>xx", function()
    if not ensure_setup() then return end
    trouble.toggle("diagnostics")
end, { desc = "Diagnostics (Trouble)" })

vim.keymap.set("n", "<leader>xX", function()
    if not ensure_setup() then return end
    trouble.toggle("diagnostics", { filter = { buf = 0 } })
end, { desc = "Buffer Diagnostics (Trouble)" })

vim.keymap.set("n", "<leader>cs", function()
    if not ensure_setup() then return end
    trouble.toggle("symbols", { focus = false })
end, { desc = "Symbols (Trouble)" })

vim.keymap.set("n", "<leader>cl", function()
    if not ensure_setup() then return end
    trouble.toggle("lsp", { focus = false, win = { position = "right" } })
end, { desc = "LSP (Trouble)" })

vim.keymap.set("n", "<leader>xL", function()
    if not ensure_setup() then return end
    trouble.toggle("loclist")
end, { desc = "Location List (Trouble)" })

vim.keymap.set("n", "<leader>xQ", function()
    if not ensure_setup() then return end
    trouble.toggle("qflist")
end, { desc = "Quickfix List (Trouble)" })
