return {
    name = "Build current C/C++ file",
    tags = { "BUILD" },
    condition = {
        filetype = { "c", "cpp" },
    },
    builder = function()
        local path = vim.api.nvim_buf_get_name(0)
        return assert(require("config.build.single_file").task_definition(path, vim.bo.filetype))
    end,
}
