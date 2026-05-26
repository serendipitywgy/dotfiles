local sidekick_ok, sidekick

local function ensure_setup()
    if sidekick_ok == nil then
        sidekick_ok, sidekick = pcall(require, "sidekick")
        if sidekick_ok then
            sidekick.setup({
                cli = {
                    mux = { backend = "tmux", enabled = true },
                    win = {
                        layout = "right",
                        split = { width = 80 },
                    },
                    tools = {
                        claude = {
                            env = { TERM = "xterm-kitty" },
                        },
                        opencode = {},
                    },
                },
            })
        end
    end
    return sidekick_ok
end

vim.api.nvim_create_autocmd("InsertEnter", {
    once = true,
    callback = ensure_setup,
})

vim.keymap.set("n", "<Tab>", function()
    if not ensure_setup() then return "<Tab>" end
    return require("sidekick").nes_jump_or_apply() or "<Tab>"
end, { expr = true, desc = "NES 编辑建议跳转" })

vim.keymap.set("n", "<leader>aa", function()
    if not ensure_setup() then return end
    require("sidekick.cli").toggle()
end, { desc = "切换 CLI 终端" })

vim.keymap.set("n", "<leader>ac", function()
    if not ensure_setup() then return end
    require("sidekick.cli").toggle({ name = "claude", focus = true })
end, { desc = "打开 Claude" })

vim.keymap.set("n", "<leader>as", function()
    if not ensure_setup() then return end
    require("sidekick.cli").select()
end, { desc = "选择 CLI 工具" })

vim.keymap.set("n", "<leader>ad", function()
    if not ensure_setup() then return end
    require("sidekick.cli").close()
end, { desc = "关闭 CLI 终端" })

vim.keymap.set({ "n", "t", "i", "x" }, "<c-.>", function()
    if not ensure_setup() then return end
    require("sidekick.cli").focus()
end, { desc = "聚焦 CLI 终端" })

vim.keymap.set({ "n", "x" }, "<leader>at", function()
    if not ensure_setup() then return end
    require("sidekick.cli").send({ msg = "{this}" })
end, { desc = "发送此处上下文" })

vim.keymap.set("n", "<leader>af", function()
    if not ensure_setup() then return end
    require("sidekick.cli").send({ msg = "{file}" })
end, { desc = "发送当前文件" })

vim.keymap.set("x", "<leader>av", function()
    if not ensure_setup() then return end
    require("sidekick.cli").send({ msg = "{selection}" })
end, { desc = "发送选中代码" })

vim.keymap.set({ "n", "x" }, "<leader>ap", function()
    if not ensure_setup() then return end
    require("sidekick.cli").prompt()
end, { desc = "选择提示词模板" })
