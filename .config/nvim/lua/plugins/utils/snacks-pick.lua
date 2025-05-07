-- 文件: lua/utils/pickers/snacks_picker.lua

-- 检查是否需要使用 snacks 作为默认选择器
if vim.g.default_picker == "snacks" then
  vim.g.default_picker = "snacks"
end

---@module 'snacks'

---@type Picker
local picker = {
  name = "snacks",
  commands = {
    files = "files",
    live_grep = "grep",
    oldfiles = "recent",
    grep_word = "grep_word",
    buffers = "buffers",
    git_files = "git_files",
    diagnostics = "diagnostics",
    lsp_references = "lsp_references",
    lsp_definitions = "lsp_definitions",
    lsp_implementations = "lsp_implementations",
    lsp_type_definitions = "lsp_type_definitions",
    lsp_symbols = "lsp_symbols",
    lsp_workspace_symbols = "lsp_workspace_symbols",
  },

  ---@param source string
  ---@param opts? snacks.picker.Config
  open = function(source, opts)
    -- 确保 Snacks 已加载
    if not package.loaded["snacks"] then
      require("snacks")
    end
    
    -- 处理特殊命令
    if source == "grep_word" then
      local word
      if vim.fn.mode() == "v" or vim.fn.mode() == "V" then
        -- 获取可视模式选择的文本
        local saved_reg = vim.fn.getreg("v")
        vim.cmd([[normal! "vy]])
        word = vim.fn.getreg("v")
        vim.fn.setreg("v", saved_reg)
      else
        -- 获取光标下的单词
        word = vim.fn.expand("<cword>")
      end
      
      opts = opts or {}
      opts.default_text = word
      return Snacks.picker.grep(opts)
    end
    
    -- 处理标准命令
    if Snacks.picker[source] then
      return Snacks.picker[source](opts)
    end
    
    -- 回退到通用选择器
    return Snacks.picker.pick(source, opts)
  end,
}

-- 注册选择器
local pick = require("plugins.utils.pick")
if not pick.register(picker) then
  return false
end

return true
