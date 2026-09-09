-- 彩虹括号：为不同层级的 () {} [] 赋予不同颜色，Lisp 系语言尤其受用。
-- 基于 treesitter，默认策略即可用，无需额外 setup。
return {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
}
