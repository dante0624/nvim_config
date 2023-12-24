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
		paths.Config_Path .. "resources/lintConfigs/ruff.toml",
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
		local ok, results = pcall(vim.json.decode, output)
		if not ok then
			return diagnostics
		end
		for _, result in ipairs(results or {}) do
			local diagnostic = {
				message = result.message,
				col = result.location.column - 1,
				end_col = result.end_location.column - 1,
				lnum = result.location.row - 1,
				end_lnum = result.end_location.row - 1,
				code = result.code,
				severity = severities[result.code] or warn,
				source = "ruff",
			}
			table.insert(diagnostics, diagnostic)
		end
		return diagnostics
	end,
}
