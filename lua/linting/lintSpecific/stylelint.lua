local paths = require("utils.paths")

local severities = {
	error = vim.diagnostic.severity.INFO,
	warning = vim.diagnostic.severity.HINT,
}

local linter_name = "stylelint"

return {
	cmd = paths.Mason_Bin .. linter_name,
	stdin = true,
	args = {
		"-c",
		paths.Lint_Fallback .. "stylelintrc.json",
		"-f",
		"json",
		"--stdin",
	},
	stream = "stderr",
	ignore_exitcode = true,
	parser = function(output)
		local diagnostics = {}
		local ok, decoded = pcall(vim.json.decode, output)
		if not ok then
			return diagnostics
		end

		for _, lint_response in ipairs(decoded[1].warnings) do
			table.insert(diagnostics, {
				-- The message code is added to the message text
				-- It is always in parenthesis, so take it out manually
				message = lint_response.text:gsub(" %(.*%)", ""),
				col = lint_response.column - 1,
				end_col = lint_response.endColumn - 1,
				lnum = lint_response.line - 1,
				end_lnum = lint_response.line - 1,
				code = lint_response.rule,
				severity = severities[lint_response.severity],
				source = linter_name,
			})
		end
		return diagnostics
	end,
}
