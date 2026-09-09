-- Racket 文件：快捷运行（buffer-local）
-- REPL 交互式求值用 conjure（\ee 等，见 plugins/conjure.lua）
local file = vim.api.nvim_buf_get_name(0)

local function run_in_terminal(cmd)
    vim.cmd("belowright split | terminal " .. cmd)
end

vim.keymap.set("n", "<leader>rl", function()
    if file == "" then
        vim.notify("buffer not saved yet, save it first", vim.log.levels.WARN)
        return
    end
    run_in_terminal("racket " .. vim.fn.shellescape(file))
end, { buffer = true, desc = "Run racket file" })

vim.keymap.set("n", "<leader>rT", function()
    if file == "" then
        vim.notify("buffer not saved yet, save it first", vim.log.levels.WARN)
        return
    end
    run_in_terminal("raco test -x " .. vim.fn.shellescape(file))
end, { buffer = true, desc = "Raco test file" })
