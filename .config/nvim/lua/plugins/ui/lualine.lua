return {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        -- "stevearc/aerial.nvim",
    },
    event = "VeryLazy",
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
        },
        -- extensions = { "nvim-tree" },
        sections = {
            lualine_b = { "branch", "diff" },
            lualine_x = { "filesize", "encoding", "filetype" },
            lualine_y = { 'progress' }, -- 当前所在行数占总行数的百分比
            lualine_z = { 'location' }, -- 当前所在的行数和列数
            lualine_c = {               -- 添加一个新的组件来显示当前函数名
                {
                    -- function()
                    --     local aerial = require("aerial")
                    --     local symbol_info = aerial.get_location()
                    --
                    --     -- 添加调试信息，使用 vim.notify 输出 symbol_info
                    --     if symbol_info then
                    --         vim.notify("aerial.get_location() 返回: " .. vim.inspect(symbol_info), vim.log.levels.INFO,
                    --             { title = "Lualine Debug" })
                    --     else
                    --         vim.notify("aerial.get_location() 返回: nil", vim.log.levels.INFO, { title = "Lualine Debug" })
                    --     end
                    --
                    --     if symbol_info and symbol_info.name then
                    --         return symbol_info.name
                    --     end
                    --     return "No Function"
                    -- end,
                    -- color = { fg = "#ffffff", bg = "#444444" }, -- 可选：自定义颜色
                    -- padding = { left = 1, right = 1 },          -- 可选：自定义 padding
                    --
                    -- function()
                    --     local aerial = require("aerial")
                    --     local symbols = aerial.get_location()
                    --     if symbols and #symbols > 0 then
                    --         return symbols[1].name
                    --     end
                    --     return "No Function"
                    -- end,
                    -- color = { fg = "#ffffff", bg = "#444444" }, -- 可选：自定义颜色
                    -- padding = { left = 1, right = 1 },          -- 可选：自定义 padding
                },
            },
        },
    },
}
