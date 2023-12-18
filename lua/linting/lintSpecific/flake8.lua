local paths = require("utils.paths")

local linter_name = "flake8"

local pattern = '[^:]+:(%d+):(%d+):(%w+):(.+)'
local groups = { 'lnum', 'col', 'code', 'message' }

return {
	cmd = paths.Mason_Bin .. linter_name,
	stdin = true,
	args = {
		'--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s',
		'--no-show-source',
		'-',
	},
	ignore_exitcode = true,
	parser = require('lint.parser').from_pattern(pattern, groups, nil, {
		source = linter_name,
		severity = vim.diagnostic.severity.INFO,
	}),
}
