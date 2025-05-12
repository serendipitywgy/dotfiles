return {
    "williamboman/mason.nvim",
    event = "VeryLazy",
    dependencies = {
        {"neovim/nvim-lspconfig"},
        {"williamboman/mason-lspconfig.nvim"},
        { "MysticalDevil/inlay-hints.nvim", event = "LspAttach" },
    },
    opts = {},
    config = function(_, opts)
        require("mason").setup(opts)
        local registry = require "mason-registry"

        local function setup(name, config)
            local success, package = pcall(registry.get_package, name)
            if success and not package:is_installed() then
                package:install()
            end
            local nvim_lsp = require("mason-lspconfig.mappings.server").package_to_lspconfig[name]
            config.capabilities = require("blink.cmp").get_lsp_capabilities()
            require("lspconfig")[nvim_lsp].setup(config)
        end

        require("inlay-hints").setup()

        local servers = {
            ["lua-language-server"] = {
                settings = {
                    Lua = {
                        hint = { enabled = true},
                        diagnostics = {
                            globals = { "vim" }
                        }
                    }
                }
            },
            pyright = {},
            clangd = {
                InlayHints = {
                    Designators = true,
                    Enabled = true,
                    ParameterNames = true,
                    DeducedTypes = true,
                },
                fallbackFlags = { "-std=c++20" },
            },
            ["cmake-language-server"] = {},
            -- stylua = {},
            -- shfmt = {},
        }

        for server, config in pairs(servers) do
            setup(server, config)
        end

        vim.cmd("LspStart")
        vim.diagnostic.config({
            virtual_text = true,
            -- virtual_lines = true,
            update_in_insert = true,
        })
    end,
}
