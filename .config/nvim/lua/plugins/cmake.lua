vim.api.nvim_create_autocmd("VimEnter", {
    once = true,
    callback = function()
        require("cmake-tools").setup({
            cmake_command = "cmake",
            cmake_build_directory = "build",
            cmake_build_options = {},
            cmake_roll_forward = false,
            cmake_variantsfile = "CMakeLists.txt.user",
            cmake_executor = {
                name = "overseer",
                opts = {
                    on_new_task = function(task)
                        task:subscribe("on_complete", function(t, status)
                            if status == "SUCCESS" then
                                vim.schedule(function() t:dispose(true) end)
                            end
                        end)
                        require("overseer").open({ enter = false, direction = "bottom" })
                    end,
                },
            },
            cmake_runner = {
                name = "overseer",
                opts = {
                    on_new_task = function(_)
                        require("overseer").open({ enter = false, direction = "bottom" })
                    end,
                },
            },
            cmake_dap_configuration = {
                name = "cpp",
                type = "codelldb",
                request = "launch",
            },
            cmake_dap_debugger = "codelldb",
            cmake_notify_cmake_file_modified = false,
            cmake_show_compile_commands = function()
                return vim.fn.stdpath("data") .. "/cmake-tools/" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t") .. "/compile_commands.json"
            end,
        })
    end,
})
