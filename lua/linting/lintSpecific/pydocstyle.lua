local paths = require("utils.paths")

local linter_name = "pydocstyle"

return {
	cmd = paths.Mason_Bin .. linter_name,
	stdin = false,
	ignore_exitcode = true,
	parser = require('lint.parser').from_errorformat(
		'%N%f:%l%.%#,%Z%s%#D%n: %m',
		{
			source = linter_name,
		}
	),
}
