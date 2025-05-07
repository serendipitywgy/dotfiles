return {
  'Exafunction/windsurf.vim',
  -- event = "InsertEnter",
  enabled = false,
  config = function ()
	-- Change '<C-g>' here to any keycode you like.
	-- 基本设置
    -- 确保 Windsurf 已启用
	vim.g.codeium_enabled = true
    -- 确保启用渲染
	vim.g.codeium_render = true
    -- 确保不是手动模式
	vim.g.codeium_manual = false

	-- 禁用状态栏集成，这可能是导致错误的原因
	vim.g.codeium_disable_status = true

	-- 设置超时时间，避免空响应
	vim.g.codeium_server_timeout_ms = 5000 -- 5秒超时
      
      -- 禁用默认的 Tab 键绑定
    vim.g.codeium_no_map_tab = 1
    vim.keymap.set('i', '<C-g>', function () return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-;>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-,>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
    vim.keymap.set('i', '<c-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
  end
}
