local mason_bin = require("utils.paths").Mason_Bin
local array_to_set = require("utils.tables").array_to_set

local ignored_code = array_to_set({
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
})

--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			mason_bin .. "pyright-langserver",
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

		-- https://microsoft.github.io/pyright/#/settings
		post_init_settings = {
			python = {
				analysis = {
					typeCheckingMode = "strict",
					diagnosticSeverityOverrides = {
						-- These get duplicated for some reason when using typeCheckingMode = "strict"  
						-- They show up once as warnings (which I want them to be) then again as errors
						-- Setting these to false has a nice affect of making them show up once as warnings
						reportUnusedImport = false,
						reportUnusedClass = false,
						reportUnusedFunction = false,
						reportUnusedVariable = false,
					},
				},
			},
		},

		diagnostic_filters = {
			normal = function(diagnostic)
				return not ignored_code[diagnostic.code]
			end,
			strict = function(_) return true end,
		},
	}

	return server_config
end

return get_server_config
