local paths = require("utils.paths")

local ignored_message_substrings = {
	"'browser' is not defined.",
	"Cannot find name 'browser'.",
	"implicitly has an 'any' type, but a better type may be inferred from usage.",
}

--- @param diagnostic lsp.Diagnostic
--- @return boolean
local filter_func = function(diagnostic)
	for _, substring in ipairs(ignored_message_substrings) do
		if string.find(diagnostic.message, substring) then
			return false
		end
	end

	return true
end

--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			paths.Mason_Bin .. "typescript-language-server",
			"--stdio",
		},
		single_file_support = true,

		-- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
		init_options = {
			hostInfo = "neovim",
			tsserver = {
				logDirectory = paths.Logs_Path,
				-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
				logVerbosity = "off",
			},
		},
		post_init_settings = {
			implicitProjectConfiguration = {
				checkJs = true,
				strictNullChecks = false,
			},
		},
		diagnostic_filters = {
			normal = filter_func,
			strict = filter_func,
		},
	}

	return server_config
end

return get_server_config
