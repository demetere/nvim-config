return {
	"mfussenegger/nvim-lint",
	event = { "BufReadPre", "BufNewFile" },
	config = function()
		local lint = require("lint")

		lint.linters_by_ft = {
			python = { "mypy" },
		}

		-- Configure mypy to use the virtual environment
		lint.linters.mypy.cmd = function()
			local venv = vim.fn.getcwd() .. "/.venv/bin/mypy"
			if vim.fn.filereadable(venv) == 1 then
				return venv
			end
			return "mypy" -- fallback to global if no .venv
		end

		-- Create autocommand to trigger linting
		local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

		vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
			group = lint_augroup,
			callback = function()
				lint.try_lint()
			end,
		})
	end,
}
