-- CodeCompanion 配置（Cursor CLI ACP）
local M = {}

local setup_ok, setup
local function ensure_setup()
    if setup_ok == nil then
        setup_ok, setup = pcall(require, "codecompanion")
        if setup_ok then
            setup.setup({
                adapters = {
                    acp = {
                        cursor_cli = function()
                            return require("codecompanion.adapters").extend("cursor_cli", {
                                commands = {
                                    default = { "agent", "acp", "--trust" },
                                },
                            })
                        end,
                    },
                },
                interactions = {
                    chat = {
                        adapter = "cursor_cli",
                        roles = {
                            llm = function(adapter)
                                local info = "Cursor"
                                if adapter.model then
                                    info = info .. "." .. adapter.model
                                end
                                return info
                            end,
                            user = "Me",
                        },
                    },
                },
                extensions = {
                    history = {
                        enabled = true,
                        opts = {
                            keymap = "gh",
                        },
                    },
                    spinner = {},
                },
                opts = {
                    language = "Chinese",
                    log_level = "WARN",
                },
            })
        end
    end
    return setup_ok
end

-- 快捷键
-- 聊天
vim.keymap.set("n", "<leader>ai", function()
    if not ensure_setup() then return end
    vim.cmd("CodeCompanionChat Toggle")
end, { desc = "[AI] 聊天 toggle" })

vim.keymap.set("v", "<leader>ae", function()
    if not ensure_setup() then return end
    vim.cmd("CodeCompanionChat Add")
end, { desc = "[AI] 选中内容加入聊天" })

vim.keymap.set({ "n", "v" }, "<leader>ao", function()
    if not ensure_setup() then return end
    vim.cmd("CodeCompanionActions")
end, { desc = "[AI] 动作面板" })

-- CLI（需配置 cli adapter）
-- vim.keymap.set("n", "<leader>ac", function()
--     if not ensure_setup() then return end
--     require("codecompanion").toggle_cli()
-- end, { desc = "[AI] CLI toggle" })

-- 命令行扩展 cc → CodeCompanion
vim.cmd([[cab cc CodeCompanion]])

return M
