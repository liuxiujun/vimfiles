local wezterm = require("wezterm")
local act = wezterm.action

-- 检测操作系统，用于输入法切换命令
local is_windows = package.config:sub(1, 1) == "\\"

-- ==================== 输入法切换（仅 Windows 生效） ====================
local im_select_path = "im-select.exe"
local english_ime_id = "1033"

local function switch_to_english()
    if is_windows then
        wezterm.run_child_process({ im_select_path, english_ime_id })
    end
end

wezterm.on("user-var-changed", function(window, pane, name, value)
    wezterm.log_info(string.format("Captured Var: %s = %s", name, value))
    if name == "IM_SWITCH" then
        wezterm.log_info("Received IM_SWITCH=" .. value)
        if value == "normal" then
            switch_to_english()
        end
    end
end)

-- 可选：在窗口失去焦点时也切回英文（避免在别的窗口打字还是中文）
wezterm.on('window-focus-changed', function(window, pane)
    switch_to_english()
end)

-- ==================== 基础配置 ====================
local config = {}

-- 啟用 ConPTY 的透傳模式（需要較新版本的 Windows 10/11）
-- config.enable_conpty_backend = true
-- config.conpty_enable_passthrough = true
-- 檢查是否被轉換成了普通的控制序列
-- config.experimental_handle_unsupported_control_sequences = true

-- 基础外观
config.color_scheme = "Dracula"                 -- 可选：'GruvboxDark', 'Tokyo Night' 等

if is_windows then
    config.font = wezterm.font("Cascadia Code") -- 或 'Fira Code', 'JetBrains Mono'
else
    config.font = wezterm.font("CaskaydiaCove Nerd Font")
end
-- 全局禁用连字功能
config.harfbuzz_features = { 'calt=0', 'clig=0', 'liga=0' }
config.font_size = 12.0
config.enable_tab_bar = true
config.window_background_opacity = 1.0
config.hide_tab_bar_if_only_one_tab = false
-- config.window_decorations = 'RESIZE'  -- 只保留窗口边框调整

-- config.default_prog = { 'wsl.exe', '--cd', '~' }  -- 启动 WSL（如果你用 WSL）
if is_windows then
    config.default_prog = { "pwsh.exe" }
else
    config.default_prog = { "zsh", "-l" }
end

-- ==================== 启动菜单 ====================
if is_windows then
    config.launch_menu = {
        {
            label = "PowerShell",
            args = { "pwsh.exe" },
        },
        {
            label = "Windows PowerShell",
            args = { "powershell.exe" },
        },
        {
            label = "Command Prompt",
            args = { "cmd.exe" },
        },
        {
            label = "WSL:Ubuntu",
            args = { "wsl.exe", "~", "-d", "Ubuntu" },
        },
        {
            label = "tiankun(110)",
            args = {
                "ssh",
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "tiankun@172.18.102.110",
            },
        },
        {
            label = "zabbix MySQL(110)",
            args = {
                "mysqlsh",
                "root@172.18.102.110:3306"
            },
        },
        {
            label = "dev@debian-lxj-test",
            args = {
                "ssh",
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "dev@172.31.0.150",
            },
        },
        {
            label = "lxj@debian-lxj-test",
            args = {
                "ssh",
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "lxj@172.31.0.150",
            },
        },
        {
            label = "Oracle 19c(150)",
            args = {
                "sql",
                "sys/oracle@//172.31.0.150:1521/ORCLPDB1",
                "as",
                "sysdba"
            },
        },
        {
            label = "cns@172.31.0.151",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "cns@172.31.0.151",
            },
        },
        {
            label = "dev@172.31.0.151",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "dev@172.31.0.151",
            },
        },
        {
            label = "root@lwops",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@172.18.102.233",
            },
        },
        {
            label = "root@saier",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@172.18.102.133",
            },
        },
        {
            label = "root@192.168.100.101",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@192.168.100.101",
            },
        },
        {
            label = "root@192.168.100.102",
            args = {
                "ssh", 
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@192.168.100.102",
            },
        },
        {
            label = "116 (CentOS 7)",
            args = {
                "ssh",
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@172.18.101.116",
            },
        },
        {
            label = "117 (CentOS 7)",
            args = {
                "ssh",
                "-i",
                wezterm.home_dir .. "/.ssh/id_ed25519",
                "root@172.18.101.117",
            },
        },
    }
else
    config.launch_menu = {
        {
            label = "zsh",
            args = { "zsh", "-l" },
        },
    }
end

-- ==================== 键盘快捷键 ====================
config.keys = {
    -- 常规复制/粘贴 (Ctrl+Shift+C / V)
    { key = "C",   mods = "CTRL|SHIFT", action = act.CopyTo("Clipboard") },
    { key = "V",   mods = "CTRL|SHIFT", action = act.PasteFrom("Clipboard") },

    -- 分屏 (Ctrl+Shift+ 上下左右)
    -- { key = 'UpArrow', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Up' } },
    -- { key = 'DownArrow', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Down' } },
    -- { key = 'LeftArrow', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Left' } },
    -- { key = 'RightArrow', mods = 'CTRL|SHIFT', action = act.SplitPane { direction = 'Right' } },

    -- 类似 DuplicatePaneAuto
    -- { key = "D", mods = "ALT|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },

    -- 窗格导航 (Alt+ 方向键)
    -- { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
    -- { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
    -- { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
    -- { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

    -- 调整窗格大小 (Ctrl+Alt+ 方向键)
    -- { key = 'UpArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize { 'Up', 1 } },
    -- { key = 'DownArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize { 'Down', 1 } },
    -- { key = 'LeftArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize { 'Left', 1 } },
    -- { key = 'RightArrow', mods = 'CTRL|ALT', action = act.AdjustPaneSize { 'Right', 1 } },

    -- 标签页管理 (Ctrl+Shift+T 新建, Ctrl+Shift+W 关闭, Ctrl+Tab 切换)
    { key = "t",   mods = "CTRL|SHIFT", action = act.SpawnTab("CurrentPaneDomain") },
    { key = "w",   mods = "CTRL|SHIFT", action = act.CloseCurrentTab({ confirm = true }) },
    { key = "Tab", mods = "CTRL",       action = act.ActivateTabRelative(1) },
    { key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },

    -- 快速重载配置 (Ctrl+Shift+r)
    { key = "r",   mods = "CTRL|SHIFT", action = act.ReloadConfiguration },

    -- 搜索模式 (Ctrl+Shift+f)
    { key = "f",   mods = "CTRL|SHIFT", action = act.Search("CurrentSelectionOrEmptyString") },

    -- 打开 launcher 菜单
    { key = "p",   mods = "CTRL|SHIFT", action = act.ShowLauncher },
}

return config
