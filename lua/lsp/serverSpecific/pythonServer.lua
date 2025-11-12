local mason_bin = require("utils.paths").Mason_Bin
local merge_tables = require("utils.tables").merge_tables

local strict_only_disagnostics = {
	reportMissingParameterType = "information",
	reportMissingTypeArgument = "information",
	reportMissingTypeStubs = "information",
	reportPropertyTypeMismatch = "information",
	reportTypeCommentUsage = "information",
	reportUnknownArgumentType = "information",
	reportUnknownLambdaType = "information",
	reportUnknownMemberType = "information",
	reportUnknownParameterType = "information",
	reportUnknownVariableType = "information",
	reportUnnecessaryTypeIgnoreComment = "information",
}

local normal_severity_overrides = {
	reportUnusedClass = "warning",
	reportUnusedFunction = "warning",
	reportUnusedImport = "warning",
	reportUnusedVariable = "warning",
}

local all_severity_overrides = merge_tables(
	strict_only_disagnostics,
	normal_severity_overrides
)


--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			mason_bin .. "basedpyright-langserver",
			"--stdio",
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

		-- https://docs.basedpyright.com/latest/configuration/language-server-settings/
		post_init_settings = {
			basedpyright = {
				analysis = {
					autoSearchPaths = true,
					diagnosticMode = 'openFilesOnly',
					diagnosticSeverityOverrides = all_severity_overrides,
					typeCheckingMode = "strict",
					useLibraryCodeForTypes = true,
				},
			},
		},

		diagnostic_filters = {
			normal = function(diagnostic)
				return not strict_only_disagnostics[diagnostic.code]
			end,
			strict = function(_) return true end,
		},
	}

	return server_config
end

return get_server_config
