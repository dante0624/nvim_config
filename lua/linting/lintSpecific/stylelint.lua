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
		paths.Config_Path .. "resources/lintConfigs/stylelintrc.json",
		"-f",
		"json",
		"--stdin",
	},
	stream = "stderr",
	ignore_exitcode = true,
	parser = function(output)
		local status, decoded = pcall(vim.json.decode, output)
		if not status then
			return { {
				lnum = 0,
				col = 0,
				message = "error parsing linter output, run `" ..
					linter_name .. " -f json " .. vim.fn.expand("%:p") ..
					"` to begin debugging",
				source = linter_name,
			} }
		end

		local diagnostics = {}
		for _, message in ipairs(decoded[1].warnings) do
			-- Hotfix col and end_col being only 1 apart
			-- Just make them the same thing, so that nothing is underlined
			if message.endColumn == message.column + 1 then
				message.endColumn = message.column
			end

			table.insert(diagnostics, {
				lnum = message.line - 1,
				col = message.column - 1,
				end_lnum = message.line - 1,
				end_col = message.endColumn - 1,

				-- The message code is added to the message text
				-- It is always in parenthesis, so take it out manually
				message = message.text:gsub(" %(.*%)", ""),

				code = message.rule,
				user_data = {
					lsp = {
						code = message.rule,
					}
				},
				severity = severities[message.severity],
				source = linter_name,
			})
		end
		return diagnostics
	end
}
