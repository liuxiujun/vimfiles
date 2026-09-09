-- 跨平台添加 Mason bin 到 PATH
local mason_bin = vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin")
local separator = vim.fn.has("win32") == 1 and ";" or ":"
vim.env.PATH = mason_bin .. separator .. vim.env.PATH

-- blink.cmp 的补全能力声明；blink 未加载时退回默认能力，避免对它产生硬依赖
local capabilities = (function()
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        return blink.get_lsp_capabilities()
    end
    return vim.lsp.protocol.make_client_capabilities()
end)()

vim.lsp.config("bashls", {
    cmd = { "bash-language-server", "start" }, -- 启动命令
    filetypes = { "sh", "bash" },              -- 作用于哪些文件类型
    root_markers = { ".git", "package.json" }, -- 根目录标记（可选）
    capabilities = capabilities,
    settings = {},                             -- 服务器特定设置
})

-- 需要安装 cpan install Perl:Critic
vim.lsp.config("perlnavigator", {
    cmd = { "perlnavigator" },
    filetypes = { "perl" },
    capabilities = capabilities,
    init_options = {
        documentFeatures = {
            "documentSymbol", -- 必须启用
            "folding",
            "syntax",
        },
    },
    settings = {
        perlnavigator = {
            -- Windows 下 perl 通常在 PATH 中，不需要硬编码 /usr/bin/perl
            -- 如果报错找不到 perl，可以改为 "perl" 让系统自己去 PATH 找
            perlPath = vim.fn.has("win32") == 1 and "perl" or "/usr/bin/perl",
            enableWarnings = false,
            perlcriticEnabled = true,
            includePaths = {
                "lib",
                "t",
                -- 【修复核心】安全地获取用户主目录
                (function()
                    local home = os.getenv("HOME") or os.getenv("USERPROFILE")
                    if not home then
                        return ""
                    end -- 防止 nil
                    -- Windows 路径分隔符处理
                    local sep = vim.fn.has("win32") == 1 and "\\" or "/"
                    return home .. sep .. "perl5" .. sep .. "lib" .. sep .. "perl5"
                end)(),
            },
        },
    },
})

vim.lsp.config("basedpyright", {
    cmd = { "basedpyright-langserver", "--stdio" },
    filetypes = { "python" },
    root_markers = { ".git", ".venv", "pyproject.toml", "pyrightconfig.json" },
    capabilities = capabilities,
    -- 每次 LSP 启动时动态解析解释器：项目 .venv/venv > $VIRTUAL_ENV > 系统 python
    -- （放在 before_init 而不是这里求值，多项目/晚激活的 venv 也能生效）
    before_init = function(_, config)
        local suffix = vim.fn.has("win32") == 1 and "\\Scripts\\python.exe" or "/bin/python"
        local venv = vim.fs.find({ ".venv", "venv" }, { upward = true, path = config.root_dir or vim.uv.cwd() })[1]
        if venv then
            config.settings.python.pythonPath = vim.fs.joinpath(venv, suffix)
            return
        end
        local env = os.getenv("VIRTUAL_ENV")
        if env and env ~= "" then
            config.settings.python.pythonPath = env .. suffix
            return
        end
        config.settings.python.pythonPath = vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
    end,
    settings = {
        python = {
            analysis = {
                -- 类型检查模式，可选 "off", "basic", "strict"
                typeCheckingMode = "basic",
                -- 开启自动导入补全和建议的关键！
                autoImportCompletions = true,
                -- 诊断模式，设置为 "workspace" 以获得全局诊断，或 "openFilesOnly"
                diagnosticMode = "workspace",
                -- 启用未定义变量诊断（这是自动导入的前提）
                diagnosticSeverity = {
                    reportUndefinedVariable = "error",
                },
                -- 如果你希望禁用基于 pyright 的 import 组织（交给 ruff），可以保留
                disableOrganizeImports = true,
                -- 删除无效的 extraPaths，或者改用 Windows 路径（一般不需要）
                -- extraPaths = {},

                reportMissingTypeStubs = "none",
                reportUnknownVariableType = "none",
                reportUnknownMemberType = "none",
                reportFunctionMemberAccess = "none",
                reportAny = false,
            },
        },
    },
})

-- 配置 Ruff 内置语言服务器（负责 linting 和 formatting）
vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { ".git", "", "pyproject.toml", "pyrightconfig.json", "ruff.toml", ".ruff.toml" },
    capabilities = capabilities,
    -- 可选：覆盖某些能力，避免与 pyright 重复
    on_attach = function(client)
        -- 禁用 hover 能力，让 basedpyright 提供更好的类型信息
        -- （格式化统一走 conform 的 <leader>cf，不在这里挂保存时自动格式化）
        client.server_capabilities.hoverProvider = false
    end,
    init_options = {
        settings = {
            -- 你可以在这里配置 ruff 的具体行为，也可以在项目根目录的 ruff.toml 或 pyproject.toml 中配置
            lint = {
                ignore = { "F821" },
            },
        },
    },
})

vim.lsp.config("ts_ls", {
    cmd = { "typescript-language-server", "--stdio" },
    filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
    capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
    cmd = { "lua-language-server" },
    capabilities = capabilities,
    filetypes = { "lua" },
    settings = {
        Lua = {
            runtime = {
                -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim).
                version = "LuaJIT",
            },
            diagnostics = {
                -- Get the language server to recognize the `vim` global.
                globals = { "vim", "require", "pcall", "tonumber", "tostring", "unpack" },
            },
            workspace = {
                -- Make the server aware of Neovim runtime files.
                library = {
                    -- 1. 添加 Vim 运行时路径
                    vim.api.nvim_get_runtime_file("", true),
                    -- 2. 添加 $VIMRUNTIME/lua 目录
                    vim.fn.expand("$VIMRUNTIME/lua"),
                },
            },
            -- Do not send telemetry data containing a randomized but unique identifier.
            telemetry = {
                enable = false,
            },
        },
    },
})

vim.lsp.config("clangd", {
    cmd = { "clangd" },
    capabilities = capabilities,
    filetypes = { "c", "cpp", "objc", "objcpp" },
})

vim.lsp.config("gopls", {
    cmd = { "gopls" },
    capabilities = capabilities,
    -- 必须限定 filetypes：vim.lsp.enable 下不写 filetypes 会附着到所有 buffer
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.mod", ".git" },
    settings = {
        gopls = {
            analyses = {
                unusedparams = true,   -- 检查未使用的参数
                shadow = true,         -- 检查变量覆盖
            },
            staticcheck = true,        -- 启用 staticcheck[reference:11][reference:12]
            gofumpt = true,            -- 使用 gofumpt 进行格式化[reference:13]
            completeUnimported = true, -- 自动补全未导入的包[reference:14]
            usePlaceholders = true,    -- 为函数参数使用占位符[reference:15]
            semanticTokens = true,     -- 启用语义高亮[reference:16]
            hints = {                  -- 启用 inlay hints，显示类型等信息
                assignVariableTypes = true,
                compositeLiteralFields = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
            },
            codelenses = { -- 启用 CodeLens，在代码上方显示运行测试、整理依赖等快捷操作
                generate = true,
                test = true,
                tidy = true,
            },
        },
    },
})

-- vim.lsp.config("phpactor", {
--     cmd = { 'phpactor', 'language-server' },
--     filetypes = { 'php' },
--     root_markers = { '.git', 'composer.json', '.phpactor.json', '.phpactor.yml' },
--     init_options = {
--         ["language_server_phpstan.enabled"] = false,
--         ["language_server_psalm.enabled"] = false,
--     }
-- })

vim.lsp.config("intelephense", {
    cmd = { "intelephense", "--stdio" },
    filetypes = { "php" },
    root_markers = { '.git', 'composer.json', '.phpactor.json', '.phpactor.yml' },
})

-- Racket LSP（需先 raco pkg install racket-langserver）
-- 提供补全、跳转定义/引用、语法检查；REPL 求值由 conjure 负责（plugins/conjure.lua）
vim.lsp.config("racket_langserver", {
    cmd = { "racket", "-lib", "racket-langserver" },
    filetypes = { "racket" },
    root_markers = { "info.rkt", ".git" },
    capabilities = capabilities,
})

-- 1. 获取 JDTLS 安装路径
local jdtls_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"

-- 2. 获取确切的 launcher jar 文件名
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
-- glob 可能返回多行（如果有多个匹配），只取第一行
if type(launcher_jar) == "string" and launcher_jar:find("\n") then
    launcher_jar = launcher_jar:match("[^\n]+")
end

-- 3. 如果找不到 launcher jar，报错并停止
if not launcher_jar or launcher_jar == "" then
    vim.notify("jdtls launcher jar not found at " .. jdtls_path .. "/plugins/", vim.log.levels.ERROR)
else
    -- 4. JDK 21 的 java 可执行文件（根据你的实际路径）
    local java21 = "C:/Users/liuxi/scoop/apps/temurin21-jdk/current/bin/java.exe"

    -- 5. 配置 jdtls
    vim.lsp.config("jdtls", {
        cmd = {
            java21,
            "-Declipse.application=org.eclipse.jdt.ls.core.id1",
            "-Dosgi.bundles.defaultStartLevel=4",
            "-Declipse.product=org.eclipse.jdt.ls.core.product",
            "-Dlog.protocol=true",
            "-Dlog.level=ALL",
            "-javaagent:" .. jdtls_path .. "/lombok.jar",
            "-Xmx2G",
            "--add-modules=ALL-SYSTEM",
            "--add-opens", "java.base/java.util=ALL-UNNAMED",
            "--add-opens", "java.base/java.lang=ALL-UNNAMED",
            "-jar", launcher_jar, -- 使用精确路径
            "-configuration", jdtls_path .. "/config_win",
            "-data", vim.fn.stdpath("data") .. "/jdtls_workspace",
        },
        filetypes = { "java" },
        root_markers = { ".git", "pom.xml", "build.gradle", "gradle.build", "mvnw", "gradlew" },
        capabilities = capabilities, -- 确保这个变量已定义
        init_options = {
            extendedClientCapabilities = {
                classFileContentsSupport = true,
            },
            settings = {
                java = {
                    configuration = {
                        runtimes = {
                            {
                                name = "JavaSE-21",
                                default = true,
                                path = "C:/Users/liuxi/scoop/apps/temurin21-jdk/current",
                            },
                            {
                                name = "JavaSE-17",
                                path = "C:/Users/liuxi/scoop/apps/temurin17-jdk/current",
                            },
                        },
                    },
                },
            },
        },
    })
    vim.lsp.enable("jdtls")
end

-- jdtls 只在上面的 launcher jar 找到时启用，不放在下面的列表里，
-- 避免找不到 jar 时启用一个没有 cmd 的空配置
vim.lsp.enable({
    "lua_ls",
    "basedpyright",
    "ruff",
    "perlnavigator",
    "bashls",
    "ts_ls",
    "clangd",
    "gopls",
    "intelephense",
    "racket_langserver",
})
