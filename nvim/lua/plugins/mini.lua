return {
    "nvim-mini/mini.nvim",
    version = false,  -- 使用 main 分支，获取最新更新
    config = function()
        -- 只有你显式 setup 的模块才会被启用
        require('mini.icons').setup()
        -- 注释用 nvim 0.10+ 内置的 gc/gcc 操作符，不再需要 mini.comment
        -- require('mini.ai').setup()
    end
}
