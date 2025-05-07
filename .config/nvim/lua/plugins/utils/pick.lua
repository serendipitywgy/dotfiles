---@class utils.pick
---@overload fun(command:string, opts?:utils.pick.Opts): fun()
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.wrap(...)
  end,
})

---@class utils.pick.Opts: table<string, any>
---@field root? boolean
---@field cwd? string
---@field buf? number
---@field show_untracked? boolean

---@class Picker
---@field name string
---@field open fun(command:string, opts?:utils.pick.Opts)
---@field commands table<string, string>

---@type Picker?
M.picker = nil

-- 简单的日志函数
local function log(level, msg)
  vim.notify(msg, vim.log.levels[level:upper()])
end

---@param picker Picker
function M.register(picker)
  if M.picker and M.picker.name ~= picker.name then
    log("warn", "`pick`: picker already set to `" .. M.picker.name .. "`,\nignoring new picker `" .. picker.name .. "`")
    return false
  end
  M.picker = picker
  return true
end

---@param command? string
---@param opts? utils.pick.Opts
function M.open(command, opts)
  if not M.picker then
    return log("error", "pick: picker not set")
  end

  command = command ~= "auto" and command or "files"
  opts = opts or {}

  opts = vim.deepcopy(opts)

  if type(opts.cwd) == "boolean" then
    log("warn", "pick: opts.cwd should be a string or nil")
    opts.cwd = nil
  end

  -- 使用你的 Root 模块获取根目录
  if not opts.cwd and opts.root ~= false then
    opts.cwd = Root({ buf = opts.buf, normalize = true })
  end

  command = M.picker.commands[command] or command
  M.picker.open(command, opts)
end

---@param command? string
---@param opts? utils.pick.Opts
function M.wrap(command, opts)
  opts = opts or {}
  return function()
    M.open(command, vim.deepcopy(opts))
  end
end

function M.config_files()
  return M.wrap("files", { cwd = vim.fn.stdpath("config") })
end

return M
