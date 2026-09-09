-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

------------------------------------------------------------------------------------
--- 通过 wezterm 获取本地或远程的nvim模式，用来自动切换本地输入法 
------------------------------------------------------------------------------------
local function wezterm_set_user_var(name, value)
	local encoded = vim.base64.encode(value)
	local osc = string.format("\x1b]1337;SetUserVar=%s=%s\x1b\\", name, encoded)
	if vim.env.TMUX and vim.env.TMUX ~= "" then
		-- tmux 环境：包装后通过 stdout 输出（远程服务器上工作正常）
		local wrapped = "\x1bPtmux;\x1b" .. osc:gsub("\x1b", "\x1b\x1b") .. "\x1b\\"
		io.stdout:write(wrapped)
		io.stdout:flush()
	elseif vim.fn.has("win32") == 1 then
        -- todo 这并没有生效
        -- powershell执行: Write-Host "`eP+p`e]1337;SetUserVar=IM_SWITCH=bm9ybWFs`e\`e\"
        -- 执行成功并触发日志，说明WezTerm+ConPTY 25H2之间的连接是通的，问题还是出在nvim上
        -- :lua vim.fn.chansend(vim.v.stderr, "\x1bP+p\x1b]1337;SetUserVar=IM_SWITCH=bm9ybWFs\x1b\\\x1b\\")
        -- 没有输出說明 Windows 25H2 的 ConPTY 核心 對來自 Neovim 進程的 \x1bP 序列做了強制過濾。這通常是因為 Neovim 在 Windows 上是以 PIPE 模式啟動的，而 ConPTY 只對真正的 TTY 句柄開放透傳。
		local conpty_passthrough = "\x1bP+p" .. osc .. "\x1b\\"
		io.stdout:write(conpty_passthrough)
		io.stdout:flush()
	else
		io.stdout:write(osc)
		io.stdout:flush()
	end
end

vim.api.nvim_create_autocmd("InsertEnter", {
	callback = function()
		-- vim.notify("InsertEnter fired")
		wezterm_set_user_var("IM_SWITCH", "insert")
	end,
})

vim.api.nvim_create_autocmd("InsertLeave", {
	callback = function()
		-- vim.notify("InsertLeave fired")
		wezterm_set_user_var("IM_SWITCH", "normal")
	end,
})

-----------------------------------------------------------------
--- LspAttach 回调：所有 LSP 功能快捷键在这里设置
-----------------------------------------------------------------
-- 高亮相关的 augroup 只创建一次；光标停留时高亮符号，移动时清除
local highlight_augroup = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = true })
local clear_highlight_augroup = vim.api.nvim_create_augroup("LspClearHighlight", { clear = true })

vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("UserLspConfig", {}),
    callback = function(ev)

        local opts = { buffer = ev.buf, remap = false }

        -- 跳转
        vim.keymap.set("n", "gd", vim.lsp.buf.definition, vim.tbl_extend("keep", opts, { desc = "Goto definition" }))
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, vim.tbl_extend("keep", opts, { desc = "Goto declaration" }))
        vim.keymap.set("n", "gi", vim.lsp.buf.implementation, vim.tbl_extend("keep", opts, { desc = "Goto implementation" }))
        vim.keymap.set("n", "gr", vim.lsp.buf.references, vim.tbl_extend("keep", opts, { desc = "Goto references" }))
        vim.keymap.set("n", "gy", vim.lsp.buf.type_definition, vim.tbl_extend("keep", opts, { desc = "Goto type definition" }))

        -- 悬停与签名帮助
        vim.keymap.set("n", "K", vim.lsp.buf.hover, vim.tbl_extend("keep", opts, { desc = "Hover documentation" }))
        vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, vim.tbl_extend("keep", opts, { desc = "Signature help" }))

        -- 代码操作与重构
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, vim.tbl_extend("keep", opts, { desc = "Rename symbol" }))
        vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", opts, { desc = "Code action" }))
        vim.keymap.set("v", "<leader>ca", vim.lsp.buf.code_action, vim.tbl_extend("keep", opts, { desc = "Code action (visual)" }))
        -- 格式化统一走 conform 的 <leader>cf（LSP 作为 fallback），见 plugins/conform.lua

        -- 其他实用功能
        vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, vim.tbl_extend("keep", opts, { desc = "Add workspace folder" }))
        vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, vim.tbl_extend("keep", opts, { desc = "Remove workspace folder" }))
        vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, vim.tbl_extend("keep", opts, { desc = "List workspace folders" }))

        -- 获取 client 对象
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
            return
        end

        -- 动态获取缓冲区所在服务器的能力，可以设置更精细的快捷键（可选）
        if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
                buffer = ev.buf,
                callback = vim.lsp.buf.document_highlight,
                group = highlight_augroup,
            })
            vim.api.nvim_create_autocmd("CursorMoved", {
                buffer = ev.buf,
                callback = vim.lsp.buf.clear_references,
                group = clear_highlight_augroup,
            })
        end
    end,
})
