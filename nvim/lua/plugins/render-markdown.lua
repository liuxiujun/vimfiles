return {
	"MeanderingProgrammer/render-markdown.nvim",
	opts = {
		completions = {
			blink = { enabled = true }, -- 开启 blink 补全源
		},
        -- 让markdown中的<!-- ... --> 原样显示出来, 不渲染
        html = {
            comment = {
                conceal = false,
            }
        }
	},
}
