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

        local function set_keymaps(mode, keymaps, target, opts)
            for _, keymap in ipairs(keymaps) do
                vim.keymap.set(mode, keymap, target, opts)
            end
        end

        set_keymaps("n", { "<leader>cK" }, "<cmd>CMakeSelectKit<cr>", { desc = "CMake: 选择工具包" })
        set_keymaps("n", { "<leader>cG" }, "<cmd>CMakeGenerate<cr>", { desc = "CMake: 生成" })
        set_keymaps("n", { "<leader>cg" }, "<cmd>CMakeGenerate<cr>", { desc = "CMake: 配置" })
        set_keymaps("n", { "<leader>cb" }, "<cmd>CMakeBuild<cr>", { desc = "CMake: 构建" })
        set_keymaps("n", { "<leader>cr" }, "<cmd>CMakeRun<cr>", { desc = "CMake: 构建并运行" })
        set_keymaps("n", { "<leader>cD" }, "<cmd>CMakeQuickRun<cr>", { desc = "CMake: 构建并调试" })
        set_keymaps("n", { "<leader>ct" }, "<cmd>CMakeSelectBuildType<cr>", { desc = "CMake: 选择构建类型" })
        set_keymaps("n", { "<leader>cx" }, "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake: 选择启动目标" })
        set_keymaps("n", { "<leader>cv" }, "<cmd>CMakeSelectBuildPreset<cr>", { desc = "CMake: 选择变体" })
        set_keymaps("n", { "<leader>co" }, "<cmd>CMakeOpenExecutor<cr>", { desc = "CMake: 打开执行器" })
    end,
})
