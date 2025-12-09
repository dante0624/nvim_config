
--- @param _ ServerConfigParams
--- @return ServerConfig
local function get_server_config(_)

	--- @type ServerConfig
	local server_config = {
		-- Assuming that swift development is being done on macOS
		-- If this is the case, then this is automatically installed and on the PATH
		-- If any other OS, this will need to be installed
		cmd = { "sourcekit-lsp" },

		single_file_support = true,
	}

	return server_config
end

return get_server_config
