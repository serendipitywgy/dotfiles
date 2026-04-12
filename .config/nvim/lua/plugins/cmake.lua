require("cmake-tools").setup({
    cmake_command = "cmake",
    cmake_build_directory = "build",
    cmake_build_options = {},
    cmake_roll_forward = false,
    cmake_variantsfile = "CMakeLists.txt.user",
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

set_keymaps("n", { "<leader>cK" }, "<cmd>CMakeSelectKit<cr>", { desc = "CMake: Select Kit" })
set_keymaps("n", { "<leader>cG" }, "<cmd>CMakeGenerate<cr>", { desc = "CMake: Generate" })
set_keymaps("n", { "<leader>cg" }, "<cmd>CMakeGenerate<cr>", { desc = "CMake: Configure" })
set_keymaps("n", { "<leader>cb" }, "<cmd>CMakeBuild<cr>", { desc = "CMake: Build" })
set_keymaps("n", { "<leader>cr" }, "<cmd>CMakeRun<cr>", { desc = "CMake: Build & Run" })
set_keymaps("n", { "<leader>cd" }, "<cmd>CMakeQuickRun<cr>", { desc = "CMake: Build & Debug" })
set_keymaps("n", { "<leader>ct" }, "<cmd>CMakeSelectBuildType<cr>", { desc = "CMake: Select Build Type" })
set_keymaps("n", { "<leader>cx" }, "<cmd>CMakeSelectLaunchTarget<cr>", { desc = "CMake: Select Launch Target" })
set_keymaps("n", { "<leader>cv" }, "<cmd>CMakeSelectBuildPreset<cr>", { desc = "CMake: Select Variant" })
set_keymaps("n", { "<leader>co" }, "<cmd>CMakeOpenExecutor<cr>", { desc = "CMake: Open Executor" })

-- require("which-key").register({
--     ["<leader>c"] = { name = "CMake" },
-- })
