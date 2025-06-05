return {
  'mason-org/mason.nvim',
  event = { 'BufReadPost', 'BufNewFile', 'VimEnter' },
  dependencies = {
    'mason-org/mason-lspconfig.nvim',
  },
  config = function()
    -- Mason基础配置
    require('mason').setup {
      pip = {
        upgrade_pip = false,
        install_args = pip_args,
      },
      ui = {
        border = 'single',
        width = 0.7,
        height = 0.7,
      },
    }

    -- 只管理语言服务器安装
    require('mason-lspconfig').setup {
      -- 预设需要安装的语言服务器列表
      ensure_installed = {
        'lua_ls',        -- Lua
        'pyright',       -- Python
        'clangd',        -- C/C++
        'cmake',         -- CMake
        -- 'rust_analyzer', -- Rust
        -- 'gopls',         -- Go
        -- 'tsserver',      -- TypeScript/JavaScript
        'bashls',        -- Bash
        'jsonls',        -- JSON
        'yamlls',        -- YAML
      },
      
      -- 自动更新注册表（可选）
      automatic_installation = true,
    }
  end
}
