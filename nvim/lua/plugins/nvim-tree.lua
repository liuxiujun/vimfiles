return {
    "nvim-tree/nvim-tree.lua",
    lazy = false,
    config = function()
        local is_ok, nvim_tree = pcall(require, "nvim-tree")
        if not is_ok then
            return
        end

        -- Hint: :help nvim-tree-default-mappings
        -- setup with some options
        nvim_tree.setup({
            sort_by = "case_sensitive",
            git = {
                enable = true,
                timeout = 10000,
            },
            renderer = {
                group_empty = true,
                icons = {
                    show = {
                        git = true,
                    },
                },
            },
            filters = {
                dotfiles = false,
            },
            diagnostics = {
                enable = true,
            },
            tab = {
                sync = {
                    open = true,  -- 新标签也自动打开文件树
                    close = true, -- 同步关闭所有标签页的文件
                },
            },
            view = {
                width = {
                    min = 20,
                    max = 60,
                    padding = 1,
                },
            },
        })
    end,
    keys = {
        { "<leader>e", "<cmd>NvimTreeToggle<CR>", desc = "[E]xplorer" },
        { "<leader>o", "<cmd>NvimTreeFindFile<CR>", desc = "Reveal current file" },
    },
}
