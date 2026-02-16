local M = {}

function M.setup()
	local dap = require("dap")
	local dapui = require("dapui")

	-- Setup DAP UI
	dapui.setup({})

	-- Setup virtual text
	require("nvim-dap-virtual-text").setup({
		commented = true,
	})

	-- Mason DAP setup
	require("mason-nvim-dap").setup({
		ensure_installed = { "python", "delve" },
		automatic_installation = true,
		handlers = {},
	})

	-- Setup signs
	vim.fn.sign_define("DapBreakpoint", {
		text = "",
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})

	vim.fn.sign_define("DapBreakpointRejected", {
		text = "", -- or "❌"
		texthl = "DiagnosticSignError",
		linehl = "",
		numhl = "",
	})

	vim.fn.sign_define("DapStopped", {
		text = "", -- or "→"
		texthl = "DiagnosticSignWarn",
		linehl = "Visual",
		numhl = "DiagnosticSignWarn",
	})

	-- Automatically open/close DAP UI
	dap.listeners.after.event_initialized["dapui_config"] = dapui.open
	dap.listeners.before.event_terminated["dapui_config"] = dapui.close
	dap.listeners.before.event_exited["dapui_config"] = dapui.close

	-- Setup keymaps
	vim.keymap.set("n", "<leader>db", function()
		dap.toggle_breakpoint()
	end, { desc = "Toggle breakpoint" })

	vim.keymap.set("n", "<leader>dc", function()
		dap.continue()
	end, { desc = "Continue/Start debugging" })

	vim.keymap.set("n", "<leader>do", function()
		dap.step_over()
	end, { desc = "Step over" })

	vim.keymap.set("n", "<leader>di", function()
		dap.step_into()
	end, { desc = "Step into" })

	vim.keymap.set("n", "<leader>dO", function()
		dap.step_out()
	end, { desc = "Step out" })

	vim.keymap.set("n", "<leader>dq", function()
		dap.terminate()
	end, { desc = "Terminate debugging" })

	vim.keymap.set("n", "<leader>du", function()
		dapui.toggle()
	end, { desc = "Toggle DAP UI" })

	vim.keymap.set("n", "<leader>ds", function()
		local filetype = vim.bo.filetype
		local configs = dap.configurations[filetype]

		if not configs or #configs == 0 then
			vim.notify("No debug configurations found for filetype: " .. filetype, vim.log.levels.WARN)
			return
		end

		local config_names = {}
		for i, config in ipairs(configs) do
			table.insert(config_names, config.name)
		end

		vim.ui.select(config_names, {
			prompt = "Select configuration: ",
		}, function(_, idx)
			if idx then
				dap.run(configs[idx])
			end
		end)
	end, { desc = "Select debug configuration" })

	-- Load language configurations
	require("demetere.dap.languages.python").setup()
	require("demetere.dap.languages.go").setup()
end

return M
