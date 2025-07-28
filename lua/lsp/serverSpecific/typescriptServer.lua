local paths = require("utils.paths")

--- @param _ string the root directory for the LSP server.
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		cmd = {
			paths.Mason_Bin .. "typescript-language-server",
			"--stdio",
		},
		-- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md
		init_options = {
			hostInfo = "neovim",
			tsserver = {
				logDirectory = paths.Logs_Path,
				-- Can set to 'off', 'terse', 'normal', 'requestTime', 'verbose'
				logVerbosity = "off",
			},
		},
		single_file_support = true,
	}

	return server_config
end

return get_server_config
