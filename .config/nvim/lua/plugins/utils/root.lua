---@class utils.root
---@overload fun(): string
local M = setmetatable({}, {
  __call = function(m, ...)
    return m.get(...)
  end,
})

-- 缓存每个缓冲区的根目录，键为缓冲区ID，值为根目录路径
---@type table<number, string>
M.cache = {}

-- 根目录检测策略，按优先级排序
-- 1. 首先尝试使用LSP服务器确定的根目录
-- 2. 然后查找 .git、lua 或 package.json 文件/目录
-- 3. 最后回退到当前工作目录
---@type string[]|string[][]|function[]
M.spec = { "lsp", { ".git", "lua", "package.json" }, "cwd" }

-- 检测器集合
M.detectors = {}

-- 当前工作目录检测器
-- 返回当前Neovim进程的工作目录
function M.detectors.cwd()
  return { vim.uv.cwd() }
end

-- LSP检测器
-- 从活动的LSP服务器获取根目录信息
function M.detectors.lsp(buf)
  local bufpath = M.bufpath(buf)
  if not bufpath then
    return {}
  end
  local roots = {} ---@type string[]
  -- 获取所有附加到该缓冲区的LSP客户端
  local clients = vim.lsp.get_clients({ bufnr = buf })
  for _, client in pairs(clients) do
    -- 收集工作区文件夹
    local workspace = client.config.workspace_folders
    for _, ws in pairs(workspace or {}) do
      roots[#roots + 1] = vim.uri_to_fname(ws.uri)
    end
    -- 收集根目录
    if client.config.root_dir then
      roots[#roots + 1] = client.config.root_dir
    end
  end
  -- 过滤出包含当前缓冲区路径的根目录（确保根目录是当前文件的祖先目录）
  return vim.tbl_filter(function(path)
    path = M.norm(path)
    return path and bufpath:find(path, 1, true) == 1
  end, roots)
end

-- 模式检测器
-- 向上查找匹配指定模式的文件或目录
---@param patterns string[]|string
function M.detectors.pattern(buf, patterns)
  -- 确保patterns是一个表
  patterns = type(patterns) == "string" and { patterns } or patterns
  -- 获取当前缓冲区的路径，如果没有则使用当前工作目录
  local path = M.bufpath(buf) or vim.uv.cwd()
  -- 向上查找匹配指定模式的文件/目录
  local pattern = vim.fs.find(function(name)
    for _, p in ipairs(patterns) do
      -- 精确匹配
      if name == p then
        return true
      end
      -- 通配符匹配（如 *.json）
      if p:sub(1, 1) == "*" and name:find(vim.pesc(p:sub(2)) .. "$") then
        return true
      end
    end
    return false
  end, { path = path, upward = true })[1]
  -- 如果找到，返回该文件/目录的父目录作为根目录
  return pattern and { vim.fs.dirname(pattern) } or {}
end

-- 获取缓冲区的完整路径
function M.bufpath(buf)
  return M.realpath(vim.api.nvim_buf_get_name(assert(buf)))
end

-- 规范化路径（统一斜杠方向，移除尾部斜杠）
function M.norm(path)
  if path == "" or path == nil then
    return nil
  end
  path = path:gsub("\\", "/"):gsub("/$", "")
  return path
end

-- 解析符号链接，获取真实路径
function M.realpath(path)
  if path == "" or path == nil then
    return nil
  end
  path = vim.uv.fs_realpath(path) or path
  return M.norm(path)
end

-- 将规范（spec）转换为检测器函数
---@param spec string|string[]|function
---@return function
function M.resolve(spec)
  -- 如果是内置检测器名称（如 "lsp"、"cwd"），返回对应的检测器
  if M.detectors[spec] then
    return M.detectors[spec]
  -- 如果是函数，直接返回该函数
  elseif type(spec) == "function" then
    return spec
  end
  -- 否则，假设是文件/目录模式，返回一个使用pattern检测器的函数
  return function(buf)
    return M.detectors.pattern(buf, spec)
  end
end

-- 核心函数：按照指定的规范检测根目录
---@param opts? { buf?: number, spec?: string[]|string[][]|function[], all?: boolean }
function M.detect(opts)
  opts = opts or {}
  -- 使用默认规范或自定义规范
  opts.spec = opts.spec or M.spec
  -- 使用指定的缓冲区或当前缓冲区
  opts.buf = (opts.buf == nil or opts.buf == 0) and vim.api.nvim_get_current_buf() or opts.buf

  local ret = {}
  -- 遍历所有规范（spec）
  for _, spec in ipairs(opts.spec) do
    -- 对每个规范调用相应的检测器
    local paths = M.resolve(spec)(opts.buf)
    paths = paths or {}
    -- 确保paths是一个表
    paths = type(paths) == "table" and paths or { paths }
    local roots = {}
    -- 收集和规范化找到的路径
    for _, p in ipairs(paths) do
      local pp = M.realpath(p)
      if pp and not vim.tbl_contains(roots, pp) then
        roots[#roots + 1] = pp
      end
    end
    -- 按路径长度排序（优先选择更深的路径）
    table.sort(roots, function(a, b)
      return #a > #b
    end)
    -- 如果找到根目录，添加到结果中
    if #roots > 0 then
      ret[#ret + 1] = { spec = spec, paths = roots }
      -- 如果不需要所有结果，找到第一个根目录后就停止
      if opts.all == false then
        break
      end
    end
  end
  return ret
end

-- 设置模块：创建自动命令和用户命令
function M.setup()
  -- 创建自动命令清除缓存
  -- 在特定事件（如LSP附加、文件写入、目录更改等）时清除缓存
  vim.api.nvim_create_autocmd({ "LspAttach", "BufWritePost", "DirChanged", "BufEnter" }, {
    group = vim.api.nvim_create_augroup("root_cache", { clear = true }),
    callback = function(event)
      M.cache[event.buf] = nil
    end,
  })
  
  -- 添加用户命令 :Root，用于显示当前缓冲区的所有可能根目录
  vim.api.nvim_create_user_command("Root", function()
    local roots = M.detect({ all = true })
    local lines = {}
    for i, root in ipairs(roots) do
      for _, path in ipairs(root.paths) do
        lines[#lines + 1] = string.format("%s %s (%s)", 
          i == 1 and "→" or " ", -- 第一个根目录用箭头标记
          path, 
          type(root.spec) == "table" and table.concat(root.spec, ", ") or tostring(root.spec)
        )
      end
    end
    vim.print(lines)
  end, { desc = "Show root directories for current buffer" })
end

-- 获取并缓存根目录
---@param opts? {normalize?:boolean, buf?:number}
---@return string
function M.get(opts)
  opts = opts or {}
  local buf = opts.buf or vim.api.nvim_get_current_buf()
  -- 检查缓存中是否已有根目录
  local ret = M.cache[buf]
  if not ret then
    -- 如果没有，调用detect函数并取第一个结果
    local roots = M.detect({ all = false, buf = buf })
    -- 如果没有找到根目录，回退到当前工作目录
    ret = roots[1] and roots[1].paths[1] or vim.uv.cwd()
    -- 缓存结果以提高性能
    M.cache[buf] = ret
  end
  if opts and opts.normalize then
    return ret
  end
  -- 根据操作系统调整路径分隔符（Windows使用反斜杠）
  return vim.fn.has("win32") == 1 and ret:gsub("/", "\\") or ret
end

-- 获取Git仓库的根目录
function M.git()
  -- 首先获取项目根目录
  local root = M.get()
  -- 从该目录开始向上查找.git目录
  local git_root = vim.fs.find(".git", { path = root, upward = true })[1]
  -- 如果找到，返回.git的父目录；如果没有找到，返回项目根目录
  local ret = git_root and vim.fn.fnamemodify(git_root, ":h") or root
  return ret
end

return M
