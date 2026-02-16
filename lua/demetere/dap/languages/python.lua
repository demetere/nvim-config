local M = {}

function M.setup()
	local dap = require("dap")

	-- Setup Python adapter first
	local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
	if vim.fn.filereadable(debugpy_path) == 1 then
		require("dap-python").setup(debugpy_path)
	else
		require("dap-python").setup("python3")
	end

	-- Override with custom configurations only
	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Debug FastAPI (src/app.py)",
			module = "uvicorn",
			args = {
				"src.app:app",
				"--reload",
				"--host",
				"0.0.0.0",
				"--port",
				"8000",
			},
			console = "integratedTerminal",
			justMyCode = false,
		},
	}
end

return M
