local paths = require("utils.paths")

local error = vim.diagnostic.severity.ERROR
local warn = vim.diagnostic.severity.WARN
local severities = {
	["F821"] = error, -- undefined name `name`
	["E902"] = error, -- `IOError`
	["E999"] = error, -- `SyntaxError`
}
local linter_name = "ruff"

return {
	cmd = paths.Mason_Bin .. linter_name,
	stdin = true,
	args = {
		"--config",
		paths.Lint_Fallback .. "ruff.toml",
		"--force-exclude",
		"--quiet",
		"--stdin-filename",
		function()
			return vim.fn.expand("%:p")
		end,
		"--no-fix",
		"--output-format",
		"json",
		"-",
	},
	ignore_exitcode = true,
	stream = "stdout",
	parser = function(output)
		local diagnostics = {}
		local ok, decoded = pcall(vim.json.decode, output)
		if not ok then
			return diagnostics
		end
		for _, lint_response in ipairs(decoded or {}) do
			local diagnostic = {
				message = lint_response.message,
				col = lint_response.location.column - 1,
				end_col = lint_response.end_location.column - 1,
				lnum = lint_response.location.row - 1,
				end_lnum = lint_response.end_location.row - 1,
				code = lint_response.code,
				severity = severities[lint_response.code] or warn,
				source = linter_name,
			}
			table.insert(diagnostics, diagnostic)
		end
		return diagnostics
	end,
}
