local dir = require("utils.directories")

local linter_name = "pydocstyle"

return {
	cmd = dir.Mason_Dir .. "bin/" .. linter_name,
	stdin = false,
	ignore_exitcode = true,
	parser = require('lint.parser').from_errorformat(
		'%N%f:%l%.%#,%Z%s%#D%n: %m',
		{
			source = linter_name,
		}
	),
}
