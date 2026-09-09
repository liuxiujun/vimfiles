-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Define common options
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", opts)
vim.keymap.set("n", "<C-j>", "<C-w>j", opts)
vim.keymap.set("n", "<C-k>", "<C-w>k", opts)
vim.keymap.set("n", "<C-l>", "<C-w>l", opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-Up>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- custom
vim.keymap.set("n", "<leader>s", ":w<CR>", { noremap = true, silent = true, desc="[S]ave" })
vim.keymap.set("n", "<leader>x", ":q<CR>", { noremap = true, silent = true, desc="Close" })
vim.keymap.set("n", "<leader>X", ":qa<CR>", { noremap = true, silent = true, desc="Close All" })

-- Buffer
-- <C-^> (:b # 的快捷键)  快速切换至上次缓冲区
-- 缓冲区切换使用 nvim 内置的 ]b / [b（0.11+ 自带），不再映射 <Tab>/<S-Tab>：
-- <Tab> 与 <C-i> 在终端里同键码，映射 <Tab> 会导致 jumplist 前进跳转失效
vim.keymap.set('n', '<leader>bd', function() require("mini.bufremove").delete(0, false) end, { desc = "Close buffer" })
vim.keymap.set('n', '<leader>bD', function() require("mini.bufremove").delete(0, true) end, { desc = "Force close buffer" })
vim.keymap.set('n', '<leader>bp', ':BufferLinePick<CR>', { desc = "Pick buffer" })
vim.keymap.set('n', '<leader>bP', ':BufferLinePickClose<CR>', { desc = "Pick buffer to close" })
vim.keymap.set('n', '<leader>bo', ':BufferLineCloseOthers<CR>', { desc = "Close other buffers" })
vim.keymap.set('n', '<leader>b0', ':bfirst<CR>', { desc = "First buffer" })
vim.keymap.set('n', '<leader>b$', ':blast<CR>', { desc = "Last buffer" })

-- For Overseer
vim.keymap.set("n", "<leader>rr", "<cmd>OverseerRun<cr>", { desc = "Run a task from a template" })
vim.keymap.set("n", "<leader>rt", "<cmd>OverseerToggle<cr>", { desc = "Toggle the overseer windows" })
vim.keymap.set("n", "<leader>ra", "<cmd>OverseerShell<cr>", { desc = "Run a shell command as an overseer task" })
vim.keymap.set("n", "<leader>rc", "<cmd>OverseerTaskAction<cr>", { desc = "Select a task to run an action on" })

-- For nvim-surround
--     Old text                    Command         New text
-- --------------------------------------------------------------------------------
--     surr*ound_words             ysiw)           (surround_words)
--     *make strings               ys$"            "make strings"
--     [delete ar*ound me!]        ds]             delete around me!
--     remove <b>HTML t*ags</b>    dst             remove HTML tags
--     'change quot*es'            cs'"            "change quotes"
--     <b>or tag* types</b>        csth1<CR>       <h1>or tag types</h1>

-- For diagnostic
-- vim.keymap.set("n", "]d", function() vim.diagnostic.goto_next() end, { desc = "Next diagnostic" })
-- vim.keymap.set("n", "[d", function() vim.diagnostic.goto_prev() end, { noremap = true, silent = true, desc = "Previous diagnostic" } )
vim.keymap.set("n", "<leader>cd", vim.diagnostic.open_float, { noremap = true, silent = true, desc = "Show line diagnostics" } )
vim.keymap.set("n", "<leader>cq", vim.diagnostic.setloclist, { noremap = true, silent = true, desc = "Send diagnostics to loclist" } )

-- Manage Lsp 
vim.keymap.set("n", "<leader>lC", "<cmd>checkhealth vim.lsp<CR>", { noremap = true, silent = true, desc = "[C]heckhealth (LspInfo)" })
-- vim.keymap.set("n", "<leader>ls", "<cmd>LspStart<CR>", { noremap = true, silent = true, desc = "Start LSP server (if not started )" })
vim.keymap.set("n", "<leader>lR", 
    function() 
        local bufnr = vim.api.nvim_get_current_buf()
        for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
            client:stop()
            vim.lsp.start(client.config, { bufnr = bufnr })
        end 
        vim.notify("LSP clients restarted", vim.log.levels.INFO)
    end , { desc = "[R]estart LSP clients for current buffer" })
-- vim.keymap.set("n", "<leader>lS", "<cmd>LspStop<CR>", { noremap = true, silent = true, desc = "Stop LSP server" })
vim.keymap.set("n", "<leader>lL", "<cmd>lua vim.cmd('edit ' .. vim.lsp.get_log_path())<CR>", { noremap = true, silent = true, desc = "Show LSP [L]og" })
vim.keymap.set("n", "<leader>lM", "<cmd>Mason<CR>", { noremap = true, silent = true, desc = "Open [M]ason (LSP installer )" })

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.keymap.set("v", "<", "<gv", opts)
vim.keymap.set("v", ">", ">gv", opts)

-- treesitter 文本对象与函数跳转（am/im/ac/ic、]m/]M/[m/[M）见 plugins/treesitter.lua


-------------------
-- Terminal mode --
-------------------
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")
