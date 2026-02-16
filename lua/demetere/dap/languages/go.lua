local M = {}

function M.setup()
	local dap = require("dap")

	-- Setup Go adapter first
	require("dap-go").setup({
		delve = {
			initialize_timeout_sec = 20,
			port = "${port}",
		},
	})

	-- Override with custom configurations only
	dap.configurations.go = {
		{
			type = "go",
			name = "Debug Gaagore",
			request = "launch",
			program = "${workspaceFolder}/cmd/api",
		},
	}
end

return M
