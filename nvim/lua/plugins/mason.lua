return {
    -- 1. Mason: 安装 LSP 服务器、DAP、Linter 等外部工具
    {
        "mason-org/mason.nvim",
        event = "VeryLazy",
        opts = {
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        },
    },
    -- 2. mason-tool-installer: 插件会在nvim启动时自动检查并安装缺失的 Lsp Server, linter, formatter
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = { "mason-org/mason.nvim" },
        opts = {
            ensure_installed = {
                -- LSP（与 config/lsp.lua 的 vim.lsp.enable 对齐）
                "lua-language-server",
                "basedpyright",
                "ruff",
                "debugpy",
                "bash-language-server",
                "perlnavigator",
                "clangd",
                "jdtls",
                "java-debug-adapter",
                "java-test",
                "typescript-language-server", -- ts_ls
                "intelephense",               -- php
                "gopls",
                -- Formatters / Linters（与 conform.nvim 的 formatters_by_ft 对齐）
                "stylua",
                "prettier",
                "shfmt",
                "clang-format",
                "goimports",
                "gofumpt",
                "google-java-format",
                -- perltidy 不在 mason 仓库，需自行安装：cpan Perl::Tidy
                "eslint_d",
            },
            auto_update = true,
            run_on_start = true,
        }
    },
}
