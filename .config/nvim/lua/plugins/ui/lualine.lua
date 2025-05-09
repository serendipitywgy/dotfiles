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
            lualine_c = { {
                "filename",
                path = 3, -- 0 = 仅文件名, 1 = 相对路径, 2 = 绝对路径, 3 = 绝对路径，但相对于当前工作目录
            }, },
        },
    },
}
