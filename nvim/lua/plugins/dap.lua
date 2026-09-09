local function join_paths(...)
	local separator = package.config:sub(1, 1)
	return table.concat({ ... }, separator)
end

local function mason_package_path(package_name)
	local ok, registry = pcall(require, "mason-registry")
	if not ok or not registry.has_package(package_name) then
		return nil
	end

	local package = registry.get_package(package_name)
	if not package:is_installed() then
		return nil
	end

	return package:get_install_path()
end

local function debugpy_python()
	local debugpy = mason_package_path("debugpy")
	if not debugpy then
		return vim.fn.exepath("python3") ~= "" and "python3" or "python"
	end

	if vim.fn.has("win32") == 1 then
		return join_paths(debugpy, "venv", "Scripts", "python.exe")
	end

	return join_paths(debugpy, "venv", "bin", "python")
end

return {
	{
		"jay-babu/mason-nvim-dap.nvim",
		dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
		opts = {
			automatic_installation = true,
			handlers = {},
		},
	},

	{
		"mfussenegger/nvim-dap",
		event = "VeryLazy",
		dependencies = { "mason-org/mason.nvim" },
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Debug: start/continue" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Debug: step over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Debug: step into" },
			{ "<F12>", function() require("dap").step_out() end, desc = "Debug: step out" },
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
			{
				"<leader>dB",
				function()
					require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
				end,
				desc = "Debug: conditional breakpoint",
			},
			{ "<leader>dc", function() require("dap").run_to_cursor() end, desc = "Debug: run to cursor" },
			{ "<leader>dr", function() require("dap").repl.open() end, desc = "Debug: open REPL" },
			{ "<leader>dl", function() require("dap").run_last() end, desc = "Debug: run last" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Debug: terminate" },
		},
		config = function()
			local dap = require("dap")
			local java_debug = mason_package_path("java-debug-adapter")

			dap.adapters.java = function(callback)
				if not java_debug then
					vim.notify("java-debug-adapter not found, run :Mason", vim.log.levels.ERROR)
					return
				end

				local jar = vim.fn.glob(join_paths(java_debug, "extension", "server", "com.microsoft.java.debug.plugin-*.jar"))
				if jar == "" then
					vim.notify("java-debug-adapter jar not found, run :Mason", vim.log.levels.ERROR)
					return
				end

				callback({
					type = "executable",
					command = "java",
					args = { "-jar", jar },
				})
			end

			dap.configurations.java = {
				{
					type = "java",
					request = "launch",
					name = "Launch Java",
				},
			}
		end,
	},

	{
		"mfussenegger/nvim-dap-python",
		ft = "python",
		dependencies = { "mfussenegger/nvim-dap", "mason-org/mason.nvim" },
		config = function()
			require("dap-python").setup(debugpy_python())
		end,
	},

	{
		"rcarriga/nvim-dap-ui",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-neotest/nvim-nio",
		},
		keys = {
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
			{ "<leader>de", function() require("dapui").eval() end, desc = "Debug: eval expression", mode = { "n", "v" } },
		},
		config = function()
			local dap = require("dap")
			local dapui = require("dapui")

			dapui.setup()

			dap.listeners.after.event_initialized["dapui_config"] = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated["dapui_config"] = function()
				dapui.close()
			end
			dap.listeners.before.event_exited["dapui_config"] = function()
				dapui.close()
			end
		end,
	},

	{
		"theHamsta/nvim-dap-virtual-text",
		dependencies = {
			"mfussenegger/nvim-dap",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = {},
	},
}
