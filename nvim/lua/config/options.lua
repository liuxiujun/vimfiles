-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local system = require("config.system")

vim.opt.guifont = "MesloLGS Nerd Font:h11"

-- Enable undo/redo changes even after closing and reopening a file
vim.opt.undofile = true
vim.opt.exrc = true
vim.opt.secure = true -- 安全起见

-- File Format
vim.opt.fileformat = "unix" -- 新建文件默认保存为 Unix 格式（LF）
vim.opt.fileformats = "unix,dos,mac" -- 打开文件时自动检测行尾，优先当作 Unix 格式处理

-- Set Encoding
-- nvim 内部编码固定为 utf-8，这里只配置打开文件时的编码探测顺序
vim.opt.fileencodings = "utf-8,gbk,gb18030,latin1,ucs-bom"

-- Set Filetype
-- 将.tcss文件类型设置为css,为了让treesitter解析
vim.filetype.add({
	extension = {
		tcss = "css",
	},
})

-- 代码折叠不在这里全局设置：
-- treesitter 在 FileType 时设置 foldmethod=expr（配合 nvim-ufo），
-- 没有语法解析器的文件保持默认 manual，不做折叠

-- Clipboard
-- Hint: use `:h <option>` to figure out the meaning if needed
vim.opt.clipboard = "unnamedplus" -- use system clipboard

-- for Windows WSL
if system.is_windows or system.is_wsl then
	if vim.fn.executable("win32yank.exe") == 1 then
		vim.g.clipboard = {
			name = "win32yank",
			copy = { ["+"] = "win32yank.exe -i --crlf", ["*"] = "win32yank.exe -i --crlf" },
			paste = { ["+"] = "win32yank.exe -o --lf", ["*"] = "win32yank.exe -o --lf" },
			cache_enabled = 0,
		}
	else
		vim.notify("📋 win32yank not found, clipboard may not work on Windows/WSL", vim.log.levels.INFO)
	end
end

-- set terminal (windows)
-- if system.is_windows then
-- 	vim.opt.shell = "pwsh"
-- 	vim.opt.shellcmdflag = "-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command"
-- 	vim.opt.shellquote = ""
-- 	vim.opt.shellxquote = ""
-- end

-- Mouse
vim.opt.mouse = "a" -- allow the mouse to be used in Nvim

-- Tab
vim.opt.tabstop = 4 -- number of visual spaces per TAB
vim.opt.softtabstop = 4 -- number of spacesin tab when editing
vim.opt.shiftwidth = 4 -- insert 4 spaces on a tab
vim.opt.expandtab = true -- tabs are spaces, mainly because of python

-- UI config
vim.opt.number = true -- show absolute number
vim.opt.relativenumber = false -- add numbers to each line on the left side
vim.opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
vim.opt.splitbelow = true -- open new vertical split bottom
vim.opt.splitright = true -- open new horizontal splits right
vim.opt.termguicolors = true -- enabl 24-bit RGB color in the TUI
vim.opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint

-- Searching
vim.opt.incsearch = true -- search as characters are entered
vim.opt.hlsearch = false -- do not highlight matches
vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- For nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Diagnostic
-- :help vim.diagnostic.Opts
vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = " ", -- 这里配置“错误”的图标，需要nerd font字体
			[vim.diagnostic.severity.WARN] = " ",
			[vim.diagnostic.severity.INFO] = " ",
			[vim.diagnostic.severity.HINT] = " ",
		},
	},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local icons = {
				[vim.diagnostic.severity.ERROR] = " ",
				[vim.diagnostic.severity.WARN] = " ",
				[vim.diagnostic.severity.INFO] = " ",
				[vim.diagnostic.severity.HINT] = " ",
			}
			return (icons[diagnostic.severity] or "") .. diagnostic.message
		end,
	},
})

-- for neovide
if vim.g.neovide then
	vim.g.neovide_scale_factor = 1
	-- vim.g.guifont = "MesloLGS Nerd Font:h11"
	vim.g.neovide_cursor_animation_length = 0

	-- 添加快捷键，方便随时缩放 [citation:6]
	local function set_scale(delta)
		vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
		-- 强制重绘，让缩放立即生效
		vim.api.nvim_command("redraw!")
	end

	vim.keymap.set({ "n", "v" }, "<C-=>", function()
		set_scale(1.1)
	end, { desc = "Increase Neovide scale" })
	vim.keymap.set({ "n", "v" }, "<C-->", function()
		set_scale(0.9)
	end, { desc = "Decrease Neovide scale" })
	vim.keymap.set({ "n", "v" }, "<C-0>", function()
		vim.g.neovide_scale_factor = 1.0
		vim.api.nvim_command("redraw!")
	end, { desc = "Reset Neovide scale" })
end
