return {
    "ojroques/nvim-osc52",
    event = "VeryLazy",
    -- 只在 SSH 远程会话启用：本地已有 clipboard=unnamedplus（win32yank），
    -- 重复走 OSC52 既无收益，Windows ConPTY 也透传不了
    cond = function()
        return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil or vim.env.SSH_CONNECTION ~= nil
    end,
    config = function()
        require("osc52").setup({
            max_length = 0,
            trim = false,
            silent = false,
        })

        -- 当使用 `"+y` 或默认 `y` 时自动触发复制
        vim.api.nvim_create_autocmd("TextYankPost", {
            callback = function()
                if vim.v.event.operator == "y" then
                    require("osc52").copy_register(vim.v.event.regname == "" and '"' or vim.v.event.regname)
                end
            end,
        })
    end,
}
