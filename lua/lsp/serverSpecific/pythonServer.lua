local mason_bin = require("utils.paths").Mason_Bin

return {
	cmd = {
		mason_bin .. "pyright-langserver",
		"--stdio",
	},
	pre_attach_settings = {
		python = {
			analysis = {
				typeCheckingMode = "strict",
			},
		},
	},

	--[[ Having this as true or false both have downsides

	false downside:
		If we create a python file in $HOME,
		the LSP will timeout trying to index everything

	true downside:
		Consider the case where 2 files are in a non-project folder:
			a.py
			b.py
		And b.py imports from a.py

		If we are in single_file_mode, and we pass in nil for the root_dir,
		pyright will warn "... could not be resolved [reportMissingImports]"
		it will do so because it has no idea what the workspace is

		However if we run b.py it will work, so it is a false positive
	
	The true downside is a less common use case, so go with this one
	It can be resolved by creating any file which marks it as a root]]
	single_file_support = true,

	ignore_diagnostics = {
		strict = {},
		lenient = {
			"reportPropertyTypeMismatch",
			"reportMissingTypeStubs",
			"reportTypeCommentUsage",
			"reportUnknownParameterType",
			"reportUnknownArgumentType",
			"reportUnknownLambdaType",
			"reportUnknownVariableType",
			"reportUnknownMemberType",
			"reportMissingParameterType",
			"reportMissingTypeArgument",
			"reportUnnecessaryTypeIgnoreComment",
		},
	},
}
