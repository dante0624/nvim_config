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
	single_file_support = true,
	ignore_diagnostics = {
		strict = {
		},
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
