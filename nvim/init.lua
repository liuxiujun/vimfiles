-- 先设置系统判断和选项，再加载插件：lazy=false 的插件在 lazy.setup() 期间加载，
-- 选项（netrw 禁用、clipboard 等）必须先就位
require("config.system")
require("config.options")
require("config.lazy")
require("config.lsp")
require("config.keymaps")
require("config.autocmds")
