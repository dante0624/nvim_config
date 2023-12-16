local dir = require("utils.directories")

local linter_name = "eslint_d"

return {
	cmd = dir.Mason_Dir .. "bin/" ..linter_name,
	args = {
		'-c',
		dir.Config_Dir .. "resources/lintConfigs/eslintrc.json",
		'-f',
		'json',
		'--stdin',
		'--stdin-filename',
		function() return vim.api.nvim_buf_get_name(0) end,
	},
	stdin = true,
	stream = 'stdout',
	ignore_exitcode = true,
	parser = function(output, bufnr)
		local result = require("lint.linters.eslint").parser(output, bufnr)
		for _, d in ipairs(result) do
			d.source = linter_name
		end
		return result
	end
}
