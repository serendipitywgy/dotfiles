local M = {}

local initialized = false
local dap_enabled = false

function M.ensure()
    if initialized then return require("overseer") end

    vim.cmd.packadd("overseer.nvim")
    local overseer = require("overseer")
    overseer.setup({
        dap = false,
        component_aliases = {
            default = {
                "on_exit_set_status",
                "on_complete_notify",
            },
            default_vscode = {
                "default",
                "on_result_diagnostics",
            },
        },
        task_list = {
            direction = "bottom",
            min_height = 12,
            max_height = 20,
            default_detail = 1,
            keymaps = {
                -- Let vim-tmux-navigator handle these keys.
                ["<C-k>"] = false,
                ["<C-j>"] = false,
            },
        },
    })
    initialized = true
    return overseer
end

function M.enable_dap()
    local overseer = M.ensure()
    if not dap_enabled then
        overseer.enable_dap()
        dap_enabled = true
    end
    return overseer
end

function M.open()
    M.ensure().open({ enter = false, direction = "bottom" })
end

function M.toggle()
    M.ensure().toggle({ direction = "bottom" })
end

function M.restart_last()
    local overseer = M.ensure()
    local task_list = require("overseer.task_list")
    local tasks = overseer.list_tasks({
        status = {
            overseer.STATUS.SUCCESS,
            overseer.STATUS.FAILURE,
            overseer.STATUS.CANCELED,
        },
        sort = task_list.sort_finished_recently,
    })

    if vim.tbl_isempty(tasks) then
        vim.notify("没有可重跑的任务", vim.log.levels.WARN)
        return
    end
    overseer.run_action(tasks[1], "restart")
end

vim.keymap.set("n", "<leader>oo", M.toggle, { desc = "切换任务面板" })
vim.keymap.set("n", "<leader>or", M.restart_last, { desc = "重跑最近任务" })

return M
