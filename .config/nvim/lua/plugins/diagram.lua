vim.cmd.packadd("diagram.nvim")
local ok, diagram = pcall(require, "diagram")
if not ok then return end

diagram.setup({
  integrations = {
    require("diagram.integrations.markdown"),
  },
  renderer_options = {
    plantuml = {
      charset = "utf-8",
    },
    mermaid = {
      cli_args = { "--puppeteerConfigFile", vim.fn.stdpath("config") .. "/puppeteer.json" },
    },
  },
})

-- Markdown 文件中在代码块内按 K 预览图表
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.keymap.set("n", "K", function()
      require("diagram").show_diagram_hover()
    end, { desc = "预览图表 (PlantUML/Mermaid/D2)", buffer = true })
  end,
})
