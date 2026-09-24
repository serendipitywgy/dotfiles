local M = {}

local languages = {
    c = { compiler = "clang", args = { "-std=c17", "-g", "-Wall", "-Wextra" } },
    cpp = { compiler = "clang++", args = { "-std=c++20", "-g", "-Wall", "-Wextra" } },
}

function M.executable(path)
    local hash = vim.fn.sha256(vim.fs.normalize(path)):sub(1, 12)
    local directory = vim.fs.joinpath(vim.fn.stdpath("cache"), "build", hash)
    local name = vim.fs.basename(path):gsub("%.[^.]+$", "")
    return vim.fs.joinpath(directory, name)
end

function M.task_definition(path, filetype)
    local language = languages[filetype]
    if not language then return nil end

    local output = M.executable(path)
    vim.fn.mkdir(vim.fs.dirname(output), "p")
    local args = vim.deepcopy(language.args)
    vim.list_extend(args, { path, "-o", output })
    return {
        name = "Build current C/C++ file",
        cmd = { language.compiler },
        args = args,
        cwd = vim.fs.dirname(path),
        components = {
            {
                "on_output_quickfix",
                items_only = true,
                open_on_match = true,
                open_on_exit = "failure",
            },
            "default",
        },
    }
end

return M
