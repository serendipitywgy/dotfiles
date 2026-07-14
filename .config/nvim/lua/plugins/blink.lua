-- 自动检测并下载 blink.cmp 预编译二进制
local function ensure_blink_binary()
    local root = PackUtils.get_root("blink.cmp")
    if not root then return end

    -- 获取当前 git tag
    local handle = io.popen("cd " .. root .. " && git describe --tags 2>/dev/null")
    if not handle then return end
    local git_tag = handle:read("*l")
    handle:close()
    if not git_tag then return end

    -- 读取已安装的二进制版本
    local version_file = root .. "/target/release/version"
    local installed_version = nil
    local f = io.open(version_file, "r")
    if f then
        installed_version = f:read("*l")
        f:close()
    end

    -- 版本匹配，无需更新
    if installed_version == git_tag then return end

    -- 检测系统架构
    local arch = vim.loop.os_uname().machine
    local sysname = vim.loop.os_uname().sysname
    local platform = "x86_64-unknown-linux-gnu"
    local ext = ".so"

    if sysname == "Darwin" then
        ext = ".dylib"
        if arch == "arm64" then
            platform = "aarch64-apple-darwin"
        else
            platform = "x86_64-apple-darwin"
        end
    elseif sysname == "Linux" then
        if arch == "aarch64" then
            platform = "aarch64-unknown-linux-gnu"
        else
            platform = "x86_64-unknown-linux-gnu"
        end
    end

    local url = string.format(
        "https://github.com/Saghen/blink.cmp/releases/download/%s/%s%s",
        git_tag, platform, ext
    )
    local target_dir = root .. "/target/release"
    local target_file = target_dir .. "/libblink_cmp_fuzzy" .. ext

    vim.schedule(function()
        vim.notify("⚙️ Downloading blink.cmp binary for " .. git_tag .. "...", vim.log.levels.INFO)

        -- 创建目录
        vim.fn.mkdir(target_dir, "p")

        -- 下载二进制
        local cmd = string.format("curl -fSL -o %s %s", target_file, url)
        vim.fn.system(cmd)

        if vim.v.shell_error == 0 then
            -- 写入版本文件
            f = io.open(version_file, "w")
            if f then
                f:write(git_tag)
                f:close()
            end
            vim.notify("✅ blink.cmp binary downloaded for " .. git_tag, vim.log.levels.INFO)
        else
            vim.notify("❌ Failed to download blink.cmp binary", vim.log.levels.ERROR)
        end
    end)
end

-- 启动时检测并下载
ensure_blink_binary()

local function blink_cmp2()
    require("blink.cmp").setup({
        completion = {
            documentation = {
                auto_show = true
            },
            ghost_text = {
                enabled = true,
                show_with_menu = false
            },
            list = {
                selection = {
                    auto_insert = true,
                    preselect = true,
                },
            },
            accept = {
                auto_brackets = { enabled = true },
            },
            menu = {
                draw = {
                    treesitter = { 'lsp', },
                    columns = { { 'item_idx' }, { 'kind_icon' }, { 'label', 'label_description', gap = 1 } },
                    components = {
                        item_idx = {
                            text = function(ctx)
                                return ctx.idx == 10 and '0' or ctx.idx >= 10 and ' ' or
                                    tostring(ctx.idx)
                            end,
                            highlight = 'BlinkCmpItemIdx' -- optional, only if you want to change its color
                        }
                    }
                },
            },
        },
        keymap = {
            preset = "super-tab",
            ['<Tab>'] = {
                "snippet_forward",
                function()
                    return require("sidekick").nes_jump_or_apply()
                end,
                "select_and_accept",
                "fallback",
            },
            ['<C-1>'] = { function(cmp) cmp.accept({ index = 1 }) end },
            ['<C-2>'] = { function(cmp) cmp.accept({ index = 2 }) end },
            ['<C-3>'] = { function(cmp) cmp.accept({ index = 3 }) end },
            ['<C-4>'] = { function(cmp) cmp.accept({ index = 4 }) end },
            ['<C-5>'] = { function(cmp) cmp.accept({ index = 5 }) end },
            ['<C-6>'] = { function(cmp) cmp.accept({ index = 6 }) end },
            ['<C-7>'] = { function(cmp) cmp.accept({ index = 7 }) end },
            ['<C-8>'] = { function(cmp) cmp.accept({ index = 8 }) end },
            ['<C-9>'] = { function(cmp) cmp.accept({ index = 9 }) end },
            ['<C-0>'] = { function(cmp) cmp.accept({ index = 10 }) end },
        },
        signature = {
            enabled = true
        },

        fuzzy = {
            frecency = { enabled = true },
        },

        sources = {
            default = { "lazydev", "path", "snippets", "buffer", "lsp" },
            providers = {
                lazydev = { module = "lazydev.integrations.blink", score_offset = 100 },
                buffer = {
                    opts = {
                        max_async_buffer_size = 1000000,
                        max_total_buffer_size = 2000000,
                    },
                },
            },
        },
        cmdline = {
            sources    = function()
                local cmd_type = vim.fn.getcmdtype()
                if cmd_type == "/" then
                    return { "buffer" }
                end
                if cmd_type == ":" then
                    return { "cmdline" }
                end
                return {}
            end,
            keymap     = {
                preset = "super-tab",
            },
            completion = {
                menu = {
                    auto_show = true
                }
            }
        }
    })
end

vim.api.nvim_create_autocmd({ "InsertEnter", "CmdlineEnter" }, {
    group = vim.api.nvim_create_augroup("SetupCompletion", { clear = true }),
    once = true,
    callback = function()
        blink_cmp2()
    end,
})
